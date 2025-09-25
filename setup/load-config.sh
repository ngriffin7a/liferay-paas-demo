#!/bin/bash

ColorOn=$(tput setaf 2)
ColorOff=$(tput sgr0)

# Store the config filename in a variable
configFile="config.json"

# Read values from config.json using jq and assign them to shell variables
adminUserId=$(jq -r '.admin.userId' "$configFile")
adminEmailDefault="test@liferay.com"
adminEmail=$(jq -r '.admin.email' "$configFile")
adminProfileImagePath=$(jq -r '.admin.profileImagePath' "$configFile")
adminPasswordDefault="test1"
adminPassword=$(jq -r '.admin.password' "$configFile")
adminGivenName=$(jq -r '.admin.givenName' "$configFile")
adminFamilyName=$(jq -r '.admin.familyName' "$configFile")
adminAlternateName=$(jq -r '.admin.alternateName' "$configFile")
userPassword=$(jq -r '.userPassword' "$configFile")
personasFolderId=$(jq -r '.personasFolderId' "$configFile")
scheme=$(jq -r '.scheme' "$configFile")
port=$(jq -r '.port' "$configFile")
project=$(jq -r '.project' "$configFile")
projectEnv=$(jq -r '.environment' "$configFile")
hostname=$(jq -r '.hostname' "$configFile")

# Output the variables (optional)
if [ "$1" = "print" ]; then
	echo "Admin User ID: $ColorOn$adminUserId$ColorOff$ColorOff"
	echo "Admin Email (Default): $ColorOn$adminEmailDefault$ColorOff"
	echo "Admin Email: $ColorOn$adminEmail$ColorOff"
	echo "Admin Profile Image Path: $ColorOn$adminProfileImagePath$ColorOff"
	echo "Admin Password (Default): $ColorOn$adminPasswordDefault$ColorOff"
	echo "Admin Password: $ColorOn$adminPassword$ColorOff"
	echo "Admin Given Name: $ColorOn$adminGivenName$ColorOff"
	echo "Admin Family Name: $ColorOn$adminFamilyName$ColorOff"
	echo "Admin Alternate Name: $ColorOn$adminAlternateName$ColorOff"
	echo "User Password: $ColorOn$userPassword$ColorOff"
	echo "Personas Folder ID: $ColorOn$personasFolderId$ColorOff"
	echo "Scheme: $ColorOn$scheme$ColorOff"
	echo "Port: $ColorOn$port$ColorOff"
	echo "Project: $ColorOn$project$ColorOff"
	echo "Environment: $ColorOn$projectEnv$ColorOff"
	echo "Hostname: $ColorOn$hostname$ColorOff"
fi
