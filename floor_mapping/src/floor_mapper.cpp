#include <stdlib.h>
#include <stdio.h>

#include <vector>
#include <string>

#include <ros/ros.h>
#include <tf/tf.h>
#include <tf/transform_listener.h>

#include <sensor_msgs/Image.h>
#include <opencv2/opencv.hpp>
#include <cv_bridge/cv_bridge.h>

#include <image_transport/image_transport.h>
#include <image_transport/transport_hints.h>



class FloorMapper {
    protected:
        ros::NodeHandle nh_;
        image_transport::Publisher ptpub_;
        image_transport::Publisher tpub_;
        image_transport::Subscriber tsub_;
        image_transport::ImageTransport it_;

        tf::TransformListener listener_;

        int floor_size_pix;
        double floor_size_meter;
        double proj_scale;
        double projected_floor_size_meter;
        std::string target_frame;
	int increment;
        cv::Mat floor_;
	cv::Mat z_;
    public:
        FloorMapper() : nh_("~"), it_(nh_) {
            std::string transport = "raw";
            nh_.param("transport",transport,transport);
            // Image size to represent the environment
            nh_.param("floor_size_pix",floor_size_pix,1000);
            // Scaling of the environment, in meter
            nh_.param("floor_size_meter",floor_size_meter,50.);
            // Scaling of the image received as project floor in meter
            nh_.param("projected_floor_size_meter",projected_floor_size_meter,4.2);
            // Where to project
            nh_.param("target_frame",target_frame,std::string("/world"));

            proj_scale = projected_floor_size_meter / floor_size_meter;

            tsub_ = it_.subscribe<FloorMapper>("/floor_projector/floor",1, &FloorMapper::callback,this,transport);
            ptpub_ = it_.advertise("p_floor",1);
            tpub_ = it_.advertise("floor",1);
	   		
            // This matrix/image will represent the floor. 0x80 (=128) is half of the
            // range of a 8-bit integer. We will represent probabilities as
            // values between 0 and 255, where 255 represents 1.0.
            floor_ = cv::Mat_<uint8_t>(floor_size_pix,floor_size_pix,0x80);
	    	z_ = cv::Mat_<uint8_t>(floor_size_pix,floor_size_pix,0x80);
        }

        void callback(const sensor_msgs::ImageConstPtr& msg) {
            // First extract the image to a cv:Mat structure, from opencv2
            cv::Mat img(cv_bridge::toCvShare(msg,"mono8")->image);
	    try{
                // Then receive the transformation between the robot body and
                // the world
                tf::StampedTransform transform;
                // Use the listener to find where we are. Check the
                // tutorials... (note: the arguments of the 2 functions below
                // need to be completed
                listener_.waitForTransform(msg->header.frame_id,target_frame,msg->header.stamp,ros::Duration(1.0));
                listener_.lookupTransform(target_frame,msg->header.frame_id, msg->header.stamp, transform);
                

                double proj_x = transform.getOrigin().x();
                double proj_y = transform.getOrigin().y();
                double proj_theta = -tf::getYaw(transform.getRotation());
                printf("We were at %.2f %.2f theta %.2f\n",proj_x,proj_y,proj_theta*180./M_PI);

                // Once the transformation is know, you can use it to find the
                // affine transform mapping the local floor to the global floor
                // and use cv::warpAffine to fill p_floor
                cv::Mat_<uint8_t> p_floor(floor_size_pix,floor_size_pix,0xFF);
		/*cv::Mat affine = (cv::Mat_<float>(2,3) 
                        << 1, 0, 0,   
                           0, 1, 0);*/
		cv::Mat affine = (cv::Mat_<float>(2,3) 
                        << proj_scale*cos(-proj_theta), proj_scale*sin(-proj_theta), 500+proj_x/proj_scale,   
                           -proj_scale*sin(-proj_theta), proj_scale*cos(-proj_theta), 500-proj_y/proj_scale);
                cv::warpAffine(img,p_floor,affine, p_floor.size(), 
                        cv::INTER_NEAREST,cv::BORDER_CONSTANT,0xFF);
				
                // This published the projected floor on the p_floor topic
                cv_bridge::CvImage pbr(msg->header,"mono8",p_floor);
                ptpub_.publish(pbr.toImageMsg());
				
				increment = 0;
				int jj=0;
				int ii=0;
                // Now that p_floor and floor have the same size, you can use
                // the following for loop to go through all the pixels and fuse
                // the current observation with the previous one.

				/*for (unsigned int j=0;j<(unsigned)floor_.rows;j++) {
                    for (unsigned int i=0;i<(unsigned)floor_.cols;i++) {
						uint8_t pp = p_floor.at<uint8_t>(i,j);						
						if(pp!= 0xFF)
						{
							ii=i;
							jj=j;
							j=(unsigned)floor_.rows;
							i=(unsigned)floor_.cols;
						}   
					}
				}    */         
               for (unsigned int j=0;j<(unsigned)floor_.rows;j++) {
                    for (unsigned int i=0;i<(unsigned)floor_.cols;i++) {
                
				/*for (unsigned int j=jj;j<jj+proj_scale ;j++) {
                    for (unsigned int i=ii;i<ii+proj_scale;i++) {*/
                        uint8_t p = p_floor.at<uint8_t>(i,j);
                        uint8_t f = floor_.at<uint8_t>(i,j);
                        uint8_t zz= z_.at<uint8_t>(i,j);
						//increment++;
						//if(f==0xFF)
						//{
							
						//	f = (uint8_t)((f+10*p)/11);//std::min(f,p);
			//f = (uint8_t)((((float)p/255.0)*((float)f/255.0))/((float)p/255.0*(float)f/255.0+((1-(float)p*(float)p)/255.0*(1-(float)f)/255.0))); //(f*(increment-1)+p)/(increment+1);
			double proba = (255.0*(p/255.0)*(f/255.0)/((p/255.0)*(f/255.0)+(1.0-((p/255.0)*(p/255.0)))*(1.0-(f/255.0))));
			floor_.at<uint8_t>(i,j)=(uint8_t)proba;		/*
								floor_.at<uint8_t>(i,j) = 			p(z|x)*p(x)
															---------------------------
															p(z|x)*p(x) + p(z|~x)*p(~x)
							

								p(z|x) = 
							*/
						//}
                    }
                }
                // Finally publish the floor estimation.
                cv_bridge::CvImage br(msg->header,"mono8",floor_);
                //cv_bridge::CvImage br2(msg->header,"mono8",z_);
				tpub_.publish(br.toImageMsg());
				//tpub_.publish(br2.toImageMsg());
            }
            catch (tf::TransformException ex){
                ROS_ERROR("%s",ex.what());
            }
        }
        
};


int main(int argc, char *argv[]) {
    ros::init(argc,argv,"floor_mapper");

    FloorMapper fm;

    ros::spin();

    return 0;
}
        

