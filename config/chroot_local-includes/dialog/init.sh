#!/bin/sh -e
###################################################################################
# FusionInventory  Live USB                                                       #
# one line to give the program's name and an idea of what it does.                #
# Copyright (C) 2010  Henon Valentin valentin.henon@gmail.com                     #
#                     Blot  Aurélie  blot.aurelie@gmail.com                       #
#                                                                                 #
# This program is free software; you can redistribute it and/or                   #
# modify it under the terms of the GNU General Public License                     #
# as published by the Free Software Foundation; either version 2                  #
# of the License, or (at your option) any later version.                          #
#                                                                                 #
# This program is distributed in the hope that it will be useful,                 #
# but WITHOUT ANY WARRANTY; without even the implied warranty of                  #
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the                   #
# GNU General Public License for more details.                                    #
#                                                                                 #
# You should have received a copy of the GNU General Public License               #   
# along with this program; if not, write to the Free Software                     #
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA. #
###################################################################################
DIALOG=${DIALOG=dialog}
file_path="../dialog"
save_path="/root/.a_configuration_agent"

#########################################################
# Function used during the interruption of programme    #
#########################################################
stop_user()
{
    $DIALOG --title "Fusion Inventory" --clear \
	--yesno "Do you want to restart your computer now?" 10 30
    
    valRet=$?
    case $valRet in
	0)
            # Oui
	    # reboot
	    reboot
	    ;;
	*)
	    # Non ou echap - Recommencer?
	    sh init.sh
	    exit 0
	    ;;
    esac
}


#---------------------------------------------------------------------------------------------------------
# Begin of script

### Creation of the temp file for the responses ###
fichierTemp=/tmp/fichierTempFusionInventory.$$
### Trap for deleting the temp file ###
trap "rm -f $fichierTemp" 0 1 2 5 15


### Check for a backup ###
if [ -f $save_path ]; then
    $DIALOG --title "Fusion Inventory" --clear \
	--yesno "Backup is present, do you want to execute?" 10 100
    valRet=$?
    case $valRet in
	0)
	    # Oui
	    Commande=`cat $save_path | head -n 1`
	    echo $Commande
	    `echo $Commande`
	    sh $file_path/launch_shell.sh $DIALOG
	    exit 0
	    ;;
	255)
	    stop_user
	    ;;
    esac
fi
Commande="fusioninventory-agent"

### Servers's list ###
$DIALOG --title "Fusion Inventory" --clear \
    --inputbox "Servers addresses (separated by a comma [,]): \n( http://fusionserv/ocsinventory )" 16 100 2>$fichierTemp

valRet=$?

case $valRet in
    0)
	if [ ! `cat $fichierTemp` = "" ]; then
	    Commande=$Commande" --server "`cat $fichierTemp`
	fi
	;;
    *)
	stop_user
	;;
esac

### Advanced options ###
$DIALOG --title "Fusion Inventory" --clear \
    --yesno "Do you need advanced options?" 10 100

valRet=$?

case $valRet in
    0)
	# Oui
	sh $file_path/advanced.sh $DIALOG "$Commande" "$file_path" "$save_path"
	exit 0
	;;
    1)
	# Non
	sh $file_path/execution.sh $DIALOG "$Commande" "$file_path" "$save_path"
	exit 0
	;;
    255)
	stop_user
	;;
esac