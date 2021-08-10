#!/bin/bash

SCRIPT_DIR=$(dirname "$0")

# always go back to project directory regardless of the path you are in while executing this script
cd $SCRIPT_DIR/../

NEW_VERSION=$1
CURRENT_VERSION=$(cat package.json \
  | grep version \
  | head -1 \
  | awk -F: '{ print $2 }' \
  | sed 's/[",]//g')

echo -e "Notes: There are 2 scenarios that we will run this script."
echo -e ""
echo -e "\t1: To bump the version after a production release in the development branch after merged back from the master branch."
echo -e "\t   Reason: The released production version is closed for new build submissions in Apple TestFlight"
echo -e "\t2: To bump the version right before a release in the development branch before merging into master."
echo -e ""
echo -e "Example of Current Version vs New Version:"
echo -e "\tCurrent -> New :"
echo -e "\t  X.Y.Z -> X.Y.Z+1 : bump a patch"
echo -e "\t  X.Y.Z -> X.Y+1.0 : bump a minor"
echo -e "\t  X.Y.Z -> X+1.0.0 : bump a major"
echo -e ""
echo -e "Current Version: $CURRENT_VERSION"
echo -e "New Version: $NEW_VERSION\n"

read -p "Please confirm if you want to bump to new version? (Y/n) " confirm_user_input

if [[ $confirm_user_input == "Y" || $confirm_user_input == "y" || $confirm_user_input == "Yes" || $confirm_user_input == "yes" ]]
then
  echo -e ""
  echo -e "User entered $confirm_user_input. Proceeding...\n"

  echo -e "Replacing package.json Version Code.....\n"

  find package.json -exec sed -i '.bak' -e '/version/s/: ".*",/: "'${NEW_VERSION}'",/' {} \;

  echo -e "Replacing Android Version Code.....\n"

  find android/app/build.gradle -exec sed -i '.bak' -e '/versionName/s/".*"/"'${NEW_VERSION}'"/' {} \;

  echo -e "Replacing iOS Version Code....\n"

  find ios/ProjectName.xcodeproj/project.pbxproj -exec sed -i '.bak' -e '/MARKETING_VERSION/s/ = .*;/ = '${NEW_VERSION}';/' {} \;

  echo -e "App version bump completed from $CURRENT_VERSION to $NEW_VERSION"

  # LEAVE THIS HERE FOR TESTING PURPOSE

  # cd ../ios/ProjectName.xcodeproj/
  # ls -la
  # pwd
  # sed -i '.bak' -e '/MARKETING_VERSION/s/ = .*;/ = '${VERSION}';/' project.pbxproj
else
  echo "User entered $confirm_user_input, exit!"
fi
