#!/bin/bash

set -Eeuo pipefail

source _ops/get-deps.sh

dartanalyzer ./ --fatal-infos --fatal-warnings

flutter analyze
flutter test
#flutter pub run grinder verify-code-segments
