#! /bin/bash


#删除保存的log日志文件
if [ -d ~/.ros/log ];then
	sudo rm -rf ~/.ros/log
	if [ $? -eq 0 ];then
		echo "log删除成功"
	else 
		echo "log删除失败"
		exit 1
	fi
fi
#关闭roslaunch程序
State=$(pgrep roslaunch)
if [ -n "${State}" ];then   
	pkill roslaunch
	if [ ${?} -ne 0 ];then
		exit 1
	fi
	while [ -n "${State}" ]
	do 
		sleep 2s
		State=$(pgrep roslaunch)
	done
	echo "roslaunch进程已结束"
fi
#删除terminal.txt文件
if [  -f "$(pwd)/terminal.txt" ];then
	#关闭相关bash
	while read LINE
	do
		kill -9 ${LINE##*:}
		if [ ${?} -ne 0 ];then
			echo "关闭BASH :${LINE##*:} 失败，脚本退出！"
			exit 1
		fi
		done < terminal.txt
	rm -rf $(pwd)/terminal.txt
	echo "$(pwd)/terminal.txt 删除成功，脚本程序结束！"
fi

