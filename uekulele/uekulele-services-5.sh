#!/bin/bash

#    Copyright 2015-2017 Gilbert Standen
#    This file is part of orabuntu-lxc.

#    Orabuntu-lxc is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.

#    Orabuntu-lxc is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.

#    You should have received a copy of the GNU General Public License
#    along with orabuntu-lxc.  If not, see <http://www.gnu.org/licenses/>.

#    v2.4 GLS 20151224
#    v2.8 GLS 20151231
#    v3.0 GLS 20160710 Updates for Ubuntu 16.04
#    v4.0 GLS 20161025 DNS DHCP services moved into an LXC container

clear

echo ''
echo "=============================================="
echo "Script: uekulele-services-5.sh                  "
echo "=============================================="
echo ''
echo "=============================================="
echo "This script is re-runnable.                   "
echo "=============================================="
echo ''
echo "=============================================="
echo "This script starts lxc clones                 "
echo "=============================================="

OracleRelease=$1$2
OracleVersion=$1.$2
OR=$OracleRelease
Config=/var/lib/lxc/oel$OracleRelease/config

sleep 5

clear

echo ''
echo "=============================================="
echo "Create Priv/ASM OpenvSwitch Onboot Services..."
echo "=============================================="
echo ''

SwitchList='sw1 sx1 sw2 sw3 sw4 sw5 sw6 sw7 sw8 sw9'
for k in $SwitchList
do
        if [ ! -f /etc/systemd/system/$k.service ]
        then
                sudo sh -c "echo '[Unit]'						 > /etc/systemd/system/$k.service"
                sudo sh -c "echo 'Description=$k Service'				>> /etc/systemd/system/$k.service"
		if [ $k = 'sw1' ]
		then
			sudo sh -c "echo 'Wants=network-online.target'			>> /etc/systemd/system/$k.service"
			sudo sh -c "echo 'After=network-online.target'			>> /etc/systemd/system/$k.service"
		fi
		if [ $k = 'sx1' ]
		then
			sudo sh -c "echo 'Wants=network-online.target'			>> /etc/systemd/system/$k.service"
			sudo sh -c "echo 'After=network-online.target sw1.service'	>> /etc/systemd/system/$k.service"
		fi
		if [ $k != 'sw1' ] && [ $k != 'sx1' ]
		then
                	sudo sh -c "echo 'After=network-online.target'			>> /etc/systemd/system/$k.service"
		fi
                sudo sh -c "echo ''							>> /etc/systemd/system/$k.service"
                sudo sh -c "echo '[Service]'						>> /etc/systemd/system/$k.service"
                sudo sh -c "echo 'Type=oneshot'						>> /etc/systemd/system/$k.service"
                sudo sh -c "echo 'User=root'						>> /etc/systemd/system/$k.service"
                sudo sh -c "echo 'RemainAfterExit=yes'					>> /etc/systemd/system/$k.service"
                sudo sh -c "echo 'ExecStart=/etc/network/openvswitch/crt_ovs_$k.sh' 	>> /etc/systemd/system/$k.service"
                sudo sh -c "echo ''							>> /etc/systemd/system/$k.service"
                sudo sh -c "echo '[Install]'						>> /etc/systemd/system/$k.service"
                sudo sh -c "echo 'WantedBy=multi-user.target'				>> /etc/systemd/system/$k.service"
        fi
done

echo ''
echo "=============================================="
echo "OpenvSwitch Priv/ASM Onboot Services Created. "
echo "=============================================="

sleep 5

clear

for k in $SwitchList
do
	echo ''
	echo "=============================================="
	echo "Start OpenvSwitch $k ...            "
	echo "=============================================="
	echo ''

        sudo chmod 644 /etc/systemd/system/$k.service
        sudo systemctl enable $k.service
	sudo service $k start
	sudo service $k status

	echo ''
	echo "=============================================="
	echo "OpenvSwitch $k is up.                         "
	echo "=============================================="
	
	sleep 3

	clear
done

echo ''
echo "=============================================="
echo "Openvswitch interfaces installed & configured."
echo "=============================================="
echo ''

sleep 5

clear

echo ''
echo "=============================================="
echo "Starting LXC cloned containers for Oracle...  "
echo "=============================================="
echo ''

function CheckClonedContainersExist {
sudo ls /var/lib/lxc | egrep "oel$OracleRelease|ora$OracleRelease" | sort -V | sed 's/$/ /' | tr -d '\n' 
}
ClonedContainersExist=$(CheckClonedContainersExist)

for j in $ClonedContainersExist
do
	# GLS 20160707 updated to use lxc-copy instead of lxc-clone for Ubuntu 16.04
	# GLS 20160707 continues to use lxc-clone for Ubuntu 15.04 and 15.10

	function GetRedHatVersion {
	cat /etc/redhat-release  | cut -f7 -d' ' | cut -f1 -d'.'
	}
	RedHatVersion=$(GetRedHatVersion)

	echo "Starting container $j ..."
	if [ $RedHatVersion = 7 ]
	then
	function CheckPublicIPIterative {
	sudo lxc-ls -f | sed 's/  */ /g' | grep $j | grep RUNNING | cut -f2 -d'-' | sed 's/^[ \t]*//;s/[ \t]*$//' | cut -f1 -d' ' | cut -f1-2 -d'.' | sed 's/\.//g'
	}
	fi
	PublicIPIterative=$(CheckPublicIPIterative)
	echo $j | grep oel
	if [ $? -eq 0 ]
	then
	sudo bash -c "cat $Config|grep ipv4|cut -f2 -d'='|sed 's/^[ \t]*//;s/[ \t]*$//'|cut -f4 -d'.'|sed 's/^/\./'|xargs -I '{}' sed -i "/ipv4/s/\{}/\.1$OR/g" $Config"
#	sudo sed -i "s/\.39/\.$OracleRelease/g" /var/lib/lxc/oel$OracleRelease/config
#	sudo sed -i "s/\.40/\.$OracleRelease/g" /var/lib/lxc/oel$OracleRelease/config
	fi
	sudo lxc-start -n $j > /dev/null 2>&1
	sleep 5
	i=1
	while [ "$PublicIPIterative" != 10207 ] && [ "$i" -le 10 ]
	do
		echo "Waiting for $j Public IP to come up..."
		sleep 5
		PublicIPIterative=$(CheckPublicIPIterative)
		if [ $i -eq 5 ]
		then
		sudo lxc-stop -n $j
		sleep 2
		echo ''
		sudo /etc/network/openvswitch/veth_cleanups.sh $j
		echo ''
		sleep 2
		sudo lxc-start -n $j
		fi
	sleep 1
	i=$((i+1))
	done
done

echo ''
echo "=============================================="
echo "LXC clone containers for Oracle started.      "
echo "=============================================="
echo ''

sleep 5

clear

echo ''
echo "=============================================="
echo "LXC containers for Oracle started.            "
echo "=============================================="
echo ''

sudo lxc-ls -f

echo ''
echo "=============================================="

sleep 5

clear

echo ''
echo "=============================================="
echo "Management links directory creation...        "
echo "Location is:  /home/ubuntu/Play-The-Uekulele  "
echo "Step creates pointers to relevant files for   "
echo "quickly locating Orabuntu-LXC config files.   "
echo "=============================================="
echo ''

if [ ! -e /home/ubuntu/Play-The-Uekulele ]
then
mkdir /home/ubuntu/Play-The-Uekulele
fi

cd /home/ubuntu/Play-The-Uekulele
sudo chmod 755 /etc/orabuntu-lxc-scripts/crt_links.sh 
sudo /etc/orabuntu-lxc-scripts/crt_links.sh

echo ''
sudo ls -l /home/ubuntu/Play-The-Uekulele
echo ''

echo ''
echo "=============================================="
echo "Management links directory created.           "
echo "=============================================="
echo ''

sleep 15

clear

echo ''
echo "=============================================="
echo "Set selinux to permissive mode & set rules... "
echo "=============================================="
echo ''

function GetFacter {
facter virtual
}
Facter=$(GetFacter)
if [ $Facter = 'physical' ]
then
	mkdir -p /home/ubuntu/Downloads/uekulele-master/uekulele/selinux
	cd /home/ubuntu/Downloads/uekulele-master/uekulele/selinux
	sudo setenforce 0
	sudo getenforce
	sudo sed -i '/\([^T][^Y][^P][^E]\)\|\([^#]\)/ s/enforcing/permissive/' /etc/sysconfig/selinux
	echo ''
	sudo ausearch -c 'lxcattach' --raw | audit2allow -M my-lxcattach
	sudo semodule -i my-lxcattach.pp
	sudo ausearch -c 'dhclient' --raw | audit2allow -M my-dhclient
	sudo semodule -i my-dhclient.pp
	sudo ausearch -c 'passwd' --raw | audit2allow -M my-passwd
	sudo semodule -i my-passwd.pp
	sudo ausearch -c 'sedispatch' --raw | audit2allow -M my-sedispatch
	sudo semodule -i my-sedispatch.pp
	sudo ausearch -c 'systemd-sysctl' --raw | audit2allow -M my-systemdsysctl
	sudo semodule -i my-systemdsysctl.pp
	sudo ausearch -c 'ovs-vsctl' --raw | audit2allow -M my-ovsvsctl
	sudo semodule -i my-ovsvsctl.pp
	sudo ausearch -c 'sshd' --raw | audit2allow -M my-sshd
	sudo semodule -i my-sshd.pp
	sudo ausearch -c 'gdm-session-wor' --raw | audit2allow -M my-gdmsessionwor
	sudo semodule -i my-gdmsessionwor.pp
fi

echo ''
echo "=============================================="
echo "Set selinux to permissive & set rules.        "
echo "=============================================="

sleep 5

clear

echo ''
echo "=============================================="
echo "Next step is to setup storage...              "
echo "tar -xvf scst-files.tar                       "
echo "cd scst-files                                 "
echo "cat README                                    "
echo "follow the instructions in the README         "
echo "Builds the SCST Linux SAN.                    "
echo "                                              "
echo "Note that deployment management links are     "
echo "in /home/ubuntu/Play-The-Uekulele   "
echo "where you can learn more about what files and "
echo "configurations are used for the Orabuntu-LXC  "
echo "project.                                      "
echo "=============================================="
