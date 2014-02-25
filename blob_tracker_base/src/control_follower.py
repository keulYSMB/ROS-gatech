#!/usr/bin/env python
import roslib
roslib.load_manifest('blob_tracker_base')

import rospy
from sensor_msgs.msg import RegionOfInterest
from sensor_msgs.msg import CameraInfo
from geometry_msgs.msg import Twist


class BlobFollower:
	def __init__(self):
		self.blob = None
		self.info = None
		self.twist = Twist() 
        	rospy.init_node('blob_follow')
#		rospy.loginfo("begin init")
        	self.pub = rospy.Publisher("/vrep/follower/twistCommand",Twist)
#		rospy.loginfo("publisher initialized")
        	rospy.Subscriber("blobimage",RegionOfInterest,self.store_blob)
#        	rospy.loginfo("subscribed to ROI")
		#rospy.Subscriber("~info",CameraInfo,self.store_info)
#		rospy.loginfo("subscribed to Info")
		self.xcenterImage=128
		self.ycenterImage=128
		

    	def store_blob(self,blob):
#		rospy.loginfo("begin store blob")
        	self.blob = blob
		self.compute_traj()

	def compute_traj(self):
#		rospy.loginfo("begin compute traj")
		ycenterleader = self.blob.y_offset+self.blob.height/2
		xcenterleader = self.blob.x_offset+self.blob.width/2
		#rospy.loginfo("xcenterleader : " + str(xcenterleader)+ "  ycenterleader : " + str(ycenterleader))
		xdiff = self.xcenterImage-xcenterleader
		ydiff = self.ycenterImage-ycenterleader
		#rospy.loginfo("xdiff = " + str(xdiff) + "ydiff" +str(ydiff))
		self.twist.angular.z = float(xdiff)/float(self.xcenterImage)
		rospy.loginfo(" angular : " + str(self.twist.angular.z))
#		self.twist.angular.z=0
		self.twist.linear.x= 4.0*(float(ydiff)/float(self.ycenterImage)+0.35)
		if self.twist.linear.x >= 0.95:
			self.twist.linear.x = 0.9
		elif self.twist.linear.x <= -0.95:
			self.twist.linear.x = -0.9
	
    	def store_info(self,info):
        	self.info = info

    	def run(self):
        	rospy.loginfo("Waiting for first blob and camera info")
        	t = Twist()
        	rate = rospy.Rate(10)
        	while (not rospy.is_shutdown()) and ((not self.blob)):
			# or (not self.info)):
			rospy.loginfo("not blob received")
	    		rate.sleep()
        	while not rospy.is_shutdown():
			#rospy.loginfo("loop not suhtdowm")
#			rospy.loginfo("published speed  linear : " + str(self.twist.linear))
#            		self.twist.linear.x=0
			self.pub.publish(self.twist)
			rate.sleep()

if __name__=="__main__":
	demo = BlobFollower()
	rospy.loginfo("launching following controller")
    	demo.run()
