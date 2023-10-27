# SingleFile-for-WSL2  
Create and install SingleFIle as a WSL appliance from alpine rootfs  

https://github.com/gildas-lormeau/SingleFile  
https://github.com/gildas-lormeau/single-file-cli

Command to install  
```irm https://raw.githubusercontent.com/go2tom42/SingleFile-for-WSL2/master/SingleFile-for-WSL2.ps1 | iex```  

Command to get HTML  

```$wslPath = "$env:windir\system32\wsl.exe"; &$wslPath -d tom42-SingleFile -u chrome -e sh -c "/usr/src/app/SingleFile.sh https://typetype.org/fonts/tt-ricks/"```  

Command to remove SingleFile WSL  

```irm https://raw.githubusercontent.com/go2tom42/SingleFile-for-WSL2/master/Remove-SingleFile-for-WSL2.ps1 | iex```
