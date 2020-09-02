#! /bin/bash

declare -i bashID
bashID=${$}
echo "The ${0} ID is :${bashID}"
let bashID=bashID-1
echo "The ${0} ID is :${bashID}" >> terminal.txt
#用键盘控制turtlebot3
roslaunch turtlebot3_teleop turtlebot3_teleop_key.launch
