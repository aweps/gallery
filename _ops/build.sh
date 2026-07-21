#!/usr/bin/env bash

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
	if command -v flutter &> /dev/null; then
		flutter precache --android
	fi	
fi

if [[ "${1:-}" == "web" ]]; then

	export PATH="$PATH:$PUB_CACHE/bin"
	#flutter pub global activate webdev

	# Build application
	flutter pub get
	flutter doctor -v
	if [[ "${DEBUG:-}" == "true" ]]; then VERBOSE_FLAG="-v"; fi
	flutter build ${VERBOSE_FLAG:-} web --no-pub --base-href ${2} --${3:-release} ${DART_DEFINES:-}

elif [[ "${1:-}" == "android" ]]; then

	# Monorepo-safe: the invocation cwd is already the app dir; fall back
	# to GITHUB_WORKSPACE only for standalone checkouts (root == app).
	if [ -f pubspec.yaml ]; then pushd .; else pushd ${GITHUB_WORKSPACE:-.}; fi
	flutter pub get
	flutter doctor -v
	if [[ "${DEBUG:-}" == "true" ]]; then VERBOSE_FLAG="-v"; fi

	# Add support for unique Application ID
	export DART_DEFINES="${DART_DEFINES//=gallery/=gallery01}"

	# No --no-pub: with it the tool SKIPS regenerating platform tooling
	# (flutter_command.dart's regenerate...IfApplicable gates on shouldRunPub),
	# so a release build compiles the pub-get-era GeneratedPluginRegistrant —
	# still registering dev-dependency plugins (integration_test) that Gradle
	# rightly EXCLUDES from the release classpath → javac "package ... does
	# not exist" (first live tag build, 2026-07-19). pub get is cached, so
	# the cost is nil.
	flutter build ${VERBOSE_FLAG:-} appbundle --${2:-debug} ${DART_DEFINES:-}
	popd

elif [[ "${1:-}" == "ios" ]]; then

	if [[ "$OSTYPE" != "darwin"* ]]; then
		echo "Need Macos"
		exit 1
	fi

	# Monorepo-safe: the invocation cwd is already the app dir; fall back
	# to GITHUB_WORKSPACE only for standalone checkouts (root == app).
	if [ -f pubspec.yaml ]; then pushd .; else pushd ${GITHUB_WORKSPACE:-.}; fi
	flutter pub get
	flutter doctor -v
	if [[ "${DEBUG:-}" == "true" ]]; then VERBOSE_FLAG="-v"; fi
	flutter build ${VERBOSE_FLAG:-} ipa --no-pub --${2:-debug} --no-codesign ${DART_DEFINES:-}
	# "flutter build ios" is used for local application instead of archive above. Maybe useful in future.
	# Currently, we build xcarchive/ipa to distribute. And "flutter run" to build & run in simulator
	rm -rf ios/Runner.xcarchive && \cp -rf ./build/ios/archive/Runner.xcarchive ios/
	popd

else
    echo "Usage: bash _ops/build.sh web|ios|android"
fi
