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

# Format gate (tests/test_frontend_quality.py FQ-7): the pinned SDK's
# formatter is the arbiter; scoped to source dirs (build/ carries
# generated .dart the formatter must never judge).
FORMAT_PATHS=(lib test)
if [ -d integration_test ]; then FORMAT_PATHS+=(integration_test); fi
dart format --set-exit-if-changed --output=none "${FORMAT_PATHS[@]}"

if [[ "${DEBUG:-}" == "true" ]]; then VERBOSE_FLAG="-v"; fi
<<<<<<< Updated upstream
flutter test ${VERBOSE_FLAG:-} --no-pub ${DART_DEFINES:-}
=======
# --coverage: writes coverage/lcov.info for the floor ratchet below; golden
# comparisons (test/goldens/) run inside this same pass.
flutter test ${VERBOSE_FLAG:-} --coverage --no-pub ${DART_DEFINES:-}
>>>>>>> Stashed changes

# Widget-level integration flows (integration_test/) run in the same VM
# tester when present — an app enrols by adding the directory (catalog
# doctrine; tests/test_app_skeleton.py gates presence per app).
if [ -d integration_test ]; then
    # -d flutter-tester: the tools image exposes desktop+chrome devices too,
# and integration_test triggers device selection (2026-07-16 hunt-adjacent
# find during slopestix enrolment)
flutter test ${VERBOSE_FLAG:-} --no-pub ${DART_DEFINES:-} -d flutter-tester integration_test
fi
<<<<<<< Updated upstream
=======

# Real-browser smoke (test/browser/) — an app enrols by adding the dir
# (FQ-6). Compiles the suite to JS and runs it in the image's headless
# Chrome, catching web-renderer/JS-compile regressions flutter-tester
# cannot see. Container hardening: the default 64MB /dev/shm wedges
# headless Chrome intermittently (observed as an indefinite hang at the
# loading stage), so wrap the executable with --disable-dev-shm-usage;
# and a wedge must turn RED, never hang a CI runner — hence the timeout.
if [ -d test/browser ]; then
    CHROME_REAL="${CHROME_EXECUTABLE:-$(command -v chrome || command -v google-chrome || true)}"
    if [ -n "$CHROME_REAL" ]; then
        CHROME_WRAP="$(mktemp -d)/chrome"
        printf '#!/bin/bash\nexec "%s" --disable-dev-shm-usage --no-sandbox "$@"\n' "$CHROME_REAL" > "$CHROME_WRAP"
        chmod +x "$CHROME_WRAP"
        export CHROME_EXECUTABLE="$CHROME_WRAP"
    fi
    if command -v timeout >/dev/null 2>&1; then
        timeout 600 flutter test ${VERBOSE_FLAG:-} --no-pub ${DART_DEFINES:-} --platform chrome test/browser
    else
        flutter test ${VERBOSE_FLAG:-} --no-pub ${DART_DEFINES:-} --platform chrome test/browser
    fi
fi

# Coverage floor ratchet (FQ-4) — an app enrols by committing
# test/.coverage_floor (a percent, e.g. 85). Asserts the EFFECT (line rate
# computed from lcov) rather than any command's exit code; a missing or
# empty lcov.info fails, never skips.
if [ -f test/.coverage_floor ]; then
    floor=$(tr -d '[:space:]' < test/.coverage_floor)
    rate=$(awk -F: '/^LF:/{lf+=$2} /^LH:/{lh+=$2} END{if (lf==0) print "-1"; else printf "%.1f", lh*100/lf}' coverage/lcov.info)
    echo "Line coverage: ${rate}% (floor: ${floor}%)"
    if ! awk -v r="$rate" -v f="$floor" 'BEGIN{exit (r+0 >= f+0) ? 0 : 1}'; then
        echo "FAIL: line coverage ${rate}% is below the committed floor ${floor}% (test/.coverage_floor — raise tests, never lower the floor)"
        exit 1
    fi
fi
>>>>>>> Stashed changes
