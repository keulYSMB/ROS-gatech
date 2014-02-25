# generated from genmsg/cmake/pkg-genmsg.cmake.em

message(STATUS "face_detection: 1 messages, 0 services")

set(MSG_I_FLAGS "-Iface_detection:/home/group11/fuerte_workspace/src/face_detection/msg;-Isensor_msgs:/opt/ros/groovy/share/sensor_msgs/msg;-Igeometry_msgs:/opt/ros/groovy/share/geometry_msgs/msg;-Istd_msgs:/opt/ros/groovy/share/std_msgs/msg")

# Find all generators
find_package(gencpp REQUIRED)
find_package(genlisp REQUIRED)
find_package(genpy REQUIRED)

add_custom_target(face_detection_generate_messages ALL)

#
#  langs = gencpp;genlisp;genpy
#

### Section generating for lang: gencpp
### Generating Messages
_generate_msg_cpp(face_detection
  "/home/group11/fuerte_workspace/src/face_detection/msg/ROIArray.msg"
  "${MSG_I_FLAGS}"
  "/opt/ros/groovy/share/sensor_msgs/msg/RegionOfInterest.msg"
  ${CATKIN_DEVEL_PREFIX}/${gencpp_INSTALL_DIR}/face_detection
)

### Generating Services

### Generating Module File
_generate_module_cpp(face_detection
  ${CATKIN_DEVEL_PREFIX}/${gencpp_INSTALL_DIR}/face_detection
  "${ALL_GEN_OUTPUT_FILES_cpp}"
)

add_custom_target(face_detection_generate_messages_cpp
  DEPENDS ${ALL_GEN_OUTPUT_FILES_cpp}
)
add_dependencies(face_detection_generate_messages face_detection_generate_messages_cpp)

# target for backward compatibility
add_custom_target(face_detection_gencpp)
add_dependencies(face_detection_gencpp face_detection_generate_messages_cpp)

# register target for catkin_package(EXPORTED_TARGETS)
list(APPEND ${PROJECT_NAME}_EXPORTED_TARGETS face_detection_generate_messages_cpp)

### Section generating for lang: genlisp
### Generating Messages
_generate_msg_lisp(face_detection
  "/home/group11/fuerte_workspace/src/face_detection/msg/ROIArray.msg"
  "${MSG_I_FLAGS}"
  "/opt/ros/groovy/share/sensor_msgs/msg/RegionOfInterest.msg"
  ${CATKIN_DEVEL_PREFIX}/${genlisp_INSTALL_DIR}/face_detection
)

### Generating Services

### Generating Module File
_generate_module_lisp(face_detection
  ${CATKIN_DEVEL_PREFIX}/${genlisp_INSTALL_DIR}/face_detection
  "${ALL_GEN_OUTPUT_FILES_lisp}"
)

add_custom_target(face_detection_generate_messages_lisp
  DEPENDS ${ALL_GEN_OUTPUT_FILES_lisp}
)
add_dependencies(face_detection_generate_messages face_detection_generate_messages_lisp)

# target for backward compatibility
add_custom_target(face_detection_genlisp)
add_dependencies(face_detection_genlisp face_detection_generate_messages_lisp)

# register target for catkin_package(EXPORTED_TARGETS)
list(APPEND ${PROJECT_NAME}_EXPORTED_TARGETS face_detection_generate_messages_lisp)

### Section generating for lang: genpy
### Generating Messages
_generate_msg_py(face_detection
  "/home/group11/fuerte_workspace/src/face_detection/msg/ROIArray.msg"
  "${MSG_I_FLAGS}"
  "/opt/ros/groovy/share/sensor_msgs/msg/RegionOfInterest.msg"
  ${CATKIN_DEVEL_PREFIX}/${genpy_INSTALL_DIR}/face_detection
)

### Generating Services

### Generating Module File
_generate_module_py(face_detection
  ${CATKIN_DEVEL_PREFIX}/${genpy_INSTALL_DIR}/face_detection
  "${ALL_GEN_OUTPUT_FILES_py}"
)

add_custom_target(face_detection_generate_messages_py
  DEPENDS ${ALL_GEN_OUTPUT_FILES_py}
)
add_dependencies(face_detection_generate_messages face_detection_generate_messages_py)

# target for backward compatibility
add_custom_target(face_detection_genpy)
add_dependencies(face_detection_genpy face_detection_generate_messages_py)

# register target for catkin_package(EXPORTED_TARGETS)
list(APPEND ${PROJECT_NAME}_EXPORTED_TARGETS face_detection_generate_messages_py)


debug_message(2 "face_detection: Iflags=${MSG_I_FLAGS}")


if(gencpp_INSTALL_DIR)
  # install generated code
  install(
    DIRECTORY ${CATKIN_DEVEL_PREFIX}/${gencpp_INSTALL_DIR}/face_detection
    DESTINATION ${gencpp_INSTALL_DIR}
  )
endif()
add_dependencies(face_detection_generate_messages_cpp sensor_msgs_generate_messages_cpp)

if(genlisp_INSTALL_DIR)
  # install generated code
  install(
    DIRECTORY ${CATKIN_DEVEL_PREFIX}/${genlisp_INSTALL_DIR}/face_detection
    DESTINATION ${genlisp_INSTALL_DIR}
  )
endif()
add_dependencies(face_detection_generate_messages_lisp sensor_msgs_generate_messages_lisp)

if(genpy_INSTALL_DIR)
  install(CODE "execute_process(COMMAND \"/usr/bin/python\" -m compileall \"${CATKIN_DEVEL_PREFIX}/${genpy_INSTALL_DIR}/face_detection\")")
  # install generated code
  install(
    DIRECTORY ${CATKIN_DEVEL_PREFIX}/${genpy_INSTALL_DIR}/face_detection
    DESTINATION ${genpy_INSTALL_DIR}
  )
endif()
add_dependencies(face_detection_generate_messages_py sensor_msgs_generate_messages_py)
