#!/bin/sh -ex

build() {
	P=$(pwd)
	cd $1
	
	# Install compiled make dependencies
	if [ -e "makedepends" ];
	then
		sudo pacman --noconfirm -U makedepends/*.pkg.*
	fi
	
	makepkg --ignorearch --syncdeps --clean --cleanbuild --force --noconfirm --skipinteg
	
	# in case there's nothing to copy, don't fail
	cp -n *.pkg.* /build-target || true
	
	# Install packages separately.
	# When building multiple packages with different version numbers and in one PKGBUILD,
	# on the end makepkg tries to install all packages with the last version number
	sudo pacman --noconfirm -U *.pkg.*
	
	cd $P
}

out_h1() {
	echo
	echo "# $1"
	echo
}

out_h1 "PREPARE"
	# Work all 'PKGBUILD.template'-Files
	find makepkgs -name "PKGBUILD.template" -print0 | while read -d $'\0' pkgBuildTemplate
	do
	     makepkg-template --template-dir makepkgs-templates --input $pkgBuildTemplate --output $(dirname $pkgBuildTemplate)/PKGBUILD
	done

out_h1 "CHECKOUT"
	git clone https://aur.archlinux.org/libiconv.git makepkgs/libiconv
	git clone https://aur.archlinux.org/apache-ant-contrib.git makepkgs/ant-contrib
	
	# ARCHIVE
	# php
	# gcc
	# jdk
	# pip2pkgbuild
#	git clone https://aur.archlinux.org/python-sleekxmpp.git makepkgs/python-sleekxmpp
	#-git clone https://aur.archlinux.org/python2-vobject.git
	#git clone https://aur.archlinux.org/php-xapian.git
	#git clone https://aur.archlinux.org/python2-minimock.git
	#git clone https://aur.archlinux.org/perl-lockfile-simple.git

	# MAIN PACKAGES
	#-git clone ssh://aur@aur.archlinux.org/z-push.git ; cd z-push ; git checkout -b "v2.3.3" 56db7b35459438dc6228b307f0f8855ac7fd9138 ; cd ..

out_h1 "BUILD"
	# CORE
	build makepkgs/libiconv
	build makepkgs/kopano-libvmime
	build makepkgs/kopano-core

	# WEBAPP
	# OPTIONAL build makepkgs/jdk
	build makepkgs/ant-contrib
	build makepkgs/kopano-webapp

	# DEPENDENCIES - KOPANO-CORE
#	build makepkgs/php-xapian
#	build makepkgs/python-sleekxmpp
#	build makepkgs/python2-minimock
#	#-$chroot_build ./makepkgs/python2-vobject

#	build makepkgs/libical2
#	build makepkgs/python2-tlslite

	# DEPENDENCIES - KOPANO-POSTFIXADMIN
#	build makepkgs/perl-lockfile-simple
	# MAIN PACKAGES

#	build makepkgs/z-push
#	build makepkgs/kopano-webapp

#	build makepkgs/kopano-sabre
#	build makepkgs/kopano-postfixadmin
#	build makepkgs/kopano-service-overview

out_h1 "FINISHED"
