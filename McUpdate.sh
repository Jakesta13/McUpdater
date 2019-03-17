#!/bin/bash
### ### ### Settings ### ### ###
# Please enter the BASE DIRECTORY where all the files will be managed localy.
# If you are unsure, enter the directory of the script.
BASE_DIR=.

# We only work with minecraft servers that are accessable via FTP.
# NCFTP is being used, please make a login file, enter the entire path along with the filename to the cfg file.
flogin=${BASE_DIR}/login.cfg
# If your FTP port is different to port 21, please specify the port number below.
port=21

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
mIP=??
mPORT=??
mPASSWD=??

# Unfortunately we kind of do need to use Minecraft Remote Tool Kit in this sense
# As it will not switch jar files until it has shut istelf down... though mcrcon can still be used
# as this part will only shut the wrapper down afterwards.
# Options: y/n
# If y, then we will use an external script to run the tellnet command, this may work better.
# If n, then will try to run the telnet command inside this script
MRTK_ALT=n

# IP to ping, this is for the script to know if your server has actually rebooted.
# If none of the above options are enabled, then this will be disabled. (Rcon port will do if you are unsure, though it will spam the console)
pIP=example.com
pPORT=25565

## DEBUG SETTING
# This will help you figure out what went wrong and
# this will tell you what url the script used in order to update.
# for example, this helped me figure out what happened when the server.jar
# file was missing ... turned out that the updater got blank text from the updater file
# which I then created a fail-safe for.
# Valid options: y/n
debug=n
debug_dir="${BASE_DIR}"



#Setting first state of update, don't touch this or you will super break it.
NewUpdate=n
uploaded=n

# Setting up variables for ftp script below
# FTP scrpt source is commented above it.
host=$(grep host ${flogin} | sed -e 's/host //g')
user=$(grep user ${flogin} | sed -e 's/user //g')
pass=$(grep pass ${flogin} | sed -e 's/pass //g')


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
rm "${BASE_DIR}/${ufile}"
ncftpget -Z -P "${port}" -f "${flogin}" "${BASE_DIR}" /"${ufile}"

# # # Added Jan 26 2019
# Check if file is empty!
# This prevents false-positives
empty=$(wc -c < "${BASE_DIR}/${ufile}")
if [ "${empty}" == "0" ]; then
	echo File is empty ... Abort Abort
	exit
fi


if md5sum -c "${BASE_DIR}/${ufile}.md5"; then
        echo file not changed
        echo Exiting...
        sleep 2
else
        NewUpdate=y
        echo update avaliable.
	# debug part
	if [ ${debug} == "y" ]; then
		echo "Updating" >> "${debug_dir}/McUpdate_debug.log"
		echo "Download file: `cat "${BASE_DIR}/${ufile}"`" >> "${debug_log}/McUpdate_debug.log"
		date >> "${debug_log}/McUpdate_debug.log"
		echo "--- --- --- ----"
	fi
	###
        md5sum "${BASE_DIR}/${ufile}" > "${BASE_DIR}/${ufile}.md5"
fi


if [ "$NewUpdate" == "n" ]; then
	exit
fi


# We will now download the Minecraft Remote Tool Kit Wrapper.properties file
rm ${BASE_DIR}/wrapper.properties
ncftpget -Z -P "${port}" -f "${flogin}" "${BASE_DIR}" "${wpdir}/wrapper.properties"

# If we find the alternative filename in the wrapper.properties, then we
# Want to upload the default filename and replace alternative filename with default filename
if grep -q "${alternative}" "${BASE_DIR}/wrapper.properties"; then
	# upload default file, sed replace alternate jar from properties file with default jar
	wget `cat "${BASE_DIR}/${ufile}"` -O "${BASE_DIR}/${default}"

	# lftp inspired from
	# http://stackoverflow.com/q/9773454/
	lftp -e "rm ${jardir}/${default}; bye" -u "${user},${pass} ${host}:${port}"

	ncftpput -P "${port}" -f "${flogin}" "${jardir}" "${BASE_DIR}/${default}"
	sed -i "s,${jardir}${alternative},${jardir}${default},g" "${BASE_DIR}/wrapper.properties"
	# upload modified Wrapper.properties
	ncftpput -P "${port}" -f "${flogin}" "${wpdir}" "${BASE_DIR}/wrapper.properties"
	# Setting updated value so we can use workarounds as allowed.
	uploaded=y
else
	# Same as above, just opposite.
	# Upload alternate jar file, sed replace default jar from properties file with alternate jar
	wget `cat "${BASE_DIR}/${ufile}"` -O "${BASE_DIR}/${alternative}"

        # lftp inspired  from
	# http://stackoverflow.com/q/9773454/
	lftp -e "rm ${jardir}/${alternative}; bye" -u "${user},${pass} ${host}:${port}"

        ncftpput -P "${port}" -f "${flogin}" "${jardir}" "${BASE_DIR}/${alternative}"
        sed -i "s,${jardir}${default},${jardir}${alternative},g" "${BASE_DIR}/wrapper.properties"
	# upload modified Wrapper.properties
        ncftpput -P "${port}" -f "${flogin}" "${wpdir}" "${BASE_DIR}/wrapper.properties"
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
		# Added Dec 30 2018
		# No longer needed Feb 1 2019, bug is fixed 19w05a
#		Acually we need it Feb 7 2019, mrtk doesnt see jar change otherwise
#		need to make it better
#		Best I can do is make MRTK mandatory.
		if [ "$MRTK_ALT" == "n" ]; then
			"${BASE_DIR}/stopwrapper.sh"
		else
			{ sleep "${delay}"; echo "${USER}"; sleep 1; echo "${PASSWD}"; sleep 2; echo ".stopwrapper";} | telnet ${IP} ${PORT} > /dev/null
		fi
	fi
	if [ "$MCRTK" == "y" ]; then
		# Run telnet command
		{ sleep "${delay}"; echo "${USER}"; sleep 1; echo "${PASSWD}"; sleep 2; echo ".stopwrapper";}  | telnet ${IP} ${PORT} > /dev/null
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
