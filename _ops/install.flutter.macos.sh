#!/usr/bin/env bash

set -Eeuo pipefail
if [ "$(echo "${DEBUG:-}" | tr '[:upper:]' '[:lower:]')" = "true" ]; then set -x; fi

# Load ENV
source _ops/utils/env.sh

if [[ "$OSTYPE" != "darwin"* ]]; then
	echo "---"
	echo "Need MacOS"
	exit 1
fi

#sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
#sudo xcodebuild -runFirstLaunch

if ! type pod; then
  echo "CocoaPods not installed. Installer requires sudo permissions"
  sudo gem install cocoapods
fi

if [[ ! -f $FLUTTER_HOME/success ]]; then

	mkdir -p $FLUTTER_HOME && pushd $FLUTTER_HOME

	if [[ ! -f flutter_macos_${FLUTTER_VER}-stable.zip ]]; then
		if [[ "$(uname -a)" = *ARM64* ]]; then
			sudo softwareupdate --install-rosetta --agree-to-license || :
			wget -q https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_arm64_${FLUTTER_VER}-stable.zip -O flutter_macos_${FLUTTER_VER}-stable.zip
		else
			wget -q https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_${FLUTTER_VER}-stable.zip
		fi
	fi

	if [[ ! -d ./flutter ]]; then
		unzip -q flutter_macos_${FLUTTER_VER}-stable.zip
	fi

	#flutter channel stable && flutter upgrade --force
	flutter precache
	popd

	touch $FLUTTER_HOME/success
fi
