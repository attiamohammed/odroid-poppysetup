#! /bin/bash


creature=$1
EXISTING_ONES="poppy-humanoid poppy-torso"

if [ "${creature}" == "" ]; then
  echo 'ERROR: option "CREATURE" not given. See -h.' >&2
  exit 1
fi

if ! [[ $EXISTING_ONES =~ $creature ]]; then
    echo "ERROR: creature \"${creature}\" not among possible creatures (choices \"$EXISTING_ONES\")"
    exit 1
fi

# Here is the script start :

arch="$(uname -m)"
if [[ $arch != arm* ]]
then
        echo -e "\e[31mWARNING\e[0m : \e[33mThis script change some system setting, you should NOT run it in your desk computer.\e[0m"
        exit 0
fi

if [ `whoami` != "root" ];
then
    echo -e "\e[33mYou must run the app as root:\e[0m"
    echo -e "\e[32msudo bash $0\e[0m"
    exit 0
fi

apt-get update
apt-get install --yes avahi-daemon avahi-autoipd passwd libnss-mdns network-manager iptables
    
# Do it only if it is a ODROID U3
if [ -e /etc/smsc95xx_mac_addr ]; then
    # see http://forum.odroid.com/viewtopic.php?f=7&t=1070 for understanting
    echo -e "\e[33mChange Mac address'\e[0m"
    rm /etc/smsc95xx_mac_addr
fi


echo -e "\e[33mdownload needed files.\e[0m"
wget -P $HOME/src https://raw.githubusercontent.com/poppy-project/odroid-poppysetup/master/src/poppy_launcher.sh
#cd $HOME/src; bash poppy_launcher.sh; rm poppy_launcher.sh
echo $creature > $HOME/src/creature
cd ..

echo -e "\e[33mDefault Hostname change to \e[4mpoppy\e[0m."
echo 'poppy' > /etc/hostname
sed -i "s/odroid/poppy/g" /etc/hosts

service avahi-daemon restart

echo -e "\e[33mCreate a new user \e[4mpoppy\e[0m\e[33m with the default password \e[4mpoppy\e[0m."

groupadd fuse
useradd -m -s /bin/bash -G adm,dialout,fax,cdrom,floppy,tape,sudo,audio,dip,video,plugdev,netdev,lpadmin,fuse poppy
echo "poppy:poppy" | passwd

echo -e '\e[33mPlease reconnect you with:\e[0m'
echo -e '\e[32mssh poppy@poppy.local\e[0m'
echo -e '\e[33mto follow the next step of installation process.\e[0m'
echo -e "\e[33mYour new password is 'poppy'\e[0m"


