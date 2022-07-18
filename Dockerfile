FROM bitnami/git as Git-Clone
WORKDIR /usr/local/code
RUN git clone https://github.com/HibiKier/zhenxun_bot.git

###############################################################################

FROM python:3.9-slim-bullseye as Python-Whl-Builder
#更换国内apt源
RUN mv /etc/apt/sources.list /etc/apt/sources.list.bak && \
echo "deb http://mirrors.ustc.edu.cn/debian stable-updates main contrib non-free" >>/etc/apt/sources.list && \
echo "deb http://mirrors.ustc.edu.cn/debian stable main contrib non-free" >>/etc/apt/sources.list && \
#安装依赖
apt update && apt install -y --no-install-recommends gcc libc6-dev  && \
#更换国内pip源
pip install -i https://pypi.douban.com/simple/ -U pip && \
pip config set global.index-url https://pypi.douban.com/simple/ && \
#安装依赖
pip install -r https://www.lyun.me/requirements.txt && \
pip install rich requests jinja2 thefuzz aiocache baike imageio

##############################################################################

FROM python:3.9-slim-bullseye as Python-ENV
WORKDIR /home
#拷贝git下载的东西
COPY --from=Git-Clone /usr/local/code /home
#拷贝安装好的python依赖
COPY --from=Python-Whl-Builder /usr/local/lib/python3.9/site-packages /usr/local/lib/python3.9/site-packages
COPY --from=Python-Whl-Builder /usr/local/bin/playwright /usr/local/bin/playwright
#拷贝预先准备好的文件
COPY files /home
COPY docker-entrypoint.sh /
#环境变量
#ENV bot_qq=$bot_qq
#ENV bot_qq_key=$bot_qq_key
#ENV SU=$SU
#ENV webui_passwd=$webui_passwd
#ENV webui_user=$webui_user
#ENV api_key=$api_key
#ENV DB=$DB
#ENV DB_ROOT=$DB_ROOT

# apt安装依赖
RUN  mv /etc/apt/sources.list /etc/apt/sources.list.bak && \
echo "deb http://mirrors.ustc.edu.cn/debian stable-updates main contrib non-free" >>/etc/apt/sources.list && \
echo "deb http://mirrors.ustc.edu.cn/debian stable main contrib non-free" >>/etc/apt/sources.list && apt update && \
apt upgrade -y && \
apt install -y --no-install-recommends \
#解决重启BUG
net-tools \
#PostgreSQL数据库
postgresql \
postgresql-contrib \
#BOT运行需要的依赖
ffmpeg \
libgl1 \
libnss3 \
libatk1.0-0 \
libatk-bridge2.0-0 \
libcups2 \
libxcomposite1 \
#screen，用于后台运行gocq
screen \
#中文字体，解决原神黄历方块字问题
fonts-wqy-microhei && \
#安装chromium，免得每次重装都要重新安装
playwright install chromium && \
playwright install-deps chromium && \
#清缓存
apt clean && \
#恢复源
mv /etc/apt/sources.list.bak /etc/apt/sources.list && \
# 调时区
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
echo 'Asia/Shanghai' > /etc/timezone
#声明匿名卷，保证最重要的数据库不会丢失
VOLUME /var/lib/postgresql

ENTRYPOINT ["/docker-entrypoint.sh"]