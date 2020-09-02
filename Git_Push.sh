#! /bin/bash

#判断命令是否执行成功
#${1}:执行的命令语句
function Judge_Order(){
	local status=${?}
	if [ ${#} -eq 3 ];then
		#判断上一条命令的返回值是否为0，若为0则执行成功，若不为0则执行失败
		if [ ${status} -eq 0 ];then
			echo -e "[\033[32m$(date +"%Y-%m-%d %T") Info\033[0m]  ""\033[32m\"${1}\" \033[0m"
		else 
			echo -e "[\033[33m$(date +"%Y-%m-%d %T") Warning\033[0m]  ""\033[33m\"${2}\" \033[0m"
			if [ "${3}" -eq 0 ];then
				exit 127
			fi
		fi	
	else
		echo -e "[\033[31m$(date +"%Y-%m-%d %T") Error\033[0m] ""\033[31mIncorrect function parameter input, the \"Judge_Order()\" is about to terminate execution!\033[0m"
		return 80
	fi
}
#远程提交
function Remote_Push()
{
	echo
	#添加远程仓库 git remote add <名称> <URL>
	git remote add origin ${repository}
	Judge_Order "添加远程仓库成功!" "添加远程仓库失败!" 1
	git push -u origin ${localDirName}
	Judge_Order "推送到远程仓库成功" "推送到远程仓库失败" 0
	echo
}
#本地提交
function Local_Push()
{
	echo 
	read -t 20 -p "Input a text to describe the change:" input
	if [ -z ${input} ];then
		echo
		echo -e "[\033[31m$(date +"%Y-%m-%d %T") Error\033[0m] Your input is timeout!"
		exit 127
	fi
	#将文件的修改、文件的删除、文件的新建，添加到暂存区
	git add -A
	git commit -m "$(date "+%Y-%m-%d %H:%M:%S") : ${input}"	
	echo 
}
function Main(){
	#=======================================================
	#参数更改
	repository=git@github.com:335134701/Turtlebot3.git
	#=======================================================
	localDir=$(pwd)
	localDirName=${localDir##*/}
	git --version >/dev/null 2>&1
	Judge_Order "Git已安装!" "Git未安装!" 0
	git checkout -b ${localDirName}  >/dev/null 2>&1
	if [ ${?} -eq 128 ];then
		git checkout ${localDirName}  >/dev/null 2>&1
		Judge_Order "切换至${localDirName}分支成功!" "切换至${localDirName}分支失败!" 0
	fi
	eval "$(ssh-agent -s)" 
	ssh-add
	git pull origin ${localDirName}
	Judge_Order "获取最新${localDirName}分支成功!" "获取最新${localDirName}分支失败!" 0
	Local_Push
	Remote_Push
}

Main
