##!/bin/bash

# Check if stepNumber is provided as an argument
if [ -z "$1" ]; then
  echo "Usage: $0 stepNumber"
  exit 1
fi

stepNumber=$1

case $stepNumber in
  5)
	source ./load-config.sh print
    ;;
  *)
	source ./load-config.sh
    ;;
esac

baseURL="$scheme://$hostname:$port"

push_deploy_restart_wait() {
    local step=$1
	echo "Step $step: PUSH (yes, PUSH!) the clone to origin"
	echo "        e.g."
	echo "        git push origin master"
    echo "        WAIT for Jenkins to do a build"
	echo "        DEPLOY the build to PRD"
	echo "        RESTART the Liferay Service after it warms up (might be necessary for site initializers to work)"
	echo "        WAIT for the restart to finish"
}

case $stepNumber in
  1)
	echo "Step $stepNumber: Sign-in to the PRD site provisioned by SSA as ${ColorOn}test@liferay.com${ColorOff} and change the password to ${ColorOn}test1${ColorOff}"
    ;;

  2)
    echo "Step $stepNumber: Under Instance Settings > User Authentication:"
    echo "        UNCHECK \"Require strangers to verify their email address?\""
    echo "        UNCHECK \"Require password for email or screen name updates?\""
    echo "        CLICK \"Save\""
	echo " "
    echo "        Under Instance Settings > Infrastructure > Site Scope > Session Timeout:"
    echo "        CHECK \"Auto Extend\""
    echo "        CLICK \"Update\""
	echo " "
    echo "        Under Instance Settings > Page Fragments > Virtual Instance Scope > Page Fragments:"
    echo "        CHECK \"Propagate Fragment Changes Automatically\""
    echo "        CLICK \"Save\""
	echo " "
    echo "        Under Instance Settings > AI Creator > OpenAI:"
    echo "        PASTE \"API Key\""
    echo "        CLICK \"Save\""
    ;;

  3)
    echo "Step $stepNumber: NAVIGATE TO App Menu > Control Panel > Security > Password Policies > Default Password Policy"
	echo "        DISABLE \"PASSWORD CHANGES > Change Required\""
	echo "        SAVE the password policy"
    ;;

  4)
	echo "Step $stepNumber: CREATE an Asset Library named ${ColorOn}Images${ColorOff}"
	echo "        SHARE the Asset Library with the ${ColorOn}Liferay DXP${ColorOff} site and MAKE-UNSEARCHABLE"
    ;;

  5)
	echo "Step $stepNumber: Under the Asset Library Documents and Media, create a folder named ${ColorOn}Personas${ColorOff} and determine the ${ColorOn}personasFolderId${ColorOff}\n"
	# As of release 2024.q3.3 the headless REST API does not have an endpoint that supports creation of an asset library
	#curl -X POST -u $adminEmail:$adminPassword -H "Content-Type: application/json" "$baseURL/o/headless-asset-library/v1.0/asset-libraries" -d '{"name": "Images"}'
	#curl -X POST -u $adminEmail:$adminPassword -H "Content-Type: application/json" "$baseURL/o/headless-asset-library/v1.0/asset-libraries" -d '{"name": "Shared"}'
    ;;

  6)
    echo "Step $stepNumber: Edit config.json and FIX the ${ColorOn}values${ColorOff} ^^^ above ^^^ (including the ${ColorOn}personasFolderId${ColorOff} from the previous step"
    ;;

  7)
    echo "Step $stepNumber: Fixing administrator screenName=[$adminAlternateName] firstName=[$adminGivenName], lastName=[$adminFamilyName], and emailAddress=[$adminEmail]"
	json='{"alternateName": "'$adminAlternateName'", "emailAddress": "'$adminEmail'", "currentPassword": "'$adminPasswordDefault'", "password": "'$adminPassword'", "givenName": "'$adminGivenName'", "familyName": "'$adminFamilyName'", "jobTitle": "Liferay DXP Admin", "status": "Active"}'
	curl -X PUT -u $adminEmailDefault:$adminPasswordDefault -H "Content-Type: application/json" "$baseURL/o/headless-admin-user/v1.0/user-accounts/$adminUserId" -d "${json}"
    ;;

  8)
    echo "Step $stepNumber: Uploading administrator PROFILE image"
	curl -X POST -u $adminEmail:$adminPassword -H "Content-Type: multipart/form-data" -F "image=@$adminProfileImagePath" "$baseURL/o/headless-admin-user/v1.0/user-accounts/$adminUserId/image"
    ;;

  9)
    echo "Step $stepNumber: Uploading administrator PERSONA image to the Personas folder"
	response=$(curl -S -X POST -u "$adminEmail:$adminPassword" -H "Content-Type: multipart/form-data" -F "file=@$adminProfileImagePath" "$baseURL/o/headless-delivery/v1.0/document-folders/$personasFolderId/documents")
	documentId=$(echo "$response" | jq -r '.id')
	curl -X PUT -u $adminEmail:$adminPassword -H "Content-Type: application/json" "$baseURL/o/headless-delivery/v1.0/documents/$documentId/permissions" -d '[{"actionIds":["VIEW","DOWNLOAD"],"roleName":"Guest"}]'
    ;;

  10)
	echo "Step $stepNumber: Clone the GitHub repo locally, and determine the clone's name (e.g. ${ColorOn}$project${ColorOff})"
    ;;

  11)
    echo "Step $stepNumber: EDIT liferay/LCP.json in the clone (the ${ColorOn}memory${ColorOff} one is close to the top, ${ColorOn}LIFERAY_JVM_OPTS${ColorOff} close to the bottom)"
    echo "         \"${ColorOn}memory${ColorOff}\": ${ColorOn}16384${ColorOff},"
	echo "         \"${ColorOn}LIFERAY_JVM_OPTS${ColorOff}\": \"${ColorOn}-Xms8192m -Xmx12288m -XX:MaxMetaspaceSize=3072m --add-opens=java.base/java.lang=ALL-UNNAMED --add-opens=java.base/java.lang.invoke=ALL-UNNAMED --add-opens=java.base/java.lang.reflect=ALL-UNNAMED --add-opens=java.base/java.net=ALL-UNNAMED --add-opens=java.base/sun.net.www.protocol.http=ALL-UNNAMED --add-opens=java.base/sun.net.www.protocol.https=ALL-UNNAMED --add-opens=java.base/sun.util.calendar=ALL-UNNAMED --add-opens=jdk.zipfs/jdk.nio.zipfs=ALL-UNNAMED${ColorOff}\""
	echo " "
	echo "         STAGE and COMMIT"
    ;;

  12)
	echo "Step $stepNumber: COPY ../liferay/configs/${ColorOn}common${ColorOff}/portal-common.properties to $project/liferay/configs/${ColorOn}common${ColorOff}"
    echo "         COPY ../liferay/configs/${ColorOn}prd${ColorOff}/portal-ext.properties to $project/liferay/configs/${ColorOn}prd${ColorOff}"
	echo "         STAGE and COMMIT"
    ;;

  13)
    echo "Step $stepNumber: COPY ../liferay/configs/common/osgi to the $project/liferay/configs/common"
	echo "         IF NECESSARY, CREATE $project/liferay/configs/common/tomcat/css/fonts.css"
	echo "         DOWNLOAD FONTS TO $project/liferay/configs/common/tomcat/fonts"
	echo "         STAGE and COMMIT"
    ;;

  14)
	echo "Step $stepNumber: Create the client-extensions folder in the clone (e.g. $project/liferay/${ColorOn}client-extensions${ColorOff})"
	echo "         COPY ../liferay/client-extensions/global-site-initializer to $project/liferay/client-extensions"
    echo "         cd $project/liferay/client-extensions/global-site-initializer"
	echo "         EDIT ${ColorOn}siteExternalReferenceCode${ColorOff} in client-extension.yaml (UNLESS IT IS ${ColorOn}L_GLOBAL${ColorOff} WHICH STARTED WITH 2024.Q3)${ColorOff}"
	echo "         cd global-site-initializer"
	echo "         blade gw clean build"
	echo "         lcp deploy --extension dist/global-site-initializer.zip -p $project-$projectEnv"
    ;;

  15)
	push_deploy_restart_wait 14;
    ;;

  16)
    echo "Step $stepNumber: OBSERVE: The value of the ${ColorOn}ID${ColorOff} of the Press Release structure (needed for the ${ColorOn}subTypeId${ColorOff} in the next step)"
    ;;

  17)
    echo "Step $stepNumber: COPY ../liferay/client-extensions/guest-site-initializer to the clone"
    echo "         EDIT the value of ${ColorOn}subtypeId${ColorOff} in liferay/client-extensions/guest-site-initializer/site-initializer/layout-page-templates/display-page-templates/press-release-dpt/display-page-template.json"
	echo "         cd guest-site-initializer"
	echo "         blade gw clean build"
	echo "         lcp deploy --extension dist/guest-site-initializer.zip -p $project-$projectEnv"
    ;;

  18)
	echo "Step $stepNumber: Make sure that the Guest site initializer worked by verifying tha it has, for example, the External Video Shortcut DPT"
    ;;

  19)
    echo "Step $stepNumber: SET the \"Press Release\" DPT as the default" in the Liferay DXP site
	echo "         NOTE: It will get overwritten on subsequent restarts, so might want to make a copy of it if it has to change"
    ;;

  20)
    echo "Step $stepNumber: Make a copy the widget templates, since they will get overwritten on restarts"
	echo "         COPY \"Article Type\" to a new name"
	echo "         COPY \"File Type\" to a new name"
	echo "         COPY \"Media Type\" to a new name"
	echo "         COPY \"Search Results Preview\" to a new name"
    ;;

  21)
    echo "Step $stepNumber: CREATE a style book using https://dialect-style-book-generator.web.app"
	echo "         IMPORT the style book into the site"
	echo "         SET the imported style book as the default"
    ;;

  22)
    echo "Step $stepNumber: COPY the \"Demo Master\" page to a new project-specific master page, since it gets overwritten on restarts"
	echo "         SET the new project-specific master page as the default"
    ;;

  23)
	echo "Step $stepNumber: DELETE the OOTB Search Widget Page"
    echo "         CREATE a content page named ${ColorOn}Search${ColorOff} off the Demo Template for Search"
	echo "         SET the Display Template of the \"Article Type\" custom facet to the copied one"
	echo "         SET the Display Template of the \"File Type\" custom facet to the copied one"
	echo "         SET the Display Template of the \"Media Type\" custom facet to the copied one"
	echo "         SET the Display Template of the \"Search Results\" widget to the copied one"
	echo "         PUBLISH the Search content page"
	echo "         EDIT the new project-specific master page and configure the search box so that the Destination Page field is ${ColorOn}/search${ColorOff}"
	echo "         PUBLISH the project-specific master page"
    ;;

  24)
    echo "Step $stepNumber: Make a copy the Sign-In Utility Page template, since it will get overwritten on restarts"
	echo "         COPY \"Sign-In\" to a new name"
	echo "         EDIT the ${ColorOn}new Sign-In${ColorOff} page"
    echo "         SET the Master Page Template for the ${ColorOn}new Sign-In${ColorOff} page to the copied Master Page Template and Publish the changes"
	echo "         EDIT+PUBLISH the \"Sign-In\" page"
	echo "         SET the \"Sign-In\" as default"
    ;;

  25)
    echo "Step $stepNumber: SET the Master Page Template for the ${ColorOn}Search${ColorOff} page to the copied Master Page Template and Publish the changes"
    echo "         SET the Master Page Template for the ${ColorOn}Home${ColorOff} page to the copied Master Page Template and Publish the changes"
    ;;

  *)
    echo "Invalid step number. Please provide a value between 1 and 25."
    exit 1
    ;;

esac
