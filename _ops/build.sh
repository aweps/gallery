#!/usr/bin/env bash

set -Eeuo pipefail
if [ "$(echo "${DEBUG:-}" | tr '[:upper:]' '[:lower:]')" = "true" ]; then set -x; fi

# Load ENV
source _ops/utils/env.sh

# Ensure Flutter on non-docker host
if [[ "$OSTYPE" == "darwin"* ]]; then
	source _ops/install.flutter.macos.sh
fi

if [[ "${1:-}" == "web" ]]; then

	export PATH="$PATH:$PUB_CACHE/bin"
	#flutter pub global activate webdev

	# Build application
	flutter pub get
	flutter doctor -v
	if [[ "${DEBUG:-}" == "true" ]]; then VERBOSE_FLAG="-v"; fi
	flutter build ${VERBOSE_FLAG:-} web --no-pub --base-href ${2} --${3:-release} ${DART_DEFINES:-}

elif [[ "${1:-}" == "android" ]]; then

	pushd ${GITHUB_WORKSPACE:-.}
	flutter pub get
	flutter doctor -v
	if [[ "${DEBUG:-}" == "true" ]]; then VERBOSE_FLAG="-v"; fi
	flutter build ${VERBOSE_FLAG:-} appbundle --no-pub --${2:-debug} ${DART_DEFINES:-}
	popd

elif [[ "${1:-}" == "ios" ]]; then

	if [[ "$OSTYPE" != "darwin"* ]]; then
		echo "Need Macos"
		exit 1
	fi

	pushd ${GITHUB_WORKSPACE:-.}
	flutter pub get
	flutter doctor -v
	if [[ "${DEBUG:-}" == "true" ]]; then VERBOSE_FLAG="-v"; fi
	flutter build ${VERBOSE_FLAG:-} ipa --no-pub --${2:-debug} --no-codesign ${DART_DEFINES:-}
	# "flutter build ios" is used for local application instead of archive above. Maybe useful in future.
	# Currently, we build xcarchive/ipa to distribute. And "flutter run" to build & run in simulator
	rm -rf ios/Runner.xcarchive && \cp -rf ./build/ios/archive/Runner.xcarchive ios/
	popd

else
    echo "Usage: bash _ops/build.sh web|ios|android"
fi
