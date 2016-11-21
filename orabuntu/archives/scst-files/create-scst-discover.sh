#    Copyright 2015-2016 Gilbert Standen
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

#    v2.8 GLS 20151231
#    v3.0 GLS 20160710

echo ''
echo "============================================================================================================"
echo "Discover portals and targets...                                                                             "
echo "============================================================================================================"
echo ''

function GetTargetName {
cat /etc/scst.conf | grep 'TARGET iqn' | cut -f2 -d' '
}
TargetName=$(GetTargetName)
echo $TargetName
sudo iscsiadm -m discovery -t sendtargets --portal 127.0.0.1
sudo iscsiadm -m node --login
echo ''
sleep 5
ls -lrt /dev/mapper

echo ''
echo "============================================================================================================"
echo "Portals and targets discovered.                                                                             "
echo "============================================================================================================"

sleep 5

clear

echo ''
echo "============================================================================================================"
echo "Set the startups of all portals to manual.  You can change 'manual' to 'automatic' later if you want.       "
echo "============================================================================================================"
echo ''

sleep 7

function GetAllPortals {
sudo iscsiadm -m discovery -t sendtargets --portal 127.0.0.1 | egrep -v '10.207.40.1|10.207.41.1' | cut -f1 -d':' |  sed 's/$/ /' | tr -d '\n'
}
AllPortals=$(GetAllPortals)

function GetPortals {
sudo iscsiadm -m discovery -t sendtargets --portal 127.0.0.1 | egrep '10.207.40.1|10.207.41.1' | cut -f1 -d':' |  sed 's/$/ /' | tr -d '\n'
}
Portals=$(GetPortals)

echo $AllPortals

for i in $AllPortals
do
echo 'Setting All Portals to manual startup...'
echo ''
sudo  iscsiadm -m node -T iqn.2016-11.com.popeye:uekulele1.san.asm.oracle -p $i --op update -n node.startup -v manual
sudo  iscsiadm -m node --logout
sudo  multipath -F
echo ''
done

echo $Portals

for i in $Portals
do
sudo iscsiadm -m node -T iqn.2016-11.com.popeye:uekulele1.san.asm.oracle -p $i --login
sudo iscsiadm -m node -T iqn.2016-11.com.popeye:uekulele1.san.asm.oracle -p $i --login
sudo iscsiadm -m node -T iqn.2016-11.com.popeye:uekulele1.san.asm.oracle -p $i --op update -n node.startup -v manual
done

echo ''
echo "============================================================================================================"
echo "Set the startups of all portals to manual.                                                                  "
echo "============================================================================================================"

sleep 5

clear

echo ''
echo "============================================================================================================"
echo "Create a service (uekuscst) to manage the SCST storage on the sw2 and sw3 dedicated storage networks...     "
echo "============================================================================================================"
echo ''

sudo sh -c "echo '[Unit]'             	         					 > /etc/systemd/system/uekuscst.service"
sudo sh -c "echo 'Description=uekuscst Service'  					>> /etc/systemd/system/uekuscst.service"
sudo sh -c "echo 'Wants=network-online.target sw2.service sw3.service scst.service'	>> /etc/systemd/system/uekuscst.service"
sudo sh -c "echo 'After=network-online.target sw2.service sw3.service scst.service'	>> /etc/systemd/system/uekuscst.service"
sudo sh -c "echo ''                                 					>> /etc/systemd/system/uekuscst.service"
sudo sh -c "echo '[Service]'                        					>> /etc/systemd/system/uekuscst.service"
sudo sh -c "echo 'Type=oneshot'                     					>> /etc/systemd/system/uekuscst.service"
sudo sh -c "echo 'User=root'                        					>> /etc/systemd/system/uekuscst.service"
sudo sh -c "echo 'RemainAfterExit=yes'              					>> /etc/systemd/system/uekuscst.service"
sudo sh -c "echo 'ExecStart=/etc/network/openvswitch/strt_scst.sh'			>> /etc/systemd/system/uekuscst.service"
sudo sh -c "echo 'ExecStop=/etc/network/openvswitch/stop_scst.sh'			>> /etc/systemd/system/uekuscst.service"
sudo sh -c "echo ''                                 					>> /etc/systemd/system/uekuscst.service"
sudo sh -c "echo '[Install]'                        					>> /etc/systemd/system/uekuscst.service"
sudo sh -c "echo 'WantedBy=multi-user.target'       					>> /etc/systemd/system/uekuscst.service"
sudo chmod 644 /etc/systemd/system/uekuscst.service
sudo systemctl enable uekuscst.service

echo ''
echo "============================================================================================================"
echo "Service (uekuscst) to manage the SCST storage on the sw2 and sw3 dedicated storage networks created.        "
echo "============================================================================================================"

sleep 10

clear
