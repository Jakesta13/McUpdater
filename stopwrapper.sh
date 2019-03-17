#!/bin/sh

# Unfortunately this script was made before I entered my sources for commands.
# The source of where I found this specific code is lost.

# All of the following is not mine.

# As such, I will not enter a link to my profile, as I do not
# want to mistakenly claim credit for.

# Host is the same syntax as what telnet is expecting
# E.g HOST.NAME P0RT | example.com 23
HOST=''
USER=''
PASSWD=''
CMD='.forcestopwrapper'

(
echo open "$HOST"
sleep 2
echo "$USER"
sleep 2
echo "$PASSWD"
sleep 2
echo "$CMD"
sleep 2
echo "exit"
) | telnet > /dev/null
