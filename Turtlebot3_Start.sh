#! /bin/bash
: << !
#删除保存的log日志文件
sudo rm -rf ~/.roc/log
if [ $? -eq 0 ];then
	echo "log删除成功"
else 
	echo "log删除失败"
	exit 1
fi
!


#杀死相关进程
State=$(pgrep roslaunch)
if [ "${State}" != "" ];then   
	pkill roslaunch
	if [ ${?} -ne 0 ];then
		exit 1
	fi
	while [ "${State}" != "" ]
	do 
		sleep 2s
		State=$(pgrep roslaunch)
	done
	echo "roslaunch进程已结束"
fi
if [  -f "$(pwd)/terminal.txt" ];then
	while read LINE
	do
		kill -9 ${LINE##*:}
		if [ ${?} -ne 0 ];then
			echo "关闭BASH :${LINE##*:} 失败，脚本退出！"
			rm -rf $(pwd)/terminal.txt
			exit 1
		fi
	done < terminal.txt
	rm -rf $(pwd)/terminal.txt
fi
sleep 2s
#打开新窗体，启动世界地图，默认的空白地图环境中加载Turtlebot3机器人
chmod 755 $(pwd)/Turtlebot3_Empty_World.sh
gnome-terminal -x bash -c "sh $(pwd)/Turtlebot3_Empty_World.sh;exec bash"
#CmdState=${?}
sleep 3s
sum=0
State=$(pgrep roslaunch)  
while [ -z "${State}" ]
do 
	sleep 2s
	State=$(pgrep roslaunch)
	let "sum+=1"
	if [ ${sum} -gt 6 ];then
		echo "世界地图启动失败！"
		exit 127
	fi
done

#启动RVIZ可视化
chmod 755 $(pwd)/Turtlebot3_Gazebo_Rviz.sh
gnome-terminal  -x bash -c "sh $(pwd)/Turtlebot3_Gazebo_Rviz.sh;exec bash "
#CmdState=${?}
sum=0
State=$(pgrep rviz)  
while [ -z "${State}" ]
do 
	sleep 2s
	State=$(pgrep rviz)
	let "sum+=1"
	if [ ${sum} -gt 6 ];then
		echo "RVIZ可视化启动失败！"
		exit 127
	fi
done
#打开新窗体，用键盘控制turtlebot3
chmod 755 $(pwd)/Turtlebot3_Teleop.sh
gnome-terminal -x bash -c "sh $(pwd)/Turtlebot3_Teleop.sh;exec bash "

