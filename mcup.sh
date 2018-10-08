#!/bin/bash
### Settings ###
# Remote Tool Kit connection settings
# Do you have the Minecraft Remote Tool Kit wrapper on the server?
MRTK=y
username=
passwd=
IP=
port=

# NCFTP settings
# Enter filenames with their dirs to the connect .cfg files for NCFTP
ChkSrv=
ChkSrvFILE=
McSrv=
McSrvJAR_DIR=
# mcrcon settings
# Want to send commands before the update?
# Hint: You can send multiple commands, separated by double quotes and a space.
# NOTE: although you may not want to send a command, please enter the IP and either RCON or login port
#  We use the IP and port below for checking if the server has stopped.
cmd=n
command="kick @a Updating server, please come back shortly."
mcIP=
mcpasswd=
mcport=

# Checker settings
# We want to keep all the files in the same directory.
# Enter the base dir (Where this script is located)
# Note: Include a final forward slash.
BASE_DIR=.

# http://github.com/jakesta13
### ### ### ###

# Checking if md5sum file exists, if not we will create a dummy mcup.txt and ms5sum that.
# Then the script will close, so you can create the mcup.txt file in the ftp server and the script will update the minecraft server on second launch.
if [ ! -e "${BASE_DIR}mcup.md5" ]; then
	touch "${BASE_DIR}mcup.txt"
	md5sum "${BASE_DIR}mcup.txt" > "${BASE_DIR}mcup.md5"
	echo Finished inital start up, exiting...
	sleep 2
	exit
fi

# Checking if file has changed.
ncftpget -Z -f "${ChkSrv}" "${BASE_DIR}mcup.txt" "${ChkSrvFILE}"
if [ "`md5sum -c ${BASE_DIR}mcup.md5`" ]; then
	echo file not changed
	echo Exiting...
	sleep 2
	exit
else
	update=y
	echo update avaliable.
	md5sum "${BASE_DIR}mcup.txt" > "${BASE_DIR}mcup.md5"
fi


# Function defining stage.

mcrt () {
	(
	echo open "${IP} ${port}"
	sleep 2
	echo "${username}"
	sleep 2
	echo "${passwd}"
	sleep 2
	echo "${mcrtkc}"
	sleep 2
	echo "exit"
	) | telnet > /dev/null
}

nomcrt () {
	mcrcon -H "${mcIP}" -P "${mcport}" -p "${mcpasswd}" "stop"
}

cmdend () {
	mcrcon -H "${mcIP}" -P "${mcport}" -p "${mcpasswd}" "${command}"
}

isup () {
	# The following while loop is from the answer at:
	# http://unix.stackexchange.com/q/137133/
	# This is used so that we are sure the server has truely stopped
	failed=0
	while [ $failed -ne 1 ]
	do
		ping -n "${mcIP}" "${mcport}" 2> /dev/null
		failed=$?
		sleep 2
	done
}

# Updating stage

if [ "$update" == "y" ]; then
	wget "`cat ${BASE_DIR}mcup.txt`" -o "${BASE_DIR}server.jar"
	if [ "$cmd" == "y" ]; then
		cmdend
	fi
	if [ "$MCRTK" == "y" ]; then
		mrtkc=.hold
		mcrt
		isup
		ncftpput -f "${McServ}" "${BASE_DIR}server.jar" "${McServJAR_DIR}server.jar"
		sleep 1
		mrtkc=.unhold
		mcrt
	else
		nomcrt
	fi
fi
exit
