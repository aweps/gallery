#!/bin/bash

set -Eeuo pipefail

source _ops/get-deps.sh

dartanalyzer ./ --fatal-infos --fatal-warnings

flutter test
