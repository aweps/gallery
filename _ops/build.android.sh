#!/bin/bash

set -Eeuo pipefail

# Build application
source _ops/get-deps.sh
flutter build apk --dart-define=${DART_DEFINES:-}

exit
(cd android && bundle update && bundle exec fastlane internal || :)
