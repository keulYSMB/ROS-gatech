#!/usr/bin/env python
import roslib; roslib.load_manifest('cb_vs_base')
import rospy
from cb_detector.msg import Checkerboard
from sensor_msgs.msg import Joy,CameraInfo
from geometry_msgs.msg import Twist,Point
from std_msgs.msg import Float32
from numpy import *
from numpy.linalg import pinv
import math
import collections

#dircoll=collections.namedtuple('directions', ('UP', 'DOWN', 'LEFT', 'RIGHT'))
#directions=dircoll(0,1,2,3)


def sat(x, mx):
    if x > mx:
        return mx
    if x < -mx:
        return -mx
    return x


class CheckerboardVS:
    def __init__(self):
        rospy.init_node("cb_vs");
        self.scale = rospy.get_param("~scale",1.0)
        self.ref_button = rospy.get_param("~ref_button",3)
        #self.Z = rospy.get_param("~Z",1.0)
	self.mode = rospy.get_param("~mode","holonomic")
        self.current_cb = None
        self.info = None
        self.ref_cb = None
        self.lastroi = rospy.Time.now()

        self.joy_sub = rospy.Subscriber("~joy",Joy,self.joy_cb)
        self.roi_sub = rospy.Subscriber("~cb",Checkerboard,self.cb_cb)
        self.info_sub = rospy.Subscriber("~info",CameraInfo,self.store_info)
        self.vel_pub = rospy.Publisher("~twistCommand",Twist)
	
#	self.modes = collections.namedtuple('modeDrive',('holonomic','translations','ackermann'))
#	self.modeDrive=self.modes(0,1,2)
#	self.mode = self.modeDrive.holonomic
	#self.mode = 2
	#modes = enum('holonomic', 'translations', 'ackermann')
	
	# store the camera parameters
    def store_info(self,info):
        self.info = info

    # Called whenever the joystick is ready
    def joy_cb(self,value):
        if value.buttons[self.ref_button]:
            self.ref_cb = self.current_cb
            rospy.loginfo("Recorded reference Checkerboard")

    # called whenever a new checkerboard has been detected
    def cb_cb(self, value):
        self.current_cb = value
        self.lastroi = self.current_cb.header.stamp

    def computeVS(self):
        twist = Twist()
	satvalue = 0.15
        if not self.ref_cb or not self.current_cb:
            return twist

        if ((self.ref_cb.num_x != self.current_cb.num_x) \
                or (self.ref_cb.num_y != self.current_cb.num_y)):
            return twist
	#mode=modes.holonomic

	#	if self.mode==self.modeDrive.holonomic:
#	print ''+str(len(self.ref_cb) )
#	print 'length reference point array : '+str(len(self.ref_cb.points))
	#if self.mode ==0:
	if self.mode == "holonomic":		
		Lx = zeros((2*len(self.ref_cb.points),3))
	else:
		Lx = zeros((2*len(self.ref_cb.points),2))


	epsilon=0.1
	
	Error = zeros((2*len(self.ref_cb.points),1))
	#F = zeros((2,2))
	k=0
        # Go through the list of features
        for (pstar,p) in zip(self.ref_cb.points,self.current_cb.points):
            # pstar is a geometry_msgs/Point object in the reference image
            # p is a geometry_msgs/Point object in the current image
            # By construction the matching between p* and p is garanteed. 
	    fx = self.info.K[0]	    
	    xc = self.info.K[2]
	    fy = self.info.K[4]
	    yc = self.info.K[5]
  
	    Kp = 5 
	    #Z = self.store_info.K[0,2]
	    if (p.z!=0):
	    	Z = p.z
		Kp = Kp/Z
	    else:
		Z = 1.0
	    x =  (p.x - xc)/fx
	    y = (p.y - yc)/fy
	    #x =  (self.info.K[2] - p.x)/self.info.K[0]
	    #y =  (self.info.K[5] - p.y)/self.info.K[4]

	    #Kp = 5
	    v = zeros((1,3))
	    Error[2*k,0]=(p.x - pstar.x)/fx
	    Error[2*k+1,0]=(p.y - pstar.y)/fy
	    print 'x : ' + str(x) + '  y: ' + str(y) + '  z:  ' + str(pstar.z) + '\n'
	

	   # if self.mode==0:
      	    if self.mode=="holonomic":
	    	Lx[2*k,:] = (x/Z,-1/Z,-(1+x**2)) 
		Lx[2*k+1,:] = (y/Z,0,-x*y)

	    #elif self.mode==1:
	    elif self.mode=="ackermann":
	    	Lx[2*k,:] = (x/Z, -(1+x**2))
		Lx[2*k+1,:] = (y/Z, -x*y)



	    #elif self.mode==2:
	    elif self.mode=="translations":
	    	Lx[2*k,:] = (x/Z, -1/Z)
		Lx[2*k+1,:] = (y/Z, 0)
	    
	    k=k+1

	
	print 'mode : ' + str(self.mode)
	#if self.mode==0:
	if self.mode=="holonomic":
	    v = Kp*(dot(pinv(Lx),Error))
	    print 'velocity matrix = ' + str(v)
	    twist.linear.x=sat(-v[0],satvalue)
	    twist.linear.y=sat(v[1],satvalue)
	    twist.angular.z=sat(v[2],satvalue)
	    if(abs(v[0])<epsilon):
		twist.linear.x=0
	    if(abs(v[1])<epsilon):
		twist.linear.y=0
	    if(abs(v[2])<epsilon):
		twist.angular.z=0
	
#	elif self.mode==1:
	elif self.mode=="ackermann":
	    v = Kp*(dot(pinv(Lx),Error))
	    print 'velocity matrix = ' + str(v)
	    twist.linear.x=sat(-v[0],satvalue)
	    twist.linear.y=0
	    twist.angular.z=sat(v[1],satvalue)
	    if(abs(v[0])<epsilon):
		twist.linear.x=0
	    if(abs(v[1])<epsilon):
		twist.angular.z=0


	#elif self.mode==2:
	elif self.mode=="translations":
	    v = Kp*(dot(pinv(Lx),Error))
	    print 'velocity matrix = ' + str(v)
	    twist.linear.x=sat(-v[0],satvalue)
	    twist.linear.y=sat(v[1],satvalue)
	    twist.angular.z=0
	    if(abs(v[0])<epsilon):
		twist.linear.x=0
	    if(abs(v[1])<epsilon):
		twist.linear.y=0


        return twist


    def run(self):
        timeout = True
        rate = rospy.Rate(10)
        rospy.loginfo("Waiting for first camera info")
        t = Twist()
        while (not rospy.is_shutdown()) and ((not self.info) or (not self.current_cb)):
            self.vel_pub.publish(t)
            rate.sleep()
	rospy.loginfo("Starting VS control")
        while not rospy.is_shutdown():
        #    if (rospy.rostime.get_time() - self.lastroi.to_sec()) < 0.5: 
        #        if timeout:
        #            timeout = False
        #            rospy.loginfo("Accepting joystick commands")
            twist = self.computeVS()
            self.vel_pub.publish(twist)
        #    else:
        #        if not timeout:
        #            timeout = True
        #            rospy.loginfo("Timeout: ignoring joystick commands")
        #        self.vel_pub.publish(Twist())
            rate.sleep()


if __name__ == '__main__':
    try:
        rd = CheckerboardVS() 
        rd.run()
    except rospy.ROSInterruptException:
        pass

