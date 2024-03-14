# ffmpeg-normalize-for-WSL2  
![](ffmpeg-normalize.png?raw=true)
Create and install OpenAPITools as a WSL appliance from ffmpeg-normalize Docker image (REQUIRED [Docker Desktop](https://www.docker.com/products/docker-desktop/))

https://github.com/slhck/ffmpeg-normalize  

**Command to install** (In Powershell as admin)  
```irm https://raw.githubusercontent.com/go2tom42/Stuff-for-WSL2/master/ffmpeg-normalize/ffmpeg-normalize-for-WSL2.ps1 | iex```  

**Command to get HTML**  

```$wslPath = "$env:windir\system32\wsl.exe"; &$wslPath -d tom42-ffmpeg_normalize -e sh -c "ffmpeg-normalize file.mkv"```  

**Output file location**  
```LOCALAPPDATA\tom42-ffmpeg_normalize```  
like  
```c:\Users\tom42\AppData\Local\tom42-ffmpeg_normalize\```


**Command to remove ffmpeg-normalize WSL**  


```irm https://raw.githubusercontent.com/go2tom42/Stuff-for-WSL2/master/ffmpeg-normalize/Remove-ffmpeg-normalize-for-WSL2.ps1 | iex```
&nbsp;  

&nbsp;  

&nbsp;  

fyi:  I did this on Windowws 11 using Powershell 7
