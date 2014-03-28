#!/usr/bin/env python
import roslib; roslib.load_manifest('cb_vs_base')
import rospy
import tf
from cb_detector.msg import Checkerboard
from sensor_msgs.msg import Joy,CameraInfo
from geometry_msgs.msg import Twist,Point
from kobuki_msgs.msg import PowerSystemEvent
from std_msgs.msg import Float32
from numpy import *
from numpy.linalg import pinv
import math
import collections
from visualization_msgs.msg import Marker, MarkerArray
from ar_track_alvar.msg import AlvarMarkers
from tf.transformations import euler_from_quaternion
from math import atan2, hypot, pi, cos, sin, pi, fmod, exp

def norm_angle(x):
    return ((x+pi)%(2*pi))-pi

def sat(x, mx):
    if x > mx:
        return mx
    if x < -mx:
        return -mx
    return x

def sinc(x):
    if abs(x)>1e-5:
        return sin(x)/x
    else:
        return 1.


class CheckerboardVS:
    def __init__(self):
        rospy.init_node("cb_vs");
        self.ref_button = rospy.get_param("~ref_button",3)
        self.reference_frame = rospy.get_param("~reference_frame","/base_link")
        self.body_frame = rospy.get_param("~body_frame","/ar_marker_0")
        self.max_rot_speed = rospy.get_param("~max_rot_speed",0.3)
        self.max_speed = rospy.get_param("~max_speed",0.2)
	self.intermediateDist = rospy.get_param("~intermediateDist",0.6)
        self.distanceEnterDockingPhase = rospy.get_param("~distanceEnterDockingPhase",0.5)
	self.distanceMarkerDockingStation = rospy.get_param("~distanceMarkerDockingStation",0.375)
	self.max_y_error = rospy.get_param("~max_y_error",0.4)
        self.k_y = rospy.get_param("~k_y",20)
	self.k_theta = rospy.get_param("~k_theta",5)
	self.k_v = rospy.get_param("~k_v",1)


        self.current_cb = None
        self.info = None
        self.ref_cb = None
	self.charging = 0
        self.lastroi = rospy.Time.now()
	self.listener = tf.TransformListener()
        self.joy_sub = rospy.Subscriber("/joy",Joy,self.joy_cb)
        self.roi_sub = rospy.Subscriber("/ar_pose_marker",AlvarMarkers,self.markers_cb)
        self.power_sub = rospy.Subscriber("/mobile_base/events/power_system",PowerSystemEvent,self.power_cb)
        self.info_sub = rospy.Subscriber("/camera/rgb/camera_info",CameraInfo,self.store_info)
        self.vel_pub = rospy.Publisher("/cmd_vel_mux/input/navi",Twist)
	#self.goal_theta =0
	#self.goal_x =0
	#self.goal_y =0
	self.lastErr = 0
	#etheta =0
	#ex =0
	#ey =0
	self.state="approaching_marker"

	# store the camera parameters
    def store_info(self,info):
        self.info = info

    def power_cb(self,powermsg):
	print "state power" + str(powermsg)
	print "\nstate power value" + str(powermsg.event)
	self.charging = powermsg.event

    # Called whenever the joystick is ready
    def joy_cb(self,value):
        if value.buttons[self.ref_button]:
	    self.listener.waitForTransform(self.body_frame,self.reference_frame,rospy.Time(),rospy.Duration(0.1))
	    ((y,_,x),rot)= self.listener.lookupTransform(self.reference_frame, self.body_frame, rospy.Time(0))
	    euler = euler_from_quaternion(rot)
	    self.goal_x = x
     	    self.goal_y = y
    	    self.goal_theta = euler[2]
	    rospy.loginfo("Recorded reference Marker")
	    
    # called whenever a new mark has been detected
    def markers_cb(self, value):
	if (value.markers):
	        self.current_cb = value.markers[0].pose.pose
		self.markerID = value.markers[0].id
		self.body_frame = "/ar_marker_" + str(self.markerID) 
		#	print "bodyframe : " + str(self.body_frame)
		#	print "x = "+str(x) +"  y = "+str(y)+ "  theta = " + str(norm_angle(-pi/2-self.theta)) +"\n"
        	
    def compute_error(self):
	self.listener.waitForTransform(self.body_frame,self.reference_frame,rospy.Time(),rospy.Duration(20))
        ((ex,ey,_),rot) = self.listener.lookupTransform(self.reference_frame, self.body_frame, rospy.Time(0))
        euler = euler_from_quaternion(rot,'ryxz')
        theta = euler[1] 

        return (ex,ey,theta)#-etheta)

    def computeVS(self):
        twist = Twist()
        
	(ex,ey,etheta) = self.compute_error()
	print "ex = " + str(ex) +"  ey = " + str(ey) + "  etheta = " + str(etheta) +"\n"
	#ex=ex-0.37	
	if (self.state =="approaching_marker"):
		print "state = " + str(self.state) #+ " ex = " + str(ex)
		twist.linear.x =sat(self.k_v*(ex-self.distanceMarkerDockingStation),self.max_speed)
		twist.angular.z=sat(twist.linear.x*sinc(etheta)*sat(ey,self.max_y_error)*self.k_y +etheta*self.k_theta,self.max_rot_speed)     
		if(self.charging == 2):
			self.state = "charging"	

		if(ex < self.intermediateDist ):
			twist.linear.x =sat(self.k_v*(ex-self.distanceMarkerDockingStation),self.max_speed)
			twist.angular.z=sat(twist.linear.x*sinc(etheta)*sat(ey,self.max_y_error)*self.k_y*10 +etheta*self.k_theta/2,self.max_rot_speed)    
			
		if(ex < self.distanceEnterDockingPhase):
			self.state="docking_phase"
			self.t = rospy.Time.now()
			
	elif self.state=="docking_phase":
		print "state = " + str(self.state) + " time elapsed = " + str(rospy.Time.now().to_sec())
		twist.linear.x =sat(self.k_v*ex-self.distanceMarkerDockingStation,self.max_speed)
		twist.angular.z=sat(twist.linear.x*sinc(etheta)*sat(ey,self.max_y_error)*5*self.k_y +etheta*self.k_theta,self.max_rot_speed)    
		if(ex-self.distanceMarkerDockingStation < 0.02):
			print "rotation to reach charging mode"
			twist.angular.z=sat(20*ey*self.k_y,self.max_rot_speed)   
			
		print "ex = "+str(ex) +"  ey = "+str(ey)+ "  etheta = " + str(etheta) +"\n"
		if(self.charging == 2):
			self.state = "charging"
		elif(abs(ey)>0.12 or abs(etheta)>0.8 ):
			twist.linear.x=0
			twist.angular.z=0
			print "too far from goal"
			#twist.linear.x*sinc(etheta)*sat(ey,self.max_y_error)*5*self.k_y +etheta*self.k_thetalinear.x*sinc(etheta)*sat(ey,self.max_y_error)*5*self.k_y +etheta*self.k_theta
 
		elif((rospy.Time.now()-self.t).to_sec() > 5 or abs(ey)>0.02 or abs(etheta)>0.4):
			self.state="going backward"	
			self.lastErr = ey
			
	elif self.state=="going backward":
		print "state = " + str(self.state)
		#twist.linear.x = -sat(abs(5*self.k_v*self.lastErr),self.max_speed)
	#	if(ex<0.6):
		twist.linear.x = -.1
		twist.angular.z=sat(twist.linear.x*sinc(etheta)*sat(ey,self.max_y_error)*2*self.k_y +etheta*self.k_theta/5,self.max_rot_speed)
	#		self.oldang=twist.angular.z 
	#	else:
	#		twist.linear.x=-.1
	#		twist.angular.z=sat(twist.linear.x*sinc(etheta)*sat(ey,self.max_y_error)*2*self.k_y +etheta*self.k_theta/5,self.max_rot_speed)

	#		twist.angular.z=self.oldang
		sign=cmp(ey*etheta,0)
		#twist.angular.z = sat(sign*(max(abs(3*ey),abs(etheta))),self.max_rot_speed)
		#twist.angular.z = sat(10*self.k_y*self.lastErr*((ex-self.intermediateDist)),self.max_rot_speed)
		#twist.angular.z=sat(twist.linear.x*sinc(etheta)*sat(ey,self.max_y_error)*2*self.k_y +etheta*self.k_theta/10,self.max_rot_speed)  	

		if(ex>self.intermediateDist):
			self.state = "approaching_marker"
			twist.linear.x=0
			twist.angular.z=0

	elif self.state=="charging":
		print self.state
		twist.linear.x = 0
		twist.angular.z = 0
		if(self.charging==0):
			self.state= "approaching_marker"
		elif(self.charging==3):
			self.state="charged"

	elif self.state=="charged":
		print self.state
		twist.linear.x = 0
		twist.angular.z = 0
		if(self.charging==0):
			self.state="approaching_marker"


	return twist


    def run(self):
        timeout = True
        rate = rospy.Rate(10)
        rospy.loginfo("Waiting for first camera info")
        t = Twist()
        while (not rospy.is_shutdown()) and ((not self.info)) :#or (not self.current_cb)):
            self.vel_pub.publish(t)
	    print 'cb :  ' + str(not self.info) + '\n'
            rate.sleep()
	self.listener.waitForTransform(self.body_frame,self.reference_frame,rospy.Time(),rospy.Duration(20))
	rospy.loginfo("Starting VS control")
	rate.sleep()
        while not rospy.is_shutdown():
            twist = self.computeVS()
            self.vel_pub.publish(twist)
            rate.sleep()


if __name__ == '__main__':
    try:
        rd = CheckerboardVS() 
        rd.run()
    except rospy.ROSInterruptException:
        pass

