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
            export SECRETS_B64=$SECRETS_B64_PROD
        else
            export SECRETS_B64=$SECRETS_B64_DEV
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
    source /dev/stdin <<<"$(grep -v '^#' $1 | sed -re "s/^([^=]+)=([^']+).*/\1='\2'/" | grep = | sed -re "s/^[^=]+=.*[^'=]$/\0'/" | sed -re "s/^[^=]+='$/\0'/" | sed -E -n 's/[^#]+/export &/ p')"
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
        echo "TARGET_USR=u$((git config user.name || :) | md5sum | cut -f1 -d' ' | fold -w8 | head -n1)" >> $ENV_FILE2
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
#Remove empty vars
sed -i -re '/^[^=]+=$/d' $SECRETS_FILE
exportVars $SECRETS_FILE

######## Updated Env Vars ########
# Fill secrets
( printf "cat <<EOF\n" ; cat $ENV_FILE2 ; printf "\nEOF" ) | sh > ${ENV_FILE2}.tmp
mv ${ENV_FILE2}.tmp $ENV_FILE2

# Load modified env
exportVars $ENV_FILE2


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

DART_DEFINES=DART_DEFINES_B64_${RELEASE_CHANNEL}
export DART_DEFINES=`echo ${!DART_DEFINES} | base64 -d`
[[ $DART_DEFINES != "" ]] || (echo "Missing DART_DEFINES"; exit 1)
export $(echo $DART_DEFINES | sed 's/--dart-define //g' | tr " " "\n" | tr "\n" "\0" | xargs -0 -n1)
export APP_IDENTIFIER=${APP_IDENTIFIER}.${APP_SUFFIX:-gallery}

# Save keystore file
if [[ "${ANDROID_KEYSTORE_B64:-}" != "" ]]; then
    echo $ANDROID_KEYSTORE_B64 | base64 -d > _ops/keystore.jks
fi
