# McUpdater

This is to make it simpler to update your minecraft server, partially automated.
It uses [Minecraft Tool Kit](https://bukkit.org/threads/remotetoolkit-restarts-crash-detection-auto-saves-remote-console.674/) for properly stopping and starting the minecraft server, unless you pefer to manually start the server afterwards.

## INSTALLATION
* Drop mcup.sh into a new folder
* Create two NCFTP login cfg files, one for the ftp server where the update file is, the other for server.jar to go.
* Paste the url to an update into a file called mcup.txt on the first ftp server.
* Schedule this script and manually change the file with an updated url whenever you wish to update your minecraft server.

## DEPENDANCIES
* NCFTP
* [Minecraft Remote Toolkit](https://bukkit.org/threads/remotetoolkit-restarts-crash-detection-auto-saves-remote-console.674/) -- Not required, but convinient
* Minecraft server with an FTP server to access files.
* [MCRCON](https://github.com/Tiiffi/mcrcon)
* Telnet -- Only required if you wish to use Minecraft Remote Toolkit method

## NOTES
* The script assumes you have all of the required dependancies.
* You can use this to download any kind of jar file, it doesn't have to be vanilla minecraft.
* If running on something like a Raspberry Pi, you have to build mcrcon from source if you use that feature.
* If the Telnet connection doesn't show the login screen, you may have to run '.stopwrapper' on the minecraft server console and restart the wrapper.





## To-do list
* Add pre-check rcon command to send to server (Will be user customizeable, toggleable)
* Add pre-update rcon command to send to server (Will be user customizeable, along with a user-defined delay, toggleable)
