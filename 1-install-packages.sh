#!/bin/bash
###### Openstack-Ocata-Neutron_VXLAN-Ubuntu-16.04-SVK-GIT-MaY-2017 #######
###################################################
# Network-Node-Installation #
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
echo -e "############\e[1;96m Installing Various Openstack-Packages for Network Node\e[0m ############"
Key_To_Start
apt install -y curl wget
sleep 3
apt -y install software-properties-common
sleep 2
add-apt-repository cloud-archive:ocata
sleep 2
apt update 
sleep 3
apt install -y chrony
sleep 2
apt install -y python-pymysql python-openstackclient
sleep 2
apt install -y neutron-plugin-ml2 neutron-plugin-linuxbridge-agent neutron-l3-agent neutron-dhcp-agent neutron-metadata-agent python-neutronclient
# Double check all packages are installed
sleep 3
apt install chrony python-pymysql python-openstackclient \
neutron-plugin-ml2 neutron-plugin-linuxbridge-agent neutron-l3-agent neutron-dhcp-agent neutron-metadata-agent python-neutronclient
sleep 3
echo -e "############\e[1;96m Installed Various Openstack-Packages on Controller Node\e[0m ############"
Key_To_Exit
###################################################
