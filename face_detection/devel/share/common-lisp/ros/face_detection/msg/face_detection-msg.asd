
(cl:in-package :asdf)

(defsystem "face_detection-msg"
  :depends-on (:roslisp-msg-protocol :roslisp-utils :sensor_msgs-msg
)
  :components ((:file "_package")
    (:file "ROIArray" :depends-on ("_package_ROIArray"))
    (:file "_package_ROIArray" :depends-on ("_package"))
  ))