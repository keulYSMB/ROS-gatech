/* Auto-generated by genmsg_cpp for file /home/jjm/vrep_ros_stack/occgrid_planner_base/msg/Trajectory.msg */
#ifndef OCCGRID_PLANNER_BASE_MESSAGE_TRAJECTORY_H
#define OCCGRID_PLANNER_BASE_MESSAGE_TRAJECTORY_H
#include <string>
#include <vector>
#include <map>
#include <ostream>
#include "ros/serialization.h"
#include "ros/builtin_message_traits.h"
#include "ros/message_operations.h"
#include "ros/time.h"

#include "ros/macros.h"

#include "ros/assert.h"

#include "std_msgs/Header.h"
#include "occgrid_planner_base/TrajectoryElement.h"

namespace occgrid_planner_base
{
template <class ContainerAllocator>
struct Trajectory_ {
  typedef Trajectory_<ContainerAllocator> Type;

  Trajectory_()
  : header()
  , Ts()
  {
  }

  Trajectory_(const ContainerAllocator& _alloc)
  : header(_alloc)
  , Ts(_alloc)
  {
  }

  typedef  ::std_msgs::Header_<ContainerAllocator>  _header_type;
   ::std_msgs::Header_<ContainerAllocator>  header;

  typedef std::vector< ::occgrid_planner_base::TrajectoryElement_<ContainerAllocator> , typename ContainerAllocator::template rebind< ::occgrid_planner_base::TrajectoryElement_<ContainerAllocator> >::other >  _Ts_type;
  std::vector< ::occgrid_planner_base::TrajectoryElement_<ContainerAllocator> , typename ContainerAllocator::template rebind< ::occgrid_planner_base::TrajectoryElement_<ContainerAllocator> >::other >  Ts;


  typedef boost::shared_ptr< ::occgrid_planner_base::Trajectory_<ContainerAllocator> > Ptr;
  typedef boost::shared_ptr< ::occgrid_planner_base::Trajectory_<ContainerAllocator>  const> ConstPtr;
  boost::shared_ptr<std::map<std::string, std::string> > __connection_header;
}; // struct Trajectory
typedef  ::occgrid_planner_base::Trajectory_<std::allocator<void> > Trajectory;

typedef boost::shared_ptr< ::occgrid_planner_base::Trajectory> TrajectoryPtr;
typedef boost::shared_ptr< ::occgrid_planner_base::Trajectory const> TrajectoryConstPtr;


template<typename ContainerAllocator>
std::ostream& operator<<(std::ostream& s, const  ::occgrid_planner_base::Trajectory_<ContainerAllocator> & v)
{
  ros::message_operations::Printer< ::occgrid_planner_base::Trajectory_<ContainerAllocator> >::stream(s, "", v);
  return s;}

} // namespace occgrid_planner_base

namespace ros
{
namespace message_traits
{
template<class ContainerAllocator> struct IsMessage< ::occgrid_planner_base::Trajectory_<ContainerAllocator> > : public TrueType {};
template<class ContainerAllocator> struct IsMessage< ::occgrid_planner_base::Trajectory_<ContainerAllocator>  const> : public TrueType {};
template<class ContainerAllocator>
struct MD5Sum< ::occgrid_planner_base::Trajectory_<ContainerAllocator> > {
  static const char* value() 
  {
    return "18f77ffd2d905ff0c111ac0074191f03";
  }

  static const char* value(const  ::occgrid_planner_base::Trajectory_<ContainerAllocator> &) { return value(); } 
  static const uint64_t static_value1 = 0x18f77ffd2d905ff0ULL;
  static const uint64_t static_value2 = 0xc111ac0074191f03ULL;
};

template<class ContainerAllocator>
struct DataType< ::occgrid_planner_base::Trajectory_<ContainerAllocator> > {
  static const char* value() 
  {
    return "occgrid_planner_base/Trajectory";
  }

  static const char* value(const  ::occgrid_planner_base::Trajectory_<ContainerAllocator> &) { return value(); } 
};

template<class ContainerAllocator>
struct Definition< ::occgrid_planner_base::Trajectory_<ContainerAllocator> > {
  static const char* value() 
  {
    return "Header header\n\
occgrid_planner_base/TrajectoryElement[] Ts\n\
\n\
================================================================================\n\
MSG: std_msgs/Header\n\
# Standard metadata for higher-level stamped data types.\n\
# This is generally used to communicate timestamped data \n\
# in a particular coordinate frame.\n\
# \n\
# sequence ID: consecutively increasing ID \n\
uint32 seq\n\
#Two-integer timestamp that is expressed as:\n\
# * stamp.secs: seconds (stamp_secs) since epoch\n\
# * stamp.nsecs: nanoseconds since stamp_secs\n\
# time-handling sugar is provided by the client library\n\
time stamp\n\
#Frame this data is associated with\n\
# 0: no frame\n\
# 1: global frame\n\
string frame_id\n\
\n\
================================================================================\n\
MSG: occgrid_planner_base/TrajectoryElement\n\
Header header\n\
geometry_msgs/Pose pose\n\
geometry_msgs/Twist twist\n\
\n\
================================================================================\n\
MSG: geometry_msgs/Pose\n\
# A representation of pose in free space, composed of postion and orientation. \n\
Point position\n\
Quaternion orientation\n\
\n\
================================================================================\n\
MSG: geometry_msgs/Point\n\
# This contains the position of a point in free space\n\
float64 x\n\
float64 y\n\
float64 z\n\
\n\
================================================================================\n\
MSG: geometry_msgs/Quaternion\n\
# This represents an orientation in free space in quaternion form.\n\
\n\
float64 x\n\
float64 y\n\
float64 z\n\
float64 w\n\
\n\
================================================================================\n\
MSG: geometry_msgs/Twist\n\
# This expresses velocity in free space broken into its linear and angular parts.\n\
Vector3  linear\n\
Vector3  angular\n\
\n\
================================================================================\n\
MSG: geometry_msgs/Vector3\n\
# This represents a vector in free space. \n\
\n\
float64 x\n\
float64 y\n\
float64 z\n\
";
  }

  static const char* value(const  ::occgrid_planner_base::Trajectory_<ContainerAllocator> &) { return value(); } 
};

template<class ContainerAllocator> struct HasHeader< ::occgrid_planner_base::Trajectory_<ContainerAllocator> > : public TrueType {};
template<class ContainerAllocator> struct HasHeader< const ::occgrid_planner_base::Trajectory_<ContainerAllocator> > : public TrueType {};
} // namespace message_traits
} // namespace ros

namespace ros
{
namespace serialization
{

template<class ContainerAllocator> struct Serializer< ::occgrid_planner_base::Trajectory_<ContainerAllocator> >
{
  template<typename Stream, typename T> inline static void allInOne(Stream& stream, T m)
  {
    stream.next(m.header);
    stream.next(m.Ts);
  }

  ROS_DECLARE_ALLINONE_SERIALIZER;
}; // struct Trajectory_
} // namespace serialization
} // namespace ros

namespace ros
{
namespace message_operations
{

template<class ContainerAllocator>
struct Printer< ::occgrid_planner_base::Trajectory_<ContainerAllocator> >
{
  template<typename Stream> static void stream(Stream& s, const std::string& indent, const  ::occgrid_planner_base::Trajectory_<ContainerAllocator> & v) 
  {
    s << indent << "header: ";
s << std::endl;
    Printer< ::std_msgs::Header_<ContainerAllocator> >::stream(s, indent + "  ", v.header);
    s << indent << "Ts[]" << std::endl;
    for (size_t i = 0; i < v.Ts.size(); ++i)
    {
      s << indent << "  Ts[" << i << "]: ";
      s << std::endl;
      s << indent;
      Printer< ::occgrid_planner_base::TrajectoryElement_<ContainerAllocator> >::stream(s, indent + "    ", v.Ts[i]);
    }
  }
};


} // namespace message_operations
} // namespace ros

#endif // OCCGRID_PLANNER_BASE_MESSAGE_TRAJECTORY_H

