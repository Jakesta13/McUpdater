#!/bin/bash
### ### ### Settings ### ### ###
# Enter the BASE_DIR where the files will be downloaded to
# If you are unsure, just put the directory of where the script is located
BASE_DIR=/home/pi/temp/

# This will probably never change but just in case
# Enter minecraft's download page url
M_URL=https://minecraft.net/en-us/download/server/

# Since this script is made to work with my other script, McUpdater
# Please make sure the ufile filename matches what is set in McUpdate.sh
# https://github.com/Jakesta13/McUpdater
McUpdater=n
ufile=mcup.txt

# If McUpdater is enabled, please enter the location of the login.cfg file for
# ncftp
login=${BASE_DIR}/login.cfg
# Enter FTP port if not default
port=21
# https://github.com/Jakesta13/
### ### ### ### ### ###

# Deleting old webpage file
if [ -e ${BASE_DIR}/update.html ]; then
	rm ${BASE_DIR}/update.html
fi
# Deleting old update file
if [ -e ${BASE_DIR}/${ufile} ]; then
        rm ${BASE_DIR}/${ufile}
fi

# Downloading webpage file, then will look for server.jar 
wget ${M_URL} -O ${BASE_DIR}/update.html

jarv=$(tr = '\n' < ${BASE_DIR}/update.html | grep -m 1 /server.jar)

# Specific sed command came from https://serverfault.com/a/505985
# Altered to remove everything after last double quotes
jarv2=$(echo ${jarv} | sed -e 's/\"[^\"]*$//')
jarv3=$(echo ${jarv2} | sed 's/\"//g')

if [ ${McUpdater} == y]; then
	echo ${jarv3} > ${BASE_DIR}/${ufile}
	ncftpput -P "${port}"-f ${login} / ${BASE_DIR}/${ufile}
else
	wget ${jarv3} -O ${BASE_DIR}/server.jar
fi
exit

