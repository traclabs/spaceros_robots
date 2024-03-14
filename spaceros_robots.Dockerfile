################################################
# Pull space-ros base                          #
################################################
FROM osrf/space-ros AS spaceros_robots
ENV DEBIAN_FRONTEND=noninteractive


RUN sudo apt-get update \
  && sudo apt-get install -y python3-rosinstall-generator
# Needed for OpenGL fix for Rviz to display
# && apt-get install -y software-properties-common \
# && add-apt-repository -y ppa:kisak/kisak-mesa \ 
# && apt update \ 
# && apt -y upgrade 
  
# Switch to bash shell
SHELL ["/bin/bash", "-c"]

USER ${USERNAME}
WORKDIR ${HOME_DIR}

# **********************************
# Create a workspace for 
# spaceros_robots's dependencies
# **********************************
WORKDIR ${HOME_DIR}
RUN mkdir -p ${HOME_DIR}/extra_deps_ws
WORKDIR ${HOME_DIR}/extra_deps_ws

# Generate repos file for moveit2 dependencies, excluding packages from Space ROS core.
COPY --chown=${USERNAME}:${USERNAME} ./config/extra_pkgs.txt /tmp/
COPY --chown=${USERNAME}:${USERNAME} ./config/excluded_pkgs.txt /tmp/
RUN rosinstall_generator \
  --rosdistro humble \
  --deps \
  --exclude $(cat /tmp/excluded_pkgs.txt) \
  -- $(cat /tmp/extra_pkgs.txt) \
  > /tmp/extra_generated_pkgs.repos

# Get the repositories required to simulate the robots, but not included in Space ROS
RUN mkdir src && vcs import src < /tmp/extra_generated_pkgs.repos

# Install system dependencies
# Build the dependencies workspace
RUN source ${HOME_DIR}/spaceros/install/setup.bash \
 && rosdep install --from-paths src --ignore-src --rosdistro ${ROSDISTRO} -r -y --skip-keys "console_bridge generate_parameter_library fastcdr fastrtps rti-connext-dds-5.3.1 rmw_connextdds ros_testing rmw_connextdds rmw_fastrtps_cpp rmw_fastrtps_dynamic_cpp composition demo_nodes_py lifecycle rosidl_typesupport_fastrtps_cpp rosidl_typesupport_fastrtps_c ikos diagnostic_aggregator diagnostic_updater joy qt_gui rqt_gui rqt_gui_py" \
 && colcon build --cmake-args -DCMAKE_BUILD_TYPE=Release

# Pull demos repos
RUN mkdir -p ${HOME_DIR}/spaceros_robots_ws
WORKDIR ${HOME_DIR}/spaceros_robots_ws
COPY --chown=${USERNAME}:${USERNAME} ./config/demo_manual_pkgs.repos demo_manual_pkgs.repos
RUN mkdir src && vcs import src < demo_manual_pkgs.repos

# Build the demos workspace
RUN source ${HOME_DIR}/extra_deps_ws/install/setup.bash &&  \
    rosdep install --from-paths src --ignore-src -r -y && \
    colcon build --cmake-args -DCMAKE_BUILD_TYPE=Release && \
    echo '"source ${HOME_DIR}/spaceros_robots_ws/install/setup.bash"' >> ~/.bashrc
        

# Create an empty workdir so user can mount stuff if desired
RUN mkdir -p ${HOME_DIR}/test_ws
WORKDIR ${HOME_DIR}/test_ws
