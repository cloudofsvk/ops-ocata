#!/bin/bash
###### Openstack-Ocata-Neutron_VXLAN-Ubuntu-16.04-SVK-GIT-MaY-2017 #######
###################################################
# Compute-Node-Configuration #
###################################################  
Node_Inst_Start () {
	echo -e  "######\e[92m Starting ---- $1 ---- Configuration \e[0m######"
	sleep 2
	read -rsp $' ... \e[92mPress any key\e[0m to Continue OR \e[31mCTRL+C\e[0m to Exit Configuration ... \n' -n1 key
} 
Key_To_Start () {
	read -rsp $' ... \e[92mPress any key\e[0m to Continue OR \e[31mCTRL+C\e[0m to Exit Configuration ... \n' -n1 key
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
	echo -e "############  \e[92m---Configuration Completed----\e[0m  ############"
	echo -e "##### ...\e[93m Access the dashboard using a web browser: \e[0m--- \e[96mhttp://$con_ip/horizon\e[0m ...#####"
	sleep 2
	read -rsp $'\e[1;97;44m     ...Press any key to Exit...and...Reboot The Sever After Exit...     \e[0m\n' -n1 key
}
###################################################
echo "" 
sleep 2
if [ -s ops-compute-localrc ]; then
	echo -e "\e[1;96m Entry in Source File \e[0m"
	cat ops-compute-localrc
else
 	echo -e "\e[1;91m Local-Source-File Not Found or Empty , \n Run the script after setting source file \e[0m" 
	sleep 3 
	exit 1 
fi
tday=$(date +%d-%b-%Y-%H%M)
source ops-compute-localrc
sleep 2
Node_Inst_Start Compute-Node
sed -i '/network\|controller\|compute/d' /etc/hosts
echo -e " ##### \e[93m Adding OPenstack-Host-IP'S to /etc/hosts file\e[0m ##### "
echo -e "$con_ip 	controller\n$net_ip 	network\n$com_ip 	compute\n " >> /etc/hosts
echo -e '###### \e[92m Starting Configuration\e[0m ######'
sleep 2
###################################################
######Enable IP Forwarding#######
echo -e "######\e[96m  Configuring IP Forwarding  \e[0m######"
cp /etc/sysctl.conf /etc/sysctl.conf.$tday
cat compute-conf/sysctl.conf > /etc/sysctl.conf
sleep 3
sysctl -p
sleep 3
######Configuration of Chrony-NTP-Server#######
config_of NTP-Server-Chrony
sleep 2
Key_To_Start
sleep 3
cp /etc/chrony/chrony.conf /etc/chrony/chrony.conf.$tday
sleep 2
cat compute-conf/chrony.conf > /etc/chrony/chrony.conf
sleep 2
systemctl restart chrony 
sleep 3
chronyc sources
sleep 2

##########################################################
# Compute-Node Configuration  
##########################################################
Openstack_Service_Inst Basic-System NOVA
sleep 1
cp /etc/nova/nova.conf /etc/nova/nova.conf.$tday
cp /etc/nova/nova-compute.conf /etc/nova/nova-compute.conf.$tday
cp /etc/neutron/neutron.conf /etc/neutron/neutron.conf.$tday
cp /etc/neutron/plugins/ml2/ml2_conf.ini  /etc/neutron/plugins/ml2/ml2_conf.ini.$tday 
cp /etc/neutron/plugins/ml2/linuxbridge_agent.ini /etc/neutron/plugins/ml2/linuxbridge_agent.ini.$tday
sleep 1
cat compute-conf/nova.conf > /etc/nova/nova.conf
sed -i "s/\$com_ip/${com_ip}/g" /etc/nova/nova.conf
cat compute-conf/nova-compute.conf > /etc/nova/nova-compute.conf
sleep 1

cat compute-conf/neutron.conf > /etc/neutron/neutron.conf
sleep 2
cat compute-conf/ml2_conf.ini > /etc/neutron/plugins/ml2/ml2_conf.ini 
sleep 2
cat compute-conf/linuxbridge_agent.ini > /etc/neutron/plugins/ml2/linuxbridge_agent.ini
sleep 2
sed -i "s/\$extdev/${extdev}/g" /etc/neutron/plugins/ml2/linuxbridge_agent.ini
sed -i "s/\$tunnel_ip/${com_ip}/g" /etc/neutron/plugins/ml2/linuxbridge_agent.ini
sleep 2
ln -s /etc/neutron/plugins/ml2/ml2_conf.ini /etc/neutron/plugin.ini 
sleep 2
rm -rf /var/lib/nova/nova.sqlite
sleep 2
systemctl restart nova-compute neutron-linuxbridge-agent
sleep 2
echo -e 'export OS_PROJECT_DOMAIN_NAME=default
export OS_USER_DOMAIN_NAME=default
export OS_PROJECT_NAME=admin
export OS_TENANT_NAME=admin
export OS_USERNAME=admin
export OS_PASSWORD=0penstack
export OS_AUTH_URL=http://controller:35357/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2
export OS_VOLUME_API_VERSION=2'>/root/adminrc
sleep 2
source /root/adminrc
sleep 3
echo "source /root/adminrc" >> /root/.bashrc
sleep 3
sleep 2
echo -e "#########\e[1;95m openstack compute service list \e[0m#########"
openstack compute service list
sleep 3
echo -e "######\e[31m  Deleting Default Virtual Net of KVM Service  \e[0m######" 
sleep 2
Key_To_Start
sleep 2
virsh net-list
sleep 2
virsh net-autostart default --disable
sleep 2
virsh net-destroy default
sleep 2
######### Local Script For Checking Openstack Logs and Service Status #########
echo -e "###\e[96m Creating Local Script For Checking Openstack Logs and Service Status \e[0m###"
echo -e 'for i in nova-compute neutron-linuxbridge-agent\ndo\n systemctl $1 $i\ndone' > /root/opser.sh
chmod +x /root/opser.sh
sleep 1
echo -e 'for i in $(ls /var/log/{neutron,nova}/*)\ndo\n>$i\ndone'> /root/cleanlog.sh
chmod +x /root/cleanlog.sh
sleep 1
echo -e 'grep -i error /var/log/{neutron,nova}/*.log ' > /root/errlogcheck
chmod +x /root/errlogcheck
sleep 1
echo 'egrep -v "^\s*#|^\s*;|^$" $1 $2' > /bin/uv 
sleep 1
chmod +x /bin/uv
sleep 1
##########################################################
Complete_Reboot
sleep 3
exit
##########################################################
##########################################################
