; Auto-generated. Do not edit!


(cl:in-package face_detection-msg)


;//! \htmlinclude ROIArray.msg.html

(cl:defclass <ROIArray> (roslisp-msg-protocol:ros-message)
  ((list
    :reader list
    :initarg :list
    :type (cl:vector sensor_msgs-msg:RegionOfInterest)
   :initform (cl:make-array 0 :element-type 'sensor_msgs-msg:RegionOfInterest :initial-element (cl:make-instance 'sensor_msgs-msg:RegionOfInterest))))
)

(cl:defclass ROIArray (<ROIArray>)
  ())

(cl:defmethod cl:initialize-instance :after ((m <ROIArray>) cl:&rest args)
  (cl:declare (cl:ignorable args))
  (cl:unless (cl:typep m 'ROIArray)
    (roslisp-msg-protocol:msg-deprecation-warning "using old message class name face_detection-msg:<ROIArray> is deprecated: use face_detection-msg:ROIArray instead.")))

(cl:ensure-generic-function 'list-val :lambda-list '(m))
(cl:defmethod list-val ((m <ROIArray>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader face_detection-msg:list-val is deprecated.  Use face_detection-msg:list instead.")
  (list m))
(cl:defmethod roslisp-msg-protocol:serialize ((msg <ROIArray>) ostream)
  "Serializes a message object of type '<ROIArray>"
  (cl:let ((__ros_arr_len (cl:length (cl:slot-value msg 'list))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) __ros_arr_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) __ros_arr_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) __ros_arr_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) __ros_arr_len) ostream))
  (cl:map cl:nil #'(cl:lambda (ele) (roslisp-msg-protocol:serialize ele ostream))
   (cl:slot-value msg 'list))
)
(cl:defmethod roslisp-msg-protocol:deserialize ((msg <ROIArray>) istream)
  "Deserializes a message object of type '<ROIArray>"
  (cl:let ((__ros_arr_len 0))
    (cl:setf (cl:ldb (cl:byte 8 0) __ros_arr_len) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 8) __ros_arr_len) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 16) __ros_arr_len) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 24) __ros_arr_len) (cl:read-byte istream))
  (cl:setf (cl:slot-value msg 'list) (cl:make-array __ros_arr_len))
  (cl:let ((vals (cl:slot-value msg 'list)))
    (cl:dotimes (i __ros_arr_len)
    (cl:setf (cl:aref vals i) (cl:make-instance 'sensor_msgs-msg:RegionOfInterest))
  (roslisp-msg-protocol:deserialize (cl:aref vals i) istream))))
  msg
)
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql '<ROIArray>)))
  "Returns string type for a message object of type '<ROIArray>"
  "face_detection/ROIArray")
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql 'ROIArray)))
  "Returns string type for a message object of type 'ROIArray"
  "face_detection/ROIArray")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql '<ROIArray>)))
  "Returns md5sum for a message object of type '<ROIArray>"
  "0941bf598c7a2d0c4bc682a51a568b28")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql 'ROIArray)))
  "Returns md5sum for a message object of type 'ROIArray"
  "0941bf598c7a2d0c4bc682a51a568b28")
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql '<ROIArray>)))
  "Returns full string definition for message of type '<ROIArray>"
  (cl:format cl:nil "sensor_msgs/RegionOfInterest[] list~%~%================================================================================~%MSG: sensor_msgs/RegionOfInterest~%# This message is used to specify a region of interest within an image.~%#~%# When used to specify the ROI setting of the camera when the image was~%# taken, the height and width fields should either match the height and~%# width fields for the associated image; or height = width = 0~%# indicates that the full resolution image was captured.~%~%uint32 x_offset  # Leftmost pixel of the ROI~%                 # (0 if the ROI includes the left edge of the image)~%uint32 y_offset  # Topmost pixel of the ROI~%                 # (0 if the ROI includes the top edge of the image)~%uint32 height    # Height of ROI~%uint32 width     # Width of ROI~%~%# True if a distinct rectified ROI should be calculated from the \"raw\"~%# ROI in this message. Typically this should be False if the full image~%# is captured (ROI not used), and True if a subwindow is captured (ROI~%# used).~%bool do_rectify~%~%~%"))
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql 'ROIArray)))
  "Returns full string definition for message of type 'ROIArray"
  (cl:format cl:nil "sensor_msgs/RegionOfInterest[] list~%~%================================================================================~%MSG: sensor_msgs/RegionOfInterest~%# This message is used to specify a region of interest within an image.~%#~%# When used to specify the ROI setting of the camera when the image was~%# taken, the height and width fields should either match the height and~%# width fields for the associated image; or height = width = 0~%# indicates that the full resolution image was captured.~%~%uint32 x_offset  # Leftmost pixel of the ROI~%                 # (0 if the ROI includes the left edge of the image)~%uint32 y_offset  # Topmost pixel of the ROI~%                 # (0 if the ROI includes the top edge of the image)~%uint32 height    # Height of ROI~%uint32 width     # Width of ROI~%~%# True if a distinct rectified ROI should be calculated from the \"raw\"~%# ROI in this message. Typically this should be False if the full image~%# is captured (ROI not used), and True if a subwindow is captured (ROI~%# used).~%bool do_rectify~%~%~%"))
(cl:defmethod roslisp-msg-protocol:serialization-length ((msg <ROIArray>))
  (cl:+ 0
     4 (cl:reduce #'cl:+ (cl:slot-value msg 'list) :key #'(cl:lambda (ele) (cl:declare (cl:ignorable ele)) (cl:+ (roslisp-msg-protocol:serialization-length ele))))
))
(cl:defmethod roslisp-msg-protocol:ros-message-to-list ((msg <ROIArray>))
  "Converts a ROS message object to a list"
  (cl:list 'ROIArray
    (cl:cons ':list (list msg))
))
