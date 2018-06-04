#!/bin/bash

# ubuntu16.04

repository="deb http://repo.yandex.ru/clickhouse/deb/stable/ main/"
version="1.1.54385"
#version=\*

# install ClickHouse
apt-get update && \
apt-get install -y apt-transport-https && \
mkdir -p /etc/apt/sources.list.d && \
echo $repository | tee /etc/apt/sources.list.d/clickhouse.list && \
apt-get update && \
apt-get install --allow-unauthenticated -y clickhouse-server=$version clickhouse-client=$version && \
apt-get install -y ssh && \
rm -rf /var/lib/apt/lists/* /var/cache/debconf && \
apt-get clean

# setup ClickHouse to listen on 127.0.0.1:9000
sed -i 's,<tcp_port>9000</tcp_port>,<tcp_port>9000</tcp_port><listen_host>0.0.0.0</listen_host>,' /etc/clickhouse-server/config.xml && \
sed -i 's,<listen_host>::1</listen_host>,,' /etc/clickhouse-server/config.xml

#echo 'root:root' | chpasswd
#sed -i 's,PermitRootLogin prohibit-password,PermitRootLogin yes,' /etc/ssh/sshd_config

chown -R clickhouse /etc/clickhouse-server/

# ports used by ClickHouse: 9000 8123 9009

#CLICKHOUSE_CONFIG="/etc/clickhouse-server/config.xml"

service clickhouse-server restart
#/etc/init.d/ssh restart && service clickhouse-server restart
#CMD /etc/init.d/ssh start && /usr/bin/clickhouse-server --config=${CLICKHOUSE_CONFIG}
#ENTRYPOINT exec /usr/bin/clickhouse-server --config=${CLICKHOUSE_CONFIG}
