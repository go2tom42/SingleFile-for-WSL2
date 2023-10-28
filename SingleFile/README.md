# SingleFile-for-WSL2  
![](SingleFile.png?raw=true)
Create and install SingleFIle as a WSL appliance from alpine rootfs  

https://github.com/gildas-lormeau/SingleFile  
https://github.com/gildas-lormeau/single-file-cli

**Command to install** (In Powershell as admin)  
```irm https://raw.githubusercontent.com/Stuff-for-WSL2/master/SingleFile/SingleFile-for-WSL2.ps1 | iex```  

**Command to get HTML**  

```$wslPath = "$env:windir\system32\wsl.exe"; &$wslPath -d tom42-SingleFile -u chrome -e sh -c "/usr/src/app/SingleFile.sh https://typetype.org/fonts/tt-ricks/"```  

**Output file location**  
```LOCALAPPDATA\tom42-SingleFile```  
like  
```c:\Users\tom42\AppData\Local\tom42-SingleFile\```


**Command to remove SingleFile WSL**  


```irm https://raw.githubusercontent.com/go2tom42/Stuff-for-WSL2/master/SingleFile/Remove-SingleFile-for-WSL2.ps1 | iex```
&nbsp;  

&nbsp;  

&nbsp;  

fyi:  I did this on Windowws 10 using Powershell 7
