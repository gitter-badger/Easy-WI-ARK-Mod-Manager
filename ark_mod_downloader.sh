#!/bin/bash

# Debug Modus
DEBUG="OFF"

# Easy-WI Masterserver User
MASTERSERVER_USER="webinterface"

# Steam Login Data
STEAM_USERNAME=""
STEAM_PASSWD=""

# Mod ID�s for Modus "Install all ModIDs"
# Following Mods will be install:
# - K9 Custom Stacks Size
# - Aku Shima
# - No Collision Structures
# - Ark Reborn
# - Admin Command Menu (ACM)
ARK_MOD_ID=("525507438" "479295136" "632091170" "485964701" "558079412")


##########################################
######## from here nothing change ########
##########################################

VERSION="2.0"
ARK_APP_ID="346110"
STEAM_MASTER_PATH="/home/$MASTERSERVER_USER/masterserver/steamCMD"
STEAM_CMD_PATH="$STEAM_MASTER_PATH/steamcmd.sh"
STEAM_CONTENT_PATH="$STEAM_MASTER_PATH/steamapps/workshop/content/$ARK_APP_ID"
STEAM_DOWNLOAD_PATH="$STEAM_MASTER_PATH/steamapps/workshop/downloads/$ARK_APP_ID"
ARK_MOD_PATH="/home/$MASTERSERVER_USER/masteraddons"
EASYWI_XML_FILES="/home/$MASTERSERVER_USER/easywi-xml-files"
LOG_PATH="/home/"$MASTERSERVER_USER"/logs"
MOD_LOG=""$LOG_PATH"/ark_mod_id.log"
MOD_BACKUP_LOG=""$LOG_PATH"/ark_mod_id_backup.log"
TMP_PATH="/home/"$MASTERSERVER_USER"/temp"
DEAD_MOD="depreciated|deprecated|outdated|brocken|not-supported|mod-is-dead|no-longer-supported|old"

USERCHECK() {
	echo; echo
	if [ -d "$ARK_MOD_PATH" ]; then
		if [ ! "$MASTERSERVER_USER" = "" ]; then
			USER_CHECK=$(cat /etc/passwd | grep "$MASTERSERVER_USER" | cut -c 27-)
			if [ ! "$USER_CHECK" == "/home/$MASTERSERVER_USER:/bin/bash" ] && [ ! "$USER_CHECK" == "/home/$MASTERSERVER_USER/:/bin/bash" ]; then
				redMessage "User $MASTERSERVER_USER not found!"
				redMessage "Please check the Masteruser in this Script."
				FINISHED
			fi
		else
			redMessage 'Variable "MASTERSERVER_USER" are empty!'
			FINISHED
		fi
	else
		redMessage "Wrong Masterserver User!"
		redMessage "Please change the Masterserver User inside this Script."
		FINISHED
	fi
}

MENU() {
	clear
	echo
	cyanMessage "###################################################"
	cyanMessage "####         EASY-WI - www.Easy-WI.com         ####"
	cyanMessage "####        ARK - Mod / Content Manager        ####"
	cyanMessage "####               Version: $VERSION                ####"
	cyanMessage "####                    by                     ####"
	cyanMessage "####                Lacrimosa99                ####"
	cyanMessage "####         www.Devil-Hunter-Clan.de          ####"
	cyanMessage "####      www.Devil-Hunter-Multigaming.de      ####"
	cyanMessage "####  lacrimosa99@devil-hunter-multigaming.de  ####"
	cyanMessage "###################################################"
	echo
	whiteMessage "1  -  Install a certain ModID"
	whiteMessage "2  -  Install all ModIDs"
	echo
	whiteMessage "4  -  Update all installed ModIDs"
#	whiteMessage "5  -  Install Updater Script + Cronjob"
#	whiteMessage "6  -  Uninstall Updater Script"
	echo
	whiteMessage "8  -  Uninstall a certain ModID"
	whiteMessage "9  -  Uninstall all ModIDs"
	echo
	whiteMessage "0  -  EXIT"
	echo
	echo
	printf "Number:  "; read -n1 number

	case $number in
		1)
			tput civis; MODE=INSTALL; INSTALL;;

		2)
			tput civis; MODE=INSTALLALL; INSTALL_ALL;;

		4)
			tput civis; MODE=UPDATE; UPDATE;;

#		5)
#			tput civis; UPDATER_INSTALL;;
#
#		6)
#			tput civis; UPDATER_UNINSTALL;;

		8)
			tput civis; UNINSTALL;;

		9)
			tput civis; UNINSTALL_ALL;;

		0)
			echo; clear; exit;;

		*)
			ERROR; MENU;;
	esac
}

INSTALL() {
	echo; echo
	unset ARK_MOD_ID
	if [ ! -f "$TMP_PATH"/ark_mod_updater_status ]; then
		touch "$TMP_PATH"/ark_mod_updater_status
	else
		redMessage "Update in work... aborted!"
		echo
		FINISHED
	fi
	tput cnorm
	printf "Please enter the ModID: "; read -n9 ARK_MOD_ID
	tput civis; echo

	if [ ! "$ARK_MOD_ID" = "" ]; then
		INSTALL_CHECK
		if [ -f "$MOD_BACKUP_LOG" ]; then
			rm -rf "$MOD_BACKUP_LOG"
		fi
		rm -rf "$TMP_PATH"/ark_mod_updater_status
		CLEANFILES
		QUESTION1
	else
		rm -rf "$TMP_PATH"/ark_mod_updater_status
		ERROR
		QUESTION2
	fi
}

INSTALL_ALL() {
	echo; echo
	if [ ! -f "$MOD_LOG" ]; then
		INSTALL_CHECK
		if [ -f "$MOD_BACKUP_LOG" ]; then
			rm -rf "$MOD_BACKUP_LOG"
		fi
		echo; echo
		cyanMessage "List of installed Mods:"
		echo
		cat "$MOD_LOG" | sort
		FINISHED
	else
		redMessage "This option is for first mod installation only."
		redMessage "Installation canceled!"
		FINISHED
	fi
}

UPDATE() {
	echo; echo
	unset ARK_MOD_ID
	if [ ! -f "$TMP_PATH"/ark_mod_updater_status ]; then
		touch "$TMP_PATH"/ark_mod_updater_status
	else
		redMessage "Update in work... aborted!"
		echo
		FINISHED
	fi

	CLEANFILES
	if [ -f "$MOD_LOG" ]; then
		if [ -f "$MOD_BACKUP_LOG" ]; then
			rm -rf "$MOD_BACKUP_LOG"
		fi
		cp "$MOD_LOG" "$TMP_PATH"/ark_custom_appid_tmp.log
		mv "$MOD_LOG" "$MOD_BACKUP_LOG"
	elif [ -f "$MOD_BACKUP_LOG" ]; then
		cp "$MOD_BACKUP_LOG" "$TMP_PATH"/ark_custom_appid_tmp.log
	else
		echo
		redMessage 'File "ark_mod_id.log" in /logs not found!'
		redMessage "Update canceled!"
		rm -rf "$TMP_PATH"/ark_mod_updater_status
		FINISHED
	fi

	if [ -f "$TMP_PATH"/ark_custom_appid_tmp.log ]; then
		ARK_MOD_ID=$(cat "$TMP_PATH"/ark_custom_appid_tmp.log)
		INSTALL_CHECK
		if ! cmp -s "$MOD_LOG" "$MOD_BACKUP_LOG"; then
			redMessage "Error in Logfile found!"
			redMessage "Logfile Backup restored"
			cp "$MOD_BACKUP_LOG" "$MOD_LOG"
		fi
		rm -rf "$TMP_PATH"/ark_mod_updater_status 2>&1 >/dev/null
		CLEANFILES
		FINISHED
	fi
}

#UPDATER_INSTALL() {
#
#}

#UPDATER_UNINSTALL() {
#
#}

UNINSTALL() {
	echo; echo
	if [ -f "$MOD_LOG" ]; then
		unset ARK_MOD_ID
		yellowMessage "List of installed Mods:"
		echo
		cat "$MOD_LOG" | sort

		echo; echo;	tput cnorm
		printf "What ModID you want to uninstall?: "; read -n9 ARK_MOD_ID
		tput civis; echo

		if [ ! "$ARK_MOD_ID" = "" ]; then
			local TMP_NAME=$(cat "$MOD_LOG" | grep "$ARK_MOD_ID")
			local TMP_PATH=$(ls -la "$ARK_MOD_PATH"/ | grep ark_"$ARK_MOD_ID")
			if [ ! "$TMP_NAME" = "" -o ! "$TMP_PATH" = "" ]; then
				rm -rf "$ARK_MOD_PATH"/ark_"$ARK_MOD_ID" 2>&1 >/dev/null
				rm -rf "$EASYWI_XML_FILES"/"$TMP_NAME".xml 2>&1 >/dev/null
				sed -i "/$ARK_MOD_ID/d" "$MOD_LOG"
				echo
				greenMessage "ModID $ARK_MOD_ID is successfully uninstalled."
				echo
				if [ -f "$MOD_BACKUP_LOG" ]; then
					rm -rf "$MOD_BACKUP_LOG"
				fi
				sleep 3
				local CHECK_LOG=$(cat "$MOD_LOG")
				if [ ! "$CHECK_LOG" = "" ]; then
					QUESTION3
				else
					redMessage 'No more installed Mod IDs in "ark_mod_id.log" found!'
					rm -rf "$MOD_LOG"
					echo
					QUESTION2
				fi
			else
				ERROR; UNINSTALL
			fi
		else
			ERROR; UNINSTALL
		fi
	else
		echo
		redMessage 'File "ark_mod_id.log" in /logs not found!'
		redMessage "Uninstall canceled!"
		FINISHED
	fi
}

UNINSTALL_ALL() {
	if [ -f "$MOD_LOG" ]; then
		local DELETE_MOD=$(cat "$MOD_LOG" | cut -c 1-9 )

		if [ ! "$DELETE_MOD" = "" ]; then
			for DELETE in ${DELETE_MOD[@]}; do
				rm -rf "$ARK_MOD_PATH"/ark_"$DELETE" 2>&1 >/dev/null
			done
			rm -rf "$EASYWI_XML_FILES" 2>&1 >/dev/null
		fi

		if [ -f "$MOD_LOG" ] || [ -f "$MOD_BACKUP_LOG" ]; then
			rm -rf "$LOG_PATH"/ark_mod_* 2>&1 >/dev/null
		fi

		echo; echo
		greenMessage "all Mods successfully uninstalled."
		FINISHED
	else
		echo; echo
		redMessage "File $LOG_PATH/ark_mod_id.log not found!"
		redMessage "Delete all exist ARK Mod Folder by Hand."
		FINISHED
	fi
}

#v[1-9].[1-9][1-9].[1-9]
#v[1-9][1-9].[1-9][1-9].[1-9][1-9].[1-9][1-9]
#V [1-9].[1-9] Alpha
#v[1-9][1-9][1-9]
#(Updated!)
#[1-9].[1-9]
# \\ -> " "

MOD_NAME_CHECK() {
	ARK_MOD_NAME_NORMAL=$(curl -s "http://steamcommunity.com/sharedfiles/filedetails/?id=$MODID" | sed -n 's|^.*<div class="workshopItemTitle">\([^<]*\)</div>.*|\1|p')
	ARK_MOD_NAME_TMP=$(echo "$ARK_MOD_NAME_NORMAL" | egrep "Difficulty|ItemTweaks|NPC")
	if [ ! "$ARK_MOD_NAME_TMP" = "" ]; then
		ARK_MOD_NAME=$(echo "$ARK_MOD_NAME_NORMAL" | tr "/" "-" | tr "[A-Z]" "[a-z]" | tr " " "-" | tr -d ".,!()[]" | sed "s/-updated//;s/+/-plus/;s/+/plus/" | sed 's/\\/-/;s/\\/-/;s/---/-/')
	else
		ARK_MOD_NAME=$(echo "$ARK_MOD_NAME_NORMAL" | tr "/" "-" | tr "[A-Z]" "[a-z]" | tr " " "-" | tr -d ".,+!()[]" | sed "s/-updated//;s/-v[0-9][0-9]*//;s/-[0-9][0-9]*//" | sed 's/\\/-/;s/\\/-/;s/---/-/')
	fi
	ARK_MOD_NAME_DEPRECATED=$(echo "$ARK_MOD_NAME" | egrep "$DEAD_MOD")
}

INSTALL_CHECK() {
	for MODID in ${ARK_MOD_ID[@]}; do
		MOD_NAME_CHECK
		if [ "$ARK_MOD_NAME_DEPRECATED" = "" ]; then
			if [ ! "$ARK_MOD_NAME" = "" ] && [ ! "$ARK_MOD_NAME_NORMAL" = "" ]; then
				MOD_DOWNLOAD
				if [ -d "$STEAM_CONTENT_PATH"/"$MODID" ]; then
					if [ -d "$ARK_MOD_PATH"/ark_"$MODID" ]; then
						rm -rf "$ARK_MOD_PATH"/ark_"$MODID"/ShooterGame/Content/Mods/"$MODID"/
					fi
					DECOMPRESS
				else
					echo; echo
					redMessage "Mod Name $MODID in the Steam Content Folder not found!"
					redMessage "Installation canceled!"
					FINISHED
				fi
				if [ -d "$ARK_MOD_PATH"/ark_"$MODID" ]; then
					if [ -f "$MOD_LOG" ]; then
						local MOD_TMP_NAME=$(cat "$MOD_LOG" | grep "$MODID" )
					fi
					if [ "$MOD_TMP_NAME" = "" ]; then
						echo "$MODID" >> "$MOD_LOG"
						if [ "$MODE" = "INSTALL" ] || [ "$MODE" = "INSTALLALL" ]; then
							if [ ! -f "$EASYWI_XML_FILES"/"$ARK_MOD_NAME".xml ]; then
								CREATE_WI_IMPORT_FILE
							fi
						elif [ "$MODE" = "UPDATE" ]; then
							sed -i "/$MODID/d" "$TMP_PATH"/ark_custom_appid_tmp.log
						fi
						chown -cR "$MASTERSERVER_USER":"$MASTERSERVER_USER" "$ARK_MOD_PATH"/ark_"$MODID" 2>&1 >/dev/null
						chown -cR "$MASTERSERVER_USER":"$MASTERSERVER_USER" "$LOG_PATH"/* 2>&1 >/dev/null
						greenMessage "Mod $ARK_MOD_NAME_NORMAL was successfully installed."
						sleep 2
					fi
				else
					echo; echo
					redMessage "Mod $ARK_MOD_NAME_NORMAL in the masteraddons Folder has not been installed!"
					redMessage "Installation canceled!"
					FINISHED
				fi
			else
				redMessage "Steam Community are currently not available or ModID $MODID not known!"
				redMessage "Please try again later."
				redMessage "Installation canceled!"
				FINISHED
			fi
		else
			redMessage "Mod $ARK_MOD_NAME_NORMAL are not more Supported!"
			QUESTION4
			CLEANFILES
			sleep 3
		fi
	done
}

MOD_DOWNLOAD() {
	echo; echo
	cyanonelineMessage "ARK Mod ID:   "; whiteMessage "$MODID"
	cyanonelineMessage "ARK Mod Name: "; whiteMessage "$ARK_MOD_NAME_NORMAL"
	cyanonelineMessage "Steam Download Status: "

	COUNTER=0
	while [ $COUNTER -lt 4 ]; do
		if [ ! -d "$STEAM_CONTENT_PATH" ] || [ ! -d "$STEAM_DOWNLOAD_PATH" ]; then
			su "$MASTERSERVER_USER" -c "mkdir -p "$STEAM_CONTENT_PATH""
			su "$MASTERSERVER_USER" -c "mkdir -p "$STEAM_DOWNLOAD_PATH""
		fi
		touch "$TMP_PATH"/ark_spinner
		SPINNER &
		if ([ ! "$STEAM_USERNAME" = "" ] && [ ! "$STEAM_PASSWD" = "" ]); then
			RESULT=$(su "$MASTERSERVER_USER" -c "$STEAM_CMD_PATH +login $STEAM_USERNAME $STEAM_PASSWD +workshop_download_item $ARK_APP_ID $MODID validate +quit" | egrep "Success" | cut -c 1-7)
		else
			RESULT=$(su "$MASTERSERVER_USER" -c "$STEAM_CMD_PATH +login anonymous +workshop_download_item $ARK_APP_ID $MODID validate +quit" | egrep "Success" | cut -c 1-7)
		fi

		if [ "$RESULT" = "Success" ]; then
			rm -rf "$TMP_PATH"/ark_spinner
			wait $SPINNER
			greenMessage "$RESULT"
			unset RESULT
			cyanonelineMessage "Connection Attempts:   "; whiteMessage "$COUNTER"
			break
		else
			if [ "$COUNTER" = "3" ]; then
				rm -rf "$TMP_PATH"/ark_spinner
				wait $SPINNER
				redMessage "FAILURE"
				cyanonelineMessage "Connection Attempts:   "; whiteMessage "$COUNTER"
				rm -rf "$MOD_LOG"
				cp "$MOD_BACKUP_LOG" "$MOD_LOG"
				if [ -f "$TMP_PATH"/ark_mod_updater_status ]; then
					rm -rf "$TMP_PATH"/ark_mod_updater_status
				fi
				CLEANFILES
				break
			else
				rm -rf $STEAM_CONTENT_PATH/*
				rm -rf $STEAM_DOWNLOAD_PATH/*
				let COUNTER=$COUNTER+1
				sleep 5
			fi
		fi
	done
}

DECOMPRESS() {
	mod_appid=$ARK_APP_ID
	mod_branch=Windows
	modid=$MODID

	modsrcdir="$STEAM_CONTENT_PATH/$MODID"
	moddestdir="$ARK_MOD_PATH/ark_$MODID/ShooterGame/Content/Mods/$MODID"
	modbranch="${mod_branch:-Windows}"

	for varname in "${!mod_branch_@}"; do
		if [ "mod_branch_$modid" == "$varname" ]; then
			modbranch="${!varname}"
		fi
	done

	if [ \( ! -f "$moddestdir/.modbranch" \) ] || [ "$(<"$moddestdir/.modbranch")" != "$modbranch" ]; then
		rm -rf "$moddestdir"
	fi

	if [ -f "$modsrcdir/mod.info" ]; then
		if [ -f "$modsrcdir/${modbranch}NoEditor/mod.info" ]; then
			modsrcdir="$modsrcdir/${modbranch}NoEditor"
		fi

		find "$modsrcdir" -type d -printf "$moddestdir/%P\0" | xargs -0 -r mkdir -p

		find "$modsrcdir" -type f ! \( -name '*.z' -or -name '*.z.uncompressed_size' \) -printf "%P\n" | while read f; do
			if [ \( ! -f "$moddestdir/$f" \) -o "$modsrcdir/$f" -nt "$moddestdir/$f" ]; then
				printf "%10d  %s  " "`stat -c '%s' "$modsrcdir/$f"`" "$f"
				cp "$modsrcdir/$f" "$moddestdir/$f"
				echo -ne "\r\\033[K"
			fi
		done

		find "$modsrcdir" -type f -name '*.z' -printf "%P\n" | while read f; do
			if [ \( ! -f "$moddestdir/${f%.z}" \) -o "$modsrcdir/$f" -nt "$moddestdir/${f%.z}" ]; then
				printf "%10d  %s  " "`stat -c '%s' "$modsrcdir/$f"`" "${f%.z}"
				perl -M'Compress::Raw::Zlib' -e '
					my $sig;
					read(STDIN, $sig, 8) or die "Unable to read compressed file";
					if ($sig != "\xC1\x83\x2A\x9E\x00\x00\x00\x00"){
						die "Bad file magic";
					}
					my $data;
					read(STDIN, $data, 24) or die "Unable to read compressed file";
					my ($chunksizelo, $chunksizehi,
						$comprtotlo,  $comprtothi,
						$uncomtotlo,  $uncomtothi)  = unpack("(LLLLLL)<", $data);
					my @chunks = ();
					my $comprused = 0;
					while ($comprused < $comprtotlo) {
						read(STDIN, $data, 16) or die "Unable to read compressed file";
						my ($comprsizelo, $comprsizehi,
							$uncomsizelo, $uncomsizehi) = unpack("(LLLL)<", $data);
						push @chunks, $comprsizelo;
							$comprused += $comprsizelo;
					}
					foreach my $comprsize (@chunks) {
						read(STDIN, $data, $comprsize) or die "File read failed";
						my ($inflate, $status) = new Compress::Raw::Zlib::Inflate();
						my $output;
						$status = $inflate->inflate($data, $output, 1);
						if ($status != Z_STREAM_END) {
							die "Bad compressed stream; status: " . ($status);
						}
						if (length($data) != 0) {
							die "Unconsumed data in input"
						}
						print $output;
					}
				' <"$modsrcdir/$f" >"$moddestdir/${f%.z}"
				touch -c -r "$modsrcdir/$f" "$moddestdir/${f%.z}"
				echo -ne "\r\\033[K"
			fi
		done

		perl -e '
			my $data;
			{ local $/; $data = <STDIN>; }
			my $mapnamelen = unpack("@0 L<", $data);
			my $mapname = substr($data, 4, $mapnamelen - 1);
				$mapnamelen += 4;
			my $mapfilelen = unpack("@" . ($mapnamelen + 4) . " L<", $data);
			my $mapfile = substr($data, $mapnamelen + 8, $mapfilelen);
			print pack("L< L< L< Z8 L< C L< L<", $ARGV[0], 0, 8, "ModName", 1, 0, 1, $mapfilelen);
			print $mapfile;
			print "\x33\xFF\x22\xFF\x02\x00\x00\x00\x01";
		' $modid <"$moddestdir/mod.info" >"$moddestdir/.mod"

		if [ -f "$moddestdir/modmeta.info" ]; then
			cat "$moddestdir/modmeta.info" >>"$moddestdir/.mod"
		else
			echo -ne '\x01\x00\x00\x00\x08\x00\x00\x00ModType\x00\x02\x00\x00\x001\x00' >>"$moddestdir/.mod"
		fi

		echo "$modbranch" >"$moddestdir/.modbranch"
	fi
}

CREATE_WI_IMPORT_FILE() {
	if [ ! -d "$EASYWI_XML_FILES" ]; then
		mkdir "$EASYWI_XML_FILES"
	fi

	echo '<?xml version="1.0" encoding="utf-8"?>
<addon>
  <active>Y</active>
  <paddon>N</paddon>
  <addon>'ark_$MODID'</addon>
  <type>tool</type>
  <folder/>
  <menudescription>AppID: '$MODID' - '$ARK_MOD_NAME_NORMAL'</menudescription>
  <configs/>
  <cmd/>
  <rmcmd/>
</addon>' > "$EASYWI_XML_FILES"/"$ARK_MOD_NAME".xml

	chown -cR "$MASTERSERVER_USER":"$MASTERSERVER_USER" "$EASYWI_XML_FILES" 2>&1 >/dev/null
	echo
	cyanMessage "Easy-WI XML Import Files under $EASYWI_XML_FILES/ created."
	cyanMessage 'Import Files in the Webinterface under "Gameserver -> Addons -> Add Gameserver Addons".'
}

QUESTION1() {
	echo; echo;	tput cnorm
	printf "additional ModID installing [Y/N]?: "; read -n1 ANSWER
	tput civis
	case $ANSWER in
		y|Y|j|J)
			INSTALL;;
		n|N)
			FINISHED;;
		*)
			ERROR; QUESTION1;;
	esac
}

QUESTION2() {
	echo; echo; tput cnorm
	printf "Want to install a ModID [Y/N]?: "; read -n1 ANSWER
	tput civis
	case $ANSWER in
		y|Y|j|J)
			INSTALL;;
		n|N)
			FINISHED;;
		*)
			ERROR; QUESTION2;;
	esac
}

QUESTION3() {
	echo; echo;	tput cnorm
	printf "additional ModID uninstalling [Y/N]?: "; read -n1 ANSWER
	tput civis
	case $ANSWER in
		y|Y|j|J)
			echo; UNINSTALL;;
		n|N)
			FINISHED;;
		*)
			ERROR; QUESTION3;;
	esac
}

QUESTION4() {
	echo; echo
	tput cnorm
	printf "ModID uninstalling [Y/N]?: "; read -n1 ANSWER
	tput civis
	case $ANSWER in
		y|Y|j|J)
			sed -i "/$MODID/d" "$MOD_BACKUP_LOG"
			rm -rf "$ARK_MOD_PATH"/ark_"$ARK_MOD_ID" 2>&1 >/dev/null;;
		n|N)
			continue;;
		*)
			ERROR; QUESTION4;;
	esac
}

SPINNER() {
	local delay=0.45
	local spinstr='|/-\'
	while [ -f "$TMP_PATH"/ark_spinner ]; do
		local temp=${spinstr#?}
		printf "[%c]  " "$spinstr"
		local spinstr=$temp${spinstr%"$temp"}
		sleep $delay
		printf "\b\b\b\b\b"
	done
	printf "    \b\b\b\b"
}

CLEANFILES() {
	rm -rf "$STEAM_CONTENT_PATH"
	rm -rf "$STEAM_DOWNLOAD_PATH"
	if [ -f "$TMP_PATH"/ark_custom_appid_tmp.log ]; then
		rm -rf "$TMP_PATH"/ark_custom_appid_tmp.log
	fi
	if [ ! "$MODE" = "INSTALLALL" ]; then
		rm -rf "$STEAM_MASTER_PATH"/steamapps/workshop/downloads/state_"$ARK_APP_ID"_*
		rm -rf "$STEAM_MASTER_PATH"/steamapps/workshop/appworkshop_"$ARK_APP_ID".acf
	else
		rm -rf "$STEAM_MASTER_PATH"/steamapps/workshop
	fi
	if [ -f "$TMP_PATH"/ark_spinner ]; then
		rm -rf "$TMP_PATH"/ark_spinner
	fi
}

FINISHED() {
	CLEANFILES
	echo; echo
	tput cnorm
	if [ "$DEBUG" == "ON" ]; then
		set +x
	fi
	exit 0
}

ERROR() {
	echo; echo
	redMessage "It was not a valid input detected!"
	sleep 3
}

greenMessage() {
	echo -e "\\033[32;1m${@}\033[0m"
}

redMessage() {
	echo -e "\\033[31;1m${@}\033[0m"
}

cyanMessage() {
	echo -e "\\033[36;1m${@}\033[0m"
}

yellowMessage() {
	echo -e "\\033[33;1m${@}\033[0m"
}

whiteMessage() {
	echo -e "\\033[1m${@}\033[0m"
}

cyanonelineMessage() {
	echo -en "\\033[36;1m${@}\033[0m"
}

whiteonelineMessage() {
	echo -e "\\033[1m${@}\033[0m"
}

### Start ###

if [ "$DEBUG" == "ON" ]; then
	set -x
fi

id | grep "uid=0(" > /dev/null
if [ $? != "0" ]; then
	uname -a | grep -i CYGWIN > /dev/null
	if [ $? != "0" ]; then
		redMessage "Still not root, aborting!"
		echo
		echo
		exit 1
	fi
fi

USERCHECK
MENU