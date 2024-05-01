#!/bin/bash

if [ "$EUID" -ne 0 ];then
	printf  "$(tput setaf 1)Please run the script as root\n"
	exit
fi

HOME="$(getent passwd $SUDO_USER | cut -d: -f6)"
PARENT_DIRECTORY="$HOME/discord-auto-updater"
mkdir -p $PARENT_DIRECTORY

function log {
	echo "[ $(date '+%Y-%m-%d %H:%M:%S') ] - $1" >> "$PARENT_DIRECTORY/update_discord_log.txt"
}

log "script started"

DOES_SCIRPT_AUTORUN="$(grep -R update_discord /etc/rc.local)"
if [  ! "$DOES_SCIRPT_AUTORUN" ];then
	printf "Do you want to make this script autorun on startup (Y/N)?"
	read ANSWER

	if [ "$ANSWER" != "${ANSWER#[Yy]}" ];then
		cp $0 $PARENT_DIRECTORY
		echo "$PARENT_DIRECTORY/update_discord.sh" >> /etc/rc.local
		chmod +x /etc/rc.local
		log "script added to autorn procedure"
	else
		log "script was declined to be added to autorun procedure"
	fi
fi
	
	
CURRENT_APP_VERSION=$(dpkg -s "discord" | grep "^Version" | cut -d' ' -f2)
if [ ! "$CURRENT_APP_VERSION" ];then
	printf  "$(tput setaf 1)Discord is not installed\n"
	log "discord is not installed"
	exit 1
else
	FILE_NAME="discord.deb"
	wget -O $FILE_NAME  "https://discord.com/api/download/stable?platform=linux&format=deb" --max-redirect 0 2>&1 | grep "Location:" | cut -d'/' -f6 | tee version.txt
	LATEST_APP_VERSION=$(head -n 1 version.txt)
	if [ $CURRENT_APP_VERSION != $LATEST_APP_VERSION ];then
		wget -O $FILE_NAME  "https://discord.com/api/download/stable?platform=linux&format=deb"
		sudo dpkg -i $FILE_NAME
		printf "$(tput setaf 2)Discord has been updated to ${LATEST_APP_VERSION}\n"
		log "discord has been updated to ${LATEST_APP_VERSION}"
	else
		printf "$(tput setaf 3)Discord is already updated to the latest version -> ${LATEST_APP_VERSION}\n"
		log "discord is already updated to the latest version -> ${LATEST_APP_VERSION}"
	fi
	rm -f $FILE_NAME version.txt
fi
exit 0
