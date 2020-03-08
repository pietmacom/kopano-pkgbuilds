#!/bin/sh -ex

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
cd makepkgs/php-xapian
makepkg --ignorearch --syncdeps --clean --cleanbuild --force --noconfirm 
cd ../..

exit

$chroot_build ./makepkgs/python-sleekxmpp
$chroot_build ./makepkgs/python2-minimock
#-$chroot_build ./makepkgs/python2-vobject
$chroot_build ./makepkgs/libvmime
$chroot_build ./makepkgs/libical2
$chroot_build ./makepkgs/python2-tlslite


# DEPENDENCIES - KOPANO-WEBAPP
$chroot_build ./makepkgs/jdk

# DEPENDENCIES - KOPANO-POSTFIXADMIN
$chroot_build ./makepkgs/perl-lockfile-simple

# MAIN PACKAGES
$chroot_build ./makepkgs/kopano-core
$chroot_build ./makepkgs/z-push
$chroot_build ./makepkgs/kopano-webapp
$chroot_build ./makepkgs/kopano-sabre
$chroot_build ./makepkgs/kopano-postfixadmin
$chroot_build ./makepkgs/kopano-service-overview

# ADDITIONAL
$chroot_build ./makepkgs/asekey
$chroot_build ./makepkgs/openct-git
$chroot_build ./makepkgs/opensc-openct


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




echo
echo "# CREATE REPOSITORY"
echo

# unique
_repo_name="${_repo_name_origin}-$(date +%Y%m%d%H%M%S)"
$repository_create ${_repo_name} ${_repo_name_origin}
$repository_upload ${_repo_name}

# mainrepo
$repository_create ${_repo_name_origin}
$repository_upload ${_repo_name_origin}

