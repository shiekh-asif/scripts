#!/bin/bash


#------------------------------------------------------------------#
#Author Mohammad_Asif (Shiekh_aasif)-------------------------------#
#This script takes the backup of the remote server-----------------#
#This script needs to be run on the local server-------------------#
#This script uses SCP to transfer backups between the two servers--#
#------------------------------------------------------------------#


# Color codes
red=$(tput setaf 1)
skyblue=$(tput setaf 14)
green=$(tput setaf 2)
yellow=$(tput setaf 11)
reset=$(tput sgr0)
blink='\033[5m'

#Print Script Logo

echo -e "$skyblue---------------------------------------------------------$reset"
echo -e "$blink $skyblue-------------------------------------------------------$reset"

echo -e "$blink 🇷 🇪 🇲 🇴 🇹 🇪    🇸 🇪 🇷 🇻 🇪 🇷    🇧 🇦 🇨 🇰 🇺 🇵  🇸 🇨 🇷 🇮 🇵 🇹 $reset"


echo -e "$blink $skyblue-------------------------------------------------------$reset"
echo -e "$skyblue---------------------------------------------------------$reset"

echo -e "$skyblue Ⓒ  2023. All Rights Reserved. $reset"

sleep 0.5

# Prompt user for input in yellow
read -p "${yellow}Enter the username for the remote server: ${reset}" remote_username
read -p "${yellow}Enter the IP address of the remote server: ${reset}" remote_ip

# Prompt for the remote file system path in yellow
read -p "${yellow}Enter the File System Path to take backup on the remote server: ${reset}" remote_path

# Prompt for additional inputs in yellow
read -p "${yellow}Enter the remote port number: ${reset}" remote_port
read -p "${yellow}Enter the remote database name: ${reset}" db_name
read -p "${yellow}Enter the remote database user: ${reset}" db_user

if [ "$db_user" == "root" ]; then
  # Use root user without specifying the user
  db_password=""
else
  # Prompt for the database user's password in yellow
  read -s -p "${yellow}Enter the remote database password: ${reset}" db_password
fi

# Prompt for the backup storage location in yellow
read -p "${yellow}Enter the backup storage location (e.g., /var/www): ${reset}" backup_location

# Current date for backup filenames
backup_date=$(date +"%d-%m-%Y")

# Define the full path for backup files using the provided location
mysql_backup_filename="${backup_location}/DB-BKP-${backup_date}-${db_name}.sql"
fs_backup_filename="${backup_location}/FS-BKP-${backup_date}.tar.gz"

# Check if the MySQL backup file exists locally
if [ ! -f "$mysql_backup_filename" ]; then
  # MySQL backup command on the remote server
    echo "${skyblue}MySQL backup initiated on the remote server.${reset}"

  ssh -p "$remote_port" "$remote_username@$remote_ip" "mysqldump -u '$db_user' -p'$db_password' '$db_name'" > "$mysql_backup_filename"
  
  # Check if the MySQL backup was successful
  if [ $? -eq 0 ]; then
    echo "${green}MySQL backup successfully created on the remote server.${reset}"
  else
    echo "${red}Failed to create MySQL backup on the remote server.${reset}"
    exit 1
  fi
else
  echo "${green}MySQL backup file already exists locally at $mysql_backup_filename.${reset}"
fi

# Check if the file system backup file exists locally
if [ ! -f "$fs_backup_filename" ]; then
  # File system backup command on the remote server
    echo "${skyblue}File System backup initiated on the remote server.${reset}"

  ssh -p "$remote_port" "$remote_username@$remote_ip" "tar -czf '$fs_backup_filename' '$remote_path'"
  
  # Check if the file system backup was successful
  if [ $? -eq 0 ]; then
    echo "${green}File system backup successfully created on the remote server.${reset}"
  else
    echo "${red}Failed to create file system backup on the remote server.${reset}"
    exit 1
  fi
else
  echo "${green}File system backup file already exists locally at $fs_backup_filename.${reset}"
fi

# Perform the SCP operation to transfer backups from remote server to local server
scp -P "$remote_port" "$remote_username@$remote_ip:$mysql_backup_filename" "$mysql_backup_filename"
if [ $? -eq 0 ]; then
  echo "${green}MySQL backup successfully copied from the remote server to $mysql_backup_filename.${reset}"
else
  echo "${red}Failed to copy MySQL backup from the remote server to $mysql_backup_filename.${reset}"
fi

scp -P "$remote_port" "$remote_username@$remote_ip:$fs_backup_filename" "$fs_backup_filename"
if [ $? -eq 0 ]; then
  echo "${green}File system backup successfully copied from the remote server to $fs_backup_filename.${reset}"
else
  echo "${red}Failed to copy file system backup from the remote server to $fs_backup_filename.${reset}"
fi
