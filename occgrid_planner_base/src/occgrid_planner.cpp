
#include <vector>
#include <string>
#include <map>
#include <list>
#include <math.h> 
#include <typeinfo>

#include <ros/ros.h>
#include <tf/tf.h>
#include <tf/transform_listener.h>
#include <opencv2/opencv.hpp>
#include <opencv2/highgui/highgui.hpp>

#include <nav_msgs/OccupancyGrid.h>
#include <nav_msgs/Path.h>
#include <geometry_msgs/PoseStamped.h>

#define FREE 0xFF
#define UNKNOWN 0x80
#define OCCUPIED 0x00
#define WIN_SIZE 800

#define num_orientation 8
#define num_neighbors 7
//	int num_orientation =4;
//			int num_neighbors =3;
		
class OccupancyGridPlanner {
    protected:
        ros::NodeHandle nh_;
        ros::Subscriber og_sub_;
        ros::Subscriber target_sub_;
        ros::Publisher path_pub_;
        tf::TransformListener listener_;

        cv::Rect roi_;
        cv::Mat_<uint8_t> og_, cropped_og_;
        cv::Mat_<cv::Vec3b> og_rgb_, og_rgb_marked_;
        cv::Point og_center_;
        nav_msgs::MapMetaData info_;
        std::string frame_id_;
        std::string base_link_;
        unsigned int neighbourhood_;
        bool ready;
        bool debug;

        typedef std::multimap<float, cv::Point3i> Heap;

        // Callback for Occupancy Grids
        void og_callback(const nav_msgs::OccupancyGridConstPtr & msg) {
            info_ = msg->info;
            frame_id_ = msg->header.frame_id;
            // Create an image to store the value of the grid.
            og_ = cv::Mat_<uint8_t>(msg->info.height, msg->info.width,0xFF);
			//cv::Mat_<uint8_t>* og_orientation = cv::Mat_<uint8_t>[8];
			cv::Mat og_orientation[8];			
			int i=0;
			for(i=0;i<8;i++)
				og_orientation[i]=cv::Mat_<uint8_t>(msg->info.height, msg->info.width,0xFF);
            og_center_ = cv::Point(-info_.origin.position.x/info_.resolution,
                    -info_.origin.position.y/info_.resolution);

            // Some variables to select the useful bounding box 
            unsigned int maxx=0, minx=msg->info.width, 
                         maxy=0, miny=msg->info.height;
            // Convert the representation into something easy to display.
            for (unsigned int j=0;j<msg->info.height;j++) {
                for (unsigned int i=0;i<msg->info.width;i++) {
                    int8_t v = msg->data[j*msg->info.width + i];
                    switch (v) {
                        case 0: 
                            og_(j,i) = FREE; 
                            break;
                        case 100: 
                            og_(j,i) = OCCUPIED; 
                            break;
                        case -1: 
                        default:
                            og_(j,i) = UNKNOWN; 
                            break;
                    }
                    // Update the bounding box of free or occupied cells.
                    if (og_(j,i) != UNKNOWN) {
                        minx = std::min(minx,i);
                        miny = std::min(miny,j);
                        maxx = std::max(maxx,i);
                        maxy = std::max(maxy,j);
                    }
                }
            }
            if (!ready) {
                ready = true;
                ROS_INFO("Received occupancy grid, ready to plan");
            }
			int erosion_size = 3;
			cv::Mat element = cv::getStructuringElement( cv::MORPH_RECT,
                                       cv::Size( 2*erosion_size + 1, 2*erosion_size+1 ),
                                       cv::Point( erosion_size, erosion_size ) );
			cv::erode(og_,og_,element);            
			// The lines below are only for display
            unsigned int w = maxx - minx;
            unsigned int h = maxy - miny;
            roi_ = cv::Rect(minx,miny,w,h);
            cv::cvtColor(og_, og_rgb_, CV_GRAY2RGB);
            // Compute a sub-image that covers only the useful part of the
            // grid.
            cropped_og_ = cv::Mat_<uint8_t>(og_,roi_);
            if ((w > WIN_SIZE) || (h > WIN_SIZE)) {
                // The occupancy grid is too large to display. We need to scale
                // it first.
                double ratio = w / ((double)h);
                cv::Size new_size;
                if (ratio >= 1) {
                    new_size = cv::Size(WIN_SIZE,WIN_SIZE/ratio);
                } else {
                    new_size = cv::Size(WIN_SIZE*ratio,WIN_SIZE);
                }
                cv::Mat_<uint8_t> resized_og;
                cv::resize(cropped_og_,resized_og,new_size);
                cv::imshow( "OccGrid", resized_og );
            } else {
                // cv::imshow( "OccGrid", cropped_og_ );
                cv::imshow( "OccGrid", og_rgb_ );
            }
		
        }

        // Generic test if a point is within the occupancy grid
        bool isInGrid(const cv::Point & P) {
            if ((P.x < 0) || (P.x >= (signed)info_.width) 
                    || (P.y < 0) || (P.y >= (signed)info_.height)) {
                return false;
            }
            return true;
        }

        // This is called when a new goal is posted by RViz. We don't use a
        // mutex here, because it can only be called in spinOnce.
        void target_callback(const geometry_msgs::PoseStampedConstPtr & msg) {
            tf::StampedTransform transform;
            geometry_msgs::PoseStamped pose;

			int sign =0,signsin =0;
			float cost[7]={0,0,0,0,0,0,0};
            if (!ready) {
                ROS_WARN("Ignoring target while the occupancy grid has not been received");
                return;
            }
            ROS_INFO("Received planning request");
            og_rgb_marked_ = og_rgb_.clone();
            // Convert the destination point in the occupancy grid frame. 
            // The debug case is useful is the map is published without
            // gmapping running (for instance with map_server).
            
	    	if (debug) {
                pose = *msg;
            } else {
                // This converts target in the grid frame.
                listener_.waitForTransform(frame_id_,msg->header.frame_id,msg->header.stamp,ros::Duration(1.0));
                listener_.transformPose(frame_id_,*msg, pose);
                // this gets the current pose in transform
                listener_.lookupTransform(frame_id_,base_link_, ros::Time(0), transform);
            }
            // Now scale the target to the grid resolution and shift it to the
            // grid center.
            cv::Point target = cv::Point(pose.pose.position.x / info_.resolution, pose.pose.position.y / info_.resolution)
                + og_center_;
			cv::Point3i targetxytheta = cv::Point3i(target.x,target.y, ((unsigned int)round(tf::getYaw(transform.getRotation())/(M_PI/2))+4)%4);
            ROS_INFO("Planning target: %.2f %.2f -> %d %d",
                        pose.pose.position.x, pose.pose.position.y, target.x, target.y);
            cv::circle(og_rgb_marked_,target, 10, cv::Scalar(0,0,255));
            cv::imshow( "OccGrid", og_rgb_marked_ );
            if (!isInGrid(target)) {
                ROS_ERROR("Invalid target point (%.2f %.2f) -> (%d %d)",
                        pose.pose.position.x, pose.pose.position.y, target.x, target.y);
                return;
            }
            // Only accept target which are FREE in the grid (HW, Step 5).
            if (og_(target) != FREE) {
                ROS_ERROR("Invalid target point: occupancy = %d",og_(target));
                return;
            }

            // Now get the current point in grid coordinates.
            cv::Point start;
            if (debug) {
                start = og_center_;
            } else {
                start = cv::Point(transform.getOrigin().x() / info_.resolution, transform.getOrigin().y() / info_.resolution)
                    + og_center_;
            }
			cv::Point3i startxytheta = cv::Point3i(start.x ,start.y ,((unsigned int)round(tf::getYaw(transform.getRotation())/(M_PI/4))+8)%8);
            ROS_INFO("Planning origin %.2f %.2f -> %d %d",
                    transform.getOrigin().x(), transform.getOrigin().y(), start.x, start.y);
            cv::circle(og_rgb_marked_,start, 10, cv::Scalar(0,255,0));
            cv::imshow( "OccGrid", og_rgb_marked_ );
            if (!isInGrid(start)) {
                ROS_ERROR("Invalid starting point (%.2f %.2f) -> (%d %d)",
                        transform.getOrigin().x(), transform.getOrigin().y(), start.x, start.y);
                return;
            }
            // If the starting point is not FREE there is a bug somewhere, but
            // better to check
            if (og_(start) != FREE) {
                ROS_ERROR("Invalid start point: occupancy = %d",og_(start));
                return;
            }
            ROS_INFO("Starting planning from (%d, %d) to (%d, %d)",start.x,start.y, target.x, target.y);
            // Here the Dijskstra algorithm starts 
            // The best distance to the goal computed so far. This is
            // initialised with Not-A-Number. 
			int dim[3]={(og_.size()).height,(og_.size()).width,8};
            cv::Mat_<float> cell_value(3,dim, NAN);
            // For each cell we need to store a pointer to the coordinates of
            // its best predecessor. 
            cv::Mat_<cv::Vec3s> predecessor(3,dim);

            // The neighbour of a given cell in relative coordinates. The order
            // is important. If we use 4-connexity, then we can use only the
            // first 4 values of the array. If we use 8-connexity we use the
            // full array.
			
			// vector of num_orientation elements
			// each element is a vector of num_neighbours elements 
			std::vector <std::vector <cv::Point3i> > neighbour_arr(8); 
			int turn = 5;
			float cost0[num_neighbors] = {sqrt(2)+turn/2, sqrt(5)+turn/4, 1, sqrt(5)+turn/4, sqrt(2)+turn/2, turn , turn}; 
            float cost45[num_neighbors] = {1+turn/2, sqrt(5)+turn/4 ,sqrt(2), sqrt(5)+turn/4, 1+turn/2, turn , turn};
			//ROS_INFO("Before creating neighbors of type : %s\n",typeid(neighbour_arr[0][0].x).name());
			for(int i =0; i<8;i++) {
                neighbour_arr[i].resize(7);
            }
			for(int i = 0; i<8; i++)
			{
				if(i%2 == 0) // if we are at a 90 degree increment
				{
			
			//	ROS_INFO("Before assign neighbors %d",i);
					if(i%4==2)
					{
						neighbour_arr[i][0].x = -sin(i*M_PI/4); 				// left and 90 degrees
						neighbour_arr[i][0].y = sin(i*M_PI/4);
						neighbour_arr[i][0].z = (i+1+8)%8;
						neighbour_arr[i][1].x = -sin(i*M_PI/4); 	// left and 45 degrees
						neighbour_arr[i][1].y = 2*sin(i*M_PI/4);
						neighbour_arr[i][1].z = i;				
						neighbour_arr[i][2].x = 0;				// forward
						neighbour_arr[i][2].y = sin(i*M_PI/4);
						neighbour_arr[i][2].z = (i-1+8)%8;
						neighbour_arr[i][3].x = sin(i*M_PI/4);				// right and 45 degrees
						neighbour_arr[i][3].y = 2*sin(i*M_PI/4);
						neighbour_arr[i][3].z = (i-1+8)%8;
						neighbour_arr[i][4].x = sin(i*M_PI/4);				// right and 90 degrees
						neighbour_arr[i][4].y = sin(i*M_PI/4);
						neighbour_arr[i][4].z = (i-1+8)%8;
					}
					else
					{
						neighbour_arr[i][0].x = cos(i*M_PI/4); 				// left and 90 degrees
						neighbour_arr[i][0].y = cos(i*M_PI/4);
						neighbour_arr[i][0].z = (i+1+8)%8;
						neighbour_arr[i][1].x = 2*cos(i*M_PI/4); 	// left and 45 degrees
						neighbour_arr[i][1].y = cos(i*M_PI/4);
						neighbour_arr[i][1].z = i;				
						neighbour_arr[i][2].x = cos(i*M_PI/4);				// forward
						neighbour_arr[i][2].y = 0;
						neighbour_arr[i][2].z = (i-1+8)%8;
						neighbour_arr[i][3].x = 2*cos(i*M_PI/4);				// right and 45 degrees
						neighbour_arr[i][3].y = -cos(i*M_PI/4);
						neighbour_arr[i][3].z = (i-1+8)%8;
						neighbour_arr[i][4].x = cos(i*M_PI/4);				// right and 90 degrees
						neighbour_arr[i][4].y = -cos(i*M_PI/4);
						neighbour_arr[i][4].z = (i-1+8)%8;

					}
				}
				else
				{
					if(cos(i*M_PI/4)<0)
					{
						sign = -1;
					}					
					else
					{
						sign = 1;
					}
					if(sin(i*M_PI/4)<0)
					{
						signsin = -1;
					}
					else
					{
						signsin = 1;
					}
					if(cos(i*M_PI/4)==sin(i*M_PI/4))
					{
						neighbour_arr[i][0].x = 0; 				// left and 90 degrees
						neighbour_arr[i][0].y = sign;
						neighbour_arr[i][0].z = (i+1+8)%8;
						neighbour_arr[i][1].x = sign; 	// left and 45 degrees
						neighbour_arr[i][1].y = 2*sign;
						neighbour_arr[i][1].z = i;				
						neighbour_arr[i][2].x = sign;				// forward
						neighbour_arr[i][2].y = sign;
						neighbour_arr[i][2].z = (i-1+8)%8;
						neighbour_arr[i][3].x = 2*sign;				// right and 45 degrees
						neighbour_arr[i][3].y = sign;
						neighbour_arr[i][3].z = (i-1+8)%8;
						neighbour_arr[i][4].x = sign;				// right and 90 degrees
						neighbour_arr[i][4].y = 0;
						neighbour_arr[i][4].z = (i-1+8)%8;
					}
					else
					{
						neighbour_arr[i][0].x = sign; 				// left and 90 degrees
						neighbour_arr[i][0].y = 0;
						neighbour_arr[i][0].z = (i+1+8)%8;
						neighbour_arr[i][1].x = 2*sign; 	// left and 45 degrees
						neighbour_arr[i][1].y = signsin;
						neighbour_arr[i][1].z = i;				
						neighbour_arr[i][2].x = sign;				// forward
						neighbour_arr[i][2].y = signsin;
						neighbour_arr[i][2].z = (i-1+8)%8;
						neighbour_arr[i][3].x = sign;				// right and 45 degrees
						neighbour_arr[i][3].y = 2*signsin;
						neighbour_arr[i][3].z = (i-1+8)%8;
						neighbour_arr[i][4].x = 0;				// right and 90 degrees
						neighbour_arr[i][4].y = signsin;
						neighbour_arr[i][4].z = (i-1+8)%8;				
					}
				}

			neighbour_arr[i][5].x = 0;				// left turn on spot
			neighbour_arr[i][5].y = 0;
			neighbour_arr[i][5].z = (i-1+8)%8;
			neighbour_arr[i][6].x = 0;				// right turn on spot
			neighbour_arr[i][6].y = 0;
			neighbour_arr[i][6].z = (i+1+8)%8;
			}
			//ROS_INFO("Before creating heap\n");
            
            // The core of Dijkstra's Algorithm, a sorted heap, where the first
            // element is always the closer to the start.
            Heap heap;
            heap.insert(Heap::value_type(0, startxytheta));
            while (!heap.empty()) {
                // Select the cell at the top of the heap
                Heap::iterator hit = heap.begin();
                // the cell it contains is this_cell
                cv::Point3i this_cell = hit->second;
                // and its score is this_cost
                float this_cost = hit->first;
                // We can remove it from the heap now.
                heap.erase(hit);
                // Now see where we can go from this_cell
				// To know where we can go from our current cell we need to know our current angle
				int theta = (this_cell.z+8)%8;//(int)(floor(tf::getYaw(pose.pose.orientation)/M_PI/2)+4)%4; // get numbers 0-7 based on our current angle
			//	ROS_INFO("theta value %d\n",theta);  
				//for (unsigned int i=0;i<neighbourhood_;i++) {
                  for (unsigned int i=0;i<7;i++) {
				//	ROS_INFO("begin for \n");                
				
                   // cv::Point dest = this_cell + neighbours[i]; this is the original statement but we have to only look at the
					// 												the possible neighbors given our current orientation
				//	ROS_INFO("type of neighbour_arr[theta][i] = %s",typeid( neighbour_arr[theta][i]).name());
						cv::Point3i dest = this_cell + neighbour_arr[theta][i];//neighbours[i];
						dest.z = ((dest.z+8)%8);
					//	ROS_INFO("previous cell %d,%d,%d\n neighbour_arr[theta][i] = %d,%d,%d\n next cell tested %d,%d,%d\n",this_cell.x,this_cell.y,this_cell.z,neighbour_arr[theta][i].x,neighbour_arr[theta][i].y,neighbour_arr[theta][i].z,dest.x,dest.y,dest.z);                 
				
						cv::Point dest2d = cv::Point(dest.x, dest.y);
					//	ROS_INFO("before is on grid \n");         
		                if (!isInGrid(dest2d)) {
		                    // outside the grid
		                    continue;
		                }
					//	ROS_INFO("before is occupied \n");
		                uint8_t og = og_(dest2d);
		                if (og != FREE) {
		                    // occupied or unknown
		                    continue;
		                }
					//	ROS_INFO("before affecting cost : dest (%d,%d,%d),  \n",dest.x,dest.y,dest.z);
					//		ROS_INFO("dest size : %d,%d \n",cell_value.size().width,cell_value.size().height);
					//	ROS_INFO("dest value : %f \n",cell_value(dest.x,dest.y,dest.z));
		                float cv2 =(float) cell_value(dest.x,dest.y,dest.z);
					//	ROS_INFO("between \n");
						if(theta%2==0)
						{
							cost[i]=cost0[i];
						}
						else
						{
							cost[i]=cost45[i];
						}
		                float new_cost = this_cost + cost[i] + cv::norm(targetxytheta-this_cell);//hypot(abs(target.x-this_cell.x),abs(target.y-this_cell.y));
					//	ROS_INFO("heap size : %lu",heap.size());
					//	ROS_INFO("after affecting cost \n");
		                if (isnan(cv2) || (new_cost < cv2)) {
		                    // found shortest path (or new path), updating the
		                    // predecessor and the value of the cell
		                    predecessor.at<cv::Vec3s>(dest.x,dest.y,dest.z) = cv::Vec3s(this_cell.x,this_cell.y,this_cell.z);
		                    cell_value(dest.x,dest.y,dest.z) = new_cost;
		                    // And insert the selected cells in the map.
		                    heap.insert(Heap::value_type(new_cost,dest));
		                }
                }
            }
            if (isnan(cell_value(targetxytheta.x,targetxytheta.y,targetxytheta.z))) {
                // No path found
                ROS_ERROR("No path found from (%d, %d) to (%d, %d)",start.x,start.y,target.x,target.y);
                return;
            }
            ROS_INFO("Planning completed");
            // Now extract the path by starting from goal and going through the
            // predecessors until the starting point
            std::list<cv::Point3i> lpath;
			ROS_INFO("before while");
            while (targetxytheta != startxytheta) {
                lpath.push_front(targetxytheta);
                cv::Vec3s p = predecessor(targetxytheta.x, targetxytheta.y, targetxytheta.z);
                targetxytheta.x = p[0]; targetxytheta.y = p[1]; targetxytheta.z = p[2];
            }
			ROS_INFO("after while");
            lpath.push_front(startxytheta);
            // Finally create a ROS path message
            nav_msgs::Path path;
            path.header.stamp = ros::Time::now();
            path.header.frame_id = frame_id_;
            path.poses.resize(lpath.size());
            std::list<cv::Point3i>::const_iterator it = lpath.begin();
            unsigned int ipose = 0;
            while (it != lpath.end()) {
                // time stamp is not updated because we're not creating a
                // trajectory at this stage
                path.poses[ipose].header = path.header;
                cv::Point3i P = *it - cv::Point3i(og_center_.x,og_center_.y,0);
                path.poses[ipose].pose.position.x = (P.x) * info_.resolution;
                path.poses[ipose].pose.position.y = (P.y) * info_.resolution;
				P.z = (P.z+8)%8;
				P.z = P.z*M_PI/4;
				
				tf::Quaternion q = tf::createQuaternionFromRPY(0,0,P.z);
                tf::quaternionTFToMsg(q, path.poses[ipose].pose.orientation);
                ipose++;
                it ++;
            }
            path_pub_.publish(path);
            ROS_INFO("Request completed");
        }



    public:
        OccupancyGridPlanner() : nh_("~") {
            int nbour = 4;
            ready = false;
            nh_.param("base_frame",base_link_,std::string("/body"));
            nh_.param("debug",debug,false);
            nh_.param("neighbourhood",nbour,nbour);
            switch (nbour) {
				case 3: neighbourhood_ = nbour; break; // added a case for 3 possible neighbors
                case 4: neighbourhood_ = nbour; break;
                case 8: neighbourhood_ = nbour; break;
                default: 
                    ROS_WARN("Invalid neighbourhood specification (%d instead of 4 or 8)",nbour);
                    neighbourhood_ = 8;
            }
            og_sub_ = nh_.subscribe("occ_grid",1,&OccupancyGridPlanner::og_callback,this);
            target_sub_ = nh_.subscribe("goal",1,&OccupancyGridPlanner::target_callback,this);
            path_pub_ = nh_.advertise<nav_msgs::Path>("path",1,true);
        }
};

int main(int argc, char * argv[]) {
    ros::init(argc,argv,"occgrid_planner");
    OccupancyGridPlanner ogp;
    cv::namedWindow( "OccGrid", CV_WINDOW_AUTOSIZE );
    while (ros::ok()) {
        ros::spinOnce();
        if (cv::waitKey( 50 )== 'q') {
            ros::shutdown();
        }
    }
}

