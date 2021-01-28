# kopano-pkgbuilds

## Clone
```console
git clone --recursive https://github.com/pietmacom/kopano-pkgbuilds.git
```

## Update To Latest Environment
```console
cd kopano-pkgbuilds
git submodule update --remote
```
 
## Build Packages
### From Delevelopment/Master-Branch
```console
./build-docker.sh convertToGitPackage build
```
 
####  Without Docker
```console
./build.sh convertToGitPackage build
```
 
### From Latest Release-Tag
 Code from releases and their depencencies are fixed. For this reason they will have dependencies to older packages/libraries. This won't get along with Archlinux's rolling release. The build will likely fail.
 
 Anyways you can build the releases packages of day they recently/successfully compiled. Checkout the branch with the latest timestamp and compile.
 
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
