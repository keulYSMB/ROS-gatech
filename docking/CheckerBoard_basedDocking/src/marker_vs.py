
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
from visualization_msgs.msg import Marker, MarkerArray
from ar_track_alvar.msg import AlvarMarkers
from tf.transformations import euler_from_quaternion
from math import atan2, hypot, pi, cos, sin, pi, fmod, exp

#dircoll=collections.namedtuple('directions', ('UP', 'DOWN', 'LEFT', 'RIGHT'))
#directions=dircoll(0,1,2,3)

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
        self.scale = rospy.get_param("~scale",1.0)
        self.ref_button = rospy.get_param("~ref_button",3)
        #self.Z = rospy.get_param("~Z",1.0)
	self.mode = rospy.get_param("~mode","ackermann")
        self.current_cb = None
        self.info = None
        self.ref_cb = None
        self.lastroi = rospy.Time.now()

        self.joy_sub = rospy.Subscriber("/joy",Joy,self.joy_cb)
        self.roi_sub = rospy.Subscriber("/ar_pose_marker",AlvarMarkers,self.cb_cb)
        self.info_sub = rospy.Subscriber("/camera/rgb/camera_info",CameraInfo,self.store_info)
        self.vel_pub = rospy.Publisher("/cmd_vel_mux/input/navi",Twist)
	
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
	    self.goal_theta = self.theta2
            rospy.loginfo("Recorded reference Checkerboard")

    # called whenever a new checkerboard has been detected
    def cb_cb(self, value):
	#print str(value.markers)+'\n'
	if (value.markers):
	        self.current_cb = value.markers[0].pose.pose
	#print str(value)+'\n'
	        self.lastroi = value.header.stamp
		self.marker_pose=Point(self.current_cb.position.x,self.current_cb.position.y,self.current_cb.position.z)
		self.marker_orientation=self.current_cb.orientation
		#print self.current_cb.orientation
		euler = euler_from_quaternion([self.current_cb.orientation.x,self.current_cb.orientation.y,self.current_cb.orientation.z,self.current_cb.orientation.w])
		#print str(euler[1])
		self.theta2 = euler[1]
	#print str(self.marker_pose)+'\n'
	
    def computeVS(self):
        twist = Twist()
	self.max_speed = 0.1
	self.max_rot_speed = 0.2
	min_error_theta = 0.1
	self.max_y_error = 0.4
	k_y = 15
	k_theta = 2.5
	vref = 0.2
	intermediateDist =0.5
	self.state=1
	self.k_alpha = 8
	self.k_v=6
#	print 'compute vs begin  \n'  
        if not self.ref_cb or not self.current_cb:
#	    print 'missing infos\n'
            return twist
	
        if ((self.ref_cb.position.x == self.current_cb.position.x) \
                or (self.ref_cb.position.y == self.current_cb.position.y)):
		print 'already at reference \n'            
		return twist
	else:
		if (self.state ==1):
			error_x = (self.current_cb.position.z-self.ref_cb.position.z)
			error_y = (-(self.current_cb.position.x-self.ref_cb.position.x))
			#error_z = (self.current_cb.position.y-self.ref_cb.position.y)
			error_theta = (self.goal_theta - self.theta2)
			print 'error : x= ' +str(error_x) + '  y= ' +str(error_y) + '  theta = ' + str(error_theta)
			thetatogoal = atan2(error_y,error_x-intermediateDist)			
	    		twist.angular.z=min(self.k_alpha*norm_angle(thetatogoal-self.theta2),self.max_rot_speed)
   	    		twist.linear.x =min(self.k_v*(hypot(error_x-intermediateDist,error_y)),self.max_speed)
			if((hypot(error_x-intermediateDist,error_y))<0.10):
				twist.linear.x=0
				twist.angular.z=min(self.k_alpha*norm_angle(error_theta),self.max_rot_speed)
				if(abs(norm_angle(error_theta))<0.01):
					twist.angular.z=0
#	    
            
	#	if (abs(error_theta) > min_error_theta):
	#		twist.linear.x = sat(10*error_x,satvalue)
	#		twist.angular.z=sat(twist.linear.x*sinc(error_theta)*sat(error_y,min_error_theta)*k_y + error_theta*k_theta,satrot)
	#	        twist.linear.x = sat(6*error_x,satvalue)
	#        twist.angular.z = sat(vref*sinc(error_theta)*sat(error_y,self.max_y_error)*k_y + error_theta*k_theta,satrot)	
	#	else:  #+3*error_theta
	#	if(abs(error_theta)<0.1):
	#		twist.angular.z = sat(5*error_y,satrot)
	#	elif(abs(error_y)<0.05):
	#		twist.angular.z = sat(5*error_theta,satrot)
	#	else:
	#		twist.angular.z = sat(5*error_theta,satrot)
	#	twist.linear.x = sat(-2*(error_x+0.5),satvalue)
		
        return twist


    def run(self):
        timeout = True
        rate = rospy.Rate(10)
        rospy.loginfo("Waiting for first camera info")
        t = Twist()
        while (not rospy.is_shutdown()) and ((not self.info) or (not self.current_cb)):
            self.vel_pub.publish(t)
	    print 'cb :  ' + str(not self.info) + '\n'
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

