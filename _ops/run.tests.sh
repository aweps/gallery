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
# doctor is diagnostics, not a gate — DEBUG-only (it costs seconds per
# app on every deep run; the SDK image pin owns toolchain correctness)
if [[ "${DEBUG:-}" == "true" ]]; then flutter doctor -v; fi

dart analyze ./ --fatal-warnings

if [[ "${DEBUG:-}" == "true" ]]; then VERBOSE_FLAG="-v"; fi
flutter test ${VERBOSE_FLAG:-} --no-pub ${DART_DEFINES:-}

# Widget-level integration flows (integration_test/) run in the same VM
# tester when present — an app enrols by adding the directory (catalog
# doctrine; tests/test_app_skeleton.py gates presence per app).
if [ -d integration_test ]; then
    # -d flutter-tester: the tools image exposes desktop+chrome devices too,
# and integration_test triggers device selection (2026-07-16 hunt-adjacent
# find during slopestix enrolment)
flutter test ${VERBOSE_FLAG:-} --no-pub ${DART_DEFINES:-} -d flutter-tester integration_test
fi
