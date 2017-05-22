#!/bin/bash
###### Openstack-Ocata-Neutron_VXLAN-Ubuntu-16.04-SVK-GIT-MaY-2017 #######
###################################################
# Compute-Node-Installation #
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
echo -e "############\e[1;96m Installing Various Openstack-Packages for Compute Node\e[0m ############"
Key_To_Start
sleep 2
apt -y install software-properties-common
sleep 2
add-apt-repository cloud-archive:ocata
sleep 2
apt update 
sleep 2
apt install -y curl wget
sleep 2
apt install -y chrony python-pymysql python-openstackclient
sleep 2 
apt install -y nova-compute-kvm python-novaclient neutron-common neutron-plugin-ml2 neutron-plugin-linuxbridge-agent 
sleep 2
# Double check all packages are installed
sleep 2
apt install curl wget chrony python-pymysql python-openstackclient \
nova-compute-kvm python-novaclient neutron-common neutron-plugin-ml2 neutron-plugin-linuxbridge-agent
sleep 2
echo -e "############\e[1;96m Installed Various Openstack-Packages on Controller Node\e[0m ############"
Key_To_Exit
###################################################
