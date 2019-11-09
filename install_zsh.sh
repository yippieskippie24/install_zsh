#!/bin/bash

#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#
#                                                         #
#                  Install ZSH Script                     #
#                                                         #
#     This script allows a user to quickly install        #
#      ZSH, Oh My ZSH, and modify a few other shell       #
#                configurations on Ubuntu.                #
#                                                         #
#              Written by:  Tyler M Johnson               #
#           https://github.com/yippieskippie24            #
#                                                         #
#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#


#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*##*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#
#                      INSTALL_OHMYZSH function                      #
#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*##*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#

#This function runs the install script for Oh My ZSH.  https://ohmyz.sh

function INSTALL_OHMYZSH() {
              curl -Lo install.sh https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh
              chmod +x install.sh
              ./install.sh --unattended
              sleep 2
              INSTALL_PROMPT
}

#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*##*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#
#                 Set ZSH As Default Shell Function                  #
#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*##*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#

#This function will change the default shell for the user that ran the script

function SET_SHELL() {
             if (whiptail --yesno "Do you want to change the default shell to ZSH for the user: ${SUDO_USER:-${USER}}" 8 78); then
                 sed -i "/${SUDO_USER:-${USER}}/s/bash/zsh/" /etc/passwd
            else
                 whiptail --msgbox "No changes were made." 8 78
             fi
             INSTALL_PROMPT
}

#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*##*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#
#                       Check for ZSH function                       #
#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*##*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#

#This function checks to see if ZSH is installed.  If it's not it will install it with apt. 

function CHECK_ZSH() {
            if [ $(dpkg-query -W -f='${Status}' zsh 2>/dev/null | grep -c "ok installed") -eq 0 ];
            then
              (whiptail --msgbox "ZSH needs to be installed." --ok-button "Continue" 7 32 3>&1 1>&2 2>&3); 
           $SUDO apt update && apt install zsh -y
           INSTALL_PROMPT
           else whiptail --msgbox "ZSH is already installed." --ok-button "Continue" 7 29 3>&1 1>&2 2>&3
           INSTALL_PROMPT
            fi
}

#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*##*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#
#                     INSTALL_PROMPT function                        #
#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*##*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#

#This function prompts the user to install with the option to Exit. 

function INSTALL_PROMPT() {
             START_selection=$(whiptail --title "Install and Setup ZSH" --menu "" --noitem --ok-button Select --cancel-button Exit 10 31 0\
              "Install ZSH" "" "Install Oh My ZSH" "" "Set ZSH As Default Shell" "" "Change ZSH Theme" "" 3>&1 1>&2 2>&3)
             if [ "$START_selection" = "Install ZSH" ]; then
                   CHECK_ZSH
          elif [ "$START_selection" = "Install Oh My ZSH" ]; then
                   INSTALL_OHMYZSH
          elif [ "$START_selection" = "Set ZSH As Default Shell" ]; then
                   SET_SHELL
          elif [ "$START_selection" = "Change ZSH Theme" ]; then
                   SET_THEME
            fi
                   EXIT
}

#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*##*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#
#                        Root Check function                         #
#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*##*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#

#This function simply ensures that it's been run with elevated permission. 

function ROOT_CHECK() {
               ## ROOT CHECK ##
               # Are we root? If not use sudo
               if [[ $EUID -eq 0 ]];then
                   echo "You are root."
               else
                   echo "Sudo will be used for the install."
                   # Check if it is actually installed
                   # If it isn't, exit because the install cannot complete
                   if [[ $(dpkg-query -s sudo) ]];then
                       export SUDO="sudo"
                   else
                       whiptail --msgbox "Not run as root and sudo not installed. Please run as root or install sudo." --ok-button "Exit" 7 32 3>&1 1>&2 2>&3
                       exit 1
                   fi
               fi
               INSTALL_PROMPT
}

#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*##*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#
#                       Set ZSH Theme function                       #
#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*##*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#

#This function prompts the user to change their ZSH theme.  Allows for custom entry. 

function SET_THEME() {
               THEME_selection=$(whiptail --title "What theme do you want to use for ZSH?" --menu "" --nocancel --noitem 10 31 0\
              "Agnoster" "" "Other" "" "Exit" "" 3>&1 1>&2 2>&3)
            if [ "$THEME_selection" = "Agnoster" ]; then
                   sed -i '/ZSH_THEME=/c\ZSH_THEME="agnoster"' ~/.zshrc
          elif [ "$THEME_selection" = "Other" ]; then
                   OTHER_THEME_selection=$(whiptail --title "Specify the name of the ZSH theme:" --inputbox "" 10 78 3>&1 1>&2 2>&3)
                   sed -i '/ZSH_THEME=/c\ZSH_THEME="'"$OTHER_THEME_selection"'"' ~/.zshrc
            fi
            INSTALL_PROMPT
}

#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*##*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#
#                            Exit function                           #
#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*##*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#

#This function exists the script. 

function EXIT() {
     exit
}

#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*##*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#
#                           START function                           #
#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*##*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#

#This is the first function starting it off. 

function START() {
     clear
     ROOT_CHECK
}


#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*##*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#
#                        Calling Functions                           #
#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*##*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#

START


