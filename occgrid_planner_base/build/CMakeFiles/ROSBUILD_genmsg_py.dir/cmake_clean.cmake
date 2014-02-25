FILE(REMOVE_RECURSE
  "../msg_gen"
  "../msg_gen"
  "../src/occgrid_planner_base/msg"
  "CMakeFiles/ROSBUILD_genmsg_py"
  "../src/occgrid_planner_base/msg/__init__.py"
  "../src/occgrid_planner_base/msg/_Trajectory.py"
  "../src/occgrid_planner_base/msg/_TrajectoryElement.py"
)

# Per-language clean rules from dependency scanning.
FOREACH(lang)
  INCLUDE(CMakeFiles/ROSBUILD_genmsg_py.dir/cmake_clean_${lang}.cmake OPTIONAL)
ENDFOREACH(lang)
