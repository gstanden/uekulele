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

#    Usage:   anylinux-services-1.sh $major_version $minor_version $Domain1 $Domain2 $NameServer $LinuxOSMemoryReservation
#    Example: anylinux-services-1.sh 7 2 yourdomain1\.[com|net|us|info|...] yourdomain2\.[com|net|us|info|...] yournameserver MemoryReservation(Kb)
#    Example: anylinux-services-1.sh 7 2 bostonlox\.com realcrumpets\.info nycnsa

#    Note that this software builds a conntainerized DNS DHCP solution for the Ubuntu Desktop environment.
#    The nameserver should NOT be the name of an EXISTING nameserver but an arbitrary name because this software is CREATING a new LXC-containerized nameserver.
#    The domain names can be arbitrary fictional names or they can be a domain that you actually own and operate.
#    There are two domains and two networks because the "seed" LXC containers are on a separate network from the production LXC containers.
#    If the domain is an actual domain, you will need to change the subnet though (a feature this software does not yet support - it's on the roadmap) to match your subnet manually.

echo ''
echo "=============================================="
echo "Oracle container automation.                  "
echo "=============================================="
echo ''
echo 'Author:  Gilbert Standen                      '
echo 'Email :  gilstanden@hotmail.com               '
echo ''
echo 'Motto :  Any Oracle on Any Linux (sm)         '
echo ''
echo "=============================================="
echo "Oracle container automation.                  "
echo "=============================================="
echo ''

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
echo "Privileges established.                       "
echo "=============================================="

sleep 5

clear

echo ''
echo "==============================================" 
echo "Verify networking up...                       "
echo "=============================================="
echo ''

ping -c 3 google.com

function CheckNetworkUp {
ping -c 3 google.com | grep packet | cut -f3 -d',' | sed 's/ //g'
}
NetworkUp=$(CheckNetworkUp)

while [ "$NetworkUp" !=  "0%packetloss" ] && [ "$n" -lt 5 ]
do
	NetworkUp=$(CheckNetworkUp)
	let n=$n+1
done

if [ "$NetworkUp" != '0%packetloss' ]
then
	echo ''
	echo "=============================================="
	echo "Networking is not up or is hiccuping badly.   "
	echo "ping google.com test must succeed             "
	echo "Exiting script...                             "
	echo "Address network issues/hiccups & rerun script."
	echo "=============================================="

	sleep 15

	exit
else
	echo ''
	echo "=============================================="
	echo "Network ping test verification complete.      "
	echo "=============================================="
	echo ''
fi

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
NumCon=$7

GetLinuxFlavors(){
if [[ -e /etc/redhat-release ]]
then
        LinuxFlavors=$(cat /etc/redhat-release | cut -f1 -d' ')
elif [[ -e /usr/bin/lsb_release ]]
then
        LinuxFlavors=$(lsb_release -d | awk -F ':' '{print $2}' | cut -f1 -d' ')
elif [[ -e /etc/issue ]]
then
        LinuxFlavors=$(cat /etc/issue | cut -f1 -d' ')
else
        LinuxFlavors=$(cat /proc/version | cut -f1 -d' ')
fi
}
GetLinuxFlavors

function TrimLinuxFlavors {
echo $LinuxFlavors | sed 's/^[ \t]//;s/[ \t]$//'
}
LinuxFlavor=$(TrimLinuxFlavors)

echo ''
echo "=============================================="
echo "Linux Flavor.                                 "
echo "=============================================="
echo ''
echo $LinuxFlavor
echo ''
echo "=============================================="
echo "Linux Flavor.                                 "
echo "=============================================="
echo ''

sleep 5

clear

echo ''
echo "=============================================="
echo "Check Kernel Version of running kernel...     "
echo "=============================================="
echo ''
uname -a

# GLS 20151126 Added function to get kernel version of running kernel to support linux 4.x kernels in Ubuntu Wily Werewolf etc.
# GLS 20160924 SCST 3.1 does not require a custom kernel build for kernels >= 2.6.30 so now we check that kernel is >= 2.6.30.
# GLS 20160924 If the kernel version is lower than 2.6.30 and if you use the options SCST Linux SAN archive it will be necessary to compile a custom kernel.

function VersionKernelPassFail () {
    ~/Downloads/uekulele-master/anylinux/vercomp | cut -f1 -d':'
}
KernelPassFail=$(VersionKernelPassFail)

if [ $KernelPassFail = 'Pass' ]
then
	echo ''
	echo "=============================================="
	echo "Kernel Version is greater than 2.6.30 - Pass  "
	echo "=============================================="
	echo ''

	sleep 5

	clear

	if [ $LinuxFlavor = 'CentOS' ]
	then
		function CheckUser {
		id | cut -f1 -d' ' | cut -f2 -d'(' | cut -f1 -d')'
		}
		User=$(CheckUser)

		if [ $User = 'root' ]
		then
			clear
			echo ''
			echo "=============================================="
			echo "Check if install user is root...              "
			echo "=============================================="
			echo ''
			echo 'For '$LinuxFlavor' installer must be ubuntu.  '
			echo "Connect as ubuntu and run the script again.   "
			echo ''
			echo "=============================================="
			echo "Install user check completed.                 "
			echo "=============================================="
			echo ''
			exit
		fi
	fi
	if [ $LinuxFlavor = 'Red' ]
	then
		function GetRedHatVersion {
		cat /etc/redhat-release  | cut -f7 -d' ' | cut -f1 -d'.'
		}
		RedHatVersion=$(GetRedHatVersion)
		if [ $RedHatVersion = '7' ]
		then
 			echo ''
			echo "=============================================="
			echo "Script:  anylinux-services-1.sh               "
			echo "=============================================="
			echo "                                              "
			echo "Tested with Oracle Linux 7 UEK4               "
			echo "                                              "
			echo "=============================================="
			echo "Script:  anylinux-services-1.sh               "
			echo "=============================================="
			echo ''

			sleep 5
			
			clear
			
			echo ''
			echo "=============================================="
			echo "Oracle Linux Release Version Check....        "
			echo "=============================================="
			echo ''

			cat /etc/oracle-release

			echo ''
			echo "=============================================="
			echo "RedHat Release Version Check complete.        "
			echo "=============================================="

			sleep 5

			clear
		else
			echo ''
			echo "=============================================="
			echo "Oracle Version not tested with Uekulele.      "
			echo "Results may be unpredictable.                 " 
			echo "Proceeding anyway...<ctrl>+c to exit          "
			echo "=============================================="
		
			sleep 5

			clear
		fi
		function CheckUser {
		id | cut -f1 -d' ' | cut -f2 -d'(' | cut -f1 -d')'
		}
		User=$(CheckUser)
		if [ $User = 'root' ]
		then
			echo ''
			echo "=============================================="
			echo "Check if install user is root...              "
			echo "=============================================="
			echo ''
			echo 'For '$LinuxFlavor'Hat installer must be ubuntu'
			echo "Connect as ubuntu and run the scripts again.  "
			echo ''
			echo "=============================================="
			echo "Install user check completed.                 "
			echo "=============================================="
			echo ''
			exit
		fi
	echo ''
	echo "=============================================="
	echo "Check if host is physical or virtual...       "
	echo "=============================================="
	echo ''

	sleep 5

	clear

	function CheckFacterInstalled {
	sudo which facter > /dev/null 2>&1; echo $?
	}
	FacterInstalled=$(CheckFacterInstalled)
	if [ $FacterInstalled -ne 0 ]
	then
        	echo ''
        	echo "=============================================="
        	echo "Install package prerequisites for facter...   "
        	echo "=============================================="
        	echo ''

        	sudo yum -y install which ruby curl tar
        	
		echo ''
        	echo "=============================================="
        	echo "Facter package prerequisites installed.       "
        	echo "=============================================="

		sleep 5

		clear

        	echo ''
        	echo "=============================================="
        	echo "Build and install Facter from source...       "
        	echo "=============================================="
        	echo ''

		mkdir -p /home/ubuntu/Downloads/uekulele-master/uekulele/facter
		cd /home/ubuntu/Downloads/uekulele-master/uekulele/facter
		curl -s http://downloads.puppetlabs.com/facter/facter-2.4.4.tar.gz | sudo tar xz; sudo ruby facter*/install.rb

		echo ''
        	echo "=============================================="
        	echo "Build and install Facter completed.           "
        	echo "=============================================="

	else
        	echo ''
        	echo "=============================================="
        	echo "Facter already installed.                     "
        	echo "=============================================="
        	echo ''
	fi
	function GetFacter {
	facter virtual
	}
	Facter=$(GetFacter)
			
	sleep 5

	clear
		if [ $Facter != 'physical' ]
		then
 			echo ''
			echo "=============================================="
			echo "Uekulele $LinuxFlavor LXC Automation on VM... "
			echo "=============================================="
			echo ''

			sleep 5

			~/Downloads/uekulele-master/uekulele/uekulele-services-1.sh $MajorRelease $PointRelease $Domain1 $Domain2 $NameServer $LinuxOSMemoryReservation
			~/Downloads/uekulele-master/uekulele/uekulele-services-2.sh $MajorRelease $PointRelease $Domain1 $Domain2
			~/Downloads/uekulele-master/uekulele/uekulele-services-3.sh $MajorRelease $PointRelease
			~/Downloads/uekulele-master/uekulele/uekulele-services-4.sh $MajorRelease $PointRelease $NumCon ora$MajorRelease$PointRelease
			~/Downloads/uekulele-master/uekulele/uekulele-services-5.sh $MajorRelease $PointRelease 

 			echo ''
			echo "=============================================="
			echo "Uekulele $LinuxFlavor LXC Automation complete."
			echo "=============================================="

			sleep 5
 		else 
			echo ''
			echo "==============================================    "
			echo "Uekulele $LinuxFlavor Automation on physical host."
			echo "==============================================    "
			echo ''

			sleep 5

			clear

			~/Downloads/uekulele-master/uekulele/uekulele-services-1.sh $MajorRelease $PointRelease $Domain1 $Domain2 $NameServer $LinuxOSMemoryReservation
			~/Downloads/uekulele-master/uekulele/uekulele-services-2.sh $MajorRelease $PointRelease $Domain1 $Domain2
			~/Downloads/uekulele-master/uekulele/uekulele-services-3.sh $MajorRelease $PointRelease
			~/Downloads/uekulele-master/uekulele/uekulele-services-4.sh $MajorRelease $PointRelease $NumCon ora$MajorRelease$PointRelease
			~/Downloads/uekulele-master/uekulele/uekulele-services-5.sh $MajorRelease $PointRelease 

			echo ''
			echo "=============================================="
			echo "Uekulele $LinuxFlavor Automation complete.    "
			echo "=============================================="
 		fi
	fi
	if [ $LinuxFlavor = 'Ubuntu' ]
	then
		function GetUbuntuVersion {
		cat /etc/lsb-release | grep DISTRIB_RELEASE | cut -f2 -d'='
		}
		UbuntuVersion=$(GetUbuntuVersion)

		if [ $UbuntuVersion = '15.04' ] || [ $UbuntuVersion = '15.10' ] || [ $UbuntuVersion = '16.04' ]
		then
 			echo ''
			echo "=============================================="
			echo "Script:  anylinux-services-1.sh                 "
			echo "=============================================="
			echo "                                              "
			echo "Tested with Ubuntu 15.04 Vivid Vervet         "
			echo "Tested with Ubuntu 15.10 Wily Werewolf        "
			echo "Tested with Ubuntu 16.04 Xenial Xerus         "
			echo "                                              "
			echo "Suggest: Review scripts first before running. "
			echo "                                              "
			echo "=============================================="
			echo "Script:  anylinux-services-1.sh               "
			echo "=============================================="
			echo ''

			sleep 5

			clear

			echo ''
			echo "=============================================="
			echo "Ubuntu Release Version Check....              "
			echo "=============================================="
			echo ''
			sudo cat /etc/lsb-release
			echo ''
			echo "=============================================="
			echo "Ubuntu Release Version Check complete.        "
			echo "=============================================="

			sleep 5

			clear
		else
			echo ''
			echo "=============================================="
			echo "Ubuntu Version not tested with orabuntu-lxc   "
			echo "Results may be unpredictable.                 " 
			echo "Proceeding anyway...<ctrl>+c to exit          "
			echo "=============================================="
		
			sleep 5

			clear
		fi
		function CheckUser {
		id | cut -f1 -d' ' | cut -f2 -d'(' | cut -f1 -d')'
		}
		User=$(CheckUser)
		if [ $User = 'root' ]
		then
			echo ''
			echo "=============================================="
			echo "Check if install user is root...              "
			echo "=============================================="
			echo ''
			echo 'For '$LinuxFlavor' installer CANNOT be root.  '
			echo 'Connect as the '$LinuxFlavor' sudo user and   '
			echo "rerun the installer.                          "
			echo ''
			echo "=============================================="
			echo "Install user check completed.                 "
			echo "=============================================="
			echo ''
			exit
		fi

	echo ''
	echo "=============================================="
	echo "Check if host is physical or virtual...       "
	echo "=============================================="
	echo ''
	
	sudo apt-get -y install facter
	function GetFacter {
	facter virtual
	}
	Facter=$(GetFacter)
			
	sleep 5

	clear
		if [ $Facter != 'physical' ]
		then
 			echo ''
			echo "=============================================="
			echo "Uekulele $LinuxFlavor Automation on VM...     "
			echo "=============================================="
			echo ''

			~/Downloads/uekulele-master/orabuntu/orabuntu-services-1.sh $MajorRelease $PointRelease $Domain1 $Domain2 $NameServer $LinuxOSMemoryReservation
			~/Downloads/uekulele-master/orabuntu/orabuntu-services-2.sh $MajorRelease $PointRelease $Domain1
			~/Downloads/uekulele-master/orabuntu/orabuntu-services-3.sh $MajorRelease $PointRelease
			~/Downloads/uekulele-master/orabuntu/orabuntu-services-4.sh $MajorRelease $PointRelease $NumCon ora$MajorRelease$PointRelease
			~/Downloads/uekulele-master/orabuntu/orabuntu-services-5.sh $MajorRelease $PointRelease
			
			echo ''
			echo "=============================================="
			echo "Uekulele $LinuxFlavor Automation complete.    "
			echo "=============================================="
			echo ''

			sleep 5
		else
			echo ''
			echo "=============================================="
			echo "Uekulele $LinuxFlavor Automation on phys host."
			echo "=============================================="
			echo ''

			~/Downloads/uekulele-master/orabuntu/orabuntu-services-1.sh $MajorRelease $PointRelease $Domain1 $Domain2 $NameServer $LinuxOSMemoryReservation
			~/Downloads/uekulele-master/orabuntu/orabuntu-services-2.sh $MajorRelease $PointRelease $Domain1
			~/Downloads/uekulele-master/orabuntu/orabuntu-services-3.sh $MajorRelease $PointRelease
			~/Downloads/uekulele-master/orabuntu/orabuntu-services-4.sh $MajorRelease $PointRelease $NumCon ora$MajorRelease$PointRelease
			~/Downloads/uekulele-master/orabuntu/orabuntu-services-5.sh $MajorRelease $PointRelease
			
			echo ''
			echo "=============================================="
			echo "Uekulele $LinuxFlavor Automation complete.    "
			echo "=============================================="

			sleep 5
		fi

	fi #LinuxFlavor

fi # KernelPassFail
