#!/bin/sh -ex

echo
echo "# CREATE BUILD ENVIRONMENT"
echo

if [ -z "$VERSION" ];
then
    echo "# RESOLVE VERSION"
    if BRANCH_CURRENT=$(git branch --show-current) \
    && [ "$BRANCH_CURRENT" != "master" ];
    then
	VERSION="$BRANCH_CURRENT"
    else
	VERSION="latest"
    fi
fi


if [ ! -z "$DOCKER_REMOTE_REGISTRY" ];
then
    echo "# PULL DOCKER IMAGE"
    remoteImage="$DOCKER_REMOTE_REGISTRY/$(uname -m)/archlinux-basedevel:$VERSION"
    localImage="$(uname -m)/archlinux-basedevel:$VERSION"

    if docker pull $remoteImage;
    then
	docker tag $remoteImage $localImage
    fi
fi


if [ -z "$(docker image ls -q $(uname -m)/archlinux-basedevel:$VERSION)" ];
then
    echo "# BUILD DOCKER IMAGE"
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

VERSION=$VERSION docker/archlinux-basedevel-docker/run.sh ./build.sh $@
