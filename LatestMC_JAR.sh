#!/bin/bash
### ### ### Settings ### ### ###
# Enter base dir where files are to download to
# If you are unsure, just enter the directory to the script
BASE_DIR=

# Just in-case mojang changes their version_manifest.jar url
VM_URL=https://launchermeta.mojang.com/mc/game/version_manifest.json

# Since this is to go with my other script, McUpdater
# Please enter the same update file name as what is set in McUpdater.sh
# Otherwise you can disable it and get this script to just download the server.jar right away.
# https://github.com/Jakesta13/McUpdater

McUpdater=n
ufile=mcup.txt

# If McUpdater is enabled, then please enter login.cfg
# file location for ncftp
login=${BASE_DIR}/login.cfg

# http://github.com/jakesta13
### ### ### ### ### ###

# Removing old version_manifest.json
if [ -e ${BASE_DIR}/version_manifest.json ]; then
	rm ${BASE_DIR}/version_manifest.json
fi
# Removing old latset.json
if [ -e ${BASE_DIR}/latest.json ]; then
        rm ${BASE_DIR}/latest.json
fi


# Getting link to latest json file which will then give us the
# Latest server.jar file... somewhat annoying but we can work with this.
wget ${VM_URL} -O ${BASE_DIR}/version_manifest.json

jsonv=$(tr , '\n' < ${BASE_DIR}/version_manifest.json | grep -m 1 json)
jsonv1=$(echo ${jsonv} | sed 's/^.*"h/"h/')
jsonv2=$(echo ${jsonv1} | sed 's/\"//g')


# Now lets download that json file, then do something simular to the above.
wget ${jsonv2} -O ${BASE_DIR}/latest.json

jarv=$(tr , '\n' < ${BASE_DIR}/latest.json | grep -m 1 server.jar)
jarv1=$(echo ${jarv} | sed 's/^.*"h/"h/')
jarv2=$(echo ${jarv1} | sed 's/\"//g')
jarv3=$(echo ${jarv2} | sed 's/\}//g')

if [ ${McServer} == "y" ]; then
	echo ${jarv3} > ${BASE_DIR}/${ufile}
	ncftpput -f ${login} / ${BASE_DIR}/${ufile}
else
	wget ${jarv3} -O ${BASE_DIR}/server.jar
fi

exit
