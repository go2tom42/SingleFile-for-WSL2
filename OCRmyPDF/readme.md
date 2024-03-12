# OCRmyPDF-for-WSL2  
![](OCRmyPDF.png?raw=true)
Create and install OpenAPITools as a WSL appliance from OCRmyPDF Docker image (REQUIRED [Docker Desktop](https://www.docker.com/products/docker-desktop/))

https://github.com/ocrmypdf/OCRmyPDF    
https://hub.docker.com/r/jbarlow83/ocrmypdf-alpine    

**Command to install** (In Powershell as admin)  
```irm https://raw.githubusercontent.com/go2tom42/Stuff-for-WSL2/master/OCRmyPDF/OCRmyPDF-for-WSL2.ps1 | iex```  

**Command to get HTML**  

```$wslPath = "$env:windir\system32\wsl.exe"; &$wslPath -d tom42-OCRmyPDF -e sh -c "ocrmypdf File.pdf"```  

**Output file location**  
```LOCALAPPDATA\tom42-OCRmyPDF```  
like  
```c:\Users\tom42\AppData\Local\tom42-OCRmyPDF\```


**Command to remove SingleFile WSL**  


```irm https://raw.githubusercontent.com/go2tom42/Stuff-for-WSL2/master/OCRmyPDF/Remove-OCRmyPDF-for-WSL2.ps1 | iex```
&nbsp;  

&nbsp;  

&nbsp;  

fyi:  I did this on Windowws 11 using Powershell 7
