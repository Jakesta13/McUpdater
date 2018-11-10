#!/bin/bash
### ### ### Settings ### ### ###
# Please enter the BASE DIRECTORY where all the files will be managed localy.
# If you are unsure, enter the directory of the script.
BASE_DIR=

# We only work with minecraft servers that are accessable via FTP.
# NCFTP is being used, please make a login file, enter the entire path along with the filename to the cfg file.
flogin=${BASE_DIR}/login.cfg


# Enter the dir where Wrapper.properties resides.
wpdir=/toolkit/
# Now we need the filename for us to download and check if there's an update.
# Please place this file in the root dir of the ftp server....
# Or you can manually edit the script to suit your needs.
ufile=mcup.txt

# Default and alternative jar files.
# We will do a thing where we swap the jar file out, then afterwards either you or we attempt to restart the minecraft server.
default=server.jar
alternative=server1.jar
jardir=/jar/

# Use Minecraft Remote Tool Kit?
# Please note, the telnet command is not really reliable
# To acccurately stop the server. It is reconmended to use the mcron workaround which is below this.
MCRTK=n
IP=
PORT=
USER=
PASSWD=
# Delay, in seconds, to begin executing telent commands, tweak to find the best settings.
delay=10

# Use mcrcon?
# With this you need to still have Minecraft Remote Kit wrapper running,
# As multicraft will believe that the game crashed and will autoreboot.
mcrcon=y
mIP=
mPORT=
mPASSWD=

# IP to ping, this is for the script to know if your server has actually rebooted.
# If none of the above options are enabled, then this will be disabled. (Rcon port will do if you are unsure, though it will spam the console)
pIP=
pPORT=


#Setting first state of update, don't touch this or you will super break it.
NewUpdate=n
uploaded=n
# http://github.com/jakesta13
### ### ### ### ### ###

## Initial start testing
if [ ! -e "${BASE_DIR}/${ufile}.md5" ]; then
        touch "${BASE_DIR}/${ufile}"
        md5sum "${BASE_DIR}/${ufile}" > "${BASE_DIR}/${ufile}.md5"
        echo Finished inital start up, exiting...
        sleep 2
        exit
fi

# Checking if file has changed.
ncftpget -Z -f "${flogin}" "${BASE_DIR}" /"${ufile}"

if md5sum -c "${BASE_DIR}/${ufile}.md5"; then
        echo file not changed
        echo Exiting...
        sleep 2
else
        NewUpdate=y
        echo update avaliable.
        md5sum "${BASE_DIR}/${ufile}" > "${BASE_DIR}/${ufile}.md5"
fi


if [ "$NewUpdate" == "n" ]; then
	exit
fi


# We will now download the Minecraft Remote Tool Kit Wrapper.properties file
rm ${BASE_DIR}/wrapper.properties
ncftpget -Z -f "${flogin}" "${BASE_DIR}" "${wpdir}/wrapper.properties"

if grep -q "${alternative}" "${BASE_DIR}/wrapper.properties"; then
	# upload default file, sed replace alternate jar from properties file with default jar
	wget `cat "${BASE_DIR}/${ufile}"` -O "${default}"
	ncftpput -f "${flogin}" "${jardir}" "${BASE_DIR}/${default}"
	sed -i "s/${alternative}/${default}/g" "${BASE_DIR}/wrapper.properties"
	# upload modified Wrapper.properties
	ncftpput -f "${flogin}" "${wpdir}" "${BASE_DIR}/wrapper.properties"
	# Setting updated value so we can use workarounds as allowed.
	uploaded=y
else
	# Upload alternate jar file, sed replace default jar from properties file with alternate jar
	wget `cat "${BASE_DIR}/${ufile}"` -O "${alternative}"
        ncftpput -f "${flogin}" "${jardir}" "${BASE_DIR}/${alternative}"
        sed -i "s/${default}/${alternative}/g" "${BASE_DIR}/wrapper.properties"
	# upload modified Wrapper.properties
        ncftpput -f "${flogin}" "${wpdir}" "${BASE_DIR}/wrapper.properties"
	# Setting updated value so we can use workaround as allowed.
	uploaded=y
fi

if [ "$uploaded" == "y" ]; then
	if [ "$mcrcon" == "y" ]; then
		# mcrcon run /stop, You need to have Remote Tool Kit Wrapper for this to work
		# Multicraft will think it was a game crash and will auto-reboot
		${BASE_DIR}/mcrcon -H "${mIP}" -P "${mPORT}" -p "${mPASSWD}" "stop"
		# While do loop with NC port pinging, do not continue until the server is down.
		# The following while loop is from the answer at:
        	# http://unix.stackexchange.com/q/137133/
        	# This is used so that we are sure the server has truely stopped
        	# Minor edits, so we can check the port, as ping cant do that
        	# Also used https://stackoverflow.com/q/42377276
        	echo Checking ...
        	failed=0
        	while [ $failed -ne 1 ]
			do
        	                nc -z -v ${pIP} ${pPORT} 2> /dev/null
        	                failed=$?
        	                sleep 2
        	        done
		echo The server has stopped.
	fi
	if [ "$MCRTK" == "y" ]; then
		# Run telnet command
		{ sleep "${delay}"; echo "${USER}"; sleep 1; echo "${PASSWD}"; sleep 2; echo ".restart";}  | telnet ${IP} ${PORT}
		# While do loop with NC port pinging, do not continue until the server is down.
	        # The following while loop is from the answer at:
	        # http://unix.stackexchange.com/q/137133/
	        # This is used so that we are sure the server has truely stopped
	        # Minor edits, so we can check the port, as ping cant do that
	        # Also used https://stackoverflow.com/q/42377276
	        echo Checking ...
	        failed=0
	        while [ $failed -ne 1 ]
			do
				nc -z -v ${pIP} ${pPORT} 2> /dev/null
	                        failed=$?
	                        sleep 2
	                done
		echo The server has stopped.
	fi
fi

# Quick cleanup
rm  ${BASE_DIR}/*.jar