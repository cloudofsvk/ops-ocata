#!/bin/bash
###### Openstack-Ocata-Neutron_VXLAN-Ubuntu-16.04-SVK-GIT-MaY-2017 #######
###################################################
# Network-Node-Installation #
################################################### 
Node_Inst_Start () {
	echo -e  "######\e[92m Starting ---- $1 ---- Installation \e[0m######"
	echo -e "#####\e[31m Update and Upgrade the Server Before starting the Installation \e[0m#####"
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
	read -rsp $'\e[1;97;44m     ...Press any key to Exit...and...Reboot The Sever After Exit...     \e[0m\n' -n1 key
}
###################################################
echo "" 
sleep 2
if [ -s ops-network-localrc ]; then
	echo -e "\e[1;96m Entry in Source File \e[0m"
	cat ops-network-localrc
else
 	echo -e "\e[1;91m Local-Source-File Not Found or Empty , \n Run the script after setting source file \e[0m" 
	sleep 3 
	exit 1 
fi
tday=$(date +%d-%b-%Y-%H%M)
source ops-network-localrc
sleep 2
Node_Inst_Start Network-Node
sed -i '/network\|controller\|compute/d' /etc/hosts
echo -e " ##### \e[93mAdding OPenstack-Host-IP'S to /etc/hosts file\e[0m ##### "
echo -e "$con_ip 	controller\n$net_ip 	network\n$com_ip 	compute\n " >> /etc/hosts
echo -e '###### \e[92mStarting Installation\e[0m ######'
sleep 2
###################################################
######Enable IP Forwarding#######
echo -e "######\e[96m  Configuring IP Forwarding  \e[0m######"
cp /etc/sysctl.conf /etc/sysctl.conf.$tday
cat network-conf/sysctl.conf > /etc/sysctl.conf
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
cat network-conf/chrony.conf > /etc/chrony/chrony.conf
sleep 2
systemctl restart chrony 
sleep 3
chronyc sources
sleep 2

##########################################################
# Nuetron Configuration   
##########################################################
Openstack_Service_Inst Basic-System NEUTRON
sleep 1
cp /etc/neutron/neutron.conf /etc/neutron/neutron.conf.$tday
cp /etc/neutron/l3_agent.ini /etc/neutron/l3_agent.ini.$tday
cp /etc/neutron/dhcp_agent.ini /etc/neutron/dhcp_agent.ini.$tday
cp /etc/neutron/metadata_agent.ini /etc/neutron/metadata_agent.ini.$tday
cp /etc/neutron/plugins/ml2/ml2_conf.ini /etc/neutron/plugins/ml2/ml2_conf.ini.$tday
cp /etc/neutron/plugins/ml2/linuxbridge_agent.ini /etc/neutron/plugins/ml2/linuxbridge_agent.ini.$tday
sleep 3
cat network-conf/neutron.conf > /etc/neutron/neutron.conf
sleep 3
cat network-conf/l3_agent.ini > /etc/neutron/l3_agent.ini
sleep 3
cat network-conf/dhcp_agent.ini > /etc/neutron/dhcp_agent.ini
sleep 3
cat network-conf/dnsmasq-neutron.conf > /etc/neutron/dnsmasq-neutron.conf
sleep 3
cat network-conf/metadata_agent.ini > /etc/neutron/metadata_agent.ini
sleep 3
cat network-conf/ml2_conf.ini > /etc/neutron/plugins/ml2/ml2_conf.ini 
sleep 3
cat network-conf/linuxbridge_agent.ini > /etc/neutron/plugins/ml2/linuxbridge_agent.ini
sleep 3
sed -i "s/\$extdev/${extdev}/g" /etc/neutron/plugins/ml2/linuxbridge_agent.ini
sed -i "s/\$tunnel_ip/${net_ip}/g" /etc/neutron/plugins/ml2/linuxbridge_agent.ini
sleep 3
ln -s /etc/neutron/plugins/ml2/ml2_conf.ini /etc/neutron/plugin.ini 
echo -e " ########## \e[96m--------Configuring---------Bridge---------\e[0m ##########"
sleep 2
read -rsp $'\n... \e[31mEdit /etc/network/interfaces file using Another Terminal to configure bridge \e[0m...\n\n\e[0m... IF done ...\e[92mPress Any Key\e[0m to Continue installation ...\n' -n1 key
sleep 3
systemctl restart neutron-l3-agent 
sleep 3
systemctl restart  neutron-dhcp-agent
sleep 3
systemctl restart  neutron-metadata-agent
sleep 3
systemctl restart  neutron-linuxbridge-agent
sleep 3
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
echo -e "#########\e[1;95m openstack network agent list \e[0m#########"
openstack network agent list
sleep 3
######### Local Script For Checking Openstack Logs and Service Status #########
echo -e "###\e[96m Creating Local Script For Checking Openstack Logs and Service Status \e[0m ###"
echo -e 'for i in neutron-{l3-agent,dhcp-agent,metadata-agent,linuxbridge-agent}\ndo\nsystemctl $1 $i\ndone' > /root/opser.sh
chmod +x /root/opser.sh
sleep 3
/root/opser.sh enable 
sleep 3
echo -e 'for i in $(ls /var/log/neutron/*)\ndo\n>$i\ndone' > /root/cleanlog.sh
chmod +x /root/cleanlog.sh
echo -e 'grep -i error /var/log/neutron/*.log ' > /root/errlogcheck
chmod +x /root/errlogcheck
echo 'egrep -v "^\s*#|^\s*;|^$" $1 $2' > /bin/uv 
chmod +x /bin/uv
##########################################################
Complete_Reboot
sleep 3
exit
##########################################################
##########################################################
