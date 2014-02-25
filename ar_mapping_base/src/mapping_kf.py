import roslib; roslib.load_manifest('ar_mapping_base')
import rospy
from numpy import *
from numpy.linalg import inv
from math import pi, sin, cos
from visualization_msgs.msg import Marker, MarkerArray
import tf
import threading

#import rover_driver
#from rover_driver.rover_kinematics import *

# xk = xk-1
# zk = H*xk
# x = state of the robot, here : x,y,theta
# z = current observation
# Q = process noise covariance : here neglected
# R = measurement noise covariance
#--------Time Update Equations---------#
# xk(hat) = xk(hat)(apriori)
# Pk(apriori) = Pk-1  (A = Identity and Q neglected)
#-----Measurement Update equations-----#
# TIME UPDATE EQUATIONS
# gain update : Kk = Pk(apriori)*H'*inv(H*Pk*H' + R) where Pk is a priori estimate covariance
# 
# UPDATE STATE ESTIMATE
# xkhat = xkhat(apriori) + Kk*(Zk-H*xkhat(apiori))

# UPDATE COVARIANCE ESTIMATE
# Pk = (Identity - Kk*H)*Pk(apriori)
class Landmark:
    def __init__(self, Z, X , R):
        # Initialise a landmark based on measurement Z, 
        # current position X and uncertainty R
        # TODO
		# Rotate Z to the world frame
	self.theta = X[2,0]
	Rot = matrix([[cos(self.theta), -sin(self.theta)],[sin(self.theta), cos(self.theta)]])
        Zrot = Rot*Z
	
		# initialize position
	self.x = X[0,0]+Zrot[0,0]
	self.y = X[1,0]+Zrot[1,0]
		
        self.L =vstack([self.x,self.y])
        #self.P =mat([[0,0],[0,0]])
		# adding uncertainty to estimate
	self.P = R
		#


    def update(self,Z, X, R):
        # Update the landmark based on measurement Z, 
        # current position X and uncertainty R

		# update position
	self.x = self.L[0,0] - X[0,0] # maybe I need to subtract something here
	self.y = self.L[1,0] - X[1,0]
	self.theta = X[2,0]
	xnew = vstack([self.x,self.y])
		# Jacobian of Z in X frame
	#Rot_minus_theta = matrix([[cos(self.theta), sin(self.theta),0],[-sin(self.theta), cos(self.theta),0]]),[-sin(self.theta), cos(self.theta),0]])
	#self.H = identity(2)#matrix([[,],[,]])
	self.H = matrix([[cos(self.theta), sin(self.theta)],[-sin(self.theta), cos(self.theta)]]) # dimensionally this works out 
		#H = Rot_minus_theta * matrix([[1,0,X[0,0]-],[0,1,X[1,0]-]])
		# Update gain
	K = self.P*self.H.transpose()*inv(self.H*self.P*self.H.transpose() + R)
		# update state estimate
		# xkhat = xkhat(apriori) + Kk*(Zk-H*xkhat(apiori))
	self.L = self.L + K *(Z - self.H*xnew)
		
		# update covariance estimate 
	print str(self.P.shape)
	self.P = (identity(self.P.shape[0]) - K*self.H)*self.P        
		# TODO
        return
        


class MappingKF:
    def __init__(self):
        self.lock = threading.Lock()
        self.marker_list = {}
        self.marker_pub = rospy.Publisher("~landmarks",MarkerArray)
	self.ma = MarkerArray()

    def update_ar(self, Z, X, Id, uncertainty):
        self.lock.acquire()
        print "Update: Z="+str(Z.T)+" X="+str(X.T)+" Id="+str(Id)
        R = mat(diag([uncertainty,uncertainty]))
        # Take care of the landmark Id observed as Z from X
        # self.marker_list is expected to be a dictionary of Landmark
        # such that current landmark can be retrieved as self.marker_list[Id] 
        # At initialisation, self.marker_list is empty
	if(Id in self.marker_list):
		#if landmark already exists update it
		self.marker_list[Id].update(Z,X,R)
	else:
		# if landmark doesn't exist : create new one
		self.marker_list[Id] = Landmark(Z,X,R)
        # TODO
        self.lock.release()


    def publish(self, target_frame, timestamp):
        ma = MarkerArray()
        for id in self.marker_list:
            marker = Marker()
            marker.header.stamp = timestamp
            marker.header.frame_id = target_frame
            marker.ns = "landmark_kf"
            marker.id = id
            marker.type = Marker.CYLINDER
            marker.action = Marker.ADD
            Lkf = self.marker_list[id]
            marker.pose.position.x = Lkf.L[0,0]
            marker.pose.position.y = Lkf.L[1,0]
            marker.pose.position.z = 0
            marker.pose.orientation.x = 0
            marker.pose.orientation.y = 0
            marker.pose.orientation.z = 1
            marker.pose.orientation.w = 0
            marker.scale.x = max(3*sqrt(Lkf.P[0,0]),.05)
            marker.scale.y = max(3*sqrt(Lkf.P[1,1]),.05)
            marker.scale.z = 0.5;
            marker.color.a = 1.0;
            marker.color.r = 1.0;
            marker.color.g = 1.0;
            marker.color.b = 0.0;
            marker.lifetime.secs=3.0;
            ma.markers.append(marker)
            marker = Marker()
            marker.header.stamp = timestamp
            marker.header.frame_id = target_frame
            marker.ns = "landmark_kf"
            marker.id = 1000+id
            marker.type = Marker.TEXT_VIEW_FACING
            marker.action = Marker.ADD
            Lkf = self.marker_list[id]
            marker.pose.position.x = Lkf.L[0,0]
            marker.pose.position.y = Lkf.L[1,0]
            marker.pose.position.z = 1.0
            marker.pose.orientation.x = 0
            marker.pose.orientation.y = 0
            marker.pose.orientation.z = 1
            marker.pose.orientation.w = 0
            marker.text = str(id)
      	    marker.scale.x = 1.0
            marker.scale.y = 1.0
            marker.scale.z = 0.2
            marker.color.a = 1.0;
            marker.color.r = 1.0;
            marker.color.g = 1.0;
            marker.color.b = 1.0;
            marker.lifetime.secs=3.0;
            ma.markers.append(marker)
        self.marker_pub.publish(ma)

