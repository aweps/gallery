#!/bin/bash

set -Eeuo pipefail

flutter build web --dart-define=${DART_DEFINES:-}
flutter build apk --dart-define=${DART_DEFINES:-} || :
