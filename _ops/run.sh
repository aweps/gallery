#!/usr/bin/env bash

set -Eeuo pipefail
if [ "$(echo "${DEBUG:-}" | tr '[:upper:]' '[:lower:]')" = "true" ]; then set -x; fi

# Load ENV
source _ops/utils/env.sh

# Ensure Flutter on non-docker host
if [[ "$OSTYPE" == "darwin"* ]]; then
	source _ops/install.flutter.macos.sh
else
	echo "Cannot run simulator in Docker. Need Macos"
	exit 1
fi

# Run app on device
if [[ "${DEBUG:-}" == "true" ]]; then VERBOSE_FLAG="-v"; fi
flutter run ${VERBOSE_FLAG:-} --${1:-debug} --no-pub ${DART_DEFINES:-}
