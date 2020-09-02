#! /bin/bash

#判断命令是否执行成功
function Judge_Order(){
	echo
	echo
	#判断上一条命令的返回值是否为0，若为0则执行成功，若不为0则执行失败
	if [ $? -eq 0 ];then
		echo "${Order_name}脚本执行成功"
	else 
		echo "${Order_name}脚本执行失败，程序终止"
		exit 1
	fi
	echo
	echo
}
function Judge_Txt()
{
	result=`grep -w -n "${1}" /home/${USER}/.bashrc | cut -d ":" -f1`
	if [ -z "${result}" ];then
		sudo sed -i "\$a\\${1}"  /home/${USER}/.bashrc
	else
		sudo sed -i "${result}c\\${1}"  /home/${USER}/.bashrc
	fi
}
#安装ROS_kinetic
function Install_ROS_kinetic()
{
	Order_name="中国源"
	#设置计算机以接受packages.ros.org中的软件。
	sudo sh -c '. /etc/lsb-release && echo "deb http://mirrors.ustc.edu.cn/ros/ubuntu/ $DISTRIB_CODENAME main" > /etc/apt/sources.list.d/ros-latest.list'
	#执行命令判断是否执行成功方法
	Judge_Order
	Order_name="Key"
	#增加key
	sudo apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net:80 --recv-key 0xB01FA116
	Judge_Order
	#软件更新
	sudo apt-get update --fix-missing -y
	sudo apt-get upgrade --fix-missing -y
	Order_name="ros-kinetic-desktop-full"
	#Desktop-Full安装
	sudo apt-get update
	sudo apt-get install ros-kinetic-desktop-full -y --allow-unauthenticated
	Judge_Order
	Order_name="解决依赖"
	#解决依赖
	if [ -f /etc/ros/rosdep/sources.list.d/20-default.list ];then
		sudo rm -rf /etc/ros/rosdep/sources.list.d/20-default.list
	fi
	sudo rosdep init
	rosdep update
	Judge_Order
	Order_name="环境设置"
	#环境设置
	#echo "source /opt/ros/kinetic/setup.bash" >> ~/.bashrc
	Judge_Txt "source /opt/ros/kinetic/setup.bash"
	Judge_Order
	source ~/.bashrc
	Order_name="rosinstall"
	#安装rosinstall,便利的工具
	sudo apt-get install python-rosinstall -y --allow-unauthenticated
	Judge_Order
	Order_name="turtlebot3依赖包"
	#安装turtlebot3依赖包
	sudo apt-get install ros-kinetic-joy ros-kinetic-teleop-twist-joy ros-kinetic-teleop-twist-keyboard ros-kinetic-laser-proc ros-kinetic-rgbd-launch ros-kinetic-depthimage-to-laserscan ros-kinetic-rosserial-arduino ros-kinetic-rosserial-python ros-kinetic-rosserial-server ros-kinetic-rosserial-client ros-kinetic-rosserial-msgs ros-kinetic-amcl ros-kinetic-map-server ros-kinetic-move-base ros-kinetic-urdf ros-kinetic-xacro ros-kinetic-compressed-image-transport ros-kinetic-rqt-image-view ros-kinetic-gmapping ros-kinetic-navigation ros-kinetic-interactive-markers -y --allow-unauthenticated
	Judge_Order
	Order_name="turtlebot3源码"
	#安装turtlebot3源码
	if [  -d ${Path}/catkin_ws/src/ ];then
		sudo rm -rf ${Path}/catkin_ws
	fi
	mkdir -p ${Path}/catkin_ws/src/ && cd ${Path}/catkin_ws/src/
	if [  -d ${Path}/catkin_ws/src/turtlebot3_msgs ];then
		sudo rm -rf ${Path}/catkin_ws/src/turtlebot3_msgs
	fi
	git clone https://github.com/ROBOTIS-GIT/turtlebot3_msgs.git
	if [  -d ${Path}/catkin_ws/src/turtlebot3 ];then
		sudo rm -rf ${Path}/catkin_ws/src/turtlebot3
	fi
	git clone https://github.com/ROBOTIS-GIT/turtlebot3.git
	#查看pip是否安装
	pip --version
	if [ ! "${?}" -eq 0 ];then
		sudo apt install python-pip -y
		sudo easy_install --upgrade pip
		result=`grep -w -n "from pip import main" /usr/bin/pip | cut -d ":" -f1`
		sudo sed -i "${result}c\\from\ pip\ import\ __main__"  /usr/bin/pip
		result=`grep -w -n "sys.exit(main())" /usr/bin/pip | cut -d ":" -f1`
		sudo sed -i "${result}c\\\ \ \ \ sys.exit(__main__._main())"  /usr/bin/pip
		echo "Pip安装成功！"
	fi
	#如果pip升级出现问题可以使用下列命令解决
	#如果升级出现main错误，可以采取降版本方式解决
	#python -m pip install --upgrade pip==9.0.3 --user
	#可以处理方法为：
	#sudo gedit /usr/bin/pip
	#修改参考网站：https://blog.csdn.net/lyll616/article/details/85090132
	#安装过程中会出现错误，根据错误安装一些python包
	if [[ $(pip show catkin_pkg) == "catkin_pkg" ]];then
		echo "catkin_pkg已安装"
	else 
		sudo pip install catkin_pkg 
		echo "catkin_pkg包安装成功"
	fi
	if [[ $(pip show empy) == "empy" ]];then
		echo "empy已安装"
	else 
		sudo pip install empy
		echo "empy包安装成功"
	fi
	if [[ $(pip show rospkg) == "rospkg" ]];then
		echo "rospkg已安装"
	else 
		sudo pip install rospkg
		echo "rospkg包安装成功"
	fi
	if [[ $(pip show rosinstall-generator) == "rosinstall-generator" ]];then
		echo "rosinstall-generator已安装"
	else 
		sudo pip install rosinstall-generator
		echo "rosinstall-generator包安装成功"
	fi
	#如果是Boost库未找到则执行Boost_Install.sh
	#./Boost_Install.sh
	cd ${Path}/catkin_ws && catkin_make
	Judge_Order
	Order_name="环境设置"
	#环境设置
	#echo "source ${Path}/catkin_ws/devel/setup.bash" >> ~/.bashrc
	Judge_Txt "source ${Path}/catkin_ws/devel/setup.bash"
	Judge_Order
	source ~/.bashrc
	sudo apt autoremove -y
	echo
	echo
	echo "Install_ROS_kinetic方法执行完成！"
	echo
	echo
}
function Install_Gazebo()
{
	cd ${Path}/catkin_ws/src/
	if [ -d ${Path}/catkin_ws/src/turtlebot3_simulations ];then
		sudo rm -rf ${Path}/catkin_ws/src/turtlebot3_simulations
	fi
	Order_name="安装TurtleBot3 Simulation"
	git clone https://github.com/ROBOTIS-GIT/turtlebot3_simulations.git
	Judge_Order
	Order_name="catkin_make"
	cd ${Path}/catkin_ws && catkin_make  
	Judge_Order
	#判断gazebo的模型目录是否存在，若不存在则创建目录，并将Turtlebot3的模型文件，复制到gazebo的模型目录里
	if [ !  -d ${Path}/.gazebo/models/ ];then
		mkdir -p ${Path}/.gazebo/models/
	else
		sudo rm -rf ${Path}/.gazebo
		mkdir -p ${Path}/.gazebo/models/
	fi
	cp -r  ${Path}/catkin_ws/src/turtlebot3_simulations/turtlebot3_gazebo/models/turtlebot3_world ${Path}/.gazebo/models/
	#设置模型参数，指定使用那种机器人型号：burger 
	#echo "export TURTLEBOT3_MODEL=burger" >> ~/.bashrc
	Judge_Txt "export TURTLEBOT3_MODEL=burger"
	source ~/.bashrc
	Order_name="启动世界地图"
	#启动世界地图，默认的空白地图环境中加载Turtlebot3机器人
	#roslaunch turtlebot3_gazebo turtlebot3_empty_world.launch
	Judge_Order
	echo
	echo
	echo "Install_Gazebo方法执行完成！"
	echo
	echo
	echo "准备重启电脑！！！！！！！！！！！！！！！！！"
	#sudo reboot
}
#主函数方法
function Main()
{
	#源网址：http://wiki.ros.org/kinetic/Installation/Ubuntu
	#给当前文件下所有的文件加权限
	for file in $(pwd)/*.sh; do
		echo ${file}
		chmod 755 ${file}
	done
	cd /home/${USER}
	Path=$(pwd)
	Order_name="Demo"
	#echo ${Path}
	#判断Software文件夹是否存在，若不存在，创建文件夹
	if [ ! -d "${Path}/Software" ];then
		mkdir ${Path}/Software
	else
		echo "Software文件夹已经存在"
	fi
	#设置变量Path的值
	Path=${Path}/Software
	if [ -d "${Path}/catkin_ws" ];then
		sudo rm -rf ${Path}/catkin_ws
		echo "catkin_ws文件夹已删除"
	fi
	#执行Install_ROS_kinetic方法
	Install_ROS_kinetic
	#执行Install_Gazebo方法
	Install_Gazebo
}
Main
