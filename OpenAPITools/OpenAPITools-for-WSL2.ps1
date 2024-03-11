
#set these
$gzip = 'c:\tools\cygwin\bin\gzip.exe'
$tar = 'c:\tools\cygwin\bin\tar.exe'
$curl = 'C:\Windows\System32\curl.exe'

#don't touch unless you know what you are doing
if ($IsWindows) {
    $wslPath = "$env:windir\system32\wsl.exe"
    if (-not [System.Environment]::Is64BitProcess) {
        wsl.exe
        # Allow launching WSL from 32 bit powershell
        $wslPath = "$env:windir\sysnative\wsl.exe"
    }
 
} else {
    # If running inside WSL, rely on wsl.exe being in the path.
    $wslPath = "wsl.exe"
}
 
$distro = "OpenAPITools"
$dockerpath = "openapitools/openapi-generator-cli"

$distro = $distro.ToLower() 

Start-Process -FilePath "docker" -ArgumentList "run --name $distro -t $dockerpath ls /" -wait -NoNewWindow
Start-Process -FilePath "docker" -ArgumentList "export $distro -o .\$distro.tar" -wait -NoNewWindow
Start-Process -FilePath "docker" -ArgumentList "rm $distro" -wait -NoNewWindow
Start-Process -FilePath "docker" -ArgumentList "rmi $distro" -wait -NoNewWindow
[string]$BaseDirectory = $env:LOCALAPPDATA
[string]$DistributionName = "tom42-OpenAPITools"
$distribution_dir = "$BaseDirectory\$DistributionName"
$null = New-Item -ItemType Directory -Force -Path $distribution_dir

Move-Item -Path ".\$distro.tar" -Destination "$distribution_dir\rootfs.tar"
Set-Location $distribution_dir
Start-Process -FilePath $curl -ArgumentList "-o ./usr/games/neofetch --create-dirs https://raw.githubusercontent.com/dylanaraps/neofetch/master/neofetch" -wait -NoNewWindow
Start-Process -FilePath $tar -ArgumentList "-rf rootfs.tar ./usr/games/neofetch --group=0 --owner=0 --mode='0755'" -wait -NoNewWindow
Remove-Item ".\usr" -Recurse -Force
$null = New-Item -Path "root" -ItemType "directory"

$text = @'
${c2}                              ###### 
${c2}                             ########
${c2}                            #########
${c2}                            ######## 
${c1}           ==============${c2}  #######   
${c1}         ==============${c2}  ####        
${c1}       ========      =${c2} ####${c1} =        
${c1}      =======${c2}        ####${c1}  ===       
${c1}      ======${c2}   ########${c1}  =====       
${c1}      =====${c2}   ########${c1}   =====       
${c1}      =====${c2}   ########${c1}   =====       
${c1}      =====${c2}    #######${c1}   =====       
${c1}      ======${c2}      #${c1}     ======       
${c1}     =========        ========       
${c1}   =========================         
${c1} =========================           
${c1}=========================            
${c1}  ==========                         
${c1}    ======                           
${c1}      ==        
'@

$text | out-file root\prompt.txt
((Get-Content "root\prompt.txt") -join "`n") + "`n" | Set-Content -NoNewline "root\prompt.txt"
Start-Process -FilePath $tar -ArgumentList "-rf rootfs.tar ./root/prompt.txt --group=0 --owner=0 --mode='0644'" -wait -NoNewWindow

$text = @"
export PS1=`"\[\033[01;32m\]$DistributionName\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ `"                  
/usr/games/neofetch --ascii_colors 10 8 1 2 3 4 --ascii /root/prompt.txt
"@

$text | out-file -Encoding utf8 "root\.bashrcTEMP"
((Get-Content "root\.bashrcTEMP") -join "`n") + "`n" | Set-Content -NoNewline "root\.bashrcTEMP"

Start-Process -FilePath $tar -ArgumentList "--extract --file=rootfs.tar root/.bashrc" -wait -NoNewWindow
Get-Content "root\.bashrc", "root\.bashrcTEMP" | Set-Content "root\.bashrc2" ; move-item -path "root\.bashrc2" -dest "root\.bashrc" -force
((Get-Content "root\.bashrc") -join "`n") + "`n" | Set-Content -NoNewline "root\.bashrc"
Start-Process -FilePath $tar -ArgumentList "-rf rootfs.tar ./root/.bashrc" -wait -NoNewWindow
remove-item -Recurse -Path '.\root'
Start-Process -FilePath $gzip -ArgumentList "-9 rootfs.tar" -wait -NoNewWindow

$rootfs_file = Get-ChildItem "rootfs.tar.gz"

Start-Process -FilePath $wslPath -ArgumentList "--import $DistributionName $distribution_dir $rootfs_file" -Wait -NoNewWindow
Start-Process -FilePath $wslPath -ArgumentList "--set-version $DistributionName 2" -NoNewWindow -Wait 
Start-Process -FilePath $wslPath -ArgumentList "-d $DistributionName ln -s /opt/java/openjdk/bin/java /usr/local/bin/java" -NoNewWindow -Wait
Start-Process -FilePath $wslPath -ArgumentList "-d $DistributionName ln -s /usr/local/bin/docker-entrypoint.sh /usr/local/bin/openapi-generator" -NoNewWindow -Wait
