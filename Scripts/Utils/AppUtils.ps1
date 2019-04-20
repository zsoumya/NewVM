. $PSScriptRoot\OSUtils.ps1

function Install-OORegEditor {
    $localFile = "C:\Apps\OORegEditor\ooregeditor.zip"
    $remoteFile = "https://dl5.oo-software.com/files/ooregeditor12/120/ooregeditor.zip"
    
    $localFolder = Split-Path -Path $localFile
    
    New-Item -ItemType Directory -Force -Path $localFolder | Out-Null
    Invoke-WebRequest -Uri $remoteFile -OutFile $localFile
    
    & 7z x "$localFile" "-o$localFolder"
    
    Remove-Item -Path $localFile
}

function Install-Chocolatey {
    Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
    Invoke-Expression -Command ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

    refreshenv

    choco feature enable -n allowGlobalConfirmation
}

function Install-CommonChocoApps {
    $commonApps = @(
        "7zip.install", "Boxstarter", "carbon", "ccleaner", `
        "everything", "notepad3.install", "notepadplusplus.install", `
        "opera", "processhacker.install", "rapidee", "sysinternals"
    )
    $guiApps    = @("ConEmu")
    $coreApps   = @("explorerplusplus")

    if (Test-CoreOS) {
        $allApps = $commonApps + $coreApps
    }
    else {
        $allApps = $commonApps + $guiApps
    }

    choco install "$([string]::Join(";", $allApps))"
}

function Add-Links {
    param (
        [string] $linkPath,
        [hashtable] $appLinks
    )

    $appLinks.Keys | Where-Object -FilterScript {
        Test-Path -Path $appLinks[$_] -PathType Leaf
    } | ForEach-Object -Process {
        $link = Join-Path -Path $linkPath -ChildPath (Split-Path -Path $_ -Leaf)
        $target = $appLinks[$_]

        C:\ProgramData\chocolatey\tools\shimgen -o="$link" -p="$target" -i="$target"
    }
}

function Set-PrefferedNPPSettings {
	Get-Process -Name "notepad++" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
	
	$settingsPath = "$env:APPDATA\Notepad++\"
	Copy-Item -Path "Z:\HostShare\NewVM\Resources\Settings\Notepad++\*.*" -Destination $settingsPath -Force
}
