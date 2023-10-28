
#set these
$gzip = 'C:\cygwin64\bin\gzip.exe'
$tar = 'C:\cygwin64\bin\tar.exe'
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
 
[string]$BaseDirectory = $env:LOCALAPPDATA
[string]$DistributionName = "tom42-SingleFile"
$distribution_dir = "$BaseDirectory\$DistributionName"
$null = New-Item -ItemType Directory -Force -Path $distribution_dir
$rootfs_file = "$distribution_dir\rootfs.tar.gz"
$RootFSURL = "https://dl-cdn.alpinelinux.org/alpine/v3.18/releases/x86_64/alpine-minirootfs-3.18.4-x86_64.tar.gz"
(New-Object Net.WebClient).DownloadFile($RootFSURL, $rootfs_file)
Set-Location $distribution_dir
Start-Process -path $gzip -ArgumentList "-dv rootfs.tar.gz" -NoNewWindow -Wait
&$curl -o ./usr/bin/neofetch --create-dirs https://raw.githubusercontent.com/dylanaraps/neofetch/master/neofetch
&$tar -rf rootfs.tar ./usr/bin/neofetch --group=0 --owner=0 --mode='0755'
remove-item -Recurse -Path './usr'
mkdir usr\src\app
$localconf = @'
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>

 <alias>
   <family>sans-serif</family>
   <prefer>
     <family>Main sans-serif font name goes here</family>
     <family>Noto Color Emoji</family>
     <family>Noto Emoji</family>
   </prefer>
 </alias>

 <alias>
   <family>serif</family>
   <prefer>
     <family>Main serif font name goes here</family>
     <family>Noto Color Emoji</family>
     <family>Noto Emoji</family>
   </prefer>
 </alias>

 <alias>
  <family>monospace</family>
  <prefer>
    <family>Main monospace font name goes here</family>
    <family>Noto Color Emoji</family>
    <family>Noto Emoji</family>
   </prefer>
 </alias>
</fontconfig>
'@

$text = @'
#!/bin/sh

cd /usr/src/app/node_modules/single-file-cli
CHROME_BIN=/usr/bin/chromium-browser
CHROME_PATH=/usr/lib/chromium/
CHROMIUM_FLAGS="--disable-software-rasterizer --disable-dev-shm-usage"
./single-file $1 --browser-wait-until=load --insert-meta-csp=false --remove-alternative-fonts=false --remove-alternative-medias=false --remove-hidden-elements=false --remove-unused-fonts=false --remove-unused-styles=false --compress-HTML=false --browser-executable-path=/usr/bin/chromium-browser --output-directory=/mnt/c/Users/tom42/AppData/Local/tom42-SingleFile
'@

$text | out-file -Encoding utf8 usr\src\app\SingleFile.sh
((Get-Content "usr\src\app\SingleFile.sh") -join "`n") + "`n" | Set-Content -NoNewline "usr\src\app\SingleFile.sh"
&$tar -rf rootfs.tar ./usr/src/app/SingleFile.sh --group=0 --owner=0 --mode='0777'
remove-item -Recurse -Path '.\usr\src\app'


mkdir etc\profile.d

$text = @'
${c6}   .clllllllllllllll.                   
  ;llllllllllllllllox:.                 
 .llllllllllllllllloxxxc.               
 .llllllllllllllllloxxxxx:.             
 .llllllllllllllllllodxxxxd:            
 .llllllllllllllllllllllllll'           
 .llllllllllllllllllllllllll'           
 .llllllccccccccclllllllllll'           
 .lllll;''''''''':lllllllooo,           
 .llllllccccccccccclox${c2}O0KKKKK0xl,       
${c6} .lllll,'''''''''.,${c2}dKKKKKKKKKKKKKKo.    
${c6} .lllllllllllllll${c2}xKKKKKKKK;;KKKKKKK0:   
${c6} .lllll,........${c2}lKKKKKKKKK,'KKKKKKKKK:  
${c6} .llllllllllllll${c2}KKKKKKKKKK,'KKKKKKKKK0  
${c6} .lllllllllllllo${c2}KKKKK:'dKX,'KKo.;KKKKK. 
${c6}  :lllllllllllll${c2}OKKKKKx,'o''d',xKKKKKd  
${c6}   .,,;;;;;;;;;;;${c2}kKKKKKKx,..,dKKKKKKk   
                  lKKKKKKKxxKKKKKKKl    
                   .:x0KKKKKKKK0x:.     
                       ;xKKKKx;         
'@
$text | out-file etc\profile.d\prompt.txt
((Get-Content "etc\profile.d\prompt.txt") -join "`n") + "`n" | Set-Content -NoNewline "etc\profile.d\prompt.txt"
&$tar -rf rootfs.tar ./etc/profile.d/prompt.txt --group=0 --owner=0 --mode='0644'


$text = @"
#!/bin/sh

export PS1=`"\[\033[01;32m\]SingleFile\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ `"                  
neofetch --ascii_colors 2 3 1 1 5 4 --ascii /etc/profile.d/prompt.txt
"@

$text | out-file -Encoding utf8 etc\profile.d\prompt.sh
((Get-Content "etc\profile.d\prompt.sh") -join "`n") + "`n" | Set-Content -NoNewline "etc\profile.d\prompt.sh"
&$tar -uf rootfs.tar ./etc/profile.d/prompt.sh --group=0 --owner=0 --mode='0777'
remove-item -Recurse -Path './etc'
&$gzip -9 rootfs.tar

&$wslPath --import $DistributionName $distribution_dir $rootfs_file | Write-Verbose
&$wslPath --set-version $DistributionName 2
&$wslPath -d $DistributionName apk add bash
&$wslPath -d $DistributionName apk upgrade --no-cache --available 
&$wslPath -d $DistributionName apk add --no-cache chromium-swiftshader ttf-freefont font-noto-emoji 
&$wslPath -d $DistributionName apk add --no-cache --repository=https://dl-cdn.alpinelinux.org/alpine/edge/testing font-wqy-zenhei
&$wslPath -d $DistributionName apk add --no-cache tini make gcc g++ python3 git nodejs npm yarn
&$wslPath -d $DistributionName ln /usr/src/app/SingleFile.sh /SingleFile.sh
$localconf | out-file -Encoding utf8 .\local.conf
((Get-Content ".\local.conf") -join "`n") + "`n" | Set-Content -NoNewline ".\local.conf"
&$wslPath -d $DistributionName cp ./local.conf /etc/fonts/local.conf
remove-item -Recurse -Path './local.conf'

&$wslPath -d $DistributionName mkdir -p /usr/src/app 
&$wslPath -d $DistributionName adduser -D chrome 
&$wslPath -d $DistributionName chown -R chrome:chrome /usr/src/app

&$wslPath -d $DistributionName -u chrome -e sh -c "cd /usr/src/app;CHROME_BIN=/usr/bin/chromium-browser;CHROME_PATH=/usr/lib/chromium/;CHROMIUM_FLAGS=`"--disable-software-rasterizer --disable-dev-shm-usage`";npm install --production single-file-cli"
