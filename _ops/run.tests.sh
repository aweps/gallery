#!/bin/bash

set -Eeuo pipefail
if [ "$(echo "${DEBUG:-}" | tr '[:upper:]' '[:lower:]')" = "true" ]; then set -x; fi

# Load ENV
source _ops/utils/env.sh

# Check if this script is running on Macos 
if [[ "$OSTYPE" == "darwin"* ]]; then
	# Ensure Flutter on non-docker host
	source _ops/install.flutter.macos.sh
else
	# Check if not running under docker
	if [[ "${USE_DOCKER:-}" != "true" ]]; then
		echo "Need to run under docker under linux. set USE_DOCKER"
		exit 1
	fi
fi

flutter pub get
flutter doctor -v

dart analyze ./ --fatal-warnings

if [[ "${DEBUG:-}" == "true" ]]; then VERBOSE_FLAG="-v"; fi
flutter test ${VERBOSE_FLAG:-} --no-pub ${DART_DEFINES:-}
