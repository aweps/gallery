#!/bin/bash

set -Eeuo pipefail
if [ "$(echo "${DEBUG:-}" | tr '[:upper:]' '[:lower:]')" = "true" ]; then set -x; fi

# Determine CI system
# Github Action
if [[ "${GITHUB_REF:-}" != "" ]]; then
	# CI specifc vars
	GIT_CISYSTEM=actions
	GIT_COMMIT=$GITHUB_SHA
	GIT_BRANCH_REF=$GITHUB_REF

	GIT_REF=$(echo $GIT_BRANCH_REF | sed -r 's/^refs\/[^\/]+\///g')
	if [[ "$GIT_BRANCH_REF" == "refs/heads"* ]]; then
		GIT_BRANCH=$GIT_REF
	elif [[ "$GIT_BRANCH_REF" == "refs/tags/"* ]]; then
		GIT_TAG=$GIT_REF
	elif [[ "$GIT_BRANCH_REF" == "refs/pull/"* ]]; then
		GIT_PR=$(echo $GIT_REF | sed -re 's/([0-9]+).*/\1/')
		GIT_COMMIT=$GITHUB_PR_SHA
	else
		echo "Unknown github ref"
		exit 1
	fi

# Drone.IO
elif [[ "${DRONE_COMMIT_REF:-}" != "" ]]; then
	# CI specifc vars
	GIT_CISYSTEM=drone
	GIT_COMMIT=${DRONE_COMMIT_SHA:-HEAD}
	GIT_BRANCH_REF=$DRONE_COMMIT_REF

	GIT_REF=$(echo $GIT_BRANCH_REF | sed -r 's/^refs\/[^\/]+\///g')
	if [[ "$GIT_BRANCH_REF" == "refs/heads"* ]]; then
		GIT_BRANCH=$DRONE_BRANCH
	elif [[ "$GIT_BRANCH_REF" == "refs/tags/"* ]]; then
		GIT_TAG=$DRONE_TAG
	elif [[ "$GIT_BRANCH_REF" == "refs/pull/"* ]]; then
		GIT_PR=$DRONE_PULL_REQUEST
	else
		echo "Unknown drone ref"
		exit 1
	fi

# CircleCI
elif [[ "${CIRCLECI:-}" == "true" ]]; then
	# CI specifc vars
	GIT_CISYSTEM=circle
	GIT_COMMIT=$CIRCLE_SHA1

	if [[ "${CIRCLE_BRANCH:-}" != "" ]]; then
		GIT_BRANCH_REF="refs/heads/$CIRCLE_BRANCH"
		GIT_BRANCH=$CIRCLE_BRANCH
	elif [[ "${CIRCLE_TAG:-}" != "" ]]; then
		GIT_BRANCH_REF="refs/tags/$CIRCLE_TAG"
		GIT_TAG=$CIRCLE_TAG
	elif [[ "${CIRCLE_PR_NUMBER:-}" != "" ]]; then
		GIT_BRANCH_REF="refs/pull/$CIRCLE_PR_NUMBER/merge"
		GIT_PR=$CIRCLE_PR_NUMBER
	else
		echo "Unsupported in circleci"
		exit 1
	fi
	GIT_REF=$(echo $GIT_BRANCH_REF | sed -r 's/^refs\/[^\/]+\///g')

else
	echo "Unknown CI system"
	exit 1
fi

# Load ENV
source _ops/utils/env.sh

# Common functions
function add_tag()
{
    docker tag ${APP_REGISTRY_REPO}${SUFFIX}:${UNIQ_TAG} ${APP_REGISTRY_REPO}${SUFFIX}:$TAG
    docker push -q ${APP_REGISTRY_REPO}${SUFFIX}:$TAG
}
function tag_push()
{
	SUFFIX=${1:-}

	TAG=${GIT_COMMIT} add_tag
	TAG=$(echo $GIT_COMMIT | cut -c1-7) add_tag
	TAG=${GIT_CISYSTEM} add_tag
	TAG=${GIT_CISYSTEM}-$(date +%y%m%d_%H%M%S) add_tag

	if [[ "${GIT_TAG:-}" != "" ]]; then
		TAG=$(echo ${GIT_TAG} | grep -o '[0-9]\+\.\?[0-9]*\.\?[0-9]*' | head -1) && add_tag
		TAG=${GIT_CISYSTEM}-${TAG} add_tag
		TAG=$(echo ${TAG} | cut -f1-2 -d.) && add_tag
		TAG=$(echo ${TAG} | cut -f1 -d.) && add_tag

	elif [[ "${GIT_PR:-}" != "" ]]; then
		TAG=pr-${GIT_PR} && add_tag
		TAG=${GIT_CISYSTEM}-${TAG} add_tag

	else
		TAG=$(echo ${GIT_BRANCH} | sed 's/[^[:alnum:]]/_/g') && add_tag
		TAG=${GIT_CISYSTEM}-${TAG} add_tag
	fi

	docker rmi ${APP_REGISTRY_REPO}${SUFFIX}:${UNIQ_TAG}
}

# Common vars
APP_REGISTRY_REPO=${APP_REGISTRY_ENDPOINT}/${APP_IMAGE}
UNIQ_TAG=$(echo $GIT_REF | sed 's/[^[:alnum:]]/_/g')-${GIT_COMMIT}
CACHE_LABEL=`date +"%Y-%m-%U"`W

# Login to push
docker login ${APP_REGISTRY_ENDPOINT} --username ${APP_REGISTRY_USERNAME} --password ${APP_REGISTRY_PASSWORD} 2>/dev/null


if [[ "${1:-}" == "web" ]]; then

    # Run tests conditionally based on branch or tag type or hotfix+test branch for different dev scenarios
    if [[ "$GIT_BRANCH_REF" == "refs/tags/"* ]]; then
	    /bin/bash runner test
    fi

    # WEB: Builds & creates the default web contaier with Caddy
    /bin/bash runner web-build release -${RELEASE_CHANNEL}
    docker tag gallery-${RELEASE_CHANNEL} ${APP_REGISTRY_REPO}-${RELEASE_CHANNEL}:${UNIQ_TAG}
    tag_push -${RELEASE_CHANNEL}

elif [[ "${1:-}" == "android" ]]; then

    # ANDROID: Builds & generates apk for android
    /bin/bash runner android-build release
    docker build --rm=true --pull=true -t ${APP_REGISTRY_REPO}-${RELEASE_CHANNEL}-android:${UNIQ_TAG} -f _ops/Dockerfile.android .
    tag_push -${RELEASE_CHANNEL}-android

elif [[ "${1:-}" == "ios" ]]; then

    # IOS: Create new container for ios package
    docker build --rm=true --pull=true -t ${APP_REGISTRY_REPO}-${RELEASE_CHANNEL}-ios:${UNIQ_TAG} -f _ops/Dockerfile.ios .
    tag_push -${RELEASE_CHANNEL}-ios

else
    echo "Usage: bash _ops/ci.build.sh web|ios|android"
fi
