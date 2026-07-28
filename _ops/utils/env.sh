#!/bin/bash

set -Eeuo pipefail
if [ "$(echo "${DEBUG:-}" | tr '[:upper:]' '[:lower:]')" = "true" ]; then set -x; fi

######## Preserve control vars ########
if [ ! -z "${DEBUG:-}" ] && [[ "${DEBUG:-}" != "" ]]; then
    XDEBUG=${DEBUG:-}
    XNSDEBUG=${NSDEBUG:-}
    XWAIT_ON_ERROR=${WAIT_ON_ERROR:-}
fi

######## Trap errors and break via tmate ########
source _ops/utils/onerror.sh

# Find current branch
if [[ "${GIT_BRANCH_REF:-}" == "" ]]; then
    if [[ "${DRONE_COMMIT_REF:-}" != "" ]]; then
        GIT_BRANCH_REF=$DRONE_COMMIT_REF

    elif [[ "${GITHUB_REF:-}" != "" ]]; then
        GIT_BRANCH_REF=$GITHUB_REF

    elif [[ "${CIRCLECI:-}" == "true" ]]; then
        if [[ "${CIRCLE_BRANCH:-}" != "" ]]; then
            GIT_BRANCH_REF="refs/heads/$CIRCLE_BRANCH"
        elif [[ "${CIRCLE_TAG:-}" != "" ]]; then
            GIT_BRANCH_REF="refs/tags/$CIRCLE_TAG"
        elif [[ "${CIRCLE_PR_NUMBER:-}" != "" ]]; then
            GIT_BRANCH_REF="refs/pull/$CIRCLE_PR_NUMBER/merge"
        else
            echo "unsupported in circleci"
            exit 1
        fi
    else
        GIT_BRANCH_REF=local
    fi
fi
export GIT_BRANCH_REF

# Setup secret vars
if [[ `echo $GIT_BRANCH_REF | grep "^refs/" -c` == "1" ]]; then
    if [[ "${SECRETS_B64:-}" == "" ]]; then
        if [[ "$GIT_BRANCH_REF" == "refs/tags/"* ]]; then
            export SECRETS_B64=${SECRETS_B64_PROD:-}
        else
            export SECRETS_B64=${SECRETS_B64_DEV:-}
        fi
    fi
fi

# Determine which env file to load
if [[ `echo $GIT_BRANCH_REF | grep "^refs/\(heads\|pull\)/" -c` == "1" ]]; then
    BRANCH_ENV_FILE=$(echo $GIT_BRANCH_REF | sed -r 's/^refs\/[^\/]+\///g')

elif [[ `echo $GIT_BRANCH_REF | grep "^refs/tags/" -c` == "1" ]]; then
    BRANCH_ENV_FILE=tags

elif [[ "$GIT_BRANCH_REF" == "local" ]]; then
    BRANCH_ENV_FILE=local

else
    echo "unsupported ref: $GIT_BRANCH_REF"
    exit 1
fi

DIR_CI=.cicd
OPS_DIR=_ops
ENV_FILE=${ENV_FILE:-$OPS_DIR/.env}
SECRETS_SRC=${SECRETS_SRC:-$OPS_DIR/.secrets}
SECRETS_FILE="$DIR_CI/.secrets.$RANDOM"
ENV_FILE2="$DIR_CI/.env.$RANDOM"

function exportVars()
{
    set +x
<<<<<<< Updated upstream
<<<<<<< Updated upstream
<<<<<<< Updated upstream
<<<<<<< Updated upstream
<<<<<<< Updated upstream
<<<<<<< Updated upstream
<<<<<<< Updated upstream
<<<<<<< Updated upstream
<<<<<<< Updated upstream
    source /dev/stdin <<<"$(grep -v '^#' $1 | sed -re "s/^([^=]+)=([^']+).*/\1='\2'/" | grep '=' | sed -re "s/^[^=]+=.*[^'=]$/\0'/" | sed -re "s/^[^=]+='$/\0'/" | sed -E -n 's/[^#]+/export &/ p')"
=======
    source /dev/stdin <<<"$(grep -v '^#' $1 | grep -E '^[A-Za-z_][A-Za-z0-9_]*=' | sed -re "s/^([^=]+)=([^']+).*/\1='\2'/" | grep '=' | sed -re "s/^[^=]+=.*[^'=]$/\0'/" | sed -re "s/^[^=]+='$/\0'/" | sed -E -n 's/[^#]+/export &/ p')"
>>>>>>> Stashed changes
=======
=======
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
    # Same quoting transform as before, applied line-by-line so a value that
    # defeats it fails HERE, naming the source file and line -- not later as an
    # opaque '/dev/stdin: line N' abort. Values are never echoed: these files
    # carry secrets.
    local _src=$1 _lineno=0 _line _xline _out=""
    while IFS= read -r _line || [ -n "$_line" ]; do
        _lineno=$((_lineno + 1))
        case "$_line" in '#'*) continue ;; esac
        # || _xline="": under the caller's set -e/pipefail an empty or
        # non-KEY=value line exits this pipeline 1 (grep finds no '='), which
        # would kill the shell before the continue below ever runs
        # (2026-07-19 live-baker find; every .env.common leads with a blank line).
        _xline=$(printf '%s\n' "$_line" | sed -re "s/^([^=]+)=([^']+).*/\1='\2'/" | grep = | sed -re "s/^[^=]+=.*[^'=]$/\0'/" | sed -re "s/^[^=]+='$/\0'/" | sed -E -n 's/[^#]+/export &/ p') || _xline=""
        [ -n "$_xline" ] || continue
        if ! printf '%s\n' "$_xline" | grep -Eq '^export [A-Za-z_][A-Za-z0-9_]*='; then
            echo "exportVars: $_src line $_lineno: does not reduce to a single KEY=value export (value withheld)" >&2
            exit 1
        fi
        _out="${_out}${_xline}
"
    done < "$_src"
    source /dev/stdin <<<"$_out"
<<<<<<< Updated upstream
<<<<<<< Updated upstream
<<<<<<< Updated upstream
<<<<<<< Updated upstream
<<<<<<< Updated upstream
<<<<<<< Updated upstream
<<<<<<< Updated upstream
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
    if [ "$(echo "${DEBUG:-}" | tr '[:upper:]' '[:lower:]')" = "true" ]; then set -x; fi

    ######## Restore control vars ########
    if [ ! -z "${XDEBUG:-}" ]; then
        export DEBUG=${XDEBUG}
        export NSDEBUG=${XNSDEBUG}
        export WAIT_ON_ERROR=${XWAIT_ON_ERROR}
    fi

    # Load DEBUG
    if [ "$(echo "${DEBUG:-}" | tr '[:upper:]' '[:lower:]')" = "true" ]; then set -x; fi
}

# ensure CICD dir
mkdir -p $DIR_CI

######## ENV Vars ########
# Load local env file
if [ -f $ENV_FILE ]; then
    \cp -f $ENV_FILE $ENV_FILE2
fi
touch $ENV_FILE2

# Load branch specific env
ENV_FILE_BR=${ENV_FILE}.`echo ${BRANCH_ENV_FILE} | sed 's/[^[:alnum:]]/_/g'`
if [ -f "${ENV_FILE_BR}" ]; then
    cat $ENV_FILE_BR >> $ENV_FILE2
fi

# Load local env
if [[ "$GIT_BRANCH_REF" == "local" ]]; then
    if [[ `git config user.name` != "" ]]; then
        export GIT_USER=$(git config user.name)
        echo "TARGET_USR=u$( (git config user.name || :) | md5sum | cut -f1 -d' ' | fold -w8 | head -n1)" >> $ENV_FILE2
    elif [[ "${GIT_USER:-}" == "" ]]; then
        set +x
        echo 'Missing git user. Set using :- git config --global user.name "John Doe"'
        exit
    fi

    # Load local env file
    if [ -f ${ENV_FILE}.temp ]; then
        cat ${ENV_FILE}.temp >> $ENV_FILE2
    fi
fi

# Load env
exportVars $ENV_FILE2

######## Secrets ########
# Secret from external env
if [[ "${SECRETS_B64:-}" != "" ]]; then
    echo $SECRETS_B64 | base64 -d > ${SECRETS_SRC}.${STATE_ENV}
fi
# Load local secrets file
\cp -f $SECRETS_SRC $SECRETS_FILE
if [ -f ${SECRETS_SRC}.${STATE_ENV:-} ]; then
    cat ${SECRETS_SRC}.${STATE_ENV} >> $SECRETS_FILE
fi
if [[ ! -z ${ENABLE_ADMIN:-} && ${ENABLE_ADMIN} == "true" && -f ${SECRETS_SRC}.admin ]]; then
    cat ${SECRETS_SRC}.admin >> $SECRETS_FILE
fi
#Remove empty vars (portable in-place: BSD sed parses `-i -re` as backup
#extension "-re", littering a second secret copy; -i.bak works on both)
sed -i.bak -E -e '/^[^=]+=$/d' $SECRETS_FILE && rm -f ${SECRETS_FILE}.bak
exportVars $SECRETS_FILE

######## Updated Env Vars ########
# Fill secrets
# Strip comment lines before the sh stage: the unquoted heredoc executes
# backticks/$() anywhere in its body, comments included (a `cmd` in an env
# comment would RUN cmd here; 2026-07-17 verb-cycle find).
( printf "cat <<EOF\n" ; grep -v '^[[:space:]]*#' $ENV_FILE2 || : ; printf "\nEOF" ) | sh > ${ENV_FILE2}.tmp
mv ${ENV_FILE2}.tmp $ENV_FILE2

# Load modified env
exportVars $ENV_FILE2

# The temp materializations carry REAL secret values whenever a
# .secrets.<env> exists — remove them now that they are exported
# (secrets-at-rest under .cicd/ red the A9 gitleaks gate; 2026-07-17 find).
rm -f $SECRETS_FILE $ENV_FILE2


#################### APP SPECIFIC ####################3

# Setup extra paths
export PATH="$PATH:$EXTRA_PATHS"

# APP_SUFFIX is used to create a build-time RELEASE_CHANNEL
# Setup Dart Defines
if [[ `echo $GIT_BRANCH_REF | grep "^refs/tags/" -c` == "1" ]]; then
    TAG_SUFFIX=$(echo $GIT_BRANCH_REF | sed -E -e 's/refs\/tags\/[^/]*\/?.*-([^-+]+)\+.*/\1/' -e t -e 's/.*//')
    if [[ ! -z "${TAG_SUFFIX// }" ]]; then
        # Specific prod release channel
        export RELEASE_CHANNEL=${TAG_SUFFIX}
    else
        # Default prod release channel
        export RELEASE_CHANNEL=prod
    fi
else
    # Default dev release channel
    export RELEASE_CHANNEL=dev
fi

# RELEASE_CHANNEL comes from a git tag suffix, so it is operator input, not a
# known-safe token: `1.0.7-beta.1+N` yields channel "beta.1". Both lookups below
# build a VARIABLE NAME from it, and an indirect expansion on an invalid name
# ("beta.1") or an undefined one (an unknown channel like "alpha") is a hard
# bash error under `set -u`. Sanitize once here, and use `:-` so an unknown
# channel reaches its intended "Missing DART_DEFINES" message instead of an
# opaque bash abort (2026-07-22; both pre-date per-channel keystores).
RELEASE_CHANNEL_VAR=${RELEASE_CHANNEL//[^A-Za-z0-9_]/_}
export RELEASE_CHANNEL_VAR

DART_DEFINES=DART_DEFINES_B64_${RELEASE_CHANNEL_VAR}
export DART_DEFINES=`echo ${!DART_DEFINES:-} | base64 -d`
[[ $DART_DEFINES != "" ]] || (echo "Missing DART_DEFINES"; exit 1)
export $(echo $DART_DEFINES | sed 's/--dart-define //g' | tr " " "\n" | tr "\n" "\0" | xargs -0 -n1)
export APP_IDENTIFIER=${APP_IDENTIFIER}.${APP_SUFFIX:-gallery}

# Secrets appended below (PORTER_REGISTER_TOKEN, FIREBASE_*, GLITCHTIP_DSN,
# POSTHOG_*) must never hit xtrace — same set +x / conditional-restore
# pattern exportVars() uses above (DEBUG=true must never echo values).
set +x

# Porter register-gate token: channel-paired from the secrets flow
# (PORTER_REGISTER_TOKEN_{STG,PROD} schema lines in _ops/.secrets; real
# values arrive via SECRETS_B64_* / .secrets.<env>). dev+beta channels ->
# staging token, prod -> production token (docs/porter-consumption-doctrine.md
# S6/S10; pairing verified live 2026-07-20 - beta rides the PROD secrets
# bundle, which is why BOTH tokens live in one schema and the channel picks).
# Appended to the build defines only when non-empty; never committed.
if [[ "${RELEASE_CHANNEL}" == "prod" ]]; then
    PORTER_REGISTER_TOKEN=${PORTER_REGISTER_TOKEN_PROD:-}
else
    PORTER_REGISTER_TOKEN=${PORTER_REGISTER_TOKEN_STG:-}
fi
if [[ "${PORTER_REGISTER_TOKEN:-}" != "" ]]; then
    export DART_DEFINES="$DART_DEFINES --dart-define PORTER_REGISTER_TOKEN=$PORTER_REGISTER_TOKEN"
fi

# Firebase (push) + observability defines — channel/app-picked from the
# secrets flow (schema comments in _ops/.secrets). Firebase app ids are per
# app+platform+channel; GlitchTip DSNs per app; PostHog key/host shared.
# Appended as dart-defines only when present; tests strip them (run.tests.sh).
APP_SLUG_BASE=${APP_SUFFIX%%.*}
for _plat in ANDROID IOS; do
    _v="FIREBASE_APP_ID_${_plat}_${APP_SLUG_BASE}_${RELEASE_CHANNEL}"
    if [[ "${!_v:-}" != "" ]]; then
        export DART_DEFINES="$DART_DEFINES --dart-define FIREBASE_APP_ID_${_plat}=${!_v}"
    fi
done
if [[ "${FIREBASE_API_KEY:-}" != "" ]]; then
    export DART_DEFINES="$DART_DEFINES --dart-define FIREBASE_API_KEY=${FIREBASE_API_KEY} --dart-define FIREBASE_SENDER_ID=${FIREBASE_SENDER_ID:-} --dart-define FIREBASE_PROJECT_ID=${FIREBASE_PROJECT_ID:-}"
fi
_g="GLITCHTIP_DSN_${APP_SLUG_BASE}"
if [[ "${!_g:-}" != "" ]]; then
    export DART_DEFINES="$DART_DEFINES --dart-define GLITCHTIP_DSN=${!_g}"
fi
if [[ "${POSTHOG_API_KEY:-}" != "" ]]; then
    export DART_DEFINES="$DART_DEFINES --dart-define POSTHOG_API_KEY=${POSTHOG_API_KEY} --dart-define POSTHOG_HOST=${POSTHOG_HOST:-}"
fi

# Load DEBUG (restore xtrace exactly like exportVars() does — the secret
# block above ran with it deliberately suppressed).
if [ "$(echo "${DEBUG:-}" | tr '[:upper:]' '[:lower:]')" = "true" ]; then set -x; fi

# Save keystore file.
#
# PER-CHANNEL upload keys: ANDROID_KEYSTORE_B64_<channel> and its two password
# vars override the un-suffixed defaults for THIS build's RELEASE_CHANNEL. A
# package whose Play upload key is already locked (e.g. <app>NN.dev, published
# to internal testing) can therefore keep that key while .beta/prod use a
# different one. All three fall back to the single un-suffixed value, so an app
# that defines no per-channel vars behaves exactly as before.
#
# Uses RELEASE_CHANNEL_VAR (the sanitized channel defined above), never the raw
# RELEASE_CHANNEL, because the raw value can be an invalid variable name.
_ks_b64_var=ANDROID_KEYSTORE_B64_${RELEASE_CHANNEL_VAR}
_ks_sp_var=ANDROID_KEYSTORE_PASSWORD_${RELEASE_CHANNEL_VAR}
_ks_kp_var=ANDROID_KEY_PASSWORD_${RELEASE_CHANNEL_VAR}
export ANDROID_KEYSTORE_B64="${!_ks_b64_var:-${ANDROID_KEYSTORE_B64:-}}"
export ANDROID_KEYSTORE_PASSWORD="${!_ks_sp_var:-${ANDROID_KEYSTORE_PASSWORD:-}}"
export ANDROID_KEY_PASSWORD="${!_ks_kp_var:-${ANDROID_KEY_PASSWORD:-}}"
unset _ks_b64_var _ks_sp_var _ks_kp_var
if [[ "${ANDROID_KEYSTORE_B64:-}" != "" ]]; then
    echo $ANDROID_KEYSTORE_B64 | base64 -d > _ops/keystore.jks
fi
<<<<<<< Updated upstream
=======

# Fail loudly if generated files were left behind by a *different* build
# environment. Docker builds mount the repo at /src with the pub cache at
# /root/.pub-cache, so files like .flutter-plugins-dependencies end up with
# absolute paths that don't exist on the native host (and vice versa). Verbs
# that run `flutter pub get` self-heal this, but `--no-pub` verbs (run.sh) fail
# cryptically ("Plugin directory does not exist: /root/.pub-cache/..."). Call
# this before such steps to turn that into a clear, actionable message.
# `flutter run` installs the APK and the device then unpacks dex/AOT artifacts
# from it, so a device with room for the APK alone can still fail the install
# with an opaque "INSTALL_FAILED_INSUFFICIENT_STORAGE / Requested internal only,
# but not enough space" -- and flutter's retry UNINSTALLS the previous copy
# first, so the app disappears too. Assert real headroom up front instead.
# (2026-07-22: a 5.8G emulator data partition at 95% presented as "builds fine,
# doesn't run"; the AVD was configured for 16G but formatted before that.)
assert_device_space() {
    local serial="${1:-}" min_kb=1048576 free_kb
    [ -n "$serial" ] || return 0
    free_kb=$(adb -s "$serial" shell df /data 2>/dev/null | awk 'END{print $4}' | tr -d '\r')
    # Unknown//unparseable df output must never block a run -- only a number we
    # can compare is allowed to fail the build.
    case "$free_kb" in ''|*[!0-9]*) return 0 ;; esac
    if [ "$free_kb" -lt "$min_kb" ]; then
        echo "==================================================================="
        echo " ERROR: only $((free_kb / 1024))MB free on $serial's data partition."
        echo ""
        echo " A Flutter debug install needs ~1GB of headroom: the APK plus the"
        echo " dex/AOT artifacts the device unpacks from it. Installing anyway"
        echo " fails as INSTALL_FAILED_INSUFFICIENT_STORAGE and removes the"
        echo " previously installed copy."
        echo ""
        echo " Fix (emulator): wipe it, which also applies any raised"
        echo "                 disk.dataPartition.size from the AVD config:"
        echo "   emulator -avd <name> -wipe-data -no-snapshot"
        echo " Fix (device):   uninstall unused apps, or adb shell pm trim-caches 999G"
        echo "==================================================================="
        exit 1
    fi
}

assert_no_stale_env() {
    local dep_file=".flutter-plugins-dependencies"
    [ -f "$dep_file" ] || return 0
    local cur_cache="${PUB_CACHE:-$HOME/.pub-cache}"
    # Any pub-cache path in the file that isn't under this env's cache is stale.
    if grep -oE '/[^"]*\.pub-cache[^"]*' "$dep_file" 2>/dev/null | grep -qv "^${cur_cache}"; then
        echo "==================================================================="
        echo " ERROR: stale plugin paths from a different build environment."
        echo ""
        echo " $dep_file references a pub cache that does not exist here"
        echo " (this environment uses: ${cur_cache})."
        echo " You likely switched between Docker and native builds."
        echo ""
        echo " Fix:   flutter clean     (or  ./runner clean )    then re-run."
        echo "==================================================================="
        exit 1
    fi
}
>>>>>>> Stashed changes
