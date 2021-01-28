# kopano-pkgbuilds

## Clone
 $ git clone --recursive https://github.com/pietmacom/kopano-pkgbuilds.git

## Update To Latest Environment
 $ cd kopano-pkgbuilds
 
 $ git submodule update --remote
 
## Build Packages
### From Delevelopment/Master-Branch
 $ ./build-docker.sh convertToGitPackage build
 
####  Without Docker
 $ ./build.sh convertToGitPackage build
 
### From Latest Release-Tag
 Latest releases are and their depencencies are fixed. For this reason they will have dependencies to older packages/libraries. This won't get along with Archlinuxs rolling release.
 
 Anyways you can build the releases packages of day they recently compiled successfully. Checkout the branch with the latest timestamp and compile. The script is setting up a Docker-Container with an Archlinux of that day.
 
 $ ./build-docker.sh build
 
## Milestones/Plans
 - (DONE) Make the existing packages compile with branch name => $VERSION
 - Seperate kopano-configurator and kopano-core
 - Compile package independently. Don't miss neccessary dependencies that had been installed indirectly by other packages.
 - Implement resume function to skip successfull build packages
 - Atomic releases for ARM devices.
