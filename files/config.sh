#! /bin/bash
###
 # @Author: 源源圆球 1340793687@outlook.com
 # @Date: 2022-06-03 22:20:16
 # @LastEditors: 源源圆球 1340793687@outlook.com
 # @LastEditTime: 2022-06-04 18:43:37
 # @FilePath: /docker/files/config.sh
 # @Description: 在首次运行容器时更改一些配置
 # 
 # Copyright (c) 2022 by 源源圆球 1340793687@outlook.com, All Rights Reserved. 
### 
set -e

#只是判断了，没有做出回应，等一个有缘人帮我完善
#if [ ! "$bot_qq" ];then
#    echo -e "\033[31m未设置 bot 使用的 QQ 号\033[0m"
#fi
#if [ ! "$bot_qq_key" ];then
#    echo -e "\033[31m未设置 bot 的 QQ 号密码\033[0m"
#fi
if [ ! "$SU" ];then
    echo -e "\033[31m未设置超级管理员 QQ 号\033[0m"
fi
##设置数据库相关内容
if [ ! "$DB" ];then
    echo -e "\033[31m未设置数据库链接,设置为默认值\033[0m"
	DB="postgresql://meimei:meiboli@127.0.0.1:5432/zhenxun"
fi
if [ ! "$DB_ROOT" ];then
    echo -e "\033[31m未设置数据库ROOT密码,设置为默认值\033[0m"
	DB_ROOT=sdfSDF45sdfg45SD
fi
if [ ! "$GOCQ" ];then
    echo -e "\033[33m使用容器自带的go-cqhttp\033[0m"
else 
	cqipt=${GOCQ#*//}
	cqipt=${cqipt%%/*}
	cqip=${cqipt%%:*}
	cqpt=${cqipt#*:}
	if [ ! "$cqip" ];then
		cqip="127.0.0.1"
	else
		sed -i 's|HOST = .*|''HOST = '$cqip'|g' /home/zhenxun_bot/.env.dev
	fi
	if [ ! "$cqpt" ];then
		cqpt="8080"
	else
		sed -i 's|PORT = .*|''PORT = '$cqpt'|g' /home/zhenxun_bot/.env.dev
	fi
	echo -e "已设置服务器IP与端口为$cqip:$cqpt"
fi
ip=${DB#*@}
ip=${ip%%:*}
up=${DB#*//}
up=${up%%@*}
user=${up%%:*}
pw=${up#*:}
db_name=${DB#*5432/}

#sed -i 's/xxxxxx/'$bot_qq'/g' /home/go-cqhttp/config.yml
#echo -e "已设置BOT的QQ号为"$bot_qq
#sed -i 's/yyyyyy/'$bot_qq_key'/g' /home/go-cqhttp/config.yml
#echo -e "已设置BOT的QQ密码为"$bot_qq_key
sed -i '3c SUPERUSERS=["'$SU'"]' /home/zhenxun_bot/.env.dev
echo -e "已设置超级管理员的QQ为"$SU
sed -i 's|bind: str = \"\"|''bind: str = \"'$DB'\"|g' /home/zhenxun_bot/configs/config.py
echo -e "已设置数据库链接为"$DB
echo -e "请确保你的数据库信息没有问题，否则会连不上数据库！"
#因为变量里有/，所以不能用/分隔符，否则会报错，故换成|分隔符

if [ ! -d "/home/zhenxun_bot/extensive_plugin/go-cqhttp" ];then
	mkdir /home/zhenxun_bot/extensive_plugin/go-cqhttp >/dev/null 2>&1
	echo -e "已添加/home/zhenxun_bot/extensive_plugin/go-cqhttp目录"
fi
#sed -i '14a nonebot.load_plugins("extensive_plugin")' ./zhenxun_bot/bot.py
#echo -e "已添加自定义插件目录 extensive_plugin 配置"

get_arch=`arch`
if [[ $get_arch =~ "x86_64" ]];then
	if [ -f "/home/go-cqhttp/go-cqhttp-amd64" ];then
		mv /home/go-cqhttp/go-cqhttp-amd64 /usr/bin/go-cqhttp
		rm -rf /home/go-cqhttp
	fi
    echo -e "\033[34m检测到你的设备是amd64架构\033[0m"
elif [[ $get_arch =~ "aarch64" ]];then
	if [ -f "/home/go-cqhttp/go-cqhttp-arm64" ];then
		mv /home/go-cqhttp/go-cqhttp-arm64 /usr/bin/go-cqhttp
		rm -f /home/go-cqhttp
	fi
    echo -e "\033[34m检测到你的设备是arm64架构\033[0m"
fi

cat > /tmp/sql.sql <<-EOF
CREATE USER $user WITH PASSWORD '$pw';
CREATE DATABASE $db_name OWNER $user;
CREATE ROLE root superuser PASSWORD '$DB_ROOT' login;
EOF

/etc/init.d/postgresql start >/dev/null 2>&1
su postgres -c "psql -f /tmp/sql.sql" >/dev/null 2>&1
echo -e "\033[34m已创建数据库\033[0m"

if [ -f "/home/zhenxun_bot/extensive_plugin/zhenxun.sql" ]; then
    echo -e "检测到数据库文件,开始导入"
    sleep 2s
	psql zhenxun < /home/zhenxun_bot/extensive_plugin/zhenxun.sql >/dev/null 2>&1
#    su postgres -c "psql -U $user -d $db_name < /home/zhenxun_bot/extensive_plugin/zhenxun.sql" >/dev/null 2>&1
    echo -e "\033[32m✔已导入数据库\033[0m"
	nowtime=$(date "+%Y-%m-%d-%H-%M-%S")
	mv /home/zhenxun_bot/extensive_plugin/zhenxun.sql /home/zhenxun_bot/extensive_plugin/zhenxun_"$nowtime".sql
else 
    echo -e "\033[33m没有检测到数据库文件,不导入旧数据库\033[0m"
fi

echo -e "\033[32m✔已完成新容器配置,5秒后自动继续\033[0m"
sleep 5s