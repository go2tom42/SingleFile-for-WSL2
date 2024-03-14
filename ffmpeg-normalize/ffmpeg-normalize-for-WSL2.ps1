
#Variables

[string]$gzip                 = 'c:\tools\cygwin\bin\gzip.exe'
[string]$tar                  = 'c:\tools\cygwin\bin\tar.exe'
[string]$curl                 = 'C:\Windows\System32\curl.exe'

[string]$distro               = "ffmpeg-normalize"
[string]$dockerpath           = "python:3.12.0a7-alpine3.17"
[string]$DistributionName     = "tom42-ffmpeg_normalize"
[string]$neofetchPath         = "./usr/bin/neofetch"
[string]$neofetchDELPath      = "./usr"

[string]$neofetchBasePathWin  = "etc\profile.d"
[string]$neofetchtextPathWin  = "etc\profile.d\prompt.txt"
[string]$neofetchtextPathUnix = "./etc/profile.d/prompt.txt"
[string]$promptFilePathWin    = "etc\profile.d\prompt.sh"
[string]$promptFilePathUnix   = "./etc/profile.d/prompt.sh"
[string]$prompPathDel         = "./etc"

$neofetchtext = @'
███████╗███████╗███╗   ███╗██████╗ ███████╗ ██████╗          
██╔════╝██╔════╝████╗ ████║██╔══██╗██╔════╝██╔════╝          
█████╗  █████╗  ██╔████╔██║██████╔╝█████╗  ██║  ███╗         
██╔══╝  ██╔══╝  ██║╚██╔╝██║██╔═══╝ ██╔══╝  ██║   ██║         
██║     ██║     ██║ ╚═╝ ██║██║     ███████╗╚██████╔╝         
╚═╝     ╚═╝     ╚═╝     ╚═╝╚═╝     ╚══════╝ ╚═════╝          
                                                             
███╗   ██╗ ██████╗ ██████╗ ███╗   ███╗ █████╗ ██╗     ██╗███████╗███████╗
████╗  ██║██╔═══██╗██╔══██╗████╗ ████║██╔══██╗██║     ██║╚══███╔╝██╔════╝
██╔██╗ ██║██║   ██║██████╔╝██╔████╔██║███████║██║     ██║  ███╔╝ █████╗  
██║╚██╗██║██║   ██║██╔══██╗██║╚██╔╝██║██╔══██║██║     ██║ ███╔╝  ██╔══╝  
██║ ╚████║╚██████╔╝██║  ██║██║ ╚═╝ ██║██║  ██║███████╗██║███████╗███████╗
╚═╝  ╚═══╝ ╚═════╝ ╚═╝  ╚═╝╚═╝     ╚═╝╚═╝  ╚═╝╚══════╝╚═╝╚══════╝╚══════╝
'@

$prompttext = @"
export PS1=`"\[\033[01;32m\]$DistributionName\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ `"                  
/usr/bin/neofetch --ascii_colors 6 8 1 15 3 4 --ascii /etc/profile.d/prompt.txt
"@

#don't touch below unless you know what you are doing

#get WSL.exe path
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
 

#get docker image
$distro = $distro.ToLower() 
Start-Process -FilePath "docker" -ArgumentList "run --name $distro -t $dockerpath ls /" -wait -NoNewWindow
Start-Process -FilePath "docker" -ArgumentList "export $distro -o .\$distro.tar" -wait -NoNewWindow
Start-Process -FilePath "docker" -ArgumentList "rm $distro" -wait -NoNewWindow
Start-Process -FilePath "docker" -ArgumentList "rmi $distro" -wait -NoNewWindow

#add ffmpeg & ffprobe
$env:Path = "$($gzip.replace('\gzip.exe',''));" + $env:Path
&$curl -o ffmpeg-release-amd64-static.tar.xz https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-amd64-static.tar.xz
$folder = ((&$tar --list --file=ffmpeg-release-amd64-static.tar.xz) -split '\n')[0].replace('/','')
Start-Process -FilePath $tar -ArgumentList "--extract --file=ffmpeg-release-amd64-static.tar.xz $folder/ffmpeg --strip-components=1" -wait -NoNewWindow
Start-Process -FilePath $tar -ArgumentList "--extract --file=ffmpeg-release-amd64-static.tar.xz $folder/ffprobe --strip-components=1" -wait -NoNewWindow
Start-Process -FilePath $tar -ArgumentList "rf ffmpeg-normalize.tar --transform 's,^\./,/usr/local/bin/,' ./ffmpeg --group=0 --owner=0 --mode='0755'" -wait -NoNewWindow
Start-Process -FilePath $tar -ArgumentList "rf ffmpeg-normalize.tar --transform 's,^\./,/usr/local/bin/,' ./ffprobe --group=0 --owner=0 --mode='0755'" -wait -NoNewWindow
Remove-Item -Path "./ffmpeg-release-amd64-static.tar.xz" -Force
Remove-Item -Path "./ffmpeg" -Force
Remove-Item -Path "./ffprobe" -Force

#move distro to final folder
[string]$BaseDirectory = $env:LOCALAPPDATA
$distribution_dir = "$BaseDirectory\$DistributionName"
$null = New-Item -ItemType Directory -Force -Path $distribution_dir
Move-Item -Path ".\$distro.tar" -Destination "$distribution_dir\rootfs.tar"
Set-Location $distribution_dir

#download and add neofetch
Start-Process -FilePath $curl -ArgumentList "-o $neofetchPath --create-dirs https://raw.githubusercontent.com/dylanaraps/neofetch/master/neofetch" -wait -NoNewWindow
$ArgumentList = "-rf rootfs.tar $neofetchPath --group=0 --owner=0 --mode='0755'"
Start-Process -FilePath $tar -ArgumentList $ArgumentList -wait -NoNewWindow
Remove-Item $neofetchDELPath -Recurse -Force


#add neofetch splash text
$null = New-Item -ItemType Directory -Force -Path $neofetchBasePathWin
$neofetchtext | out-file $neofetchtextPathWin 
((Get-Content $neofetchtextPathWin ) -join "`n") + "`n" | Set-Content -NoNewline $neofetchtextPathWin 
$ArgumentList = "-rf rootfs.tar $neofetchtextPathUnix --group=0 --owner=0 --mode='0644'"
Start-Process -FilePath $tar -ArgumentList $ArgumentList -wait -NoNewWindow


#update prompt
$prompttext | out-file -Encoding utf8 $promptFilePathWin
((Get-Content $promptFilePathWin) -join "`n") + "`n" | Set-Content -NoNewline $promptFilePathWin
$ArgumentList = "-uf rootfs.tar $promptFilePathUnix --group=0 --owner=0 --mode='0777'"
Start-Process -FilePath $tar -ArgumentList $ArgumentList -wait -NoNewWindow
Remove-Item $prompPathDel -Recurse -Force

#compress Tar to Tar.GZ
Start-Process -FilePath $gzip -ArgumentList "-v -9 rootfs.tar" -wait -NoNewWindow

#install WSL
$rootfs_file = Get-ChildItem "rootfs.tar.gz"
Start-Process -FilePath $wslPath -ArgumentList "--import $DistributionName $distribution_dir $rootfs_file" -Wait -NoNewWindow
Start-Process -FilePath $wslPath -ArgumentList "--set-version $DistributionName 2" -NoNewWindow -Wait 
#optional commands
Start-Process -FilePath $wslPath -ArgumentList "-d $DistributionName apk add bash" -NoNewWindow -Wait
Start-Process -FilePath $wslPath -ArgumentList "-d $DistributionName pip3 install ffmpeg-normalize" -NoNewWindow -Wait


