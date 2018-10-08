# McUpdater

This is to make it simpler to update your minecraft server, partially automated.
It uses [Minecraft Tool Kit]() for properly stopping and starting the minecraft server, unless you pefer to manually start the server afterwards.

## INSTALLATION
* Drop mcup.sh into a new folder
* Create two NCFTP login file, one for the ftp server where the update file is, the other for server.jar to go.
* Paste the url to an update into a file called mcup.txt on the first ftp server.
* Schedule this script and manually change the file with an updated url whenever you wish to update your minecraft server.

## DEPENDANCIES
* NCFTP
* [Minecraft Remote Toolkit]() -- Not required, but convinient
* Minecraft server with an FTP server to access files. (You could also use this for the update file)

## NOTE
The first post of this script will most likely not work, I want to get it pushed so I don't loose the original
