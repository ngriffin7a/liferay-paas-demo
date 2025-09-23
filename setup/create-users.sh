#!/bin/bash

csv_file=$1

# Check if the file exists
if [ ! -f "$csv_file" ]; then
	echo "Error: CSV file not found - $csv_file"
	exit 1
fi

source ./load-config.sh

baseURL="$scheme://$hostname:$port"

### Read the header to get column names
header=$(head -n 1 "$csv_file")
IFS=',' read -ra column_names <<< "$header"

### Process each line in the CSV file
tail -n +2 "$csv_file" | while IFS=',' read -ra values; do
	if [[ ${values[0]} == "#"* ]]; then
		continue
	fi

	json="{"
	for ((i=0; i<${#column_names[@]}; i++)); do
		if [ "${column_names[$i]}" == "imageFile" ]; then
			imageFile="${values[$i]}"
			continue
		fi
		json+="\"${column_names[$i]}\": \"${values[$i]}\", "
	done
	json+="\"password\": \"${userPassword}\", "

	# Remove the trailing comma and space
	json="${json%, }"
	json+="}"

	echo "Creating user: ${json}"
	response=`curl -s -S -X POST -u $adminEmail:$adminPassword -H "Content-Type: application/json" "$baseURL/o/headless-admin-user/v1.0/user-accounts" -d "${json}"`
	#echo "-----------------------"
	#echo $response
	#echo "-----------------------"
	userId=`echo "$response" | grep -o '"id" *: *[0-9]*' | grep -o '[0-9]*' | awk 'NR==1{print}'`
	echo "Created userId=$userId"
	echo "Uploading user profile image..."
	response=$(curl -s -S -X POST -u $adminEmail:$adminPassword -H "Content-Type: multipart/form-data" -F "image=@$imageFile" "$baseURL/o/headless-admin-user/v1.0/user-accounts/$userId/image")
	echo "Uploaded profile image=$imageFile"
	echo "Uploading persona image"
	response=$(curl -s -S -X POST -u "$adminEmail:$adminPassword" -H "Content-Type: multipart/form-data" -F "file=@$imageFile" "$baseURL/o/headless-delivery/v1.0/document-folders/$personasFolderId/documents")
	documentId=$(echo "$response" | jq -r '.id')
	echo "Uploaded persona image, documentId=$documentId"
	echo "Updating permissions on persona image"
	response=$(curl -s -S -X PUT -u $adminEmail:$adminPassword -H "Content-Type: application/json" "$baseURL/o/headless-delivery/v1.0/documents/$documentId/permissions" -d '[{"actionIds":["VIEW","DOWNLOAD"],"roleName":"Guest"}]')
	echo "Permissions updated"
	echo " "
	echo "-----------------------"
	sleep 1
done
