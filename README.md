# kopano-pkgbuilds

## Branches

 - 20210102		Packages from latest Releases-Source build on Archlinux from that day (02.01.2021)
 - master		Packages from Development/Master-Source build on latest/todays Archlinux
 - master-nextiteration	Packages beeing reworked

## Clone
```console
git clone https://github.com/pietmacom/kopano-pkgbuilds.git
cd kopano-pkgbuilds
git submodule update --init --recursive --remote --checkout
```

## Update To Latest Environment
```console
cd kopano-pkgbuilds
git submodule update --remote
```
 
## Build Packages
### From Kopanos Delevelopment/Master-Branch, For the Latest Arch Linux
```console
./build-docker.sh convertToGitPackage build
```
 
####  Without Docker
```console
./build.sh convertToGitPackage build
```
 
### From Kopanos Latest Release-Tag, For the Latest Arch Linux
 As you can read from the next chapter, this isn't realy planed. But with a little luck the patches from the Development/Master-Branch could work for the latest Release-Tag, too.
 
```console
./build.sh build
```

### From Kopanos Latest Release-Tag, For Specific Arch Linux
 Code from releases and their depencencies are fixed. For this reason they will have dependencies to older packages/libraries. This won't get along with Archlinux's rolling release. The build will likely fail.
 
 Anyways you can build the releases packages of the day they recently/successfully compiled. Checkout the branch with the latest timestamp and compile.
 
 The script is setting up a Docker-Container with an Archlinux of that day and going to compile everything.
 
```console
./build-docker.sh build
```
 
## Milestones/Plans
 - (DONE) Make the existing packages compile with branch name => $VERSION
 - Seperate kopano-configurator and kopano-core
 - Compile package independently. Don't miss neccessary dependencies that had been installed indirectly by other packages.
 - Implement resume function to skip successfull build packages
 - Atomic releases for ARM devices.
 
