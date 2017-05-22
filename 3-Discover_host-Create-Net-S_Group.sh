#!/bin/bash
##### Openstack-Ocata-Neutron_VXLAN-Ubuntu-16.04-SVK-GIT-Mar-2017 ######
Key_To_Start () {
	read -rsp $' ... \e[92mPress any key\e[0m to Continue OR \e[31mCTRL+C\e[0m to Exit Installation ... \n' -n1 key
}
################################################
echo -e "##########\e[93mRun This Script Only in Controller-Node  After Installation of OPS-Ocata-VXLAN\e[0m###############"
sleep 3
read -rsp $'...\e[96mIf Completed OPENSTACK Installation and All Services are Working\e[0m,then \e[92mPress any key\e[0m to Continue  or \e[31mCTRL+C\e[0m to Exit Installation...\n' -n1 key

################################################
#Discover-Compute-Hosts
################################################
echo -e " ###### \e[1;96m Discover-Compute-Hosts \e[0m##########"
sleep 2
echo -e " ###### \e[1;95m nova-manage cell_v2 discover_hosts \e[0m##########"
sleep 5
su -s /bin/bash nova -c "nova-manage cell_v2 discover_hosts"
sleep 5
echo -e " ###### \e[1;95m openstack compute service list \e[0m##########"
openstack compute service list
sleep 3
echo -e " ###### \e[1;95m nova-manage cell_v2 list_cells --verbose \e[0m##########"
sleep 2
nova-manage cell_v2 list_cells --verbose
sleep 2
################################################
#Create External Network
################################################
echo -e " ###### \e[1;96m Create the External-Net For OpenStack \e[0m##########"
source /root/adminrc
echo -en "\e[93m External-Net DHCP-Pool Start IP \e[0m(e.g, 192.168.1.110) : "
read ext_dhcp_start
echo -en "\e[93m External-Net DHCP-Pool End IP \e[0m(e.g, 192.168.1.150) : "
read ext_dhcp_end
echo -en "\e[93m External-Net Gateway IP \e[0m (e.g, 192.168.1.1) : "
read ext_dhcp_gw
echo -en "\e[93m Provide External-Net/SubnetMask \e[0m(e.g, 192.168.1.0/24) : "
read ext_subnet
sleep 3

openstack network create --provider-physical-network provider --provider-network-type flat --external ext-net
sleep 3

openstack subnet create ext-subnet --network ext-net --subnet-range $ext_subnet \
--allocation-pool start=$ext_dhcp_start,end=$ext_dhcp_end --gateway $ext_dhcp_gw --dns-nameserver 8.8.4.4 --no-dhcp
sleep 3
################################################
#Network For ADMIN  Group/Tenant 
################################################

echo -e "#####\e[96m  Creating NetworK,Router,KeyPair and Sec-Groups  For ADMIN Tenant   \e[0m#####"
sleep 2
Key_To_Start
sleep 2
source /root/adminrc
echo -en "\e[93m Admin-Net Gateway IP \e[0m( e.g, 10.0.0.1) : "
read admin_net_gw
echo -en "\e[93m Provide Admin-Net/SubnetMask \e[0m(e.g, 10.0.0.0/24) : "
read admin_net_subnet
sleep 3

openstack network create admin-net --provider-network-type vxlan
sleep 3
openstack subnet create admin-subnet --network admin-net --subnet-range $admin_net_subnet --gateway $admin_net_gw --dns-nameserver 8.8.4.4

echo -e " ###### \e[1;95m Create a Virtual router \e[0m##########"
openstack router create admin-router
sleep 3
openstack router add subnet admin-router admin-subnet
sleep 3
openstack router set admin-router --external-gateway ext-net

echo -e " ###### \e[1;95m Create SSH-Key-Pairs \e[0m##########"
sleep 3
ssh-keygen -f /root/.ssh/svkopskey -q -N "" 
openstack keypair create --public-key /root/.ssh/svkopskey.pub admin-key
sleep 3
openstack keypair list 
sleep 3

echo -e " ###### \e[1;95m Create Sec-Group-For Admin-Tenant \e[0m##########"
openstack security group list
sleep 3
openstack security group create --description Admin-Sec-Group Admin
sleep 3
openstack security group rule create --proto tcp --dst-port 22 Admin
sleep 3
openstack security group rule create --proto icmp Admin
sleep 3
openstack security group rule create --proto tcp --dst-port 3389 Admin
sleep 3
openstack security group rule list Admin

################################################
#For DEMO  Group/Tenant 
################################################

echo -e "#####\e[96m   Ceating NetworK,Router,KeyPair and Sec-Groups  For DEMO Tenant   \e[0m#####"
sleep 2
Key_To_Start
sleep 2
source /root/demorc
echo -en "\e[93m Demo-Net Gateway IP ( e.g, 30.0.0.1)\e[0m : "
read demo_net_gw
echo -en "\e[93m Provide Demo-Net/SubnetMask (e.g, 30.0.0.0/24)\e[0m : "
read demo_net_subnet
sleep 3

openstack network create demo-net 
sleep 3
openstack subnet create demo-subnet --network demo-net --subnet-range $demo_net_subnet --gateway $demo_net_gw --dns-nameserver 8.8.4.4

echo -e " ###### \e[1;95m Create a Virtual router \e[0m##########"
openstack router create demo-router
sleep 3
openstack router add subnet demo-router demo-subnet
sleep 3
openstack router set demo-router --external-gateway ext-net

echo -e " ###### \e[1;95m Create SSH-Key-Pairs \e[0m##########"
sleep 3
openstack keypair create --public-key /root/.ssh/svkopskey.pub demo-key
sleep 3
openstack keypair list 
sleep 3

echo -e " ###### \e[1;95m Create Sec-Group-For Demo-Tenant \e[0m##########"
openstack security group list
sleep 3
openstack security group create --description Demo-Sec-Group Demo
sleep 3
openstack security group rule create --proto tcp --dst-port 22 Demo
sleep 3
openstack security group rule create --proto icmp Demo
sleep 3
openstack security group rule create --proto tcp --dst-port 3389 Demo
sleep 3
openstack security group rule list Demo


################################################
#Create flavors
################################################
echo -e " ###### \e[1;96m Create flavors \e[0m##########"
sleep 2
source /root/adminrc
sleep 2
Key_To_Start
sleep 2
sleep 3
echo -e " ###### \e[95m Create m1.nano flavor \e[0m##########"
sleep 3
openstack flavor create --id 0 --vcpus 1 --ram 256 --disk 5 m1.nano
sleep 3
echo -e " ###### \e[95m Create m1.micro flavor \e[0m##########"
sleep 3
openstack flavor create --id 1 --vcpus 1 --ram 512 --disk 5 m1.micro
echo -e " ###### \e[95m Create m1.tiny flavor \e[0m##########"
sleep 3
openstack flavor create --id 2 --vcpus 1 --ram 1024 --disk 10 m1.tiny
echo -e " ###### \e[95m Create m1.small flavor \e[0m##########"
sleep 3
openstack flavor create --id 3 --vcpus 1 --ram 2048 --disk 20 m1.small


sleep 3
echo -e " ###### \e[1;96m openstack flavor list \e[0m##########"
openstack flavor list
sleep 3
echo -e " ###### \e[1;96m openstack image list \e[0m##########"
openstack image list
sleep 3
echo -e " ###### \e[1;96m openstack network list \e[0m##########"
openstack network list
sleep 3
echo -e " ###### \e[1;96m openstack security group list \e[0m##########"
openstack security group list

echo -e "######\e[96m Completed Discover-Hosts,Net & SecGroup Creation \e[0m##########"
sleep 3
read -rsp $' ... \e[92m Press any key\e[0m to Exit ... \n' -n1 key
sleep 3
exit
#############################################################
#############################################################
