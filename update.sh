#!/bin/bash

## Colours variables for the installation script
RED='\033[1;91m' # WARNINGS
YELLOW='\033[1;93m' # HIGHLIGHTS
WHITE='\033[1;97m' # LARGER FONT
LBLUE='\033[1;96m' # HIGHLIGHTS / NUMBERS ...
LGREEN='\033[1;92m' # SUCCESS
NOCOLOR='\033[0m' # DEFAULT FONT
#current_version=$(./nym-mixnode_linux_x86_64 --version | grep Nym | cut -c 13- )
function downloader () {
#set -x
if [ ! -d /home/nym/.nym/mixnodes ]
then
	echo "Looking for nym config in /home/nym but could not find any! Enter the path of the nym-mixnode executable"
	read nym_path
	cd $nym_path


else
	cd /home/nym
fi

# set vars for version checking and url to download the latest release of nym-mixnode
current_version=$(./nym-mixnode_linux_x86_64 --version | grep Nym | cut -c 13- )
VERSION=$(curl https://github.com/nymtech/nym/releases/latest --cacert /etc/ssl/certs/ca-certificates.crt 2>/dev/null | egrep -o "[0-9|\.]{5}(-\w+)?")
URL="https://github.com/nymtech/nym/releases/download/v$VERSION/nym-mixnode_linux_x86_64"

# Check if the version is up to date. If not, fetch the latest release.
if [ ! -f nym-mixnode_linux_x86_64 ] || [ "$(./nym-mixnode_linux_x86_64 --version | grep Nym | cut -c 13- )" != "$VERSION" ]
   then
       if systemctl list-units --state=running | grep nym-mixnode
          then echo "stopping nym-mixnode.service to update the node ..." && systemctl stop nym-mixnode
                curl -L -s "$URL" -o "nym-mixnode_linux_x86_64" --cacert /etc/ssl/certs/ca-certificates.crt && echo "Fetching the latest version" && pwd
          else echo " nym-mixnode.service is inactive or not existing. Downloading new binaries ..." && pwd
    		curl -L -s "$URL" -o "nym-mixnode_linux_x86_64" --cacert /etc/ssl/certs/ca-certificates.crt && echo "Fetching the latest version" && pwd
	   # Make it executable
   chmod +x ./nym-mixnode_linux_x86_64 && chown nym:nym ./nym-mixnode_linux_x86_64
   fi
else
   echo "You have the latest version of Nym-mixnode $VERSION"
   exit 1

fi
}
function upgrade_nym () {
	#set -x
	directory='NymMixNode'
	
                #id=$(echo "$i" | rev | cut -d/ -f1 | rev)
                printf '%s\n' "[Unit]" > nym-mixnode.service
                printf '%s\n' "Description=Nym Mixnode (0.9.1)" >> nym-mixnode.service
                printf '%s\n' "" >> nym-mixnode.service
                printf '%s\n' "[Service]" >> nym-mixnode.service
                printf '%s\n' "User=nym" >> nym-mixnode.service
                printf '%s\n' "ExecStart=/home/nym/nym-mixnode run --id $directory" >> /etc/systemd/system/nym-mixnode.service
                printf '%s\n' "KillSignal=SIGINT # gracefully kill the process when stopping the service. Allows node to unregister cleanly." >> /etc/systemd/system/nym-mixnode.service				
                printf '%s\n' "Restart=on-failure" >> /etc/systemd/system/nym-mixnode.service
                printf '%s\n' "RestartSec=30" >> /etc/systemd/system/nym-mixnode.service
                printf '%s\n' "StartLimitInterval=350" >> /etc/systemd/system/nym-mixnode.service
                printf '%s\n' "StartLimitBurst=10" >> /etc/systemd/system/nym-mixnode.service
                printf '%s\n' "LimitNOFILE=65535 # this sets a higher ulimit for your mixnode!" >> /etc/systemd/system/nym-mixnode.service				
                printf '%s\n' "" >> /etc/systemd/system/nym-mixnode.service
                printf '%s\n' "[Install]" >> /etc/systemd/system/nym-mixnode.service
                printf '%s\n' "WantedBy=multi-user.target" >> /etc/systemd/system/nym-mixnode.service
    current_path=$(pwd)
    if
      [ -e ${current_path}/nym-mixnode.service ]
    then
      printf "%b\n\n\n" "${WHITE} Your systemd script with id $directory was ${LGREEN} successfully update !"
    else
      printf "%b\n\n\n" "${WHITE} Printing of the systemd script to the current folder ${RED} failed. ${WHITE} Do you have ${YELLOW} permissions ${WHITE} to ${YELLOW} write ${WHITE} in ${pwd} ${YELLOW}  directory ??? "
    fi
sudo -u nym -H ./nym-mixnode_linux_x86_64 upgrade --id $directory    
}
#set -x
downloader && echo "ok" && sleep 2 || exit 1
upgrade_nym && sleep 5 && systemctl start nym-mixnode.service
