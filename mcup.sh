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
# Enter filenames with their dirs to the connect .cfg files for NCFTP.
# Leave ChkSrvFILE_DIR blank if the file is in the root dir
# or if you have already entered the dir in the login.cfg (Add a forward slash at the end once entered).
# Enter the dir of where the jar file is located on your minecraft server in
# the McSrvJAR_DIR variable below.
ChkSrv=login.cfg
ChkSrvFILE_DIR=
# ncftp login file for minecraft server.
McSrv=login.cfg
McSrvJAR_DIR=jar/

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
ncftpget -Z -f ${ChkSrv} "${BASE_DIR}" ${ChkSrvFILE_DIR}mcup.txt
if md5sum -c "${BASE_DIR}mcup.md5"; then
	echo file not changed
	echo Exiting...
	sleep 2
else
	update=y
	echo update avaliable.
	md5sum "${BASE_DIR}mcup.txt" > "${BASE_DIR}mcup.md5"
fi

# Function defining stage.

nomcrt () {
	${BASE_DIR}mcrcon -H "${mcIP}" -P "${mcport}" -p "${mcpasswd}" "stop"
}

cmdend () {
	${BASE_DIR}mcrcon -H "${mcIP}" -P "${mcport}" -p "${mcpasswd}" "${command}"
}


# Updating stage

if [ "${update}" == "y" ]; then
	wget "`cat ${BASE_DIR}mcup.txt`" -O "${BASE_DIR}server.jar"
	if [ "${cmd}" == "y" ]; then
		cmdend
	fi
	if [ "${MRTK}" == "y" ]; then
		mrtkc=.hold
		# Telnet automation command found on
		# https://jonwestfall.com/2014/02/automate-telnet-session-one-command/
		{ sleep 10; echo "${username}"; sleep 1; echo "${passwd}"; sleep 2; echo "${mrtkc}";}  | telnet ${IP} ${port}
	        # The following while loop is from the answer at:
	        # http://unix.stackexchange.com/q/137133/
	        # This is used so that we are sure the server has truely stopped
		# Minor edits, so we can check the port, as ping cant do that
		# Also used https://stackoverflow.com/q/42377276
		echo Checking ...
		failed=0
		while [ $failed -ne 1 ]
		do
			nc -z -v ${mcIP} ${mcport} 2> /dev/null
			failed=$?
			sleep 2
		done

		echo Uploading jar ...
		jar=${BASE_DIR}server.jar
		sleep 5
		ncftpput -f $McSrv ${McSrvJAR_DIR}/ ${jar}
		sleep 1
		mrtkc=.unhold
		# Telnet automation command found on
                # https://jonwestfall.com/2014/02/automate-telnet-session-one-command/
		{ sleep 10; echo "${username}"; sleep 1; echo "${passwd}"; sleep 2; echo "${mrtkc}";} | telnet ${IP} ${port}
	else
		nomcrt
	fi
fi
# Before we go, lets rename server.jar so if something goes wrong we can look at the file it used.
mv ${BASE_DIR}server.jar ${BASE_DIR}server.jar.old
