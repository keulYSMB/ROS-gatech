#!/usr/bin/env python
import roslib; #roslib.load_manifest('cb_vs_base')
import rospy
from roslib import message
import sensor_msgs.point_cloud2 as pc2
from sensor_msgs.msg import PointCloud2, PointField
from geometry_msgs.msg import Point
from cb_detector.msg import Checkerboard
from numpy import hypot

class update_depth:
    def __init__(self):
	rospy.init_node("depth")
        self.depth = 1
        self.pub = rospy.Publisher('~updated_checkboard', Checkerboard)
        rospy.Subscriber('/cb_detector/checkerboard', Checkerboard, self.checker_cb)
        rospy.Subscriber('/vrep/hokuyoSensor', PointCloud2, self.laser_cb)

    def laser_cb(self, data): # get depth of each point and store it
		laser_points = PointCloud2()
		laser_points = data
		currentpoint= Point()
		data_out = pc2.read_points(data, field_names=None, skip_nans=False, uvs=currentpoint)
		min_depth = 9001 # its over 9000!
		#for i in laser_points: # as long as we have more points 
		for i in range(0, len(laser_points.data))
		#	tmp = hypot(hypot(laser_points(i).x,laser_points(i).y),laser_points(i).z) 
			tmp = hypot(hypot(i.x,i.y),i.z) 
			min_depth = min(min_depth,tmp)
        #	if tmp < min_depth:
	#		min_depth = tmp
		self.depth = min_depth
		
    def checker_cb(self, data): # assign all points a depth 
	checkb = Checkerboard()
        checkb = data
	#zmin = 255
	#for k in checkb.data:
	#    zmin = min(zmin,k)
        for k in checkb.data:
            k.z = self.depth
        for k in cb.model:
            k.z = self.depth
        self.pub.publish(checkb)
        
    def run(self):
        rospy.spin()

if __name__ == '__main__':
	ud = update_depth()
	ud.run()
