
(cl:in-package :asdf)

(defsystem "occgrid_planner_base-msg"
  :depends-on (:roslisp-msg-protocol :roslisp-utils :geometry_msgs-msg
               :std_msgs-msg
)
  :components ((:file "_package")
    (:file "Trajectory" :depends-on ("_package_Trajectory"))
    (:file "_package_Trajectory" :depends-on ("_package"))
    (:file "TrajectoryElement" :depends-on ("_package_TrajectoryElement"))
    (:file "_package_TrajectoryElement" :depends-on ("_package"))
  ))