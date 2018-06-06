#!/bin/bash

# ubuntu 16.04

# where to get CH from
REPO="deb http://repo.yandex.ru/clickhouse/deb/stable/ main/"
# and what version to get
VERSION="1.1.54385"
#VERSION=\*

set -x

# check should we try to sudo
if [ "$(id -u)" != "0" ]; then
	echo "This script must be run as root, appennding SUDO" 1>&2
	SUDO="sudo"
else
	echo "Looks like root, no need to sudo"
	SUDO=""
fi


# install ClickHouse
$SUDO apt-get update && \
$SUDO apt-get install -y apt-transport-https && \
$SUDO mkdir -p /etc/apt/sources.list.d && \
echo $REPO | $SUDO tee /etc/apt/sources.list.d/clickhouse.list && \
$SUDO apt-get update && \
$SUDO apt-get install --allow-unauthenticated -y clickhouse-server=$VERSION clickhouse-client=$VERSION && \
$SUDO apt-get install -y ssh && \
$SUDO rm -rf /var/lib/apt/lists/* /var/cache/debconf && \
$SUDO apt-get clean

# setup ClickHouse to listen on 127.0.0.1:9000
$SUDO sed -i 's,<tcp_port>9000</tcp_port>,<tcp_port>9000</tcp_port><listen_host>0.0.0.0</listen_host>,' /etc/clickhouse-server/config.xml && \
$SUDO sed -i 's,<listen_host>::1</listen_host>,,' /etc/clickhouse-server/config.xml

#echo 'root:root' | chpasswd
#sed -i 's,PermitRootLogin prohibit-password,PermitRootLogin yes,' /etc/ssh/sshd_config

$SUDO chown -R clickhouse /etc/clickhouse-server/

# ports used by ClickHouse: 9000 8123 9009

#CLICKHOUSE_CONFIG="/etc/clickhouse-server/config.xml"

$SUDO service clickhouse-server restart
#/etc/init.d/ssh restart && service clickhouse-server restart
#CMD /etc/init.d/ssh start && /usr/bin/clickhouse-server --config=${CLICKHOUSE_CONFIG}
#ENTRYPOINT exec /usr/bin/clickhouse-server --config=${CLICKHOUSE_CONFIG}
