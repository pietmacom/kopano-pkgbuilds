#!/bin/sh -ex

echo
echo "# CREATE BUILD ENVIRONMENT"
echo

if [ -z "$VERSION" ];
then
	VERSION="latest"
fi

if [ -z "$(docker image ls -q $(uname -m)/archlinux-basedevel:$VERSION)" ];
then
	cd docker/archlinux-docker
	make docker-image VERSION="$VERSION"
	cd ../..

	cd docker/archlinux-basedevel-docker
	make docker-image VERSION="$VERSION"
	cd ../..
fi

docker/archlinux-basedevel-docker/run.sh ./build.sh
