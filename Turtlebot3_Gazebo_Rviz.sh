#! /bin/bash

declare -i bashID
bashID=${$}
echo "The ${0} ID is :${bashID}"
let bashID=bashID-1
echo "The ${0} ID is :${bashID}" >> terminal.txt
#启动RVIZ可视化
roslaunch turtlebot3_gazebo turtlebot3_gazebo_rviz.launch

