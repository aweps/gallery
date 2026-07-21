#!/bin/bash

set -Eeuo pipefail
if [ "$(echo "${DEBUG:-}" | tr '[:upper:]' '[:lower:]')" = "true" ]; then set -x; fi

# Load ENV
source _ops/utils/env.sh

# Force do not use docker if MacOS in CI
if [[ "$OSTYPE" == "darwin"* ]] && [[ "${RUNNER_WORKSPACE:-}" != "" ]]; then
	export USE_DOCKER=false
fi
# Check if docker is running
if [ $USE_DOCKER == true ]; then
	# check if docker installed
	if ! type docker > /dev/null; then
		echo "Docker is not installed but USE_DOCKER is set to true"
		exit 1
	fi
	docker ps > /dev/null
	if [ $? -ne 0 ]; then
		echo "Docker is not running but USE_DOCKER is set to true"
		exit 1
	fi
fi

APP_SLUG=gallery
mkdir -p $PUB_CACHE $GRADLE_CACHE

# To get host source dir in dind scenario
if type docker && [ $USE_DOCKER == true ]; then

	# Shared vars
	SRC_DIR=`pwd`
	vars='-e DEBUG -e NSDEBUG -e WAIT_ON_ERROR -e SECRETS_B64 -e GIT_BRANCH_REF -e GIT_USER'

	if [[ "${RUNNER_WORKSPACE:-}" != "" ]]; then
		# Host-side path for the daemon-level -v mount. The template's
		# ${RUNNER_WORKSPACE}/${APP_SLUG} equals the checkout only when the
		# repo is named after the app (standalone); in a monorepo the
		# checkout is <workspace>/<repo> with the app one level deeper. Map
		# the container cwd (/github/workspace[/<app>]) back to the host
		# path generically (2026-07-19 first live monorepo tag build).
		REL_DIR=${PWD#"${GITHUB_WORKSPACE:-$PWD}"}
		SRC_DIR="${RUNNER_WORKSPACE}/$(basename "${GITHUB_REPOSITORY:-$APP_SLUG}")${REL_DIR}"
		volumes="-v $GRADLE_CACHE:/root/.gradle -v $PUB_CACHE:/root/.pub-cache -v $SRC_DIR:/src -w /src"

	elif [[ "${DRONE_COMMIT_REF:-}" != "" ]]; then
		SRC_DIR=$(docker inspect --format="{{json .Mounts}}" `hostname` | jq -r '.[] | select(.Destination=="/workspace") | .Source')
		SRC_DIR=${SRC_DIR}/src
		volumes="-v $SRC_DIR:/src:Z -w /src"

	elif [[ "${CIRCLECI:-}" == "true" ]]; then
		if grep -q docker /proc/1/cgroup; then
			echo "DinD scenario not supported in CircleCI"
			exit 1
		else
			SRC_DIR=`pwd`
			volumes="-v $GRADLE_CACHE:/root/.gradle -v $PUB_CACHE:/root/.pub-cache -v $SRC_DIR:/src -w /src"
		fi
	else
		volumes="-v $GRADLE_CACHE:/root/.gradle -v $PUB_CACHE:/root/.pub-cache -v $SRC_DIR:/src -w /src"
	fi
fi

# Build tools
if type docker && [ $USE_DOCKER == true ]; then

	PLATFORM=linux/$(docker version --format '{{.Server.Arch}}')

	# Build the app-namespaced tools image — a shared 'flutter_tools' tag
	# let a sibling app's build satisfy exit-0-no-effect guards
	# (2026-07-16 hunt H6, operator-approved local fix; template flow-back pending)
	pushd _ops
	BUILDX_CMD="build"
	if [[ "${RUNNER_WORKSPACE:-}" != "" ]]; then
		docker buildx inspect builder-main || docker buildx create --name builder-main --use --driver=docker-container
		BUILDX_CMD="buildx build --load --cache-to type=gha,mode=max --cache-from type=gha --progress=plain"
	fi
	docker $BUILDX_CMD --platform "$PLATFORM" --build-arg BUILDPLATFORM="$PLATFORM" -t "${APP_SLUG}_flutter_tools" -f Dockerfile.tools .
	popd
fi

#Build App with tools
if [[ "${1:-}" == "test" ]]; then
	if type docker && [ $USE_DOCKER == true ]; then
		docker run --platform $PLATFORM $vars $volumes --rm "${APP_SLUG}_flutter_tools" bash _ops/run.tests.sh
	else
		bash _ops/run.tests.sh
	fi

elif [[ "${1:-}" == "web-build" ]]; then
	if type docker && [ $USE_DOCKER == true ]; then
		docker run --platform $PLATFORM $vars $volumes --rm "${APP_SLUG}_flutter_tools" bash _ops/build.sh web ${APP_ROOT:-}/ ${2:-}

		#Build web
		docker build --rm=true --pull=true -t ${APP_SLUG}${3:-} -f _ops/Dockerfile.web .
	else
		echo "Missing Docker or Docker use disabled via USE_DOCKER in env file"
		exit 1
	fi

elif [[ "${1:-}" == "web-run" ]]; then
	if type docker && [ $USE_DOCKER == true ]; then
		docker run --platform $PLATFORM $vars $volumes --rm "${APP_SLUG}_flutter_tools" bash _ops/build.sh web ${APP_ROOT:-}/ ${2:-}

		#Run web
		docker build --rm=true --pull=true -t ${APP_SLUG} -f _ops/Dockerfile.web .
		docker stop ${APP_SLUG} || :
<<<<<<< Updated upstream
<<<<<<< Updated upstream
<<<<<<< Updated upstream
<<<<<<< Updated upstream
<<<<<<< Updated upstream
<<<<<<< Updated upstream
		docker run --platform $PLATFORM --rm --name ${APP_SLUG} -p 8083:8080 -d ${APP_SLUG}
		echo "Done! - Check in browser - http://<MACHINE_IP>:8083"
=======
		docker run --platform $PLATFORM --rm --name ${APP_SLUG} -p ${WEB_PORT:-8080}:8080 -d ${APP_SLUG}
		echo "Done! - Check in browser - http://<MACHINE_IP>:${WEB_PORT:-8080}"
>>>>>>> Stashed changes
=======
		docker run --platform $PLATFORM --rm --name ${APP_SLUG} -p ${WEB_PORT:-8080}:8080 -d ${APP_SLUG}
		echo "Done! - Check in browser - http://<MACHINE_IP>:${WEB_PORT:-8080}"
>>>>>>> Stashed changes
=======
		docker run --platform $PLATFORM --rm --name ${APP_SLUG} -p ${WEB_PORT:-8080}:8080 -d ${APP_SLUG}
		echo "Done! - Check in browser - http://<MACHINE_IP>:${WEB_PORT:-8080}"
>>>>>>> Stashed changes
=======
		docker run --platform $PLATFORM --rm --name ${APP_SLUG} -p ${WEB_PORT:-8080}:8080 -d ${APP_SLUG}
		echo "Done! - Check in browser - http://<MACHINE_IP>:${WEB_PORT:-8080}"
>>>>>>> Stashed changes
=======
		docker run --platform $PLATFORM --rm --name ${APP_SLUG} -p ${WEB_PORT:-8080}:8080 -d ${APP_SLUG}
		echo "Done! - Check in browser - http://<MACHINE_IP>:${WEB_PORT:-8080}"
>>>>>>> Stashed changes
=======
		docker run --platform $PLATFORM --rm --name ${APP_SLUG} -p ${WEB_PORT:-8080}:8080 -d ${APP_SLUG}
		echo "Done! - Check in browser - http://<MACHINE_IP>:${WEB_PORT:-8080}"
>>>>>>> Stashed changes
	else
		echo "Missing Docker or Docker use disabled via USE_DOCKER in env file"
		exit 1
	fi

elif [[ "${1:-}" == "android-build" ]]; then
	if type docker && [ $USE_DOCKER == true ]; then
<<<<<<< Updated upstream
		#TODO: This currently fails on Apple Silicon
		docker run --platform $PLATFORM $vars $volumes --rm flutter_tools bash _ops/build.sh android ${2:-}
=======
		# Apple Silicon: works via Rosetta — Dockerfile.tools installs amd64
		# multiarch libs so the x86_64 Android SDK/NDK tools can execute.
		docker run --platform $PLATFORM $vars $volumes --rm "${APP_SLUG}_flutter_tools" bash _ops/build.sh android ${2:-}
<<<<<<< Updated upstream
<<<<<<< Updated upstream
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
	else
		bash _ops/build.sh android ${2:-}
	fi

elif [[ "${1:-}" == "android-run" ]]; then
	bash _ops/run.sh android ${2:-}

elif [[ "${1:-}" == "ios-build" ]]; then
	bash _ops/build.sh ios ${2:-}

elif [[ "${1:-}" == "ios-run" ]]; then
	bash _ops/run.sh ios ${2:-}

elif [[ "${1:-}" == "clean" ]]; then
	if type docker && [ $USE_DOCKER == true ]; then
		docker run --platform $PLATFORM $vars $volumes --rm "${APP_SLUG}_flutter_tools" bash _ops/clean.sh
	else
		bash _ops/clean.sh
	fi

else
	echo "---"
	echo "Usage:- bash runner (web-build|web-run|android-build|android-run|ios-build|ios-run|test|clean)"
fi
