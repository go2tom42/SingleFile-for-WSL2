# SingleFile-for-WSL2  
Create and install SingleFIle as a WSL appliance from alpine rootfs  

https://github.com/gildas-lormeau/SingleFile  
https://github.com/gildas-lormeau/single-file-cli


Command to get HTML  

```$wslPath = "$env:windir\system32\wsl.exe"; &$wslPath -d tom42-SingleFile -u chrome -e sh -c "/usr/src/app/SingleFile.sh https://typetype.org/fonts/tt-ricks/"```
