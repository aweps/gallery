#!/bin/bash

set -Eeuo pipefail

mkdir -p ~/.pub-cache

# Build tools
if type docker; then
	(cd _ops && docker build --rm=true --pull=true -t flutter_tools -f Dockerfile.tools .)
fi

#Build App with tools
if [[ "${1:-}" == "test" ]]; then
	docker run -e DART_DEFINES -v ~/.pub-cache:/pub-cache -e PUB_CACHE=/pub-cache -v `pwd`:/src -w /src --rm flutter_tools bash _ops/run.tests.sh

elif [[ "${1:-}" == "web" ]]; then
	docker run -e DART_DEFINES -v ~/.pub-cache:/pub-cache -e PUB_CACHE=/pub-cache -v `pwd`:/src -w /src --rm flutter_tools bash _ops/build.web.sh

	#Run web
	docker build --rm=true --pull=true -t gallery -f _ops/Dockerfile.web .
	docker stop gallery || :
	docker run --rm --name gallery -p 8083:8080 -d gallery
	echo "Done! - Check in browser - http://<MACHINE_IP>:8083"

elif [[ "${1:-}" == "android" ]]; then
	if type docker; then
		docker run -e DART_DEFINES -v ~/.pub-cache:/pub-cache -e PUB_CACHE=/pub-cache -v `pwd`:/src -w /src --rm flutter_tools bash _ops/build.android.sh
	else
		PUB_CACHE=~/.pub-cache bash _ops/build.android.mac.sh
	fi

elif [[ "${1:-}" == "ios" ]]; then
	bash _ops/build.ios.sh

elif [[ "${1:-}" == "clean" ]]; then
	if type docker; then
		docker run -e DART_DEFINES -v ~/.pub-cache:/pub-cache -e PUB_CACHE=/pub-cache -v `pwd`:/src -w /src --rm flutter_tools bash _ops/clean.sh
	else
		PUB_CACHE=~/.pub-cache bash _ops/clean.sh
	fi

else
	echo "---"
	echo "Usage:- bash build.sh (web|android|ios|test|clean)"
fi
