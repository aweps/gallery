#!/usr/bin/env bash

set -Eeuo pipefail
if [ "$(echo "${DEBUG:-}" | tr '[:upper:]' '[:lower:]')" = "true" ]; then set -x; fi

# Load ENV
source _ops/utils/env.sh

# Ensure Flutter on non-docker host
if [[ "$OSTYPE" == "darwin"* ]]; then
	source _ops/install.flutter.macos.sh
else
	# Check if not running under docker
	if [[ "${USE_DOCKER:-}" != "true" ]]; then
		echo "Need to run under docker under linux. set USE_DOCKER"
		exit 1
	else
		echo "Cannot run simulator inside Docker. Need Macos"
		exit 1
	fi
fi	

if [[ "${1:-}" == "android" ]]; then
	# Add support for unique Application ID
	export DART_DEFINES="${DART_DEFINES//=gallery/=gallery01}"
<<<<<<< Updated upstream
<<<<<<< Updated upstream
<<<<<<< Updated upstream
<<<<<<< Updated upstream
<<<<<<< Updated upstream
=======
=======
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
	# Target the first booted Android device/emulator so `flutter run` is not
	# ambiguous when macOS/Chrome/iOS devices are also connected.
	# `|| :` so a non-zero pipe exit (e.g. no matches) doesn't trip `set -o pipefail`
	# and kill the script before the empty-device check below.
	TARGET_DEVICE=$(adb devices | awk 'NR>1 && $2=="device"{print $1; exit}' || :)
	if [[ -z "$TARGET_DEVICE" ]]; then
		echo "No Android device/emulator connected. Start one first, e.g.:"
		echo "  flutter emulators --launch <id>   (list: flutter emulators)"
		exit 1
	fi
elif [[ "${1:-}" == "ios" ]]; then
	# Target the first booted iOS simulator/device for the same reason.
	TARGET_DEVICE=$(xcrun simctl list devices booted | grep -oE '[0-9A-Fa-f-]{36}' | head -n1 || :)
	if [[ -z "$TARGET_DEVICE" ]]; then
		echo "No booted iOS simulator/device. Boot one first, e.g.:"
		echo "  xcrun simctl boot 'iPhone 17'   (or open -a Simulator)"
		exit 1
	fi
>>>>>>> Stashed changes
fi

# Run app on device
if [[ "${DEBUG:-}" == "true" ]]; then VERBOSE_FLAG="-v"; fi
flutter run ${VERBOSE_FLAG:-} --${2:-debug} --no-pub ${DART_DEFINES:-}
