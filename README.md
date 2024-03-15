# spaceros_robots
Space ROS robots demos - minimal setup


Pull the image:
---------------

```
$ docker pull ghcr.io/traclabs/spaceros_robots:latest
```
If you have trouble pulling the image, chances are, you are not logged in the ghcr.io registry (something Github requires to pull images from its packages). 

Before starting
----------------
If I am going to use graphics tools like Gazebo or Rviz, I often have to run this in the terminal:

```
xhost local:root
```
I think this is only needed if your docker user is root, but I am not sure. Just in case, I usually do this (you only need to do it once). 


Start a container
---------------------
Two options:

1. **Using vscode:** This repository has a .devcontainer folder, so you could open this with vscode and select *Reopen in container* when asked.
2. **Using terminal:** Start a container with name space_robots_container (or whatever name you want):
   ```
   $ docker run -it --name=spaceros_robots_container --env="DISPLAY=$DISPLAY"  --env="QT_X11_NO_MITSHM=1"  --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw"  --env="XAUTHORITY=$XAUTH"  --volume="$XAUTH:$XAUTH"   --net=host --privileged  ghcr.io/traclabs/spaceros_robots:latest  bash
   ```

Open a terminal in the container:
------------------------------------
Two options:

1. **Using vscode:** Go to the *Terminal* option in the menu. Click in *New terminal*, which will open a terminal inside the container.
2. **Using terminal:**
   ```
   $ docker exec -it spaceros_robots_container bash
   ```

To start the mars demo
-----------------------

(Any line here goes in a container's terminal)

1. Start the demo:
   ```
   $ ros2 launch mars_rover mars_rover.launch.py 
   ```
2. Send commands to the rover (one at a time, give it some time, the robot is slow):
   ```  
   $ ros2 service call /move_forward std_srvs/srv/Empty # Move the robot forward 
   $ ros2 service call /move_stop std_srvs/srv/Empty # Stop the robot
   $ ros2 service call /open_arm std_srvs/srv/Empty # Open the tool arm
   $ ros2 service call /close_arm std_srvs/srv/Empty # Close the tool arm
   ```
   Instructions came from the README here: https://github.com/space-ros/docker/tree/main/space_robots

   ![mars_rover_gazebo](https://github.com/traclabs/spaceros_robots/blob/master/docs/images/mars_rover_gazebo.png)

To start the canadarm demo
---------------------------

(Any line here goes in a container's terminal)

1. Start the demo:
   ```
   $ ros2 launch canadarm canadarm.launch.py
   ```
2. Send commands to the arm (takes a while, the arm moves slow):
   ```
   $  ros2 service call /open_arm std_srvs/srv/Empty {} # Open the arm to outstretched pose
   $  ros2 service call /close_arm std_srvs/srv/Empty {} # Arm back to tight pose
   $  ros2 service call /random_arm std_srvs/srv/Empty {} # Move arm to a random pose
   ```
   ![canadarm_gazebo](https://github.com/traclabs/spaceros_robots/blob/master/docs/images/canadarm_gazebo.png)
