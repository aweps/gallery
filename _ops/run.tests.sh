#!/bin/bash

set -Eeuo pipefail
if [ "$(echo "${DEBUG:-}" | tr '[:upper:]' '[:lower:]')" = "true" ]; then set -x; fi

# Load ENV
source _ops/utils/env.sh

# Ensure Flutter on non-docker host
if [[ "$OSTYPE" == "darwin"* ]]; then
	source _ops/install.flutter.macos.sh
fi

flutter pub get
flutter doctor -v

dart analyze ./ --fatal-warnings

if [[ "${DEBUG:-}" == "true" ]]; then VERBOSE_FLAG="-v"; fi
flutter test ${VERBOSE_FLAG:-} --no-pub ${DART_DEFINES:-}
