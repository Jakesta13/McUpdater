# McUpdater
## Update your minecraft server (Semi-automated)

This script was made to make updating minecraft servers easier and a lot more efficient (in my opinion)

The only thing you need to do once the script is downloaded and running in a cron schedule is just update a file in the minecraft server
and it will automatically do the rest for you.

# Dependancies
All of these are required.
* NCFTP
* [Minecraft Remote Tool Kit](https://bukkit.org/threads/remotetoolkit-restarts-crash-detection-auto-saves-remote-console.674/)
* A Minecraft server running [Multicraft](https://multicraft.org) panel
* ftp access to Minecraft server
* A [Minecraft](http://my.fadehost.com/aff.php?aff=642) server - (Referal to fadehost)

Not required
* [mcrcon](https://bukkit.org/threads/admin-rcon-mcrcon-remote-connection-client-for-minecraft-servers.70910/) -- Highly reconmended, telneting into the Remote Tool Kit in a script is ineficient.

# How does it work?
Rebooting  works because Multicraft thinks the game has crashed when you run /stop from rcon while you have the Tool Kit wrapper
I'm not sure why, but without that then this script does not work.

What we do is upload alternating names of the server.jar, and replace that name inside of the Remote Tool Kit's config to point to that one
then reboot the server and it will switch right over.

# Bonus
LatestMC_JAR.sh will grab the download link for the latest server.jar, you can choose to download the jar file
or have it save the url to the txt file that McUpdate.sh looks for when it checks for updates.

ReleasedMC_JAR.sh will grab the download link for the latest Full-Release version of server.jar,
you can choose to download the jar file or save the url to the txt file that McUpdate.sh looks for when it checks for updates.

# Notes
* if running on a Raspberry Pi you have to [compile](https://github.com/Tiiffi/mcrcon) mcrcon!
* LatestMC_JAR.sh will download ANY latest server.jar, INCLUDING Snapshtos and Pre-releases!


# To-do
* Add pre-update RCON command, along with a kick all command (/kick @a), and with a user-defined delay before updating
* Add feature to enable/disable HTTP Request once server is updated (Bonus of this; Can link to discorc!)
* ~~Ability to grab the latest full-release of server.jar~~ -- Done, see Bonus in README
* Incorperate both update grabbing scripts into McUpdate.sh
