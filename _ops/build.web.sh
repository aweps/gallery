#!/bin/bash

set -Eeuo pipefail

export PATH="$PATH:$PUB_CACHE/bin"
#flutter pub global activate webdev

# Build application
source _ops/get-deps.sh
flutter build web --dart-define=${DART_DEFINES:-}
