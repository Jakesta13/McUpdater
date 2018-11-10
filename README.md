# McUpdater
## Update your minecraft server (Semi-automated)

This script was made to make updating minecraft servers easier and a lot more efficient (in my opinion)

The only thing you need to do once the script is downloaded and running in a cron schedule is just update a file in the minecraft server
and it will automatically do the rest for you.

# Dependancies
All of these are required.
* NCFTP
* Minecraft Remote Tool Kit
* A Minecraft server running Multicraft panel
* ftp access to Minecraft server
* A Minecraft server

Not required
* mcrcon -- Highly reconmended, telneting into the Remote Tool Kit in a script is ineficient.

# How does it work?
Rebooting  works because Multicraft thinks the game has crashed when you run /stop from rcon while you have the Tool Kit wrapper
I'm not sure why, but without that then this script does not work.

What we do is upload alternating names of the server.jar, and replace that name inside of the Remote Tool Kit's config to point to that one
then reboot the server and it will switch right over.

# To-do
* Add pre-update RCON command, along with a kick all command (/kick @a), and with a user-defined delay before updating
* Add feature to enable/disable HTTP Request once server is updated (Bonus of this; Can link to discorc!)
