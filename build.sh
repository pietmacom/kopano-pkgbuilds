#!/bin/sh -ex

_outH1() {
    echo
    echo "# $1"
    echo
}

_execFunction() {
    _functionName=${1}
    if [ "$(LC_ALL=C type -t ${_functionName})" == "function" ];
    then
	_outH1 "Execute ${_functionName}"
	${_functionName}
    fi
}

_pkgBuild() {
    _pwd=$(pwd)
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

    cd ${_pwd}
}

# TODO Increment pkgrel
_pkgSync() {
    _pwd=$(pwd)
    _makepkg=$(realpath ${1})

    cd ${_makepkg}
    makepkg --printsrcinfo > .SRCINFO
    eval local $(grep -o -m 1 '^\s*pkgname\s*=\s*.*' PKGBUILD)

    cd ${_pwd}
    _syncPath="makepkgs-sync/${pkgname}"
    if ! git clone http://aur.archlinux.org/${pkgname}.git ${_syncPath} ;
    then
	echo "Clone failed ${pkgname}"
	return $?
    fi

    cd ${_syncPath}
    find  ./ -maxdepth 1 -mindepth 1 -not -name ".git*" -exec rm -rf {} \;
    cp -RT ${_makepkg} .
    git add -A || true
    git commit -a -m "next iteration" || true

    cd ${_pwd}
}

_pkgPush() {
    _pwd=$(pwd)
    _makepkg_sync=$(realpath ${1})

    cd ${_makepkg_sync}
    git remote set-url origin ssh://aur@aur.archlinux.org/$(basename ${_makepkg_sync}).git
    git push
    cd ${_pwd}
}

_pkgConvertToGitPackage() {
    _pkgnameDeclaration="$(grep -o -m 1 '^\s*pkgname\s*=\s*.*$' ${1}/PKGBUILD)"
    eval ${_pkgnameDeclaration}
    if [[ "${pkgname}" == *-git ]];
    then
	echo "Is already Git-Package ${1} (${pkgname})"
	return 0
    fi

    # Only first occurence
    sed -i "0,/${_pkgnameDeclaration}/s//pkgname='${pkgname}-git'/" ${1}/PKGBUILD
}

### START

makepkgsClone=(
    'https://aur.archlinux.org/libiconv.git'
	)

makepkgs=(
    # CORE
    'libiconv#nosync#nogit'
    'swig#nosync#nogit'
#    'libvmime#nosync'
    'kopano-libvmime'
    'kopano-core'

    # z-push
    'z-push'

    # WEBAPP
# OPTIONAL 'jdk#nosync#nogit'
    'kopano-webapp'
#    'kopano-webapp-gmaps'
#    'kopano-webapp-contactfax'
#    'kopano-webapp-pimfolder'
    'kopano-webapp-nginx'
    'kopano-webapp-files'
    'kopano-webapp-files-owncloud-backend'
    'kopano-webapp-files-smb-backend'
    'kopano-webapp-filepreview'
    'kopano-webapp-desktopnotifications'
#    'kopano-webapp-htmleditor-jodit'
    'kopano-webapp-htmleditor-minimaltiny'
    'kopano-webapp-intranet'
    'kopano-webapp-smime'
    'kopano-webapp-spellchecker'
    'kopano-webapp-spellchecker-languagepack-de-at'
    'kopano-webapp-spellchecker-languagepack-de-ch'
    'kopano-webapp-spellchecker-languagepack-de-de'
    'kopano-webapp-spellchecker-languagepack-en-gb'
    'kopano-webapp-spellchecker-languagepack-en-us'
    'kopano-webapp-spellchecker-languagepack-es-es'
    'kopano-webapp-spellchecker-languagepack-fr-fr'
    'kopano-webapp-spellchecker-languagepack-italian-it'
    'kopano-webapp-spellchecker-languagepack-nl'
    'kopano-webapp-spellchecker-languagepack-pl-pl'
    'kopano-webapp-mdm'
    'kopano-webapp-mattermost'
    'kopano-webapp-meet'
    'kopano-webapp-webmeetings'
    'kopano-webapp-passwd'
    'kopano-webapp-fetchmail'
#    'kopano-webapp-google2fa'
      )

prebuild_kopano_libvmime() {
#    if [[ "$(git branch  --show-current)" != master* ]];
#    then
	sed -i "s|https://github.com/Kopano-dev/vmime.git|https://github.com/pietmacom/kopano-vmime.git|" \
	    makepkgs/kopano-libvmime/PKGBUILD
#    fi
}
presync_kopano_libvmime() {
    prebuild_kopano_libvmime
}

prebuild_kopano_core() {
#    if [[ "$(git branch  --show-current)" != master* ]];
#    then
	sed -i "s|https://stash.kopano.io/scm/kc/kopanocore.git|https://github.com/pietmacom/kopano-core.git|" \
	    makepkgs/kopano-core/PKGBUILD
#    fi
}
presync_kopano_core() {
    prebuild_kopano_core
}

_outH1 "CHECKOUT"
    for makepkgClone in "${makepkgsClone[@]}"
    do
	makepkgCloneName=${makepkgClone}
	makepkgCloneName="${makepkgCloneName//*\//}"
	makepkgCloneName="${makepkgCloneName//.git/}"
	git clone ${makepkgClone} makepkgs/${makepkgCloneName}
    done

_outH1 "PREPARE"
    _templateDir=$(realpath ./makepkgs-templates)
    ${_templateDir}/recreate-symlinks.sh
    grep  -R -l "# template " makepkgs | while read _file
    do
	echo "Replacing Template Markers: ${_file}"
	makepkg-template --template-dir ${_templateDir} --input ${_file}
    done


for _task in "$@"
do
    case "${_task}" in
	"convertToGitPackage")
	    _outH1 "CONVERT TO GIT PACKAGE"
	    for makepkg in "${makepkgs[@]}"
	    do
		makepkgname="${makepkg//#*/}"
		if [[ "${makepkg}"  == *#nogit* ]];
		then
		    echo "NO GIT : ${makepkgname}"
		    continue
		fi
		_pkgConvertToGitPackage makepkgs/${makepkgname}
	    done
	;;
	"sync")
	    _outH1 "SYNC"
	    if [ -z "$(git config --global user.email)" ] \
		|| [ -z "$(git config --global user.name)" ];
	    then
		git config --global user.email "you@example.com"
		git config --global user.name "Your Name"
	    fi

	    for makepkg in "${makepkgs[@]}"
	    do
		makepkgname="${makepkg//#*/}"
		if [[ "${makepkg}"  == *#nosync* ]];
		then
		    echo "NO SYNC : ${makepkgname}"
		    continue
		fi
		_execFunction "presync_${makepkgname//-/_}"
		_pkgSync makepkgs/${makepkgname}
	    done
	    cp -R makepkgs-sync /build-target/
	;;
	"push")
	    for pkg in $(ls makepkgs-sync/);
	    do
		_outH1 "PUSHING ${pkg}"
		_pkgPush makepkgs-sync/${pkg}
	    done;
	;;
	"build")
	    _outH1 "BUILD"
		for makepkg in "${makepkgs[@]}"
		do
		    makepkgname="${makepkg//#*/}"

		    _execFunction "prebuild_${makepkgname//-/_}"
		    _execFunction "build_${makepkgname//-/_}"
		    _pkgBuild makepkgs/${makepkgname}
		    _execFunction "postbuild_${makepkgname//-/_}"
		done
	;;
	*)
	;;
    esac
done