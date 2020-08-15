#!/bin/bash

set -Eeuo pipefail

#Supply ENV vars
for i in $(echo ${DART_DEFINES:-} | sed "s/,/ /g")
do
    k=`echo $i | cut -d= -f1`
    v=`echo $i | cut -d= -f2`
    sed -i "s/-D${k}=.*/-D${k}=${v:-}/" build.yaml
done
