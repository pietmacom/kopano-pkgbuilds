# kopano-pkgbuilds

## Clone
 $ git clone --recursive https://github.com/pietmacom/kopano-pkgbuilds.git

### Use latest environment
 $ cd kopano-pkgbuilds
 
 $ git submodule update --remote

## Milestones/Plans
 - (DONE) Make the existing packages compile with branch name => $VERSION
 - Seperate kopano-configurator and kopano-core
 - Compile package independently. Don't miss neccessary dependencies that had been installed indirectly by other packages.
 - Implement resume function to skip successfull build packages
 - Atomic releases for ARM devices.
