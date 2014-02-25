#!/usr/bin/env python
import roslib; roslib.load_manifest('rover_driver_base')
import rospy
from geometry_msgs.msg import Twist
import numpy
from numpy.linalg import pinv
from math import atan2, hypot, pi, cos, sin
import time
import decimal

prefix=["FL","FR","CL","CR","RL","RR"]

class RoverMotors:
    def __init__(self):
        self.steering={}
        self.drive={}
        for k in prefix:
            self.steering[k]=0.0
            self.drive[k]=0.0
    def copy(self,value):
        for k in prefix:
            self.steering[k]=value.steering[k]
            self.drive[k]=value.drive[k]

class DriveConfiguration:
    def __init__(self,radius,x,y,z):
        self.x = x
        self.y = y
        self.z = z
        self.radius = radius

class RoverKinematics:
    def __init__(self):
        self.X = numpy.asmatrix(numpy.zeros((3,1)))
	self.displacement = numpy.asmatrix(numpy.zeros((3,1)))
	self.A = numpy.asmatrix(numpy.zeros((12,3)))
	self.B = numpy.asmatrix(numpy.zeros((12,1)))
        self.motor_state = RoverMotors()
        self.first_run = True
	self.previousTime = time.time()
	self.currentTime = time.time()

    def remaind(self, x,y):
	xd = decimal.Decimal(10*x)
	yd = decimal.Decimal(10*y)
	return float(xd.remainder_near(yd)/10)

    def twist_to_motors(self, twist, drive_cfg, skidsteer=False):
        motors = RoverMotors()
	self.twist = twist
        if skidsteer:
            for k in drive_cfg.keys():
                # Insert here the steering and velocity of 
                # each wheel in skid-steer mode
                motors.steering[k] = 0
                motors.drive[k] =  twist.linear.x-twist.angular.z*drive_cfg[k].y
        else:
            for k in drive_cfg.keys():
                # Insert here the steering and velocity of 
                # each wheel in rolling-without-slipping mode
		goal= atan2(twist.linear.y+twist.angular.z*drive_cfg[k].x,twist.linear.x-twist.angular.z*drive_cfg[k].y)
		velocity = hypot(twist.linear.x-twist.angular.z*drive_cfg[k].y,twist.linear.y+twist.angular.z*drive_cfg[k].x)/drive_cfg[k].radius
#		diffgoal = goal-motors.steering[k]
		
		motors.drive[k]=velocity
		motors.steering[k]=goal
##---------Optimisation of Robot Steering angle variation-------#
#		if(goal>=0):
#		motors.steering[k]=motors.steering[k]+diffgoal%pi
#		if(motors.steering[k]-goal>pi/2):
#			motors.steering[k]=(-pi+goal)
#			motors.drive[k]=-velocity
#		elif(motors.steering[k]-goal<-pi/2):
#			motors.steering[k]=(pi+goal)
#			motors.drive[k]=-velocity
#		else:
#				motors.steering[k]=goal
#                		motors.drive[k]=velocity
#		else:
#                       if(motors.steering[k]-goal>pi/2):
#                                motors.steering[k]=(-pi+goal)
#                                motors.drive[k]=-velocity
#                       elif(motors.steering[k]-goal<-pi/2):
#                                motors.steering[k]=(pi+goal)
#                                motors.drive[k]=-velocity
#                       else:
#                                motors.steering[k]=goal
#                                motors.drive[k]=velocity				
		
        return motors

    def integrate_odometry(self, motor_state, drive_cfg):
	self.currentTime = time.time()
	dt = self.currentTime - self.previousTime
        # The first time, we need to initialise the state
        if self.first_run:
            self.motor_state.copy(motor_state)
            self.first_run = False
            return self.X
        # Insert here your odometry code
	i=0
	for k in drive_cfg.keys():	
		self.A[i,:] = (1, 0, -drive_cfg[k].y)
		self.A[i+1,:] = (0, 1, drive_cfg[k].x)
		self.B[i,0] = self.remaind(motor_state.drive[k]-self.motor_state.drive[k],2*pi)*drive_cfg[k].radius*cos(self.motor_state.steering[k])
		self.B[i+1,0] = self.remaind(motor_state.drive[k]-self.motor_state.drive[k],2*pi)*drive_cfg[k].radius*sin(self.motor_state.steering[k])
		i = i+2
	self.displacement = pinv(self.A)*self.B
#	rospy.loginfo("displacement "+str(self.displacement))
#	rospy.loginfo("position "+str(self.X))
		#rotation for the world frame
	self.X[0,0] += self.displacement[0,0]*cos(self.X[2,0]) - self.displacement[1,0]*sin(self.X[2,0])
	self.X[1,0] += self.displacement[0,0]*sin(self.X[2,0]) + self.displacement[1,0]*cos(self.X[2,0])
	self.X[2,0] += self.displacement[2,0]
	self.motor_state.copy(motor_state)
	self.previousTime = self.currentTime
        return self.X
