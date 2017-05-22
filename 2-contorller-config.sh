#!/bin/bash
###### Openstack-Ocata-Neutron_VXLAN-Ubuntu-16.04-SVK-GIT-MaY-2017 #######
###################################################
#Controller-Node-Installation#
###################################################  
Node_Inst_Start () {
	echo -e  "######\e[92m Starting ---- $1 ---- Installation \e[0m######"
	echo -e "#####\e[31m Update and Upgrade the Server Before starting the Installation \e[0m#####"
	echo -e "#####\e[31m Attach Second HDD to configure Cinder-Volume During Installation \e[0m#####"
	sleep 2
	read -rsp $' ... If Updated \e[92mPress any key\e[0m to Continue OR \e[31mCTRL+C\e[0m to Exit Installation ... \n' -n1 key
}
Key_To_Start () {
	read -rsp $' ... \e[92mPress any key\e[0m to Continue OR \e[31mCTRL+C\e[0m to Exit Installation ... \n' -n1 key
}
Key_To_Exit () {
	read -rsp $' ... \e[92mPress any key\e[0m to Exit ... \n' -n1 key
	exit
}
config_of () {
	echo -e "############  \e[96mConfiguration of \e[0m \e[93m$1\e[0m  ############"
}
Openstack_Service_Inst () {
	echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	echo -e "############  \e[93m$1 Configuration Completed\e[0m  ############\n"
	echo -e "     ...\e[92m Press any key \e[0m... To Start \e[96m $2 \e[0m Configuration ...     "
	read -n1 key
	echo -e "############  \e[96m-----Configuring---$2-----\e[0m  ############"
}
Complete_Reboot () {
	echo -e "############  \e[92m---Installation Completed----\e[0m  ############"
	echo -e "##### ...\e[93m Access the dashboard using a web browser: \e[0m--- \e[96mhttp://$con_ip/horizon\e[0m ...#####"
	sleep 2
	read -rsp $'\e[1;97;45m     ...Press any key to Exit...and...Reboot The Sever After Exit...     \e[0m\n' -n1 key
}
###################################################
echo "" 
sleep 2
if [ -s ops-controller-localrc ]; then
	echo -e "\e[1;96m Entry in Source File \e[0m"
	cat ops-controller-localrc
else
 	echo -e "\e[1;91m Local-Source-File Not Found or Empty , \n Run the script after setting source file \e[0m" 
	sleep 3 
	exit 1 
fi
Key_To_Start
tday=$(date +%d-%b-%Y-%H%M)
source ops-controller-localrc
sleep 2
Node_Inst_Start Controller-Node
sed -i '/network\|controller\|compute/d' /etc/hosts
echo -e " ##### \e[93mSet OPenstack-Host-IP'S\e[0m ##### "
echo -e "$con_ip 	controller\n$net_ip 	network\n$com_ip 	compute\n " >> /etc/hosts
echo -e '###### \e[92mStarting Installation\e[0m ######'
Key_To_Start
sleep 2
###################################################
######Configuration of Chrony-NTP-Server#######
config_of NTP-Server-Chrony
sleep 2
Key_To_Start
sleep 3
cp /etc/chrony/chrony.conf /etc/chrony/chrony.conf.$tday
sleep 2
cat controller-conf/chrony.conf > /etc/chrony/chrony.conf
sleep 2
sed -i "s#\$man_net#${man_net}#g" /etc/chrony/chrony.conf
systemctl restart chrony 
sleep 3
chronyc sources
sleep 2
######Configuration of DataBase#######
config_of DataBase
sleep 3
cat controller-conf/mariadb-server.cnf > /etc/mysql/mariadb.conf.d/99-openstack.cnf
sleep 3
systemctl restart mysql 
sleep 3
mysql_secure_installation
sleep 2
######Configuration of Messaging-Queue#######
config_of Messaging-Queue
sleep 2
rabbitmqctl add_user openstack password
sleep 2
rabbitmqctl set_permissions openstack ".*" ".*" ".*"
sleep 2
cp /etc/memcached.conf /etc/memcached.conf.$tday
sleep 2
cat controller-conf/memcached.conf > /etc/memcached.conf
sleep 2
systemctl restart memcached
echo -e '######  \e[96mDB Creation for All Services\e[0m  #######'
sleep 3
mysql -u root -ppassword<<EOF
CREATE DATABASE keystone;
GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'localhost' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'controller' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%' IDENTIFIED BY 'password';
CREATE DATABASE glance;
GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'localhost' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'controller' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'%' IDENTIFIED BY 'password';
CREATE DATABASE nova_api;
GRANT ALL PRIVILEGES ON nova_api.* TO 'nova'@'localhost' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON nova_api.* TO 'nova'@'controller' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON nova_api.* TO 'nova'@'compute' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON nova_api.* TO 'nova'@'%' IDENTIFIED BY 'password';
CREATE DATABASE nova;
GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'localhost' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'controller' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'compute' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'%' IDENTIFIED BY 'password';
CREATE DATABASE nova_placement;
GRANT ALL PRIVILEGES ON nova_placement.* TO 'nova'@'localhost' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON nova_placement.* TO 'nova'@'controller' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON nova_placement.* TO 'nova'@'compute' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON nova_placement.* TO 'nova'@'%' IDENTIFIED BY 'password';
CREATE DATABASE nova_cell0;
GRANT ALL PRIVILEGES ON nova_cell0.* TO 'nova'@'localhost' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON nova_cell0.* TO 'nova'@'controller' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON nova_cell0.* TO 'nova'@'compute' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON nova_cell0.* TO 'nova'@'%' IDENTIFIED BY 'password';
CREATE DATABASE neutron;
GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'localhost' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'controller' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'%' IDENTIFIED BY 'password';
CREATE DATABASE cinder;
GRANT ALL PRIVILEGES ON cinder.* TO 'cinder'@'localhost' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON cinder.* TO 'cinder'@'controller' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON cinder.* TO 'cinder'@'%' IDENTIFIED BY 'password';
FLUSH PRIVILEGES;
EOF
sleep 5
echo -e " \e[92m########## --------Created DB for Various OpenStack Services---------##########\e[0m"
##########################################################
#KEYSTONE Installation
##########################################################
echo -e " ##########\e[96m --------Configuring----Keystone-------- \e[0m##########"
sleep 2
Key_To_Start
sleep 2
cp /etc/keystone/keystone.conf /etc/keystone/keystone.conf.$tday
sleep 3
cat controller-conf/keystone.conf > /etc/keystone/keystone.conf
sleep 3
su -s /bin/bash keystone -c "keystone-manage db_sync" 
sleep 3
keystone-manage fernet_setup --keystone-user keystone --keystone-group keystone
sleep 3
keystone-manage credential_setup --keystone-user keystone --keystone-group keystone
sleep 3
keystone-manage bootstrap --bootstrap-password 0penstack \
--bootstrap-admin-url http://controller:35357/v3/ \
--bootstrap-internal-url http://controller:35357/v3/ \
--bootstrap-public-url http://controller:5000/v3/ \
--bootstrap-region-id RegionOne
sleep 3
echo "ServerName controller" >> /etc/apache2/apache2.conf
sleep 2
rm -f /var/lib/keystone/keystone.db
sleep 2
systemctl restart apache2
sleep 5
export OS_PROJECT_DOMAIN_NAME=default
export OS_USER_DOMAIN_NAME=default
export OS_PROJECT_NAME=admin
export OS_USERNAME=admin
export OS_PASSWORD=0penstack
export OS_AUTH_URL=http://controller:35357/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2
sleep 3

openstack project create --domain default --description "Service Project" service
sleep 3

openstack project create --domain default --description "Demo Project" demo
sleep 3
openstack user create --domain default --project demo --password 123456 demo
sleep 3
openstack role create user
sleep 3
openstack role add --project demo --user demo user
sleep 3

unset OS_URL 
sleep 3
echo -e 'export OS_PROJECT_DOMAIN_NAME=default
export OS_USER_DOMAIN_NAME=default
export OS_PROJECT_NAME=admin
export OS_USERNAME=admin
export OS_PASSWORD=0penstack
export OS_AUTH_URL=http://controller:35357/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2
export OS_VOLUME_API_VERSION=2'>/root/adminrc
sleep 5
source /root/adminrc
sleep 5
echo "source /root/adminrc " >> /root/.bashrc
sleep 3
echo -e 'export OS_PROJECT_DOMAIN_NAME=default
export OS_USER_DOMAIN_NAME=default
export OS_PROJECT_NAME=demo
export OS_USERNAME=demo
export OS_PASSWORD=123456
export OS_AUTH_URL=http://controller:35357/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2
export OS_VOLUME_API_VERSION=2'>/root/demorc
sleep 3
echo -e "#########\e[95m openstack token issue \e[0m#########"
openstack token issue
echo -e "#########\e[95m openstack user list \e[0m#########"
openstack user list
echo -e "#########\e[95m openstack project list \e[0m#########"
openstack project list
sleep 3
echo -e "#########\e[96m Creating User,Service,Endpoint for Various Openstack Services \e[0m#########"
sleep 2
Key_To_Start
sleep 3
openstack user create --domain default --project service --password password glance
sleep 3
openstack role add --project service --user glance admin
sleep 3
openstack service create --name glance --description "OpenStack Image service" image
sleep 3
openstack endpoint create --region RegionOne image public http://controller:9292
sleep 3
openstack endpoint create --region RegionOne image internal http://controller:9292
sleep 3
openstack endpoint create --region RegionOne image admin http://controller:9292
sleep 3

openstack user create --domain default --project service --password password nova
sleep 3
openstack role add --project service --user nova admin
sleep 3
openstack service create --name nova --description "OpenStack Compute" compute
sleep 3
openstack endpoint create --region RegionOne compute public http://controller:8774/v2.1/%\(tenant_id\)s
sleep 3
openstack endpoint create --region RegionOne compute internal http://controller:8774/v2.1/%\(tenant_id\)s
sleep 3
openstack endpoint create --region RegionOne compute admin http://controller:8774/v2.1/%\(tenant_id\)s
sleep 3
openstack user create --domain default --project service --password password placement
sleep 3
openstack role add --project service --user placement admin
sleep 3
openstack service create --name placement --description "OpenStack Compute Placement service" placement
sleep 3
openstack endpoint create --region RegionOne placement public http://controller:8778 
sleep 3
openstack endpoint create --region RegionOne placement internal http://controller:8778 
sleep 3
openstack endpoint create --region RegionOne placement admin http://controller:8778 
sleep 3

openstack user create --domain default --project service --password password  neutron
sleep 3
openstack role add --project service --user neutron admin
sleep 3
openstack service create --name neutron --description "OpenStack Networking" network
sleep 3
openstack endpoint create --region RegionOne network public http://controller:9696
sleep 3
openstack endpoint create --region RegionOne network internal http://controller:9696
sleep 3
openstack endpoint create --region RegionOne network admin http://controller:9696

openstack user create --domain default --project service --password password cinder
sleep 3
openstack role add --project service --user cinder admin
sleep 3
openstack service create --name cinder --description "OpenStack Block Storage" volume
sleep 3
openstack service create --name cinderv2 --description "OpenStack Block Storage" volumev2
sleep 3
openstack endpoint create --region RegionOne volume public http://controller:8776/v1/%\(tenant_id\)s
sleep 3
openstack endpoint create --region RegionOne volume internal http://controller:8776/v1/%\(tenant_id\)s
sleep 3
openstack endpoint create --region RegionOne volume admin http://controller:8776/v1/%\(tenant_id\)s
sleep 3
openstack endpoint create --region RegionOne volumev2 public http://controller:8776/v2/%\(tenant_id\)s
sleep 3
openstack endpoint create --region RegionOne volumev2 internal http://controller:8776/v2/%\(tenant_id\)s
sleep 3
openstack endpoint create --region RegionOne volumev2 admin http://controller:8776/v2/%\(tenant_id\)s
sleep 3
openstack user list
sleep 3
openstack service list
sleep 3
##########################################################
#GLANCE Installation   
##########################################################
Openstack_Service_Inst KEYSTONE GLANCE
sleep 1
cp /etc/glance/glance-api.conf /etc/glance/glance-api.conf.$tday
cp /etc/glance/glance-registry.conf /etc/glance/glance-api.conf.$tday
cat controller-conf/glance-api.conf > /etc/glance/glance-api.conf
cat controller-conf/glance-registry.conf > /etc/glance/glance-registry.conf
sleep 3
su -s /bin/bash glance -c "glance-manage db_sync" 
sleep 3
systemctl restart glance-api
sleep 3
systemctl restart glance-registry 
sleep 3
rm -f /var/lib/glance/glance.sqlite

##########################################################
#NOVA Installation    
##########################################################
Openstack_Service_Inst GLANCE NOVA
sleep 1
cp /etc/nova/nova.conf /etc/nova/nova.conf.$tday
cat controller-conf/nova.conf > /etc/nova/nova.conf
sleep 3
sed -i "s/\$con_ip/${con_ip}/g" /etc/nova/nova.conf
sleep 3
su -s /bin/bash nova -c "nova-manage api_db sync" 
sleep 3
su -s /bin/bash nova -c "nova-manage cell_v2 map_cell0 --database_connection mysql+pymysql://nova:password@controller/nova_cell0"
sleep 3
su -s /bin/bash nova -c "nova-manage db sync"
sleep 3
su -s /bin/bash nova -c "nova-manage cell_v2 create_cell --name cell1 \
--database_connection mysql+pymysql://nova:password@controller/nova \
--transport-url rabbit://openstack:password@controller:5672"
sleep 3
rm -f /var/lib/nova/nova.sqlite
sleep 3
systemctl restart apache2 
sleep 3
echo -e 'for i in nova-{api,conductor,scheduler,cert,consoleauth,novncproxy}\ndo\n systemctl $1 $i\ndone' > /root/novaser.sh
sleep 1
chmod +x /root/novaser.sh
sleep 2
/root/novaser.sh restart
sleep 3
source /root/adminrc
echo -e "#########\e[95m openstack compute service list \e[0m#########"
openstack compute service list
sleep 2

##########################################################
#NEUTRON Installation 
##########################################################
Openstack_Service_Inst NOVA NEUTRON
sleep 1
cp /etc/sysctl.conf /etc/sysctl.conf.$tday
sleep 1
cat controller-conf/sysctl.conf  > /etc/sysctl.conf 
sleep 1
cp /etc/neutron/neutron.conf /etc/neutron/neutron.conf.$tday
sleep 1
cat controller-conf/neutron.conf > /etc/neutron/neutron.conf
sleep 3
cp /etc/neutron/plugins/ml2/ml2_conf.ini /etc/neutron/plugins/ml2/ml2_conf.ini.$tday
sleep 1
cat controller-conf/ml2_conf.ini > /etc/neutron/plugins/ml2/ml2_conf.ini
sleep 1
ln -s /etc/neutron/plugins/ml2/ml2_conf.ini /etc/neutron/plugin.ini 
sleep 1
su -s /bin/bash neutron -c "neutron-db-manage --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugin.ini upgrade head"
sleep 3
rm -f /var/lib/neutron/neutron.sqlite
sleep 1
systemctl start neutron-server 
sleep 1
systemctl enable neutron-server 
sleep 1
systemctl restart nova-api 
sleep 3
echo -e "#########\e[95m openstack network agent list \e[0m#########"
openstack network agent list 
sleep 3
##########################################################
#HORIZON Installation
##########################################################
Openstack_Service_Inst NEUTRON HorizoN
sleep 1
cp /etc/openstack-dashboard/local_settings.py /etc/openstack-dashboard/local_settings.py.$tday
sleep 3
cat controller-conf/local_settings.py > /etc/openstack-dashboard/local_settings.py
sleep 3
chown www-data /var/lib/openstack-dashboard/secret_key
sleep 3
systemctl restart apache2 memcached 
sleep 3
##########################################################
#CINDER Installation 
##########################################################
Openstack_Service_Inst HorizoN CINDER
sleep 1
cp /etc/cinder/cinder.conf /etc/cinder/cinder.conf.$tday
sleep 3
cat controller-conf/cinder.conf > /etc/cinder/cinder.conf
sleep 3
sed -i "s/\$con_ip/${con_ip}/g" /etc/cinder/cinder.conf
sleep 3
su -s /bin/bash cinder -c "cinder-manage db sync" 
sleep 3
rm -f /var/lib/cinder/cinder.sqlite
sleep 3
sleep 3
echo -e "\e[1;92m List of Detected HDD \e[0m\n \e[1;96m$(lsblk -o NAME,SIZE)\e[0m"
sleep 3
echo -en "\e[1;96m Enter Cinder-HDD Name \e[0m ( Like sdb or xvdb ) : "
read cin_hdd
sleep 3
pvcreate /dev/$cin_hdd
sleep 3
vgcreate cinder-volumes /dev/$cin_hdd
sleep 3
systemctl restart nova-api tgt cinder-scheduler cinder-volume apache2
sleep 3
openstack volume service list 
sleep 2
######### Local Script For Checking Openstack Logs and Service Status #########
echo -e "###\e[96m Creating Local Script For Checking Openstack Logs and Service Status \e[0m ###"
echo -e 'for i in glance-api glance-registry apache2 memcached neutron-server\ndo\nsystemctl $1 $i\ndone'>/root/op-ser.sh
chmod +x /root/op-ser.sh
sleep 3
echo -e 'for i in tgt cinder-{scheduler,volume}\ndo\nsystemctl $1 $i\ndone'>/root/cinder-ser.sh
chmod +x /root/cinder-ser.sh
sleep 3
echo -e 'for i in $(ls /var/log/{nova,cinder,neutron}/*)\ndo\n>$i\ndone' > cleanlog.sh
chmod +x cleanlog.sh
sleep 3
echo -e 'grep -i error /var/log/{glance,cinder,nova,neutron}/*.log ' > /root/errlogcheck
chmod +x /root/errlogcheck
sleep 3
echo 'egrep -v "^\s*#|^\s*;|^$" $1 $2' > /bin/uv 
chmod +x /bin/uv
##########################################################
sleep 2
echo -e "######\e[93m Creating CirrOS image \e[0m#############"
mkdir /root/images
sleep 2
wget -P /root/images http://download.cirros-cloud.net/0.3.4/cirros-0.3.4-x86_64-disk.img
sleep 2
source /root/adminrc
sleep 2
openstack image create "cirros" --file /root/images/cirros-0.3.4-x86_64-disk.img --disk-format qcow2 --container-format bare --public
sleep 2
openstack image list
echo -e "######\e[93m Creating a test Volume of size 5GB\e[0m#############"
sleep 2
Key_To_Start
source /root/adminrc
openstack volume create --size 5 Test-VoL-1
sleep 3
openstack volume list 
Complete_Reboot
sleep 3
exit
##########################################################
##########################################################
