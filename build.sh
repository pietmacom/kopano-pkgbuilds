#!/bin/sh -ex

build() {
	P=$(pwd)
	cd $1
	
	# Install compiled make dependencies
	if [ -e "makedepends" ];
	then
		sudo pacman --noconfirm -U makedepends/*.pkg.tar.xz
	fi
	
	makepkg --ignorearch --syncdeps --clean --cleanbuild --force --noconfirm
	
	# in case there's nothing to copy, don't fail
	cp -n *.pkg.tar.xz /build-target || true
	
	# Install packages separately.
	# When building multiple packages with different version numbers and in one PKGBUILD,
	# on the end makepkg tries to install all packages with the last version number
	sudo pacman --noconfirm -U *.pkg.tar.xz
	
	cd $P
}


echo
echo "# CHECKOUT"
echo

# DEPENDENCIES
cd makepkgs
# php
# gcc
# jdk
# pip2pkgbuild
git clone https://aur.archlinux.org/python-sleekxmpp.git
#-git clone https://aur.archlinux.org/python2-vobject.git
#git clone https://aur.archlinux.org/php-xapian.git
git clone https://aur.archlinux.org/python2-minimock.git
#git clone https://aur.archlinux.org/perl-lockfile-simple.git

# MAIN PACKAGES
#-git clone ssh://aur@aur.archlinux.org/zarafa-libvmime.git
#-git clone ssh://aur@aur.archlinux.org/zarafa-libical.git
#-git clone ssh://aur@aur.archlinux.org/zarafa-server.git
#-git clone ssh://aur@aur.archlinux.org/zarafa-spamhandler.git
#-git clone ssh://aur@aur.archlinux.org/zarafa-postfixadmin.git
#-git clone ssh://aur@aur.archlinux.org/zarafa-webapp.git
#-git clone ssh://aur@aur.archlinux.org/zarafa-webapp-delayeddelivery.git
#-git clone ssh://aur@aur.archlinux.org/zarafa-webapp-desktopnotifications.git
#-git clone ssh://aur@aur.archlinux.org/zarafa-webapp-filepreviewer.git
#-git clone ssh://aur@aur.archlinux.org/zarafa-webapp-passwd.git
#-git clone ssh://aur@aur.archlinux.org/zarafa-webapp-smime.git
#-git clone ssh://aur@aur.archlinux.org/zarafa-webapp-spellchecker.git
#-git clone ssh://aur@aur.archlinux.org/sabre-zarafa.git
#-git clone ssh://aur@aur.archlinux.org/z-push.git ; cd z-push ; git checkout -b "v2.3.3" 56db7b35459438dc6228b307f0f8855ac7fd9138 ; cd ..
#-git clone ssh://aur@aur.archlinux.org/zarafa-webapp-mdm.git
#-git clone ssh://aur@aur.archlinux.org/zarafa-service-overview
cd ..


echo
echo "# BUILD"
echo


# DEPENDENCIES - KOPANO-CORE
build makepkgs/jdk
build makepkgs/php-xapian
build makepkgs/python-sleekxmpp
build makepkgs/python2-minimock
#-$chroot_build ./makepkgs/python2-vobject
build makepkgs/libvmime
build makepkgs/libical2
build makepkgs/python2-tlslite


# DEPENDENCIES -
# KOPANO-WEBAPP
# Mind of this! ####### #### $chroot_build ./makepkgs/jdk

# DEPENDENCIES - KOPANO-POSTFIXADMIN
build makepkgs/perl-lockfile-simple
# MAIN PACKAGES
build makepkgs/kopano-core
build makepkgs/z-push
build makepkgs/kopano-webapp

sudo pacman --noconfirm -R composer
build makepkgs/kopano-sabre
build makepkgs/kopano-postfixadmin
build makepkgs/kopano-service-overview

# ADDITIONAL
#build makepkgs/asekey
#build makepkgs/openct-git
#build makepkgs/opensc-openct


#-$chroot_build ./makepkgs/zarafa-libvmime
#-$chroot_build ./makepkgs/zarafa-libical
#-$chroot_build ./makepkgs/zarafa-server
#-$chroot_build ./makepkgs/zarafa-spamhandler
#-$chroot_build ./makepkgs/perl-lockfile-simple
#-$chroot_build ./makepkgs/zarafa-postfixadmin
#-$chroot_build ./makepkgs/zarafa-webapp 
#-$chroot_build ./makepkgs/zarafa-webapp-delayeddelivery
#-$chroot_build ./makepkgs/zarafa-webapp-desktopnotifications
#-$chroot_build ./makepkgs/zarafa-webapp-filepreviewer
#-$chroot_build ./makepkgs/zarafa-webapp-passwd
#-$chroot_build ./makepkgs/zarafa-webapp-smime
#-$chroot_build ./makepkgs/zarafa-webapp-spellchecker
#-$chroot_build ./makepkgs/sabre-zarafa
#-$chroot_build ./makepkgs/z-push
#-$chroot_build ./makepkgs/zarafa-webapp-mdm
#-$chroot_build ./makepkgs/zarafa-service-overview