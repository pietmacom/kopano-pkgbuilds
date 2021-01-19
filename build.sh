#!/bin/sh -ex

_outH1() {
    echo
    echo "# $1"
    echo
}

_pkgBuild() {
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

_pkgSync() {
    _pwd=$(pwd)

    _pkgBaseName="$(basename $1)"
    _syncPath="sync/${_pkgBaseName}"

    if ! git clone http://aur.archlinux.org/${_pkgBaseName}.git ${_syncPath} ;
    then
	echo "Clone failed ${_pkgBaseName}"
	return $?
    fi

    find  ${_syncPath}/ -maxdepth 1 -mindepth 1 -not -name ".git*" -exec rm -rf {} \;
    cp -RT ${1} ${_syncPath}

    cd ${_syncPath}
    makepkg --printsrcinfo > .SRCINFO

    cd ${_pwd}
}

_pkgPush() {
    makepkg --printsrcinfo > .SRCINFO
#    if ! git clone ssh://aur@aur.archlinux.org/${_pkgBaseName}.git ${_syncPath} ;
}

_build() {
    _outH1 "CHECKOUT"
	    git clone https://aur.archlinux.org/libiconv.git makepkgs/libiconv
	    git clone https://aur.archlinux.org/libvmime-git.git makepkgs/libvmime

	    # ARCHIVE
	    # php
	    # gcc
	    # jdk
	    # pip2pkgbuild
#	    git clone https://aur.archlinux.org/python-sleekxmpp.git makepkgs/python-sleekxmpp
	    #-git clone https://aur.archlinux.org/python2-vobject.git
	    #git clone https://aur.archlinux.org/php-xapian.git
	    #git clone https://aur.archlinux.org/python2-minimock.git
	    #git clone https://aur.archlinux.org/perl-lockfile-simple.git

	    # MAIN PACKAGES
	    #-git clone ssh://aur@aur.archlinux.org/z-push.git ; cd z-push ; git checkout -b "v2.3.3" 56db7b35459438dc6228b307f0f8855ac7fd9138 ; cd ..

    _outH1 "BUILD"
	    # CORE
	    _pkgBuild makepkgs/libiconv
	    _pkgBuild makepkgs/kopano-libvmime
	    _pkgBuild makepkgs/kopano-core

	    # WEBAPP
	    # OPTIONAL _pkgBuild makepkgs/jdk
	    _pkgBuild makepkgs/kopano-webapp
#	    _pkgBuild makepkgs/kopano-webapp-gmaps
#	    _pkgBuild makepkgs/kopano-webapp-contactfax
#	    _pkgBuild makepkgs/kopano-webapp-pimfolder
	    _pkgBuild makepkgs/kopano-webapp-nginx
	    _pkgBuild makepkgs/kopano-webapp-files
	    _pkgBuild makepkgs/kopano-webapp-files-owncloud-backend
	    _pkgBuild makepkgs/kopano-webapp-files-smb-backend
	    _pkgBuild makepkgs/kopano-webapp-filepreview
	    _pkgBuild makepkgs/kopano-webapp-desktopnotifications
#	    _pkgBuild makepkgs/kopano-webapp-htmleditor-jodit
	    _pkgBuild makepkgs/kopano-webapp-htmleditor-minimaltiny
	    _pkgBuild makepkgs/kopano-webapp-intranet
	    _pkgBuild makepkgs/kopano-webapp-smime
	    _pkgBuild makepkgs/kopano-webapp-spellchecker
	    _pkgBuild makepkgs/kopano-webapp-spellchecker-languagepack-de-at
	    _pkgBuild makepkgs/kopano-webapp-spellchecker-languagepack-de-ch
	    _pkgBuild makepkgs/kopano-webapp-spellchecker-languagepack-de-de
	    _pkgBuild makepkgs/kopano-webapp-spellchecker-languagepack-en-gb
	    _pkgBuild makepkgs/kopano-webapp-spellchecker-languagepack-en-us
	    _pkgBuild makepkgs/kopano-webapp-spellchecker-languagepack-es-es
	    _pkgBuild makepkgs/kopano-webapp-spellchecker-languagepack-fr-fr
	    _pkgBuild makepkgs/kopano-webapp-spellchecker-languagepack-italian-it
	    _pkgBuild makepkgs/kopano-webapp-spellchecker-languagepack-nl
	    _pkgBuild makepkgs/kopano-webapp-spellchecker-languagepack-pl-pl
	    _pkgBuild makepkgs/kopano-webapp-mdm
	    _pkgBuild makepkgs/kopano-webapp-mattermost
	    _pkgBuild makepkgs/kopano-webapp-meet
	    _pkgBuild makepkgs/kopano-webapp-webmeetings
	    _pkgBuild makepkgs/kopano-webapp-passwd
	    _pkgBuild makepkgs/kopano-webapp-fetchmail
	    _pkgBuild makepkgs/kopano-webapp-google2fa

	    # DEPENDENCIES - KOPANO-CORE
#	    _pkgBuild makepkgs/php-xapian
#	    _pkgBuild makepkgs/python-sleekxmpp
#	    _pkgBuild makepkgs/python2-minimock
#	    #-$chroot_build ./makepkgs/python2-vobject

#	    _pkgBuild makepkgs/libical2
#	    _pkgBuild makepkgs/python2-tlslite

	    # DEPENDENCIES - KOPANO-POSTFIXADMIN
#	    _pkgBuild makepkgs/perl-lockfile-simple
	    # MAIN PACKAGES

#	    _pkgBuild makepkgs/z-push
#	    _pkgBuild makepkgs/kopano-webapp

#	    _pkgBuild makepkgs/kopano-sabre
#	    _pkgBuild makepkgs/kopano-postfixadmin
#	    _pkgBuild makepkgs/kopano-service-overview

    _outH1 "FINISHED"
}

_sync() {
	    _pkgSync makepkgs/kopano-libvmime
	    _pkgSync makepkgs/kopano-core

	    # WEBAPP
	    _pkgSync makepkgs/kopano-webapp
#	    _pkgSync makepkgs/kopano-webapp-gmaps
#	    _pkgSync makepkgs/kopano-webapp-contactfax
#	    _pkgSync makepkgs/kopano-webapp-pimfolder
	    _pkgSync makepkgs/kopano-webapp-nginx
	    _pkgSync makepkgs/kopano-webapp-files
	    _pkgSync makepkgs/kopano-webapp-files-owncloud-backend
	    _pkgSync makepkgs/kopano-webapp-files-smb-backend
	    _pkgSync makepkgs/kopano-webapp-filepreview
	    _pkgSync makepkgs/kopano-webapp-desktopnotifications
#	    _pkgSync makepkgs/kopano-webapp-htmleditor-jodit
	    _pkgSync makepkgs/kopano-webapp-htmleditor-minimaltiny
	    _pkgSync makepkgs/kopano-webapp-intranet
	    _pkgSync makepkgs/kopano-webapp-smime
	    _pkgSync makepkgs/kopano-webapp-spellchecker
	    _pkgSync makepkgs/kopano-webapp-spellchecker-languagepack-de-at
	    _pkgSync makepkgs/kopano-webapp-spellchecker-languagepack-de-ch
	    _pkgSync makepkgs/kopano-webapp-spellchecker-languagepack-de-de
	    _pkgSync makepkgs/kopano-webapp-spellchecker-languagepack-en-gb
	    _pkgSync makepkgs/kopano-webapp-spellchecker-languagepack-en-us
	    _pkgSync makepkgs/kopano-webapp-spellchecker-languagepack-es-es
	    _pkgSync makepkgs/kopano-webapp-spellchecker-languagepack-fr-fr
	    _pkgSync makepkgs/kopano-webapp-spellchecker-languagepack-italian-it
	    _pkgSync makepkgs/kopano-webapp-spellchecker-languagepack-nl
	    _pkgSync makepkgs/kopano-webapp-spellchecker-languagepack-pl-pl
	    _pkgSync makepkgs/kopano-webapp-mdm
	    _pkgSync makepkgs/kopano-webapp-mattermost
	    _pkgSync makepkgs/kopano-webapp-meet
	    _pkgSync makepkgs/kopano-webapp-webmeetings
	    _pkgSync makepkgs/kopano-webapp-passwd
	    _pkgSync makepkgs/kopano-webapp-fetchmail
	    _pkgSync makepkgs/kopano-webapp-google2fa
}


### START

_outH1 "PREPARE"
	_templateDir=$(realpath ./makepkgs-templates)
	${_templateDir}/recreate-symlinks.sh
	grep  -R -l "# template " makepkgs | while read _file
	do
	    echo "Replacing Template Markers: ${_file}"
	    makepkg-template --template-dir ${_templateDir} --input ${_file}
	done


case "$1" in
    "sync")
	_sync
    ;;
    "push")
	_push
    ;;
    "build")
    ;&
    *)
	_build
    ;;
esac
