#!/bin/bash

#------------------------------------------------------------------#
#Author Mohammad_Asif (Shiekh_aasif)-------------------------------#
#This script takes the backup of the local server------------------#
#Takes File System & Database Backup on local Server---------------#
#------------------------------------------------------------------#


# Colour variables for the script.
green=$(tput setaf 10)
yellow=$(tput setaf 11)
skyblue=$(tput setaf 14)
reset=$(tput sgr0)
red=$(tput setaf 1)

# Ask for user input for backup parameters.
read -p "Enter the file system path to backup: " backup_files
read -p "Enter your MySQL user: " MUSER
read -s -p "Enter your MySQL password: " MPASS
echo # Newline after password input
read -p "Enter your MySQL database name: " DBNAME
read -p "Enter the destination directory to store backups: " dest
read -p "Is it a remote database? (y/n): " remote_db
read -p "Choose the archive format (zip/tar): " archive_format

# Create archive filenames.
day=$(date +%d-%m-%Y)
if [ "$archive_format" = "zip" ]; then
    archive_file1="FS-BKP-$day.zip"
else
    archive_file1="FS-BKP-$day.tar.gz"
fi
archive_file2="DB-BKP-$day.sql"

# Print File System backup start message.
echo -e "$skyblue Script for File System & Database Backup Initiated $reset"
sleep 0.05
echo -e "$skyblue At the end of this script you will get the details of File System & Database Backup Files $reset";
sleep 0.05

# Get the parent directory of the specified backup_files
parent_dir=$(dirname "$backup_files")

# Print File System backup start message.
echo -e "$yellow Backing up $backup_files to $dest/$archive_file1 $reset"
sleep 0.05

# Backup the files using zip or tar based on user's choice
if [ "$archive_format" = "zip" ]; then
    (cd "$parent_dir" && zip -r "$dest/$archive_file1" "$backup_files")
else
    (cd "$parent_dir" && tar czf "$dest/$archive_file1" "$backup_files")
fi

# Print File System backup end status message.
if [[ $? != 0 ]]; then
    echo -e "\n";
    echo -e "$red ERROR! File System Backup Failed. $reset"
    echo -e "\n";
else
    echo -e "$green File System Backup Completed Successfully. $reset"
fi
sleep 0.05

# Print Database backup start message.
echo -e "$yellow Backing up Database to $dest/$archive_file2 $reset"
sleep 0.05

# Perform the database backup based on user input.
if [ "$remote_db" = "y" ]; then
    read -p "Enter the host IP: " HOST
    # Backup Remote Database
    $MYSQLDUMP -h "$HOST" -u "$MUSER" -p"$MPASS" "$DBNAME" > "$dest/$archive_file2"
else
    if [ -z "$MPASS" ]; then
        # Backup local Database with no root password
        $MYSQLDUMP "$DBNAME" > "$dest/$archive_file2"
    else
        # Backup local Database
        $MYSQLDUMP -u "$MUSER" -p"$MPASS" "$DBNAME" > "$dest/$archive_file2"
    fi
fi

# Print Database backup end status message.
if [[ $? != 0 ]]; then
    echo -e "\n";
    echo -e "$red ERROR! Database Backup Failed. $reset"
    echo -e "\n";
else
    echo -e "$green Database Backup Completed Successfully. $reset"
fi
sleep 0.05

# Long listing of files in $dest to check file sizes.
echo -e "$skyblue Below is the list of all Backups present at $dest $reset"
du -shc "$dest"
