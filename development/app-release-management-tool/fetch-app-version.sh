#!/bin/bash

APP_PACKAGE_VERSION=$(cat ../../package.json | grep version | head -1 | awk -F: '{ print $2 }' | sed 's/[",]//g' | xargs)

echo $APP_PACKAGE_VERSION