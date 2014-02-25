#include <ros/ros.h>
#include <sensor_msgs/Joy.h>
#include <geometry_msgs/Twist.h>


class BlobTeleop
{
public:
  BlobTeleop();

private:
  void joyCallback(const sensor_msgs::Joy::ConstPtr& joy);
  
  ros::NodeHandle nh_;

  int linear_, angular_;
  double l_scale_, a_scale_;
  ros::Publisher vel_pub_;
  ros::Subscriber joy_sub_;
  
};


BlobTeleop::BlobTeleop():
  linear_(1),
  angular_(3)
{

  nh_.param("axis_linear", linear_, linear_);
  nh_.param("axis_angular", angular_, angular_);
  nh_.param("scale_angular", a_scale_, a_scale_);
  nh_.param("scale_linear", l_scale_, l_scale_);


  vel_pub_ = nh_.advertise<geometry_msgs::Twist>("vrep/follower/twistCommand", 1);
  //vel_pub_ = nh_.advertise<geometry_msgs::Twist>("JoyCommand", 1);


  joy_sub_ = nh_.subscribe<sensor_msgs::Joy>("joy", 2, &BlobTeleop::joyCallback, this);

}

void BlobTeleop::joyCallback(const sensor_msgs::Joy::ConstPtr& joy)
{
  geometry_msgs::Twist vel;
  vel.angular.x = 0;
  vel.angular.y = 0;
  vel.angular.z = a_scale_*joy->axes[3];
if(joy->axes[1]==1.0 && vel.linear.x==0){
	vel.linear.x = l_scale_*0.9;
	vel.angular.z = 0;
	}
else
  vel.linear.x = l_scale_*joy->axes[1];
  vel.linear.y = 0;//l_scale_*joy->axes[linear_];
  vel.linear.z = a_scale_*joy->axes[3];

  vel_pub_.publish(vel);
}


int main(int argc, char** argv)
{
  ros::init(argc, argv, "teleop_blob");
  BlobTeleop teleop_blob;

  ros::spin();
}
