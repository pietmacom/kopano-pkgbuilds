#!/bin/sh -ex

BRANCH_CURRENT=$(git branch --show-current)
if [ "$BRANCH_CURRENT" != "master" ];
then
 export VERSION="$BRANCH_CURRENT"
fi

./build-docker.sh
