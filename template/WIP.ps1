<#
	.SYNOPSIS
		This creates and installs a WSL2 container from a Docker source
	.DESCRIPTION
		This creates and installs a WSL2 container from a Docker source
	.PARAMETER gzip
		[string] Full Path to gzip.exe
	.PARAMETER tar
		[string] Full Path to tar.exe
	.PARAMETER curl
		[string] Full Path to curl.exe
	.PARAMETER distro
		[string] Temporary name for Docker container
	.PARAMETER dockerpath
		[string] Docker Image path, EXAMPLE "jbarlow83/ocrmypdf-alpine" 
	.PARAMETER LinuxDistro
		[string] Type of image we are working with, ONLY "alpine" & "debian" currently supported
	.PARAMETER WSLDistributionName
		[string] Name used to idenify WSL2 container
	.PARAMETER RunExtras
		[switch] For extra install commands, anding -RunExtras means YES
	.PARAMETER AsciiColors
		[string] 6 colors used for neofetch, 0-255 seperated with a space EXAMPLE "6 8 1 15 3 4"
	.PARAMETER neofetchtext
		[string] Full Path of ascii text file for Prompt logo
	.PARAMETER ExtraCommands
		[array] Send this via varible unless you know another way EXAMPLE
		[array]$myExtras = ("-d tom42-wsldistro apk add bash","-d tom42-wsldistro ln -s /app/.venv/bin/ocrmypdf /usr/local/bin/ocrmypdf")
		-ExtraCommands $myExtras
	.EXAMPLE
		[array]$myExtras = ("-d tom42-OCRmyPDF apk add bash","-d tom42-OCRmyPDF ln -s /app/.venv/bin/ocrmypdf /usr/local/bin/ocrmypdf")
		Set-Template.ps1 -gzip "c:\tools\cygwin\bin\gzip.exe" `
				 -tar "c:\tools\cygwin\bin\tar.exe" `
				 -curl "C:\Windows\System32\curl.exe" `
				 -distro "OCRmyPDF" `
				 -dockerpath "jbarlow83/ocrmypdf-alpine" `
				 -LinuxDistro "alpine" `
				 -WSLDistributionName "tom42-OCRmyPDF" `
				 -RunExtras `
				 -AsciiColors "6 8 1 15 3 4" `
				 -neofetchtext "C:\Path\Prompt.Ascii" `
				 -ExtraCommands $myExtras
#>
[CmdletBinding()]
param (
    [string]$gzip,
    [string]$tar,
    [string]$curl,
    [string]$distro,
    [string]$dockerpath,
    [ValidateSet("alpine", "debian")]
    [string]$LinuxDistro,
    [string]$WSLDistributionName,
    [switch]$RunExtras,
    [switch]$AsciiColors,
    [string]$neofetchtext,
    [array]$ExtraCommands
)


function Set-SystemVaribles {
    if (!$gzip)                {[string]$Script:gzip                   = 'c:\tools\cygwin\bin\gzip.exe'}
    if (!$tar)                 {[string]$Script:tar                    = 'c:\tools\cygwin\bin\tar.exe'}
    if (!$curl)                {[string]$Script:curl                   = 'C:\Windows\System32\curl.exe' }
};Set-SystemVaribles

function Set-Docker {
    if (!$distro)              {[string]$Script:distro                 = "OCRmyPDF"}
    if (!$dockerpath)          {[string]$Script:dockerpath             = "jbarlow83/ocrmypdf-alpine"}
};Set-Docker

function Set-WSL2Items {
    if (!$LinuxDistro)         {[string]$Script:LinuxDistro            = "alpine"}
    if (!$WSLDistributionName) {[string]$Script:WSLDistributionName    = "tom42-OCRmyPDF"}
    if (!$RunExtras)           {[switch]$Script:RunExtras              = $true}
    if (!$AsciiColors)         {[string]$Script:AsciiColors            = "6 8 1 15 3 4"}
    if (!$neofetchtext)        {[string]$Script:neofetchtext           = @'
                                                     ${c4}@@@@@@@@@@@@@@@@@@@@      
                                                     ${c4}@                  @@@    
                                                     ${c4}@                  @@@@   
                                                     ${c4}@                  @@@@@  
                                                     ${c4}@                  @@@@@@ 
                                                     ${c4}@                        @
                                                ${c3}@@@@@@@@@@@@@@@@@@@@@@@@@@@   ${c4}@
${c1} @@@@@@@    @@@@@@ @@@@@@@                      ${c3}@@       @       @@      @@   ${c4}@
${c1}@@     @@  @@      @@    @@   ${c2}@@@@@ @@@  @@  @@ ${c3}@@  @@@  @  @@@@  @  @@@@@@   ${c4}@
${c1}@@     @@  @@      @@@@@@@    ${c2}@   @@  @@ @@  @  ${c3}@@      @@  @@@@  @     @@@   ${c4}@
${c1}@@     @@  @@      @@   @@    ${c2}@   @@  @@  @@@@  ${c3}@@  @@@@@@  @@@@  @  @@@@@@   ${c4}@
${c1} @@@@@@@    @@@@@@ @@    @@   ${c2}@   @@  @@   @@   ${c3}@@  @@@@@@       @@  @@@@@@   ${c4}@
                              ${c2}            @@    ${c3}@@@@@@@@@@@@@@@@@@@@@@@@@@@   ${c4}@
                              ${c2}           @@          ${c4}@                        @
                                                     ${c4}@                        @
                                                     ${c4}@                        @
                                                     ${c4}@                        @
                                                     ${c4}@                        @
                                                     ${c4}@@@@@@@@@@@@@@@@@@@@@@@@@@
'@
} else {
    if (Test-Path $neofetchtext) {
        $neofetchtext = Get-Content -Raw $neofetchtext
    } else {
        Write-Host "neofetchtext file path does not exit, exiting"
        Exit
    }
}

};Set-WSL2Items


#you can add as many as you want, follow template
function Set-WSL2ExtraItems {
    [array]$Script:ExtraCommands           = ("-d $WSLDistributionName apk add bash",
                                              "-d $WSLDistributionName ln -s /app/.venv/bin/ocrmypdf /usr/local/bin/ocrmypdf"
    )
}

#don't touch below unless you know what you are doing
function Invoke-RequirementChecks {
    if (!Test-Path $gzip) {
        Write-Host "gzip.exe path does not exist, exiting ..."
        Exit
    }
    if (!Test-Path $tar) {
        Write-Host "tar.exe path does not exist, exiting ..."
        Exit
    }
    if (!Test-Path $curl) {
        Write-Host "curl.exe path does not exist, exiting ..."
        Exit
    }
    if (get-command docker) {
        Write-Host ""
    } else {
        Write-Host "Docker not install and/or running, exiting ..."
        Exit
    }
};Invoke-RequirementChecks



function Set-Alpine {
    [string]$Script:neofetchPath           = "./usr/bin/neofetch"
    [string]$Script:neofetchDELPath        = "./usr"

    [string]$Script:PromptTextBasePathWin  = "etc\profile.d"
    [string]$Script:PromptTextPathWin      = "etc\profile.d\prompt.txt"
    [string]$Script:PromptTextPathUnix     = "etc/profile.d/prompt.txt"

    [string]$Script:promptFilePathWin      = "etc\profile.d\prompt.sh"
    [string]$Script:promptFilePathUnix     = "./etc/profile.d/prompt.sh"
    [string]$Script:prompPathDel           = "./etc"
    [string]$Script:prompttext             = @"
export PS1=`"\[\033[01;32m\]$WSLDistributionName\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ `"                  
/usr/bin/neofetch --ascii_colors $AsciiColors --ascii /etc/profile.d/prompt.txt
"@
}


function Set-DebianUbuntu {
    [string]$Script:neofetchPath           = "./usr/games/neofetch"
    [string]$Script:neofetchDELPath        = "./usr"

    [string]$Script:PromptTextBasePathWin  = "root"
    [string]$Script:PromptTextPathWin      = "root\prompt.txt"
    [string]$Script:PromptTextPathUnix     = "root/prompt.txt"

    [string]$Script:promptFilePathWin      = "root"
    [string]$Script:promptFilePathUnix     = "./root/.bashrc"
    [string]$Script:prompPathDel           = "./root"
    [string]$Script:prompttext             = @"
export PS1=`"\[\033[01;32m\]$WSLDistributionName\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ `"                  
/usr/games/neofetch --ascii_colors $AsciiColors --ascii /root/prompt.txt
"@ 
}

if ($LinuxDistro -eq "debian") { Set-DebianUbuntu }
if ($LinuxDistro -eq "alpine") { Set-Alpine }

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

#move distro to final folder
[string]$BaseDirectory = $env:LOCALAPPDATA
$distribution_dir = "$BaseDirectory\$WSLDistributionName"
$null = New-Item -ItemType Directory -Force -Path $distribution_dir
Move-Item -Path ".\$distro.tar" -Destination "$distribution_dir\rootfs.tar"
Set-Location $distribution_dir

#download and add neofetch
Start-Process -FilePath $curl -ArgumentList "-o $neofetchPath --create-dirs https://raw.githubusercontent.com/dylanaraps/neofetch/master/neofetch" -wait -NoNewWindow
$ArgumentList = "-rf rootfs.tar $neofetchPath --group=0 --owner=0 --mode='0755'"
Start-Process -FilePath $tar -ArgumentList $ArgumentList -wait -NoNewWindow
Remove-Item $neofetchDELPath -Recurse -Force

if ($LinuxDistro -eq "debian") { 
    #add neofetch splash text
    $null = New-Item -ItemType Directory -Force -Path $PromptTextBasePathWin
    $neofetchtext | out-file $PromptTextPathWin 
    ((Get-Content $PromptTextPathWin) -join "`n") + "`n" | Set-Content -NoNewline $PromptTextPathWin
    Start-Process -FilePath $tar -ArgumentList "-rf rootfs.tar ./$PromptTextPathUnix --group=0 --owner=0 --mode='0644'" -wait -NoNewWindow

    #update prompt
    $prompttext | out-file -Encoding utf8 "root\.bashrcTEMP"
    ((Get-Content "root\.bashrcTEMP") -join "`n") + "`n" | Set-Content -NoNewline "root\.bashrcTEMP"

    Start-Process -FilePath $tar -ArgumentList "--extract --file=rootfs.tar root/.bashrc" -wait -NoNewWindow
    Get-Content "root\.bashrc", "root\.bashrcTEMP" | Set-Content "root\.bashrc2" ; move-item -path "root\.bashrc2" -dest "root\.bashrc" -force
    ((Get-Content "root\.bashrc") -join "`n") + "`n" | Set-Content -NoNewline "root\.bashrc"
    Start-Process -FilePath $tar -ArgumentList "-rf rootfs.tar $promptFilePathUnix" -wait -NoNewWindow
    remove-item -Recurse -Path ".\$promptFilePathWin" -Force 
}

if ($LinuxDistro -eq "alpine") { 
    #add neofetch splash text
    $null = New-Item -ItemType Directory -Force -Path $PromptTextBasePathWin
    $neofetchtext | out-file $PromptTextPathWin 
    ((Get-Content $PromptTextPathWin ) -join "`n") + "`n" | Set-Content -NoNewline $PromptTextPathWin 
    $ArgumentList = "-rf rootfs.tar ./$PromptTextPathUnix --group=0 --owner=0 --mode='0644'"
    Start-Process -FilePath $tar -ArgumentList $ArgumentList -wait -NoNewWindow


    #update prompt
    $prompttext | out-file -Encoding utf8 $promptFilePathWin
    ((Get-Content $promptFilePathWin) -join "`n") + "`n" | Set-Content -NoNewline $promptFilePathWin
    $ArgumentList = "-uf rootfs.tar $promptFilePathUnix --group=0 --owner=0 --mode='0777'"
    Start-Process -FilePath $tar -ArgumentList $ArgumentList -wait -NoNewWindow
    Remove-Item $prompPathDel -Recurse -Force
}


#compress Tar to Tar.GZ
Start-Process -FilePath $gzip -ArgumentList "-v -9 rootfs.tar" -wait -NoNewWindow

#install WSL
$rootfs_file = Get-ChildItem "rootfs.tar.gz"
Start-Process -FilePath $wslPath -ArgumentList "--import $WSLDistributionName $distribution_dir $rootfs_file" -Wait -NoNewWindow
Start-Process -FilePath $wslPath -ArgumentList "--set-version $WSLDistributionName 2" -NoNewWindow -Wait 
#optional commands
if ($RunExtras) { 
    Set-WSL2ExtraItems
    foreach ($item in $ExtraCommands) {
        Start-Process -FilePath $wslPath -ArgumentList $item -NoNewWindow -Wait
    }
}
