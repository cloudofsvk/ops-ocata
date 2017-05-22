#!/bin/bash
###### Openstack-Ocata-Neutron_VXLAN-Ubuntu-16.04-SVK-GIT-MaY-2017 #######
###################################################
#Controller-Node-Installation#
################################################### 
Key_To_Start () {
	read -rsp $' ... \e[92mPress any key\e[0m to Continue OR \e[31mCTRL+C\e[0m to Exit Installation ... \n' -n1 key
}
Key_To_Exit () {
	read -rsp $' ... \e[92mPress any key\e[0m to Exit ... \n' -n1 key
	exit
}
###################################################
echo "" 
echo -e "############\e[1;96m Installing Various Openstack-Packages for Controller Node\e[0m ############"
Key_To_Start
apt install -y curl wget
sleep 2
apt -y install software-properties-common
sleep 1
add-apt-repository cloud-archive:ocata
sleep 1
apt update
sleep 2
apt install -y python-openstackclient
apt install -y chrony
apt install -y mariadb-server python-pymysql
sleep 3
apt install -y rabbitmq-server
sleep 3
apt install -y keystone apache2 libapache2-mod-wsgi memcached python-memcache python-oauth2client 
sleep 3
apt install -y glance python-glanceclient
apt install -y nova-api nova-placement-api nova-cert nova-conductor nova-consoleauth nova-scheduler nova-novncproxy python-novaclient
apt install -y neutron-server neutron-plugin-ml2 python-neutronclient
apt install -y openstack-dashboard
sleep 3
apt install -y cinder-api cinder-scheduler cinder-volume python-cinderclient python-mysqldb 
# Double check all packages are installed
sleep 3
apt install python-openstackclient chrony mariadb-server python-pymysql rabbitmq-server \
keystone apache2 libapache2-mod-wsgi memcached python-memcache python-oauth2client \
glance python-glanceclient \
nova-api nova-placement-api nova-cert nova-conductor nova-consoleauth nova-scheduler nova-novncproxy python-novaclient \
neutron-server neutron-plugin-ml2 python-neutronclient \
openstack-dashboard \
cinder-api cinder-scheduler cinder-volume python-cinderclient python-mysqldb 
sleep 3
echo -e "############\e[1;96m Installed Various Openstack-Packages on Controller Node\e[0m ############"
Key_To_Exit
###################################################
