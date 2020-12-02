#!/bin/sh -ex

echo
echo "# CREATE BUILD ENVIRONMENT"
echo

# Use version or try using branchname as version
if [ -z "$VERSION" ];
then
    if BRANCH_CURRENT=$(git branch --show-current) \
    && [ "$BRANCH_CURRENT" != "master" ];
    then
	VERSION="$BRANCH_CURRENT"
    else
	VERSION="latest"
    fi
fi

if [ -z "$(docker image ls -q $(uname -m)/archlinux-basedevel:$VERSION)" ];
then
	if [ -z "$(docker image ls -q $(uname -m)/archlinux:$VERSION)" ];
	then
		cd docker/archlinux-docker
		make docker-image VERSION="$VERSION"
		cd ../..
	fi
	
	cd docker/archlinux-basedevel-docker
	make docker-image VERSION="$VERSION"
	cd ../..
fi

docker/archlinux-basedevel-docker/run.sh ./build.sh
