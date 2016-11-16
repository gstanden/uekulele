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

#    Note that this software builds a conntainerized DNS DHCP solution for the Desktop environment.
#    The nameserver should NOT be the name of an EXISTING nameserver but an arbitrary name because this software is CREATING a new LXC-containerized nameserver.
#    The domain names can be arbitrary fictional names or they can be a domain that you actually own and operate.
#    There are two domains and two networks because the "seed" LXC containers are on a separate network from the production LXC containers.
#    If the domain is an actual domain, you will need to change the subnet though (a feature this software does not yet support - it's on the roadmap) to match your subnet manually.

echo ''
echo "=============================================="
echo "Script:  uekulele-services-1.sh               "
echo "=============================================="

sleep 5

clear

echo ''
echo "=============================================="
echo "Establish sudo privileges...                  "
echo "=============================================="
echo ''

sudo date

echo ''
echo "=============================================="
echo "Establish sudo privileges completed.          "
echo "=============================================="

sleep 5 

clear

MajorRelease=$1
PointRelease=$2
OracleRelease=$1$2
OracleVersion=$1.$2
Domain1=$3
Domain2=$4
NameServer=$5
LinuxOSMemoryReservation=$6

if [ -f /etc/uekulele-release ]
then
	which lxc-ls > /dev/null 2>&1
	if [ $? -ne 0 ]
	then
		echo ''
		echo "=============================================="
		echo "Install LXC and prerequisite packages...      "
		echo "=============================================="
		echo ''

		sudo yum -y install wget tar gzip
		mkdir -p /home/ubuntu/Downloads/orabuntu-lxc-master/uekulele/epel
		cd /home/ubuntu/Downloads/orabuntu-lxc-master/uekulele/epel
		wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
		sudo rpm -ivh epel-release-latest-7.noarch.rpm 
		cd /home/ubuntu/Downloads/orabuntu-lxc-master
		sudo yum -y install debootstrap perl libvirt
		sudo yum -y install lxc libcap-devel libcgroup busybox wget bridge-utils

		echo ''
		echo "=============================================="
		echo "LXC and prerequisite packages completed.      "
		echo "=============================================="
		echo ''

		sleep 5

		clear

		echo ''
		echo "=============================================="
		echo "Start LXC and related services...             "
		echo "=============================================="
		echo ''

		sudo systemctl start lxc.service
		sudo systemctl status lxc.service
		echo ''
		sudo systemctl start libvirtd 
		sudo systemctl status libvirtd

		echo ''
		echo "=============================================="
		echo "LXC and related services started.             "
		echo "=============================================="
		echo ''

		sleep 5

		clear

		echo ''
		echo "=============================================="
		echo "Run LXC Checkconfig...                        "
		echo "=============================================="
		echo ''

		sleep 5

		sudo lxc-checkconfig

		echo ''
		echo "=============================================="
		echo "LXC Checkconfig completed.                    "
		echo "=============================================="
		echo ''
		
		sleep 5

		clear

		echo ''
		echo "=============================================="
		echo "Display LXC Version...                        "
		echo "=============================================="
		echo ''

		sudo lxc-create --version

		echo ''
		echo "=============================================="
		echo "LXC version displayed.                        "
		echo "=============================================="
		echo ''

	fi

	sleep 5

	clear

	function GetLxcVersion {
	lxc-create --version | sed 's/\.//g'
	}
	LxcVersion=$(GetLxcVersion)

	if [ $LxcVersion -lt 205 ]	
	then
		echo ''
		echo "=============================================="
		echo "Install LXC complete.                         "
		echo "=============================================="
		echo ''
		echo "=============================================="
		echo "Installing required LXC package complete.     "
		echo "=============================================="
		echo ''

		sleep 5

		clear

		echo ''
		echo "=============================================="
		echo "Upgrade LXC from Source on Oracle Linux...    "
		echo "=============================================="

		sleep 5
	
		clear

		echo ''
		echo "=============================================="
		echo "Install required packages and prepare...      "
		echo "=============================================="
		echo ''

		sleep 5

		sudo yum -y install rpm-build wget openssl-devel gcc make docbook2X asciidoc xmlto docbook automake graphviz
		mkdir -p /home/ubuntu/Downloads/orabuntu-lxc-master/uekulele/lxc
		cd /home/ubuntu/Downloads/orabuntu-lxc-master/uekulele/lxc
		wget https://linuxcontainers.org/downloads/lxc/lxc-2.0.5.tar.gz
		mkdir -p /home/ubuntu/Downloads/orabuntu-lxc-master/uekulele/lxc/rpmbuild/{BUILD,BUILDROOT,RPMS,SOURCES,SPECS,SRPMS}
		cp -p lxc-2.0.5.tar.gz /home/ubuntu/Downloads/orabuntu-lxc-master/uekulele/lxc/rpmbuild/SOURCES/.

		echo ''
		echo "=============================================="
		echo "Packages and preparations complete.           "
		echo "=============================================="

		sleep 5

		clear

		echo ''
		echo "=============================================="
		echo "Untar source code and build LXC RPM...        "
		echo "=============================================="
		echo ''

		sleep 5

		tar -zxvf lxc-2.0.5.tar.gz
		cp -p lxc-2.0.5/lxc.spec ~/Downloads/orabuntu-lxc-master/uekulele/lxc/.
		cd /home/ubuntu/Downloads/orabuntu-lxc-master/uekulele/lxc
		sudo sh -c "echo '%_unpackaged_files_terminate_build 0' >> /etc/rpm/macros"
		rpmbuild --define '_topdir /home/ubuntu/Downloads/orabuntu-lxc-master/uekulele/lxc/rpmbuild' -ba lxc.spec

		echo ''
		echo "=============================================="
		echo "LXC RPM built.                                "
		echo "=============================================="

		sleep 5

		clear

		echo ''
		echo "=============================================="
		echo "Upgrade LXC from source: Install RPM's...    "
		echo "=============================================="
		echo ''

		cd ~/Downloads/orabuntu-lxc-master/uekulele/lxc/rpmbuild/RPMS/x86_64
		sudo yum -y localinstall lxc*

		echo ''
		echo "=============================================="
		echo "Install LXC RPM completed.            "
		echo "=============================================="

		sleep 5

		clear

		echo ''
		echo "=============================================="
		echo "Test LXC...                           "
		echo "=============================================="
		echo ''

		sleep 5

		sudo lxc-checkconfig

		echo ''
		echo "=============================================="
		echo "Test LXC complete.                    "
		echo "=============================================="

		sleep 5

		clear

		echo ''
		echo "=============================================="
		echo "Upgrade LXC from Source complete.             "
		echo "=============================================="

		sleep 5

		clear
	fi

	echo "=============================================="
	echo "Delete the etc/uekulele-release file if       "
	echo "re-running orabuntu-lxc from scratch.         "
	echo "                                              " 
	read -e -p "rm /etc/uekulele-release? [Y/N]         " -i "Y" DeleteUekuleleRelease
	echo "                                              "
	echo "=============================================="
	echo ''

	if [ $DeleteUekuleleRelease = 'y' ] || [ $DeleteUekuleleRelease = 'Y' ]
	then
		echo ''
		echo "=============================================="
		echo "Delete /etc/uekulele-release file...      "
		echo "=============================================="
		echo ''

		sudo rm -f /etc/uekulele-release

		echo ''
		echo "=============================================="
		echo "File /etc/uekulele-release deleted.       "
		echo "=============================================="

		sleep 5

		clear
	fi

	echo ''
	echo "=============================================="
	echo "Cleaning up OpenvSwitch iptables rules...     "
	echo "=============================================="
	echo ''

	SwitchList='sw1 sx1'
	for k in $SwitchList
	do
		function CheckRuleExist {
		sudo iptables -S | grep -c $k
		}
		RuleExist=$(CheckRuleExist)
		function FormatSearchString {
		sudo iptables -S | grep $k | sort -u | head -1 | sed 's/-/\\-/g'
		}
		SearchString=$(FormatSearchString)
		if [ $RuleExist -ne 0 ]
		then
			function GetSwitchRuleCount {
			sudo iptables -S | grep -c "$SearchString"
			}
			SwitchRuleCount=$(GetSwitchRuleCount)
		else
 			SwitchRuleCount=0
 		fi
		function GetSwitchRule {
		sudo iptables -S | grep $k | sort -u | head -1 | cut -f2-10 -d' '
		}
		SwitchRule=$(GetSwitchRule)
		function GetCountSwitchRules {
		echo $SwitchRule | grep -c $k
		}
		CountSwitchRules=$(GetCountSwitchRules)
		while [ $SwitchRuleCount -ne 0 ] && [ $RuleExist -ne 0 ] && [ $CountSwitchRules -ne 0 ]
		do
			SwitchRule=$(GetSwitchRule)
			sudo iptables -D $SwitchRule
			SearchString=$(FormatSearchString) 
			SwitchRuleCount=$(GetSwitchRuleCount)
			RuleExist=$(CheckRuleExist)
		done
	done

	sudo iptables -S

	echo ''
	echo "=============================================="
	echo "OpenvSwitch iptables rules cleanup completed. "
	echo "=============================================="
	echo ''

	sleep 5

	clear

	echo ''
	echo "=============================================="
	echo "Default "N" to NOT destroy existing leases.   "
	echo "This deletes DHCP leases in the DNS DHCP LXC  "
	echo "container.  It does NOT delete any DHCP leases"
	echo "on this Orabuntu-LXC host.                    "
	echo "                                              "
	echo "This step is typically used when reinstalling "
	echo "Orabuntu-LXC from scratch to zero out the     "
	echo "leases from the previous Orabuntu-LXC install."
	echo "                                              " 
	echo "On the first run of Orabuntu-LXC this can be  "
	echo "left set to "N" because there are no leases to"
	echo "delete on the first run.                      "
	echo "                                              "
	read -e -p "Terminate Existing DHCP Leases? [Y/N]   " -i "N" TerminateLeases 
	echo "                                              "
	echo "=============================================="
	echo ''

	if [ $TerminateLeases = 'y' ] || [ $TerminateLeases = 'Y' ] && [ ! -z $NameServer ] 
	then
		echo ''
		echo "=============================================="
		echo "Clear DHCP leases...                          "
		echo "=============================================="
		echo ''

		if [ -e /var/lib/lxc/$NameServer/rootfs/var/lib/dhcp/dhcpd.leases ] 
		then
		sudo lxc-attach -n nsa -- isc-dhcp-server stop >/dev/null 2>&1
			if [ -e /var/lib/lxc/$NameServer/rootfs/var/lib/dhcp/dhcpd.leases~ ]
			then
				 sudo rm /var/lib/lxc/$NameServer/rootfs/var/lib/dhcp/dhcpd.leases~
			fi

			if [ -e /var/lib/lxc/$NameServer/rootfs/var/lib/dhcp/dhcpd.leases ]
			then
				 sudo rm /var/lib/lxc/$NameServer/rootfs/var/lib/dhcp/dhcpd.leases
			fi
			sudo lxc-attach -n nsa --  service isc-dhcp-server start >/dev/null 2>&1
		fi 

		echo "=============================================="
		echo "Clear DHCP leases complete.                   "
		echo "=============================================="
	fi 

	sleep 5

	clear

	echo ''
	echo "=============================================="
	echo "         Optional step to destroy             "
	echo "      existing LXC linux containers.          "
	echo "                                              "
	echo " Clone containers script starts cloning from  "
	echo "            the n+1th container               "
	echo "          so this step is optional            "
	echo "      even on re-runs of Orabuntu-LXC         "
	echo "                                              "
	echo " If you have non-Orabuntu-LXC containers then "
	echo "  answer N to this question or else your LXC  "
	echo "        containers will be deleted.           "
	echo "=============================================="
	echo ''
	echo "=============================================="
	echo "                                              "
	read -e -p "Delete Existing LXC Containers? [Y/N]   " -i "N" DestroyContainers 
	echo "                                              "
	echo "=============================================="

	if [ $DestroyContainers = 'y' ] || [ $DestroyContainers = 'Y' ] 
	then
		echo ''
		echo "=============================================="
		echo "          Destruction of Containers           "
		echo "                                              "
		echo "                !!WARNING!!                   "
		echo "                                              "
		echo "     This step (optionally) destroys          "
		echo "          all existing containers             "
		echo "                                              "
		echo "   If any doubts, <CTRL>+c NOW to exit and    " 
		echo "    review scripts first before running!      "
		echo "                                              "
		echo "    Sleeping 25 seconds to give you time      "
		echo "              to think...                     "
		echo "                                              "
		echo "=============================================="

		sleep 25

		clear

		function CheckContainersExist {
		sudo ls /var/lib/lxc | more | sed 's/$/ /' | tr -d '\n' | sed 's/  */ /g'
		}
		ContainersExist=$(CheckContainersExist)

		function CheckSeedContainersExist {
		sudo ls /var/lib/lxc | more | grep oel | sed 's/$/ /' | tr -d '\n' | sed 's/  */ /g'
		}
		SeedContainersExist=$(CheckSeedContainersExist)

		echo ''
		echo "=============================================="
		read -e -p "Delete Only Container oel$OracleRelease? [Y/N]    " -i "Y" DestroySeedContainerOnly
		echo "=============================================="
		echo ''

		if [ $DestroySeedContainerOnly = 'Y' ] || [ $DestroySeedContainerOnly = 'y' ]
		then
			DestroyContainers=$(CheckSeedContainersExist)
		else
			DestroyContainers=$(CheckContainersExist)
		fi

		for j in $DestroyContainers
		do
			sudo lxc-stop -n $j
			sleep 2
			sudo lxc-destroy -n $j -f 
			sudo rm -rf /var/lib/lxc/$j
		done

		echo ''
		echo "=============================================="
		echo "Destruction of Containers complete            "
		echo "=============================================="
		
	fi 

	sleep 5

	clear

	echo ''
	echo "=============================================="
	echo "         Show Defined Containers...           "
	echo "=============================================="
	echo ''

	sudo which lxc-ls > /dev/null 2>&1
	if [ $? -eq 0 ]
	then
		sudo lxc-ls -f
	fi

	echo ''
	echo "=============================================="
	echo "         Container Check completed.           "
	echo "=============================================="
fi

echo ''
echo "=============================================="
echo "Package Installation...                       "
echo "=============================================="
echo ''

sleep 5

clear

which lxc-ls > /dev/null 2>&1
if [ $? -ne 0 ]
then
	echo ''
	echo "=============================================="
	echo "Install LXC & prerequisite packages...        "
	echo "=============================================="
	echo ''

	sleep 5

	sudo yum -y install wget tar gzip
	mkdir -p /home/ubuntu/Downloads/orabuntu-lxc-master/uekulele/epel
	cd /home/ubuntu/Downloads/orabuntu-lxc-master/uekulele/epel
	wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
	sudo rpm -ivh epel-release-latest-7.noarch.rpm 
	sudo yum -y install debootstrap perl libvirt
	sudo yum -y install lxc libcap-devel libcgroup busybox wget bridge-utils

	echo ''
	echo "=============================================="
	echo "LXC and prerequisite packages completed.      "
	echo "=============================================="

	sleep 5

	clear

	echo ''
	echo "=============================================="
	echo "Start LXC and related services...             "
	echo "=============================================="
	echo ''

	sudo systemctl start lxc.service
	sudo systemctl status lxc.service
	echo ''
	sudo systemctl start libvirtd 
	sudo systemctl status libvirtd

	echo ''
	echo "=============================================="
	echo "LXC and related services started.             "
	echo "=============================================="

	sleep 5

	clear

	echo ''
	echo "=============================================="
	echo "Run LXC Checkconfig...                        "
	echo "=============================================="
	echo ''

	sleep 5

	sudo lxc-checkconfig

	echo ''
	echo "=============================================="
	echo "LXC Checkconfig completed.                    "
	echo "=============================================="

	sleep 5

	clear

	echo ''
	echo "=============================================="
	echo "Install LXC complete.                         "
	echo "=============================================="
fi
	sleep 5

	clear

	function GetLxcVersion {
	lxc-create --version | sed 's/\.//g'
	}
	LxcVersion=$(GetLxcVersion)

if [ $LxcVersion -lt 205 ]	
then
	echo ''
	echo "=============================================="
	echo "Upgrade LXC from Source on Oracle Linux...    "
	echo "=============================================="

	sleep 5

	clear

	echo ''
	echo "=============================================="
	echo "Install required packages and prepare...      "
	echo "=============================================="
	echo ''

	sleep 5

	sudo yum -y install rpm-build wget openssl-devel gcc make docbook2X asciidoc xmlto docbook automake graphviz
	mkdir -p /home/ubuntu/Downloads/orabuntu-lxc-master/uekulele/lxc
	cd /home/ubuntu/Downloads/orabuntu-lxc-master/uekulele/lxc
	wget https://linuxcontainers.org/downloads/lxc/lxc-2.0.5.tar.gz
	mkdir -p /home/ubuntu/Downloads/orabuntu-lxc-master/uekulele/lxc/rpmbuild/{BUILD,BUILDROOT,RPMS,SOURCES,SPECS,SRPMS}
	cp -p lxc-2.0.5.tar.gz /home/ubuntu/Downloads/orabuntu-lxc-master/uekulele/lxc/rpmbuild/SOURCES/.

	echo ''
	echo "=============================================="
	echo "Packages and preparations complete.           "
	echo "=============================================="

	sleep 5

	clear

	echo ''
	echo "=============================================="
	echo "Untar source code and build LXC RPM...        "
	echo "=============================================="
	echo ''

	sleep 5

	tar -zxvf lxc-2.0.5.tar.gz
	cp -p lxc-2.0.5/lxc.spec ~/Downloads/orabuntu-lxc-master/uekulele/lxc/.
	cd /home/ubuntu/Downloads/orabuntu-lxc-master/uekulele/lxc
	sudo sh -c "echo '%_unpackaged_files_terminate_build 0' >> /etc/rpm/macros"
	rpmbuild --define '_topdir /home/ubuntu/Downloads/orabuntu-lxc-master/uekulele/lxc/rpmbuild' -ba lxc.spec

	echo ''
	echo "=============================================="
	echo "LXC RPM built.                                "
	echo "=============================================="

	sleep 5

	clear

	echo ''
	echo "=============================================="
	echo "Upgrade LXC from source: Install RPM's...    "
	echo "=============================================="
	echo ''

	cd ~/Downloads/orabuntu-lxc-master/uekulele/lxc/rpmbuild/RPMS/x86_64
	sudo yum -y localinstall lxc*

	echo ''
	echo "=============================================="
	echo "Install LXC RPM completed.            "
	echo "=============================================="

	sleep 5

	clear

	echo ''
	echo "=============================================="
	echo "Test LXC...                           "
	echo "=============================================="
	echo ''

	sleep 5

	sudo lxc-checkconfig

	echo ''
	echo "=============================================="
	echo "Test LXC complete.                    "
	echo "=============================================="

	sleep 5

	clear

	echo ''
	echo "=============================================="
	echo "Show LXC version...                           "
	echo "=============================================="
	echo ''

	sudo lxc-create --version

	echo ''
	echo "=============================================="
	echo "LXC version should be 2.0.5                   "
	echo "=============================================="
	
	sleep 5

	clear

	echo ''
	echo "=============================================="
	echo "Upgrade LXC from Source complete.             "
	echo "=============================================="
fi

sleep 5

clear

echo ''
echo "=============================================="
echo "Build OpenvSwitch from Source on Oracle Linux "
echo "=============================================="

sleep 5

clear

which ovs-vsctl > /dev/null 2>&1
if [ $? -ne 0 ]
then
	echo ''
	echo "=============================================="
	echo "Install required packages and prepare...      "
	echo "=============================================="
	echo ''

	sleep 5

	sudo yum -y install rpm-build wget openssl-devel gcc make
	mkdir -p /home/ubuntu/Downloads/orabuntu-lxc-master/uekulele/openvswitch
	cd /home/ubuntu/Downloads/orabuntu-lxc-master/uekulele/openvswitch
	wget http://openvswitch.org/releases/openvswitch-2.5.1.tar.gz
	mkdir -p ~/Downloads/orabuntu-lxc-master/uekulele/openvswitch/rpmbuild/{BUILD,BUILDROOT,RPMS,SOURCES,SPECS,SRPMS}
	cp -p openvswitch-2.5.1.tar.gz /home/ubuntu/Downloads/orabuntu-lxc-master/uekulele/openvswitch/rpmbuild/SOURCES/.

	echo ''
	echo "=============================================="
	echo "Packages and preparations complete.           "
	echo "=============================================="

	sleep 5

	clear

	echo ''
	echo "=============================================="
	echo "Untar source code and build openvswitch rpm..."
	echo "=============================================="
	echo ''

	sleep 5

	tar -zxvf openvswitch-2.5.1.tar.gz
	cp -p openvswitch-2.5.1/rhel/*.spec ~/Downloads/orabuntu-lxc-master/uekulele/openvswitch/.
	cd /home/ubuntu/Downloads/orabuntu-lxc-master/uekulele/openvswitch
	rpmbuild --define '_topdir /home/ubuntu/Downloads/orabuntu-lxc-master/uekulele/openvswitch/rpmbuild' -ba openvswitch.spec

	echo ''
	echo "=============================================="
	echo "OpenvSWitch RPM built.                        "
	echo "=============================================="

	sleep 5

	clear

	echo ''
	echo "=============================================="
	echo "Establish sudo privileges...                  "
	echo "=============================================="
	echo ''

	sudo date

	echo ''
	echo "=============================================="
	echo "Establish sudo privileges completed.          "
	echo "=============================================="
	
	sleep 5

	clear

	echo ''
	echo "=============================================="
	echo "Install OpenvSwitch RPM...                    "
	echo "=============================================="
	echo ''

	sleep 5

	cd ~/Downloads/orabuntu-lxc-master/uekulele/openvswitch/rpmbuild/RPMS/x86_64
#	sudo yum -y localinstall openvswitch-2.5.1-1.x86_64.rpm 
	sudo yum -y localinstall openvswitch*

	echo ''
	echo "=============================================="
	echo "Install OpenvSwitch RPM completed.            "
	echo "=============================================="
	echo ''

	sleep 5

	clear

	echo ''
	echo "=============================================="
	echo "Create OpenvSwitch database...                "
	echo "=============================================="
	echo ''

	cd /usr/local/etc
	sudo mkdir openvswitch
	sudo ovsdb-tool create /usr/local/etc/openvswitch/conf.db
	sudo systemctl start openvswitch.service
	sudo ls -l /usr/local/etc/openvswitch/conf.db

	echo ''
	echo "=============================================="
	echo "OpenvSwitch database created.                 "
	echo "=============================================="
	
	sleep 5

	clear

	echo ''
	echo "=============================================="
	echo "Test OpenvSwitch...                           "
	echo "=============================================="
	echo ''

	sudo ovs-vsctl show

	echo ''
	echo "=============================================="
	echo "Test OpenvSwitch complete.                    "
	echo "=============================================="
	echo ''
fi

sleep 5

clear

echo ''
echo "=============================================="
echo "Build OpenvSwitch from Source complete.       "
echo "=============================================="

sleep 5

clear

echo ''
echo "=============================================="
echo "Installation required packages...             "
echo "=============================================="
echo ''

sleep 5

cd /home/ubuntu/Downloads/orabuntu-lxc-master

sudo yum -y install curl ruby tar which	
sudo yum -y install wget tar gunzip
sudo yum -y install libcap-devel libcgroup wget bridge-utils graphviz
sudo yum -y install rpm-build wget openssl-devel
sudo yum -y install bind-utils net-tools openssh-server uuid
sudo yum -y install rpm ntp iotop iptables gawk

echo ''
echo "=============================================="
echo "Package Installation complete          "
echo "=============================================="

sleep 5

clear

echo ''
echo "=============================================="
echo "Verify required packages status...            "
echo "=============================================="
echo ''

function GetRedHatVersion {
sudo cat /etc/redhat-release  | cut -f7 -d' ' | cut -f1 -d'.'
}
RedHatVersion=$(GetRedHatVersion)

if [ $RedHatVersion = '7' ]
then
function CheckPackageInstalled {
echo 'wget gzip debootstrap perl libvirt bind-utils net-tools openssh-server uuid rpm yum ntp iotop which ruby curl tar lxc-2 lxc-libs lxc-debug lxc-devel libcap-devel libcgroup busybox bridge-utils rpm-build openssl-devel gcc make docbook2X asciidoc xmlto docbook automake graphviz iptables gawk libvirt-daemon-driver-lxc openvswitch-2 openvswitch-debug facter'
}
fi

PackageInstalled=$(CheckPackageInstalled)

for i in $PackageInstalled
do
sudo rpm -qa | grep $i | tail -1 | sed 's/^/Installed: /' | sort         
done

echo ''
echo "=============================================="
echo "Verify required packages status completed.    "
echo "=============================================="
echo ''

sleep 5

clear

echo ''
echo "=============================================="
echo "Pre-install backup of key files...            "
echo "==============================================" 
echo ''
echo "=============================================="
echo "Extracting backup scripts...                  "
echo "==============================================" 
echo ''

sudo tar -vP --extract --file=/home/ubuntu/Downloads/orabuntu-lxc-master/uekulele/archives/ubuntu-host.tar /etc/orabuntu-lxc-scripts/ubuntu-host-backup.sh --touch
echo ''
sudo /etc/orabuntu-lxc-scripts/ubuntu-host-backup.sh

echo ''
echo "=============================================="
echo "Key files backups check complete.             "
echo "==============================================" 

sleep 5

clear

# Create LXC DNS DHCP container.

echo ''
echo "=============================================="
echo "Create LXC DNS DHCP container...       "
echo "=============================================="
echo ''

sudo lxc-create -t download -n nsa -- --dist ubuntu --release xenial --arch amd64

echo ''
echo "=============================================="
echo "Create LXC DNS DHCP container complete."
echo "=============================================="

sleep 5

clear

echo ''
echo "=============================================="
echo "Install & configure DNS DHCP LXC container... "
echo "=============================================="

echo ''
sudo touch /var/lib/lxc/nsa/rootfs/etc/resolv.conf
sudo sed -i '0,/.*nameserver.*/s/.*nameserver.*/nameserver 8.8.8.8\n&/' /var/lib/lxc/nsa/rootfs/etc/resolv.conf
sudo lxc-start -n nsa
echo ''

sleep 5 

clear

echo ''
echo "=============================================="
echo "Testing lxc-attach for ubuntu user...         "
echo "=============================================="
echo ''


sudo lxc-attach -n nsa -- uname -a
if [ $? -ne 0 ]
then
	echo ''
	echo "=============================================="
	echo "lxc-attach has issue(s).                      "
	echo "=============================================="
else
	echo ''
	echo "=============================================="
	echo "lxc-attach successful.                        "
	echo "=============================================="

	sleep 5 
fi

sleep 5

clear

echo ''
echo "=============================================="
echo "Install bind9 & isc-dhcp-server in container. "
echo "Install openssh-server in container.          "
echo "=============================================="
echo ''

sudo lxc-attach -n nsa -- sudo apt-get -y update
sudo lxc-attach -n nsa -- sudo apt-get -y install bind9 isc-dhcp-server bind9utils dnsutils openssh-server

sleep 2

sudo lxc-attach -n nsa -- sudo service isc-dhcp-server start
sudo lxc-attach -n nsa -- sudo service bind9 start

echo ''
echo "=============================================="
echo "Install bind9 & isc-dhcp-server complete.     "
echo "Install openssh-server complete.              "
echo "=============================================="

sleep 5

clear

echo ''
echo "=============================================="
echo "DNS DHCP installed in LXC container.          "
echo "=============================================="

sleep 5

clear

echo ''
echo "=============================================="
echo "Stopping DNS DHCP LXC container...            "
echo "=============================================="
echo ''

sudo lxc-stop -n nsa
sudo lxc-info -n nsa

echo ''
echo "=============================================="
echo "DNS DHCP LXC container stopped.               "
echo "=============================================="
echo ''

sleep 5 

clear

# Unpack customized OS host files for Oracle on LXC host server

echo ''
echo "=============================================="
echo "Unpacking G1 host files for Oracle Linux...   "
echo "=============================================="
echo ''

sudo tar -P -xvf /home/ubuntu/Downloads/orabuntu-lxc-master/uekulele/archives/ubuntu-host.tar   --touch

echo ''
echo "=============================================="
echo "G1 host files for Oracle Linux unpacked.      "
echo "=============================================="

sleep 5

clear

echo ''
echo "=============================================="
echo "Unpacking G2 host files for Oracle Linux...   "
echo "=============================================="
echo ''

sudo tar -P -xvf /home/ubuntu/Downloads/orabuntu-lxc-master/uekulele/archives/dns-dhcp-host.tar --touch

echo ''
echo "=============================================="
echo "G2 host files for Oracle Linux unpacked.      "
echo "=============================================="

sleep 5

clear

echo ''
echo "=============================================="
echo "Custom files for Oracle Linux installed.      "
echo "=============================================="

sleep 5

clear

echo ''
echo "=============================================="
echo "Creating /etc/sysctl.d/60-oracle.conf file ..."
echo "=============================================="
echo ''
echo "=============================================="
echo "These values are set automatically based on   "
echo "Oracle best practice guidelines.              "
echo "You can adjust them after installation.       "
echo "=============================================="
echo ''

if [ -r /etc/sysctl.d/60-oracle.conf ]
then
sudo cp -p /etc/sysctl.d/60-oracle.conf /etc/sysctl.d/60-oracle.conf.pre.orabuntu-lxc.bak
sudo rm /etc/sysctl.d/60-oracle.conf
fi

sudo touch /etc/sysctl.d/60-oracle.conf
sudo cat /etc/sysctl.d/60-oracle.conf
sudo chmod +x /etc/sysctl.d/60-oracle.conf

echo 'Linux OS Memory Reservation (in Kb) ... '$LinuxOSMemoryReservation 
function GetMemTotal {
sudo cat /proc/meminfo | grep MemTotal | cut -f2 -d':' |  sed 's/  *//g' | cut -f1 -d'k'
}
MemTotal=$(GetMemTotal)
echo 'Memory (in Kb) ........................ '$MemTotal

((MemOracleKb = MemTotal - LinuxOSMemoryReservation))
echo 'Memory for Oracle (in Kb) ............. '$MemOracleKb

((MemOracleBytes = MemOracleKb * 1024))
echo 'Memory for Oracle (in bytes) .......... '$MemOracleBytes

function GetPageSize {
sudo getconf PAGE_SIZE
}
PageSize=$(GetPageSize)
echo 'Page Size (in bytes) .................. '$PageSize

((shmall = MemOracleBytes / 4096))
echo 'shmall (in 4Kb pages) ................. '$shmall
sudo sysctl -w kernel.shmall=$shmall

((shmmax = MemOracleBytes / 2))
echo 'shmmax (in bytes) ..................... '$shmmax
sudo sysctl -w kernel.shmmax=$shmmax

sudo sh -c "echo '# New Stack Settings'                       > /etc/sysctl.d/60-oracle.conf"
sudo sh -c "echo ''                                          >> /etc/sysctl.d/60-oracle.conf"
sudo sh -c "echo 'net.ipv4.conf.default.rp_filter=0'         >> /etc/sysctl.d/60-oracle.conf"
sudo sh -c "echo 'net.ipv4.conf.all.rp_filter=0'             >> /etc/sysctl.d/60-oracle.conf"
sudo sh -c "echo 'net.ipv4.ip_forward=1'                     >> /etc/sysctl.d/60-oracle.conf"
sudo sh -c "echo ''                                          >> /etc/sysctl.d/60-oracle.conf"
sudo sh -c "echo '# Oracle Settings'                         >> /etc/sysctl.d/60-oracle.conf"
sudo sh -c "echo ''                                          >> /etc/sysctl.d/60-oracle.conf"
sudo sh -c "echo 'kernel.shmall = $shmall'                   >> /etc/sysctl.d/60-oracle.conf"
sudo sh -c "echo 'kernel.shmmax = $shmmax'                   >> /etc/sysctl.d/60-oracle.conf"
sudo sh -c "echo 'kernel.shmmni = 4096'                      >> /etc/sysctl.d/60-oracle.conf"
sudo sh -c "echo 'kernel.sem = 250 32000 100 128'            >> /etc/sysctl.d/60-oracle.conf"
sudo sh -c "echo 'fs.file-max = 6815744'                     >> /etc/sysctl.d/60-oracle.conf"
sudo sh -c "echo 'fs.aio-max-nr = 1048576'                   >> /etc/sysctl.d/60-oracle.conf"
sudo sh -c "echo 'net.ipv4.ip_local_port_range = 9000 65500' >> /etc/sysctl.d/60-oracle.conf"
sudo sh -c "echo 'net.core.rmem_default = 262144'            >> /etc/sysctl.d/60-oracle.conf"
sudo sh -c "echo 'net.core.rmem_max = 4194304'               >> /etc/sysctl.d/60-oracle.conf"
sudo sh -c "echo 'net.core.wmem_default = 262144'            >> /etc/sysctl.d/60-oracle.conf"
sudo sh -c "echo 'net.core.wmem_max = 1048576'               >> /etc/sysctl.d/60-oracle.conf"
sudo sh -c "echo 'vm.nr_hugepages = 3500'                    >> /etc/sysctl.d/60-oracle.conf"
sudo sh -c "echo 'kernel.panic_on_oops = 1'                  >> /etc/sysctl.d/60-oracle.conf"

echo ''
echo "=============================================="
echo "Display /etc/sysctl.d/60-oracle.conf"
echo "=============================================="
echo ''

sudo sysctl -p /etc/sysctl.d/60-oracle.conf

if [ ! -f /etc/systemd/system/60-oracle.service ]
then
sudo sh -c "echo '[Unit]'                                    > /etc/systemd/system/60-oracle.service"
sudo sh -c "echo 'Description=60-oracle Service'            >> /etc/systemd/system/60-oracle.service"
sudo sh -c "echo 'After=network.target'                     >> /etc/systemd/system/60-oracle.service"
sudo sh -c "echo ''                                         >> /etc/systemd/system/60-oracle.service"
sudo sh -c "echo '[Service]'                                >> /etc/systemd/system/60-oracle.service"
sudo sh -c "echo 'Type=oneshot'                             >> /etc/systemd/system/60-oracle.service"
sudo sh -c "echo 'User=root'                                >> /etc/systemd/system/60-oracle.service"
sudo sh -c "echo 'RemainAfterExit=yes'                      >> /etc/systemd/system/60-oracle.service"
sudo sh -c "echo 'ExecStart=/etc/sysctl.d/60-oracle.conf'   >> /etc/systemd/system/60-oracle.service"
sudo sh -c "echo ''                                         >> /etc/systemd/system/60-oracle.service"
sudo sh -c "echo '[Install]'                                >> /etc/systemd/system/60-oracle.service"
sudo sh -c "echo 'WantedBy=multi-user.target'               >> /etc/systemd/system/60-oracle.service"

sudo chmod 644 /etc/systemd/system/60-oracle.service
echo ''
sudo systemctl enable 60-oracle
echo ''
fi

echo "=============================================="
echo "Created /etc/sysctl.d/60-oracle.conf          "
echo "Sleeping 10 seconds for settings review ...   "
echo "=============================================="
echo ''

sleep 5

clear

echo ''
echo "=============================================="
echo "Creating /etc/security/limits.d/70-oracle.conf"
echo "=============================================="
echo ''
echo "=============================================="
echo "These values are set automatically based on   "
echo "Oracle best practice guidelines.              "
echo "You can adjust them after installation.       "
echo "=============================================="
echo ''

sudo touch /etc/security/limits.d/70-oracle.conf
sudo chmod +x /etc/security/limits.d/70-oracle.conf

# Oracle Kernel Parameters

sudo sh -c "echo '#                                        '  > /etc/security/limits.d/70-oracle.conf"
sudo sh -c "echo '# Oracle DB Parameters                   ' >> /etc/security/limits.d/70-oracle.conf"
sudo sh -c "echo '#                                        ' >> /etc/security/limits.d/70-oracle.conf"
sudo sh -c "echo 'oracle	soft	nproc       2047   ' >> /etc/security/limits.d/70-oracle.conf"
sudo sh -c "echo 'oracle	hard	nproc      16384   ' >> /etc/security/limits.d/70-oracle.conf"
sudo sh -c "echo 'oracle	soft	nofile      1024   ' >> /etc/security/limits.d/70-oracle.conf"
sudo sh -c "echo 'oracle	hard	nofile     65536   ' >> /etc/security/limits.d/70-oracle.conf"
sudo sh -c "echo 'oracle	soft	stack      10240   ' >> /etc/security/limits.d/70-oracle.conf"
sudo sh -c "echo 'oracle	hard	stack      10240   ' >> /etc/security/limits.d/70-oracle.conf"
sudo sh -c "echo '* 	soft 	memlock  9873408           ' >> /etc/security/limits.d/70-oracle.conf"
sudo sh -c "echo '* 	hard 	memlock  9873408           ' >> /etc/security/limits.d/70-oracle.conf"

# Oracle Grid Infrastructure Kernel Parameters
	
sudo sh -c "echo '#                                        ' >> /etc/security/limits.d/70-oracle.conf"
sudo sh -c "echo '# Oracle GI Parameters                   ' >> /etc/security/limits.d/70-oracle.conf"
sudo sh -c "echo '#                                        ' >> /etc/security/limits.d/70-oracle.conf"
sudo sh -c "echo 'grid	soft	nproc       2047           ' >> /etc/security/limits.d/70-oracle.conf"
sudo sh -c "echo 'grid	hard	nproc      16384           ' >> /etc/security/limits.d/70-oracle.conf"
sudo sh -c "echo 'grid	soft	nofile      1024           ' >> /etc/security/limits.d/70-oracle.conf"
sudo sh -c "echo 'grid	hard	nofile     65536           ' >> /etc/security/limits.d/70-oracle.conf"
sudo sh -c "echo 'grid	soft	stack      10240           ' >> /etc/security/limits.d/70-oracle.conf"
sudo sh -c "echo 'grid	hard	stack      10240           ' >> /etc/security/limits.d/70-oracle.conf"

echo "=============================================="
echo 'Display /etc/security/limits.d/70-oracle.conf '
echo "=============================================="
echo ''
sudo cat /etc/security/limits.d/70-oracle.conf
echo ''
echo "=============================================="
echo "Created /etc/security/limits.d/70-oracle.conf "
echo "Sleeping 10 seconds for settings review ...   "
echo "=============================================="
echo ''

sleep 10

clear

# Unpack customized OS host files for Oracle on LXC host server

echo ''
echo "=============================================="
echo "Unpacking LXC nameserver custom files...      "
echo "=============================================="
echo ''
	
sudo tar -P -xvf /home/ubuntu/Downloads/orabuntu-lxc-master/uekulele/archives/dns-dhcp-cont.tar --touch

echo ''
echo "=============================================="
echo "Custom files unpack complete                  "
echo "=============================================="

sleep 10

clear

echo ''
echo "=============================================="
echo "Customize nameserver & domains ...            "
echo "=============================================="
echo ''

function GetHOSTNAME {
	echo $HOSTNAME | cut -f1 -d'.'
}
HOSTNAME=$(GetHOSTNAME)

# Remove the extra nameserver line used for DNS DHCP setup and add the required nameservers.
	
	sudo sed -i '/8.8.8.8/d' /var/lib/lxc/nsa/rootfs/etc/resolv.conf
	sudo sed -i '/nameserver/c\nameserver 10.207.39.2' /var/lib/lxc/nsa/rootfs/etc/resolv.conf
	sudo sh -c "echo 'nameserver 10.207.29.2' >> /var/lib/lxc/nsa/rootfs/etc/resolv.conf"
	sudo sh -c "echo 'search orabuntu-lxc.com consultingcommandos.us' >> /var/lib/lxc/nsa/rootfs/etc/resolv.conf"

if [ ! -z $HOSTNAME ]
then
	sudo sed -i "/baremetal/s/baremetal/$HOSTNAME/g" /var/lib/lxc/nsa/rootfs/var/lib/bind/fwd.orabuntu-lxc.com
	sudo sed -i "/baremetal/s/baremetal/$HOSTNAME/g" /var/lib/lxc/nsa/rootfs/var/lib/bind/rev.orabuntu-lxc.com
	sudo sed -i "/baremetal/s/baremetal/$HOSTNAME/g" /var/lib/lxc/nsa/rootfs/var/lib/bind/fwd.consultingcommandos.us
	sudo sed -i "/baremetal/s/baremetal/$HOSTNAME/g" /var/lib/lxc/nsa/rootfs/var/lib/bind/rev.consultingcommandos.us
fi

if [ -n $NameServer ]
then
	# GLS 20151223 Settable Nameserver feature added
	# GLS 20161022 Settable Nameserver feature moved into DNS DHCP LXC container.
	# GLS 20162011 Settable Nameserver feature expanded to include nameserver and both domains.
	sudo sed -i "/nsa/s/nsa/$NameServer/g" /var/lib/lxc/nsa/rootfs/var/lib/bind/fwd.orabuntu-lxc.com
	sudo sed -i "/nsa/s/nsa/$NameServer/g" /var/lib/lxc/nsa/rootfs/var/lib/bind/rev.orabuntu-lxc.com
	sudo sed -i "/nsa/s/nsa/$NameServer/g" /var/lib/lxc/nsa/rootfs/var/lib/bind/fwd.consultingcommandos.us
	sudo sed -i "/nsa/s/nsa/$NameServer/g" /var/lib/lxc/nsa/rootfs/var/lib/bind/rev.consultingcommandos.us
	sudo sed -i "/nsa/s/nsa/$NameServer/g" /var/lib/lxc/nsa/config
	sudo sed -i "/nsa/s/nsa/$NameServer/g" /var/lib/lxc/nsa/rootfs/etc/hostname
	sudo sed -i "/nsa/s/nsa/$NameServer/g" /var/lib/lxc/nsa/rootfs/etc/hosts
	sudo sed -i '/strt/s/^# //' /etc/network/if-up.d/orabuntu-lxc-net
	sudo sed -i "/nsa/s/nsa/$NameServer/g" /etc/network/if-up.d/orabuntu-lxc-net
	sudo sed -i "/nsa/s/nsa/$NameServer/g" /etc/network/openvswitch/strt_nsa.sh
	sudo mv /var/lib/lxc/nsa /var/lib/lxc/$NameServer
	sudo mv /etc/network/if-up.d/openvswitch/nsa-pub-ifup-sw1 /etc/network/if-up.d/openvswitch/$NameServer-pub-ifup-sw1
	sudo mv /etc/network/if-down.d/openvswitch/nsa-pub-ifdown-sw1 /etc/network/if-down.d/openvswitch/$NameServer-pub-ifdown-sw1
	sudo mv /etc/network/if-up.d/openvswitch/nsa-pub-ifup-sx1 /etc/network/if-up.d/openvswitch/$NameServer-pub-ifup-sx1
	sudo mv /etc/network/if-down.d/openvswitch/nsa-pub-ifdown-sx1 /etc/network/if-down.d/openvswitch/$NameServer-pub-ifdown-sx1
	sudo mv /etc/network/openvswitch/strt_nsa.sh /etc/network/openvswitch/strt_$NameServer.sh
fi

if [ -n $Domain1 ]
then
	# GLS 20151221 Settable Domain feature added
	sudo sed -i "/orabuntu-lxc\.com/s/orabuntu-lxc\.com/$Domain1/g" /var/lib/lxc/$NameServer/rootfs/var/lib/bind/fwd.orabuntu-lxc.com
	sudo sed -i "/orabuntu-lxc\.com/s/orabuntu-lxc\.com/$Domain1/g" /var/lib/lxc/$NameServer/rootfs/var/lib/bind/rev.orabuntu-lxc.com
	sudo sed -i "/orabuntu-lxc\.com/s/orabuntu-lxc\.com/$Domain1/g" /var/lib/lxc/$NameServer/rootfs/etc/resolv.conf
	sudo sed -i "/orabuntu-lxc\.com/s/orabuntu-lxc\.com/$Domain1/g" /etc/NetworkManager/dnsmasq.d/local
	sudo sed -i "/orabuntu-lxc\.com/s/orabuntu-lxc\.com/$Domain1/g" /etc/network/openvswitch/crt_ovs_sw1.sh
#	sudo sed -i "/orabuntu-lxc\.com/s/orabuntu-lxc\.com/$Domain1/g" /etc/network/interfaces
	sudo sed -i "/orabuntu-lxc\.com/s/orabuntu-lxc\.com/$Domain1/g" /var/lib/lxc/$NameServer/rootfs/etc/bind/named.conf.local
	sudo sed -i "/orabuntu-lxc\.com/s/orabuntu-lxc\.com/$Domain1/g" /var/lib/lxc/$NameServer/rootfs/etc/dhcp/dhcpd.conf
	sudo sed -i "/orabuntu-lxc\.com/s/orabuntu-lxc\.com/$Domain1/g" /var/lib/lxc/$NameServer/rootfs/etc/network/interfaces
	sudo mv /var/lib/lxc/$NameServer/rootfs/var/lib/bind/fwd.orabuntu-lxc.com /var/lib/lxc/$NameServer/rootfs/var/lib/bind/fwd.$Domain1
	sudo mv /var/lib/lxc/$NameServer/rootfs/var/lib/bind/rev.orabuntu-lxc.com /var/lib/lxc/$NameServer/rootfs/var/lib/bind/rev.$Domain1
fi

if [ -n $Domain2 ]
then
	# GLS 20151221 Settable Domain feature added
	sudo sed -i "/consultingcommandos\.us/s/consultingcommandos\.us/$Domain2/g" /var/lib/lxc/$NameServer/rootfs/var/lib/bind/fwd.consultingcommandos.us
	sudo sed -i "/consultingcommandos\.us/s/consultingcommandos\.us/$Domain2/g" /var/lib/lxc/$NameServer/rootfs/var/lib/bind/rev.consultingcommandos.us
	sudo sed -i "/consultingcommandos\.us/s/consultingcommandos\.us/$Domain2/g" /var/lib/lxc/$NameServer/rootfs/etc/resolv.conf
	sudo sed -i "/consultingcommandos\.us/s/consultingcommandos\.us/$Domain2/g" /etc/NetworkManager/dnsmasq.d/local
	sudo sed -i "/consultingcommandos\.us/s/consultingcommandos\.us/$Domain2/g" /etc/network/openvswitch/crt_ovs_sw1.sh
#	sudo sed -i "/consultingcommandos\.us/s/consultingcommandos\.us/$Domain2/g" /etc/network/interfaces
	sudo sed -i "/consultingcommandos\.us/s/consultingcommandos\.us/$Domain2/g" /var/lib/lxc/$NameServer/rootfs/etc/bind/named.conf.local
	sudo sed -i "/consultingcommandos\.us/s/consultingcommandos\.us/$Domain2/g" /var/lib/lxc/$NameServer/rootfs/etc/dhcp/dhcpd.conf
	sudo sed -i "/consultingcommandos\.us/s/consultingcommandos\.us/$Domain2/g" /var/lib/lxc/$NameServer/rootfs/etc/network/interfaces
	sudo mv /var/lib/lxc/$NameServer/rootfs/var/lib/bind/fwd.consultingcommandos.us /var/lib/lxc/$NameServer/rootfs/var/lib/bind/fwd.$Domain2
	sudo mv /var/lib/lxc/$NameServer/rootfs/var/lib/bind/rev.consultingcommandos.us /var/lib/lxc/$NameServer/rootfs/var/lib/bind/rev.$Domain2
fi

# Cleanup duplicate search lines in /etc/resolv.conf if Orabuntu-LXC has been re-run
sudo sed -i '$!N; /^\(.*\)\n\1$/!P; D' /etc/resolv.conf

sudo cat /etc/resolv.conf

sleep 5

echo ''
echo "=============================================="
echo "Customize nameserver & domains complete.      "
echo "=============================================="

sleep 5

clear

echo ''
echo "=============================================="
echo "Activating NetworkManager dnsmasq service ... "
echo "=============================================="
echo ''

# So that settings in /etc/NetworkManager/dnsmasq.d/local & /etc/NetworkManager/NetworkManager.conf take effect.

sudo cat /etc/resolv.conf
sudo sed -i '/plugins=ifcfg-rh/a dns=dnsmasq' /etc/NetworkManager/NetworkManager.conf
echo ''
sudo service NetworkManager restart

sleep 10

sudo sh -c "echo 'search $Domain1 $Domain2' >> /etc/resolv.conf"
echo ''
sudo cat /etc/resolv.conf

echo ''
echo "=============================================="
echo "NetworkManager dnsmasq activated.             "
echo "=============================================="

sleep 5

clear

echo ''
echo "=============================================="
echo "Setting secret in dhcpd.conf file...          "
echo "============================================="
echo ''

function GetKeySecret {
sudo cat /var/lib/lxc/$NameServer/rootfs/etc/bind/rndc.key | grep secret | sed 's/^[ \t]*//;s/[ \t]*$//'
}
KeySecret=$(GetKeySecret)
echo $KeySecret
sudo sed -i "/secret/c\key rndc-key { algorithm hmac-md5; $KeySecret }" /var/lib/lxc/$NameServer/rootfs/etc/dhcp/dhcpd.conf
echo 'The following keys should match (for dynamic DNS updates by DHCP):'
echo ''
sudo cat /var/lib/lxc/$NameServer/rootfs/etc/dhcp/dhcpd.conf | grep secret | cut -f7 -d' ' | cut -f1 -d';'
sudo cat /var/lib/lxc/$NameServer/rootfs/etc/bind/rndc.key   | grep secret | cut -f2 -d' ' | cut -f1 -d';'
echo ''
sudo cat /var/lib/lxc/$NameServer/rootfs/etc/dhcp/dhcpd.conf | grep secret

echo ''
echo "=============================================="
echo "Secret successfuly set in dhcpd.conf file.    "
echo "=============================================="

sleep 5

clear

echo ''
echo "=============================================="
echo "Customize nameserver & domains completed.     "
echo "=============================================="

sleep 5

clear

echo ''
echo "=============================================="
echo "Create $NameServer Onboot Service...          "
echo "=============================================="
echo ''

sudo sh -c "echo '[Unit]'             	         				 > /etc/systemd/system/$NameServer.service"
sudo sh -c "echo 'Description=$NameServer Service'  				>> /etc/systemd/system/$NameServer.service"
sudo sh -c "echo 'After=network.target'             				>> /etc/systemd/system/$NameServer.service"
sudo sh -c "echo ''                                 				>> /etc/systemd/system/$NameServer.service"
sudo sh -c "echo '[Service]'                        				>> /etc/systemd/system/$NameServer.service"
sudo sh -c "echo 'Type=oneshot'                     				>> /etc/systemd/system/$NameServer.service"
sudo sh -c "echo 'User=root'                        				>> /etc/systemd/system/$NameServer.service"
sudo sh -c "echo 'RemainAfterExit=yes'              				>> /etc/systemd/system/$NameServer.service"
sudo sh -c "echo 'ExecStart=/etc/network/openvswitch/strt_$NameServer.sh'	>> /etc/systemd/system/$NameServer.service"
sudo sh -c "echo ''                                 				>> /etc/systemd/system/$NameServer.service"
sudo sh -c "echo '[Install]'                        				>> /etc/systemd/system/$NameServer.service"
sudo sh -c "echo 'WantedBy=multi-user.target'       				>> /etc/systemd/system/$NameServer.service"
sudo chmod 644 /etc/systemd/system/$NameServer.service
sudo systemctl enable $NameServer

# done

echo ''
echo "=============================================="
echo "Created $NameServer Onboot Service.           "
echo "=============================================="
echo ''

sleep 5

clear

echo ''
echo "=============================================="
echo "Starting OpenvSwitch sw1 ...                  "
echo "=============================================="

sudo /etc/network/openvswitch/crt_ovs_sw1.sh >/dev/null 2>&1
echo ''
sleep 3
ifconfig sw1

echo "=============================================="
echo "OpenvSwitch sw1 started.                      "
echo "=============================================="
echo ''

sleep 5

clear

echo ''
echo "=============================================="
echo "Starting OpenvSwitch sx1 ...                  "
echo "=============================================="

sudo /etc/network/openvswitch/crt_ovs_sx1.sh >/dev/null 2>&1
echo ''
sleep 3
ifconfig sx1
sudo sed -i '/sx1/s/^# //g' /etc/network/if-up.d/orabuntu-lxc-net

echo "=============================================="
echo "OpenvSwitch sx1 started.                      "
echo "=============================================="
echo ''

sleep 5

clear

echo ''
echo "=============================================="
echo "Create OpenvSwitch Onboot Services...         "
echo "=============================================="
echo ''

for k in $SwitchList
do
	sudo sh -c "echo '[Unit]'                                                > /etc/systemd/system/$k.service"
	sudo sh -c "echo 'Description=$k Service'                               >> /etc/systemd/system/$k.service"
	sudo sh -c "echo 'After=network.target'                                 >> /etc/systemd/system/$k.service"
	sudo sh -c "echo ''                                                     >> /etc/systemd/system/$k.service"
	sudo sh -c "echo '[Service]'                                            >> /etc/systemd/system/$k.service"
	sudo sh -c "echo 'Type=oneshot'                                         >> /etc/systemd/system/$k.service"
	sudo sh -c "echo 'User=root'                                            >> /etc/systemd/system/$k.service"
	sudo sh -c "echo 'RemainAfterExit=yes'                                  >> /etc/systemd/system/$k.service"
	sudo sh -c "echo 'ExecStart=/etc/network/openvswitch/crt_ovs_$k.sh'     >> /etc/systemd/system/$k.service"
	sudo sh -c "echo ''                                                     >> /etc/systemd/system/$k.service"
	sudo sh -c "echo '[Install]'                                            >> /etc/systemd/system/$k.service"
	sudo sh -c "echo 'WantedBy=multi-user.target'                           >> /etc/systemd/system/$k.service"
	sudo chmod 644 /etc/systemd/system/$k.service
	sudo systemctl enable $k.service
	echo ''
done

sudo systemctl daemon-reload

for k in $SwitchList
do
	sudo service $k start
	sudo service $k status

	sleep 5

	clear
done
 
echo "=============================================="
echo s"OpenvSwitch Onboot Services Created.          "
echo "=============================================="
echo ''

sleep 5

clear

echo ''
echo "=============================================="
echo "Verify iptables rules are set correctly...    "
echo "=============================================="
echo ''

sleep 5

sudo iptables -S

echo ''
echo "=============================================="
echo "Verification of iptables rules complete.      "
echo "=============================================="
echo ''

sleep 5

clear

echo "=============================================="
echo "Ensure both required networks up...           "
echo "=============================================="
echo ''

ifconfig sw1
ifconfig sx1

echo "=============================================="
echo "Networks are up.                              "
echo "=============================================="
echo ''

sleep 5

clear

echo ''
echo "=============================================="
echo "Starting LXC container and testing DNS...   "
echo "=============================================="
echo ''

if [ -n $NameServer ]
then
	sudo lxc-start -n $NameServer > /dev/null 2>&1
	nslookup $NameServer
	if [ $? -ne 0 ]
	then
		echo "DNS is NOT RUNNING with correct status!"
	fi
else
	sudo lxc-start -n nsa > /dev/null 2>&1
	nslookup nsa
	if [ $? -ne 0 ]
	then
		echo "DNS is NOT RUNNING with correct status!"
	fi
fi

echo ''
echo "=============================================="
echo "LXC container restarted & DNS tested.         "
echo "=============================================="

sleep 5

clear

echo ''
echo "=============================================="
echo "Moving seed openvswitch veth files...         "
echo "=============================================="
echo ''

if [ ! -e /etc/uekulele-release ] || [ ! -e /etc/network/if-up.d/lxcora00-pub-ifup-sw1 ] || [ ! -e /etc/network/if-down.d/lxcora00-pub-ifdown-sw1 ]
then
	cd /etc/network/if-up.d/openvswitch

	sudo cp lxcora00-asm1-ifup-sw8  oel$OracleRelease-asm1-ifup-sw8
	sudo cp lxcora00-asm2-ifup-sw9  oel$OracleRelease-asm2-ifup-sw9
	sudo cp lxcora00-priv1-ifup-sw4 oel$OracleRelease-priv1-ifup-sw4
	sudo cp lxcora00-priv2-ifup-sw5 oel$OracleRelease-priv2-ifup-sw5
	sudo cp lxcora00-priv3-ifup-sw6 oel$OracleRelease-priv3-ifup-sw6 
	sudo cp lxcora00-priv4-ifup-sw7 oel$OracleRelease-priv4-ifup-sw7
	sudo cp lxcora00-pub-ifup-sw1   oel$OracleRelease-pub-ifup-sw1

	cd /etc/network/if-down.d/openvswitch

	sudo cp lxcora00-asm1-ifdown-sw8  oel$OracleRelease-asm1-ifdown-sw8
	sudo cp lxcora00-asm2-ifdown-sw9  oel$OracleRelease-asm2-ifdown-sw9
	sudo cp lxcora00-priv1-ifdown-sw4 oel$OracleRelease-priv1-ifdown-sw4
	sudo cp lxcora00-priv2-ifdown-sw5 oel$OracleRelease-priv2-ifdown-sw5
	sudo cp lxcora00-priv3-ifdown-sw6 oel$OracleRelease-priv3-ifdown-sw6
	sudo cp lxcora00-priv4-ifdown-sw7 oel$OracleRelease-priv4-ifdown-sw7
	sudo cp lxcora00-pub-ifdown-sw1   oel$OracleRelease-pub-ifdown-sw1

	sudo ls -l /etc/network/if-up.d/openvswitch
	echo ''
	sudo ls -l /etc/network/if-down.d/openvswitch
fi

echo ''
echo "=============================================="
echo "Moving seed openvswitch veth files complete.  "
echo "=============================================="
echo ''

sleep 5

clear

echo ''
echo "=============================================="
echo "Verify existence of Oracle and Grid users...  "
echo "=============================================="
echo ''

sudo useradd -u 1098 grid >/dev/null 2>&1
sudo useradd -u 500 oracle >/dev/null 2>&1

id grid
id oracle

echo ''
echo "=============================================="
echo "Existence of Oracle and Grid users verified.  "
echo "=============================================="

sleep 5

clear

echo ''
echo "=============================================="
echo "Create /etc/uekulele-release file...          "
echo "=============================================="
echo ''

sudo touch /etc/uekulele-release
sudo sh -c "echo 'Orabuntu-LXC v4.0' > /etc/uekulele-release"
sudo ls -l /etc/uekulele-release

echo ''
echo "=============================================="
echo "Create /etc/uekulele-release file complete.   "
echo "=============================================="

sleep 5

clear

echo ''
echo "=============================================="
echo "Create the LXC oracle container...            "
echo "=============================================="
echo ''

sudo lxc-create -n oel$OracleRelease -t oracle -- --release=$OracleVersion

echo ''
echo "=============================================="
echo "Create the LXC oracle container complete      "
echo "(Passwords are the same as the usernames)     "
echo "Sleeping 5 seconds...                         "
echo "=============================================="
echo ''

sleep 5

clear

echo ''
echo "=============================================="
echo "Create the crt_links.sh script...             "
echo "=============================================="
echo ''

sudo mkdir -p /etc/orabuntu-lxc-scripts

sudo sh -c "echo ' ln -sf /var/lib/lxc .' 								    > /etc/orabuntu-lxc-scripts/crt_links.sh"
sudo sh -c "echo ' ln -sf /etc/resolv.conf .' 								   >> /etc/orabuntu-lxc-scripts/crt_links.sh"

if [ -n $NameServer ]
then
	sudo sh -c "echo ' ln -sf /etc/network/if-up.d/openvswitch/$NameServer-pub-ifup-sw1 .' 		   >> /etc/orabuntu-lxc-scripts/crt_links.sh"
	sudo sh -c "echo ' ln -sf /etc/network/if-up.d/openvswitch/$NameServer-pub-ifup-sx1 .' 		   >> /etc/orabuntu-lxc-scripts/crt_links.sh"
	sudo sh -c "echo ' ln -sf /etc/network/if-down.d/openvswitch/$NameServer-pub-ifdown-sw1 .'	   >> /etc/orabuntu-lxc-scripts/crt_links.sh"
	sudo sh -c "echo ' ln -sf /etc/network/if-down.d/openvswitch/$NameServer-pub-ifdown-sx1 .'	   >> /etc/orabuntu-lxc-scripts/crt_links.sh"
	sudo sh -c "echo ' ln -sf /var/lib/lxc/$NameServer/rootfs/etc/resolv.conf .' 			   >> /etc/orabuntu-lxc-scripts/crt_links.sh"
	sudo sh -c "echo ' ln -sf /var/lib/lxc/$NameServer/rootfs/etc/network/interfaces .'		   >> /etc/orabuntu-lxc-scripts/crt_links.sh"
	sudo sh -c "echo ' ln -sf /var/lib/lxc/$NameServer/rootfs/etc/bind/rndc.key .' 			   >> /etc/orabuntu-lxc-scripts/crt_links.sh"
	sudo sh -c "echo ' ln -sf /var/lib/lxc/$NameServer/rootfs/etc/default/bind9 .' 			   >> /etc/orabuntu-lxc-scripts/crt_links.sh"
	sudo sh -c "echo ' ln -sf /var/lib/lxc/$NameServer/rootfs/var/lib/dhcp/dhcpd.leases .' 		   >> /etc/orabuntu-lxc-scripts/crt_links.sh"
	sudo sh -c "echo ' ln -sf /var/lib/lxc/$NameServer/rootfs/etc/dhcp .' 				   >> /etc/orabuntu-lxc-scripts/crt_links.sh"
	sudo sh -c "echo ' ln -sf /var/lib/lxc/$NameServer/rootfs/etc/dhcp/dhcpd.conf .' 		   >> /etc/orabuntu-lxc-scripts/crt_links.sh"
	sudo sh -c "echo ' ln -sf /var/lib/lxc/$NameServer/rootfs/etc/default/isc-dhcp-server .' 	   >> /etc/orabuntu-lxc-scripts/crt_links.sh"
	sudo sh -c "echo ' ln -sf /var/lib/lxc/$NameServer/rootfs/etc/default/bind9 .' 			   >> /etc/orabuntu-lxc-scripts/crt_links.sh"
	sudo sh -c "echo ' ln -sf /var/lib/lxc/$NameServer/rootfs/etc/bind/named.conf .' 		   >> /etc/orabuntu-lxc-scripts/crt_links.sh"
	sudo sh -c "echo ' ln -sf /var/lib/lxc/$NameServer/rootfs/etc/bind/named.conf.local .' 		   >> /etc/orabuntu-lxc-scripts/crt_links.sh"
	sudo sh -c "echo ' ln -sf /var/lib/lxc/$NameServer/rootfs/etc/bind/named.conf.options .' 		   >> /etc/orabuntu-lxc-scripts/crt_links.sh"
fi
if [ ! -n $NameServer ]
then
	sudo sh -c "echo ' ln -sf /etc/network/if-up.d/openvswitch/nsa-pub-ifup-sw1 .' 			   >> /etc/orabuntu-lxc-scripts/crt_links.sh"
	sudo sh -c "echo ' ln -sf /etc/network/if-up.d/openvswitch/nsa-pub-ifup-sx1 .' 			   >> /etc/orabuntu-lxc-scripts/crt_links.sh"
	sudo sh -c "echo ' ln -sf /etc/network/if-down.d/openvswitch/nsa-pub-ifdown-sw1 .'		   >> /etc/orabuntu-lxc-scripts/crt_links.sh"
	sudo sh -c "echo ' ln -sf /etc/network/if-down.d/openvswitch/nsa-pub-ifdown-sx1 .'		   >> /etc/orabuntu-lxc-scripts/crt_links.sh"
	sudo sh -c "echo ' ln -sf /var/lib/lxc/nsa/rootfs/etc/resolv.conf .' 				   >> /etc/orabuntu-lxc-scripts/crt_links.sh"
	sudo sh -c "echo ' ln -sf /var/lib/lxc/nsa/rootfs/etc/bind/rndc.key .' 				   >> /etc/orabuntu-lxc-scripts/crt_links.sh"
	sudo sh -c "echo ' ln -sf /var/lib/lxc/nsa/rootfs/etc/default/bind9 .' 				   >> /etc/orabuntu-lxc-scripts/crt_links.sh"
	sudo sh -c "echo ' ln -sf /var/lib/lxc/nsa/rootfs/var/lib/dhcp/dhcpd.leases .' 			   >> /etc/orabuntu-lxc-scripts/crt_links.sh"
	sudo sh -c "echo ' ln -sf /var/lib/lxc/nsa/rootfs/etc/dhcp .' 					   >> /etc/orabuntu-lxc-scripts/crt_links.sh"
	sudo sh -c "echo ' ln -sf /var/lib/lxc/nsa/rootfs/etc/dhcp/dhcpd.conf .' 			   >> /etc/orabuntu-lxc-scripts/crt_links.sh"
	sudo sh -c "echo ' ln -sf /var/lib/lxc/nsa/rootfs/etc/default/isc-dhcp-server .' 		   >> /etc/orabuntu-lxc-scripts/crt_links.sh"
	sudo sh -c "echo ' ln -sf /var/lib/lxc/nsa/rootfs/etc/default/bind9 .' 				   >> /etc/orabuntu-lxc-scripts/crt_links.sh"
	sudo sh -c "echo ' ln -sf /var/lib/lxc/nsa/rootfs/etc/bind/named.conf .' 			   >> /etc/orabuntu-lxc-scripts/crt_links.sh"
	sudo sh -c "echo ' ln -sf /var/lib/lxc/nsa/rootfs/etc/bind/named.conf.local .' 			   >> /etc/orabuntu-lxc-scripts/crt_links.sh"
	sudo sh -c "echo ' ln -sf /var/lib/lxc/nsa/rootfs/etc/bind/named.conf.options .' 		   >> /etc/orabuntu-lxc-scripts/crt_links.sh"
fi

if [ -n $NameServer ] && [ -n $Domain1 ]
then
	sudo sh -c "echo ' ln -sf /var/lib/lxc/$NameServer/rootfs/var/lib/bind/fwd.$Domain1 .' 		   >> /etc/orabuntu-lxc-scripts/crt_links.sh"
	sudo sh -c "echo ' ln -sf /var/lib/lxc/$NameServer/rootfs/var/lib/bind/rev.$Domain1 .' 		   >> /etc/orabuntu-lxc-scripts/crt_links.sh"
fi

if [ -n $NameServer ] && [ -n $Domain2 ]
then
	sudo sh -c "echo ' ln -sf /var/lib/lxc/$NameServer/rootfs/var/lib/bind/fwd.$Domain2 .' 		   >> /etc/orabuntu-lxc-scripts/crt_links.sh"
	sudo sh -c "echo ' ln -sf /var/lib/lxc/$NameServer/rootfs/var/lib/bind/rev.$Domain2 .' 		   >> /etc/orabuntu-lxc-scripts/crt_links.sh"
fi

if [ -n $NameServer ] && [ ! -n $Domain1 ]
then
	sudo sh -c "echo ' ln -sf /var/lib/lxc/$NameServer/rootfs/var/lib/bind/fwd.orabuntu-lxc.com .' 	   >> /etc/orabuntu-lxc-scripts/crt_links.sh"
	sudo sh -c "echo ' ln -sf /var/lib/lxc/$NameServer/rootfs/var/lib/bind/rev.orabuntu-lxc.com .' 	   >> /etc/orabuntu-lxc-scripts/crt_links.sh"
fi

if [ -n $NameServer ] && [ ! -n $Domain2 ]
then
        sudo sh -c "echo ' ln -sf /var/lib/lxc/$NameServer/rootfs/var/lib/bind/fwd.consultingcommandos.us .' >> /etc/orabuntu-lxc-scripts/crt_links.sh"
        sudo sh -c "echo ' ln -sf /var/lib/lxc/$NameServer/rootfs/var/lib/bind/rev.consultingcommandos.us .' >> /etc/orabuntu-lxc-scripts/crt_links.sh"
fi

sudo sh -c "echo ' ln -sf /etc/sysctl.d/60-oracle.conf .' 			         		   >> /etc/orabuntu-lxc-scripts/crt_links.sh"
sudo sh -c "echo ' ln -sf /etc/security/limits.d/70-oracle.conf .' 					   >> /etc/orabuntu-lxc-scripts/crt_links.sh"
sudo sh -c "echo ' ln -sf /etc/network/interfaces .' 							   >> /etc/orabuntu-lxc-scripts/crt_links.sh"
sudo sh -c "echo ' ln -sf /etc/NetworkManager/dnsmasq.d/local .' 					   >> /etc/orabuntu-lxc-scripts/crt_links.sh"
sudo sh -c "echo ' ln -sf /etc/orabuntu-lxc-scripts/stop_containers.sh .' 				   >> /etc/orabuntu-lxc-scripts/crt_links.sh"
sudo sh -c "echo ' ln -sf /etc/orabuntu-lxc-scripts/start_containers.sh .' 				   >> /etc/orabuntu-lxc-scripts/crt_links.sh"
sudo sh -c "echo ' ln -sf /etc/network/openvswitch .' 							   >> /etc/orabuntu-lxc-scripts/crt_links.sh"
sudo sh -c "echo ' ln -sf /etc/network/if-up.d/orabuntu-lxc-net .' 					   >> /etc/orabuntu-lxc-scripts/crt_links.sh"
sudo sh -c "echo ' ln -sf /etc/network/openvswitch/crt_ovs_sw1.sh .' 					   >> /etc/orabuntu-lxc-scripts/crt_links.sh"
sudo sh -c "echo ' ln -sf /etc/network/openvswitch/crt_ovs_sw2.sh .' 					   >> /etc/orabuntu-lxc-scripts/crt_links.sh"
sudo sh -c "echo ' ln -sf /etc/network/openvswitch/crt_ovs_sw3.sh .' 					   >> /etc/orabuntu-lxc-scripts/crt_links.sh"
sudo sh -c "echo ' ln -sf /etc/network/openvswitch/crt_ovs_sw4.sh .' 					   >> /etc/orabuntu-lxc-scripts/crt_links.sh"
sudo sh -c "echo ' ln -sf /etc/network/openvswitch/crt_ovs_sw5.sh .' 					   >> /etc/orabuntu-lxc-scripts/crt_links.sh"
sudo sh -c "echo ' ln -sf /etc/network/openvswitch/crt_ovs_sw6.sh .' 					   >> /etc/orabuntu-lxc-scripts/crt_links.sh"
sudo sh -c "echo ' ln -sf /etc/network/openvswitch/crt_ovs_sw7.sh .' 					   >> /etc/orabuntu-lxc-scripts/crt_links.sh"
sudo sh -c "echo ' ln -sf /etc/network/openvswitch/crt_ovs_sw8.sh .' 					   >> /etc/orabuntu-lxc-scripts/crt_links.sh"
sudo sh -c "echo ' ln -sf /etc/network/openvswitch/crt_ovs_sw9.sh .' 					   >> /etc/orabuntu-lxc-scripts/crt_links.sh"
sudo sh -c "echo ' ln -sf /etc/network/openvswitch/crt_ovs_sx1.sh .' 					   >> /etc/orabuntu-lxc-scripts/crt_links.sh"
sudo sh -c "echo ' ln -sf /etc/network/openvswitch/crt_ovs_vm1.sh .' 					   >> /etc/orabuntu-lxc-scripts/crt_links.sh"
sudo sh -c "echo ' ln -sf /etc/network/openvswitch/del-bridges.sh .' 					   >> /etc/orabuntu-lxc-scripts/crt_links.sh"
sudo sh -c "echo ' ln -sf /etc/network/openvswitch/veth_cleanups.sh .' 					   >> /etc/orabuntu-lxc-scripts/crt_links.sh"
sudo sh -c "echo ' ln -sf /etc/network/openvswitch/create-ovs-sw-files-v2.sh .' 			   >> /etc/orabuntu-lxc-scripts/crt_links.sh"
sudo sh -c "echo ' ln -sf /etc/init/openvswitch-switch.conf .' 						   >> /etc/orabuntu-lxc-scripts/crt_links.sh"
sudo sh -c "echo ' ln -sf /etc/default/openvswitch-switch .' 						   >> /etc/orabuntu-lxc-scripts/crt_links.sh"
sudo sh -c "echo ' ln -sf /etc/multipath.conf .' 							   >> /etc/orabuntu-lxc-scripts/crt_links.sh"
sudo sh -c "echo ' ln -sf /etc/multipath.conf.example .' 						   >> /etc/orabuntu-lxc-scripts/crt_links.sh"
sudo sh -c "echo ' ln -sf /etc/network/if-down.d/scst-net .' 						   >> /etc/orabuntu-lxc-scripts/crt_links.sh"

ls -l /etc/orabuntu-lxc-scripts/crt_links.sh

echo ''
echo "=============================================="
echo "Created the crt_links.sh script.              "
echo "=============================================="
echo ''

sleep 5

clear

echo "=============================================="
echo "Next script to run: uekulele-services-2.sh    "
echo "=============================================="

