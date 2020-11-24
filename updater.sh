#!/bin/bash

## Colours variables for the installation script
RED='\033[1;91m' # WARNINGS
YELLOW='\033[1;93m' # HIGHLIGHTS
WHITE='\033[1;97m' # LARGER FONT
LBLUE='\033[1;96m' # HIGHLIGHTS / NUMBERS ...
LGREEN='\033[1;92m' # SUCCESS
NOCOLOR='\033[0m' # DEFAULT FONT

function systemd_ison () {
if systemctl list-units --state=running | grep nym-mixnode
then echo "stopping nym-mixnode.service to update the node ..." && systemctl stop nym-mixnode
else echo " nym-mixnode.service is inactive or not existing. Downloading new binaries ..."
fi
}
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

downloader && echo "ok" && sleep 2 || exit 1
sleep 5 && systemctl start nym-mixnode.service
