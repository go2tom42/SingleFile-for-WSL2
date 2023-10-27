function remove-it {
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
    
     &$wslPath --unregister $DistributionName
     Start-Sleep -Seconds 5
     remove-item -Recurse -Path $distribution_dir
    
    
}; remove-it
