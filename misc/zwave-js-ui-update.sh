#!/usr/bin/env bash
set -e
RD=`echo "\033[01;31m"`
BL=`echo "\033[36m"`
CM='\xE2\x9C\x94\033'
GN=`echo "\033[1;92m"`
CL=`echo "\033[m"`
set -o errexit
set -o errtrace
set -o nounset
set -o pipefail
shopt -s expand_aliases
alias die='EXIT=$? LINE=$LINENO error_exit'
trap die ERR

function error_exit() {
  trap - ERR
  local reason="Unknown failure occured."
  local msg="${1:-$reason}"
  local flag="${RD}‼ ERROR ${CL}$EXIT@$LINE"
  echo -e "$flag $msg" 1>&2
  exit $EXIT
}
clear
while true; do
    read -p "This will update ZWave JS UI. Proceed(y/n)?" yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
clear

echo -en "${GN} Updating Z-wave JS UI... "
systemctl stop zwave-js-ui.service
cd /opt/zwave-js-ui
RELEASE=$(curl -s https://api.github.com/repos/zwave-js/zwave-js-ui/releases/latest | grep "tag_name" | awk '{print substr($2, 2, length($2)-3) }') 
wget https://github.com/zwave-js/zwave-js-ui/releases/download/${RELEASE}/zwave-js-ui-${RELEASE}-linux.zip &>/dev/null
unzip zwave-js-ui-${RELEASE}-linux.zip zwave-js-ui &>/dev/null
echo -e "${CM}${CL} \r"

echo -en "${GN} Cleanup... "
rm zwave-js-ui-${RELEASE}-linux.zip
systemctl --system daemon-reload
systemctl start zwave-js-ui.service
echo -e "${CM}${CL} \n"

echo -e "${GN} Finished ${CL}"
