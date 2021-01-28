#!/bin/bash -e

_checkupdates="n"
_release="n"
_forcebuild="n"
_repo_name_origin="pietma-kopano"
_repo_url="https://repository.pietma.com/nexus/content/repositories/archlinux"
_prefix="sudo /root/git/utils/build-utils"

chroot_create="${_prefix}/chroot_create.sh -d \"${DISTCC_HOSTS}\" -t \"${DISTCC_THREADS}\""
chroot_build="${_prefix}/chroot_build.sh -c \"${REPOSITORY_USERNAME}:${REPOSITORY_PASSWORD}\" -u \"${_repo_url}\" -n \"${_repo_name_origin}\" -m "
chroot_install="${_prefix}/chroot_install.sh"
chroot_release="${_prefix}/chroot_release.sh"
repository_create="${_prefix}/repository_create.sh ${REPOSITORY_USERNAME}:${REPOSITORY_PASSWORD} ${_repo_url}"
repository_upload="${_prefix}/repository_upload.sh ${REPOSITORY_USERNAME}:${REPOSITORY_PASSWORD} ${_repo_url}"
repository_check_updates="${_prefix}/repository_check_updates.sh -c \"${REPOSITORY_USERNAME}:${REPOSITORY_PASSWORD}\" -u \"${_repo_url}\" -n \"${_repo_name_origin}\""


_arch="$(uname -m)"
cp -Rn arch/${_arch}/* .

if [[ "${_checkupdates}" == "y" ]];
then
    echo
    echo "# CHECK FOR UPDATES"
    echo

    _updates="$($repository_check_updates | tee >(cat - >&2))"
    if [[ -z "$(echo \"${_updates}\" | grep 'Update found')" ]];
    then
	echo
        echo "No updates found. Quitting build."
	echo
        exit
    fi
fi



echo
echo "# CREATE CHROOT"
echo

$chroot_create
#$chroot_install http://tardis.tiny-vps.com/aarm/repos/2018/05/15/armv7h/core/icu-61.1-1-armv7h.pkg.tar.xz





if [ "$_arch" != "i686" ] && [ "$_arch" != "x86_64" ] && [ "$_arch" != "aarch64" ] && [ "${_arch%${_arch#arm*}*}" != "arm" ];
then
 echo
 echo "# BUILD BUILD-DEPENDENCIES"
 echo

 $chroot_build ./makepkgs/jdk
 $chroot_build ./makepkgs/gcc
 $chroot_build ./makepkgs/pip2pkgbuild

 rm paccache/*
 # => reset chroot?
 cp dependencies/*-${_arch}.pkg.tar.xz paccache || true
 cp dependencies/*-any.pkg.tar.xz paccache || true
fi



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


if [[ "${_release}" == "y" ]];
then
    echo
    echo "# RELEASE"
    echo

    # MAKEDEPENDS    
    # $chroot_release ./makepkgs/gcc
    # $chroot_release ./makepkgs/jdk

    # ARCH: SPECIFIC
    # $chroot_release ./makepkgs/php
    $chroot_release ./makepkgs/zarafa-libvmime
    $chroot_release ./makepkgs/zarafa-libical
    $chroot_release ./makepkgs/zarafa-server

    # ARCH: ANY
    # $chroot_release ./makepkgs/zarafa-webapp
    # $chroot_release ./makepkgs/zarafa-webapp-delayeddelivery
    # $chroot_release ./makepkgs/zarafa-webapp-desktopnotifications
    # $chroot_release ./makepkgs/zarafa-webapp-filepreviewer
    # $chroot_release ./makepkgs/zarafa-webapp-passwd
    # $chroot_release ./makepkgs/zarafa-webapp-smime
    # $chroot_release ./makepkgs/zarafa-webapp-spellchecker
    # $chroot_release ./makepkgs/sabre-zarafa
    # $chroot_release ./makepkgs/z-push
    # $chroot_release ./makepkgs/zarafa-webapp-mdm
    # $chroot_release ./makepkgs/zarafa-service-overview
fi


echo
echo "# UPDATE SOURCE TO MIRROR"
echo

find makepkgs -name "PKGBUILD" -exec sed -i "s|http://download.oracle.com/|http://${REPOSITORY_USERNAME}:${REPOSITORY_PASSWORD}@repository.pietma.com/nexus/content/repositories/oracle/|g" {} \;
find makepkgs -name "PKGBUILD" -exec sed -i "s|http://download.zarafa.com/|https://${REPOSITORY_USERNAME}:${REPOSITORY_PASSWORD}@repository.pietma.com/nexus/content/repositories/zarafa-community/|g" {} \;
find makepkgs -name "PKGBUILD" -exec sed -i "s|https://download.zarafa.com/|https://${REPOSITORY_USERNAME}:${REPOSITORY_PASSWORD}@repository.pietma.com/nexus/content/repositories/zarafa-community/|g" {} \;



echo
echo "# BUILD"
echo


if [[ "${_forcebuild}" == "y" ]];
then
    chroot_build="${_prefix}/chroot_build.sh -m " # force build
fi


# DEPENDENCIES - KOPANO-CORE
#-$chroot_build ./makepkgs/php
$chroot_build ./makepkgs/php-xapian
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

