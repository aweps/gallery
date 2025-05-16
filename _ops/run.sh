#!/usr/bin/env bash

set -Eeuo pipefail
if [ "$(echo "${DEBUG:-}" | tr '[:upper:]' '[:lower:]')" = "true" ]; then set -x; fi

# Load ENV
source _ops/utils/env.sh

# Ensure Flutter on non-docker host
if [[ "$OSTYPE" == "darwin"* ]]; then
	source _ops/install.flutter.macos.sh
else
	# Check if not running under docker
	if [[ "${USE_DOCKER:-}" != "true" ]]; then
		echo "Need to run under docker under linux. set USE_DOCKER"
		exit 1
	else
		echo "Cannot run simulator inside Docker. Need Macos"
		exit 1
	fi
fi	

if [[ "${1:-}" == "android" ]]; then
	# Add support for unique Application ID
	export DART_DEFINES="${DART_DEFINES//=gallery/=gallery01}"
fi

# Run app on device
if [[ "${DEBUG:-}" == "true" ]]; then VERBOSE_FLAG="-v"; fi
flutter run ${VERBOSE_FLAG:-} --${2:-debug} --no-pub ${DART_DEFINES:-}
