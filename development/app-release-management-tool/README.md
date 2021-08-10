# app-release-management-tool
aka ARM tool

## Pre-requisites
1. Install fastlane - `brew install fastlane` (Visit `fastlane/README.md` folder for more info)
2. Ensure you copy the `app-release-management-tool` into your mobile application folder where your iOS and Android application folder resides. Else you would need to modify the fastlane and bash script according to your needs.
3. Rename `.env.sample` to `.env`
4. Create an API key from your Apple Developer Account - https://docs.fastlane.tools/app-store-connect-api/
5. Store your API key in a repository and ensure the `APPSTORE_API_GIT_URL` value in the `.env` matches the Git URL value you use when you clone repositories (either SSH or HTTPS)
6. Create an API key from Google Developer Account - https://docs.fastlane.tools/actions/supply/
7. Store your API key in a repository and ensure the `KEYSTORE_GIT_URL` value in the `.env` matches the Git URL value you use when you clone repositories (either SSH or HTTPS)

    > NOTE: For Steps 5 and 7, you may park both of the API keys under a single repository and ensure both of the Environment Variable values match the same Git URL

8. Go into `fastlane/Fastfile` and change the values for the API keys accordingly on Line 6 and 47.


## Setup
1. Run `fastlane release_management`

## Resources
[Semver Tool](https://github.com/fsaintjacques/semver-tool)