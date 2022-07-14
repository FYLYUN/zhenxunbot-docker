#! /bin/bash
###
 # @Author: 源源圆球 1340793687@outlook.com
 # @Date: 2022-06-03 22:20:16
 # @LastEditors: 源源圆球 1340793687@outlook.com
 # @LastEditTime: 2022-06-04 19:40:48
 # @FilePath: /docker/files/docker-entrypoint.sh
 # @Description: 每次启动容器的时候运行
 # 
 # Copyright (c) 2022 by 源源圆球 1340793687@outlook.com, All Rights Reserved. 
### 
set -e

if [ -f "/home/config.sh" ];then
	bash /home/config.sh
	rm -f /home/config.sh
else
	echo -e "\033[33m不是第一次运行,不进行设置\033[0m"
fi
if [ -d "/home/zhenxun_bot/extensive_plugin/update" ];then
	if [ -f "/home/zhenxun_bot/extensive_plugin/update/session.token" ];then
		echo -e "\033[33m检测到新的账号令牌，替换已有账号令牌\033[0m"
		cp -rf /home/zhenxun_bot/extensive_plugin/update/session.token /home/go-cqhttp/session.token
	fi
	if [ -f "/home/zhenxun_bot/extensive_plugin/update/device.json" ];then
		echo -e "\033[33m检测到新的设备标识，替换已有设备标识\033[0m"
		cp -rf /home/zhenxun_bot/extensive_plugin/update/device.json /home/go-cqhttp/device.json
	fi
	if [ -f "/home/zhenxun_bot/extensive_plugin/update/config.yml" ];then
		echo -e "\033[33m检测到新的设置文件，替换已有设置文件\033[0m"
		cp -rf /home/zhenxun_bot/extensive_plugin/update/config.yml /home/go-cqhttp/config.yml
	fi
	if [ -f "/home/zhenxun_bot/extensive_plugin/update/config.py" ];then
		echo -e "\033[33m检测到新的真寻设置文件，替换已有设置文件\033[0m"
		cp -rf /home/zhenxun_bot/extensive_plugin/update/config.py /home/zhenxun_bot/configs/config.py
	fi
	if [ -f "/home/zhenxun_bot/extensive_plugin/update/config.yaml" ];then
		echo -e "\033[33m检测到新的真寻插件设置文件，替换已有设置文件\033[0m"
		cp -rf /home/zhenxun_bot/extensive_plugin/update/config.yaml /home/zhenxun_bot/configs/config.yaml
	fi
	rm -rf /home/zhenxun_bot/extensive_plugin/update 
fi
if [ -d "/home/zhenxun_bot/extensive_plugin/zxfile" ];then
	cp -rf /home/go-cqhttp/session.token /home/zhenxun_bot/extensive_plugin/zxfile/session.token
	cp -rf /home/go-cqhttp/device.json /home/zhenxun_bot/extensive_plugin/zxfile/device.json
	cp -rf /home/go-cqhttp/config.yml /home/zhenxun_bot/extensive_plugin/zxfile/config.yml
	cp -rf /home/zhenxun_bot/configs/config.py /home/zhenxun_bot/extensive_plugin/zxfile/config.py
	cp -rf /home/zhenxun_bot/configs/config.yaml /home/zhenxun_bot/extensive_plugin/zxfile/config.yaml
fi
/etc/init.d/postgresql start
echo -e "\033[32m✔Postgresql 开始运行\033[0m"
sleep 3s

cd /home/go-cqhttp
nohup /home/go-cqhttp/go-cqhttp -faststart >> /home/zhenxun_bot/extensive_plugin/gocq.log 2>&1 &
echo -e "\033[32m✔go-cqhttp 开始运行\033[0m，详细日志请到 ~/extensive_plugin/gocq.log 查看"
sleep 3s

cd /home/zhenxun_bot
echo -e "\033[32m✔准备启动 bot\033[0m"
sleep 3s

python /home/zhenxun_bot/bot.py

exec $@
