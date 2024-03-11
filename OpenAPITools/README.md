# OpenAPITools-for-WSL2  
![](OpenAPITools.png?raw=true)
Create and install OpenAPITools as a WSL appliance from alpine rootfs  

https://github.com/gildas-lormeau/SingleFile  
https://github.com/gildas-lormeau/single-file-cli

**Command to install** (In Powershell as admin)  
```irm https://raw.githubusercontent.com/go2tom42/Stuff-for-WSL2/master/OpenAPITools/OpenAPITools-for-WSL2.ps1 | iex```  

**Command to get HTML**  

```$wslPath = "$env:windir\system32\wsl.exe"; &$wslPath -d tom42-OpenAPITools -e sh -c "openapi-generator generate -i https://api.jellyfin.org/openapi/jellyfin-openapi-stable.json -g powershell -o ./"```  

**Output file location**  
```LOCALAPPDATA\tom42-OpenAPITools```  
like  
```c:\Users\tom42\AppData\Local\tom42-OpenAPITools\```


**Command to remove SingleFile WSL**  


```irm https://raw.githubusercontent.com/go2tom42/Stuff-for-WSL2/master/OpenAPITools/Remove-OpenAPITools-for-WSL2.ps1 | iex```
&nbsp;  

&nbsp;  

&nbsp;  

fyi:  I did this on Windowws 11 using Powershell 7
