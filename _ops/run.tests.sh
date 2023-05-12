#!/bin/bash

set -Eeuo pipefail

source _ops/get-deps.sh

dart analyze ./ --fatal-infos --fatal-warnings

flutter test --verbose --platform=chrome
