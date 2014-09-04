#!/bin/bash
ETHCONF=/etc/sysconfig/network-scripts/ifcfg-eth0
HOSTS=/etc/hosts
NETWORK=/etc/sysconfig/network
NAMESERVER=/etc/resolv.conf
DIR=/tmp/backup/`date +%Y%m%d` 
NETMASK=255.255.255.0 

#Define Path; According to the actual situation changes.

  ETHCONF=/etc/sysconfig/network-scripts/ifcfg-eth0
  HOSTS=/etc/hosts
  NETWORK=/etc/sysconfig/network
  NAMESERVER=/etc/resolv.conf
  DIR=/tmp/backup/`date +%Y%m%d`
  NETMASK=255.255.255.0

echo -e "\033[36mShow some info of the machine, please check, if there is a error message, please select the Menu to change!\033[0m\n"

	 echo -e "\033[45;37m###################INFO FOR ifcfg-eth0###########################\033[0m"

sed -i -e 's/HOSTNAME=.*//g' -e '/^$/d' $ETHCONF
cat $ETHCONF 
	 echo -e "\033[45;37m###################INFO FOR /etc/hosts###########################\033[0m"

echo -e "127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4 \n::1         localhost localhost.localdomain localhost6 localhost6.localdomain6" >/etc/hosts
sed -i '/^$/d' $HOSTS
cat $HOSTS
	 echo -e "\033[45;37m###################INFO FOR /etc/sysconfig/network###############\033[0m"
sed -i '/^$/d' $NETWORK
cat $NETWORK
	 echo -e "\033[45;37m###################INFO FOR /etc/resolv.conf#####################\033[0m"
sed -i -e 's/^#.*//g' -e '/^$/d' $NAMESERVER
cat $NAMESERVER

echo -e "\033[36m++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\033[0m\n"
#Define Change_IP

function Change_IP ()
{
if
	[ ! -d $DIR ];then
	mkdir -p $DIR
fi
	echo "reading change ip ,doing backup interface eth0"
	cp $ETHCONF $DIR
	
	grep "dhcp" $ETHCONF
if
	[ $? -eq 0 ];then
	read -p "please insert ip address:" IPADDR
	sed -i 's/dhcp/static/g' $ETHCONF
	echo -e "IPADDR=$IPADDR\nNETMASK=$NETMASK\nGATEWAY=`echo $IPADDR|awk -F. '{print $1"."$2"."$3}'`.1" >>$ETHCONF
        echo "This IP address Change success!!!" 
else
	echo -n  "This $ETHCONF is static exist ,please ensure Change IP Yes or NO": 
	read i
fi

if
	[ "$i" == "y" -o "$i" == "yes" ];then  
	read -p "Please insert ip Address:" IPADDR
	count=(`echo $IPADDR|awk -F. '{print $1,$2,$3,$4}'`)

	 A=${#count[@]}
while
	[ "$A" -ne "4" ]  
do
	read -p "Please re Inster ip Address,example 192.168.109.90 ip": IPADDR
	count=(`echo $IPADDR|awk -F. '{print $1,$2,$3,$4}'`) 
	 A=${#count[@]} 
done
	sed -i -e 's/^IPADDR.*//g' -e 's/^NETMASK.*//g' -e 's/^GATEWAY.*//g' -e '/^$/d' $ETHCONF 
	echo -e "IPADDR=$IPADDR\nNETMASK=$NETMASK\nGATEWAY=`echo $IPADDR|awk -F. '{print $1"."$2"."$3}'`.1" >>$ETHCONF
	cat $ETHCONF
	echo "This IP address Change success !!!"  
else
	echo "This $ETHCONF static exist,please exit"
	exit $?
fi
}

#define the hosts

function Change_Hosts ()
{
if
	[ ! -d $DIR ];then
	mkdir -p $DIR
fi
	cp $HOSTS $DIR
	read -p "Please enter the new hosts": IPADDR
	host=`echo $IPADDR` 
	cat $HOSTS |grep 127.0.0.1 |grep "$host"

if	[ $? -ne 0 ];then
	echo "$host" >> $HOSTS 
	cat $HOSTS 
	 echo "This hosts change success!!! "
else
	echo "This $host is Exist....."
fi
}

#define the network

function Change_HostName ()   
{
if  
  
   [ ! -d $DIR ];then  
   mkdir -p $DIR  
  
fi  
  cp $NETWORK $DIR  
  read -p "Please enter the new hostname": IPADDR  
  
  host=`echo $IPADDR`  
  grep "$host" $NETWORK  
  
if  
  [ $? -ne 0 ];then  
  sed -i -e "s/^HOSTNAME.*//g" -e "/^$/d" $NETWORK  
  echo "HOSTNAME=$host" >>$NETWORK  
  cat $NETWORK
  echo "This hostname change success!!!"
  
else  
  echo "This $host IS Exist .........."  
  
fi  
}

#define the nameserver
function Change_NameServer ()

{       
if 
        [ ! -d $DIR ];then
        mkdir -p $DIR
fi
        cp $NAMESERVER $DIR
        read -p "Please enter the new nameserver": IPADDR
        host=`echo $IPADDR`
        grep "$host" $NAMESERVER

if
        [ $? -ne 0 ];then
        sed -i -e "s/^nameserver.*//g" -e  "/^$/d" $NAMESERVER
        echo "nameserver $host" >>$NAMESERVER
	cat $NAMESERVER
        echo "This nameserver change success!!!"
else
        echo "This $host is Exist ......"
fi
}

 PS3="Please Select the Menu or Ctrl+C to exit ":
 select i in  "Change_IP" "Change_Hosts" "Change_HostName" "Change_NameServer" 
do

case $i in   
Change_IP )  
Change_IP  
;;  
Change_Hosts ) 
Change_Hosts  
;;  
Change_HostName )  
Change_HostName   
;;  
Change_NameServer )
Change_NameServer
;;
*)  
echo  
echo -e "Please Insert $0: Change_IP(1)|Change_Hosts(2)|Change_HostName(3)|Change_NameServer(4)"  
echo  
;;  
esac  
 
done  
