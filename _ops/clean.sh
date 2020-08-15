#!/bin/bash

set -Eeuo pipefail

which flutter || export PATH=$PATH:~/flutter/flutter/bin/
echo $PUB_CACHE || export PUB_CACHE=~/.pub-cache

flutter clean || :

# Clean fastlane files
(cd ios && fastlane run clean_cocoapods_cache) || :
(cd ios && fastlane run xcclean scheme:Runner) || :
(cd ios && fastlane run clean_build_artifacts) || :

rm -rf $PUB_CACHE/*

git clean -fdx
