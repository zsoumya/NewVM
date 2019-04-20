. $PSScriptRoot\Utils\OSUtils.ps1
. $PSScriptRoot\Utils\Utils.ps1

function Main {
    param (
        [Parameter(Mandatory=$true)]
        [string] $hostName, 
        
        [Parameter(Mandatory=$true)]
        [AllowEmptyString()]
        [AllowNull()]
        [string] $workGroupName
    )
	
	try {
		Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine
	}
	catch {
	}
	
    "`nRenaming VM to `"$hostName`""
    Rename-Computer -ComputerName . -NewName $hostName
    if ($?) {
        "Successfully renamed VM (pending restart)"
    } 
    else {
        "There was an error renaming VM"
    }

    if ($workGroupName) {
        "`nAdding VM to workgroup `"$workGroupName`""
        Add-ComputerToWorkGroup -workGroupName $workGroupName
        if ($?) {
            "Successfully added VM to workgroup (pending restart)"
        }
        else {
            "There was an error adding VM to workgroup"
        }
    }
    else {
        "No workgroup name specified: Skipping workgroup configuration"
    }

    "`nDisabling User Account Control"
    Disable-UAC
    if ($?) {
        "Successfully disabled User Account Control (pending restart)"
    }
    else {
        "There was an error disabling User Account Control"
    }

    "`nConfiguring VM to respond to Ping"
    netsh advfirewall firewall add rule name="ICMP Allow incoming V4 echo request" protocol=icmpv4:8,any dir=in action=allow | Out-Null
    if ($?) {
        "Successfully configured VM to repspond to Ping"
    }
    else {
        "There was an error configuring VM to repspond to Ping"
    }

    if (-not ((Get-OSName).StartsWith("Microsoft Windows 10"))) {
        "`nEnabling Server Manager remote management"
        Configure-SMremoting.exe -enable | Out-Null
        if ($?) {
            "Successfully enabled Server Manager remote management"
        }
        else {
            "There was an error enabling Server Manager remote management"
        }
    }

    "`nSetting Windows Update to Automatic"
    cscript $env:WinDir\System32\Scregedit.wsf /AU 4 | Out-Null
    if ($?) {
        "Successfully set Windows Update to Automatic"
    }
    else {
        "There was an error setting Windows Update to Automatic"
    }

    "`nTurning on updates for other Microsoft products"
    Set-UpdateOtherMSProducts -on
    if ($?) {
        "Successfully turned on updates for other Microsoft products"
    }
    else {
        "There was an error turning on updates for other Microsoft products"
    }

    "`nRestarting Windows Update service"
    Restart-Service -Name wuauserv
    if ($?) {
        "Successfully restarted Windows Update service"
    }
    else {
        "There was an error restarting Windows Update service"
    }

    "`nEnabling Remote Desktop"
    cscript $env:WinDir\System32\Scregedit.wsf /AR 0 | Out-Null
    if ($?) {
        "Successfully enabled Remote Desktop"
    }
    else {
        "There was an error enabling Remote Desktop"
    }

    "`nEnabling Network Level Authentication for Remote Desktop"
    cscript $env:WinDir\System32\Scregedit.wsf /CS 1 | Out-Null
    if ($?) {
        "Successfully enabled Network Level Authentication for Remote Desktop"
    }
    else {
        "There was an error enabling Network Level Authentication for Remote Desktop"
    }

    "`nSetting Telemetry settings to Security"
    Set-Telemetry -telemetryValue 0
    if ($?) {
        "Successfully set Telemetry settings to Security"
    }
    else {
        "There was an error setting Telemetry settings to Security"
    }
    
    "`nConfiguring date and time formats"
    Set-DateTimeFormats -shortDateFormat "MM/dd/yyyy" -timeFormat "HH:mm:ss" -shortTimeFormat "HH:mm"
    if ($?) {
        "Successfully configured date and time formats"
    }
    else {
        "There was an error configuring date and time formats"
    }

    "`nDeleting unneeded scheduled tasks"
    Remove-UnnecessaryScheduledTasks
    if ($?) {
        "Successfully deleted unneeded scheduled tasks"
    }
    else {
        "There was an error deleting unneeded scheduled tasks"
    }

    if ((Get-OSName).StartsWith("Microsoft Windows 10")) {
        "`nChanging power plan to `"High Performance`""
        powercfg /s 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
        if ($?) {
            "Successfully changed power plan to `"High Performance`""
        }
        else {
            "There was an error changing power plan to `"High Performance`""
        }
    }

    "`nCreating C:\Links folder"
    New-Item -ItemType Directory -Force -Path "C:\Links" | Out-Null
    if ($?) {
        "Successfully created C:\Links folder"
    }
    else {
        "There was an error creating C:\Links folder"
    }

    "`nCreating C:\Utils folder with contents"
    xcopy Z:\HostShare\NewVM\Resources\Utils C:\Utils /s /e /i /y
    if ($?) {
        "Successfully created C:\Utils folder with contents"
    }
    else {
        "There was an error creating C:\Utils folder with contents"
    }

    "`nAdding necessary folders to the PATH"
    setx /m PATH "$($env:PATH);C:\Utils;C:\Links" | Out-Null
    if ($?) {
        "Successfully added necessary folders to the PATH"
    }
    else {
        "There was an error adding necessary folders to the PATH"
    }

    # Backup existing profile.ps1 (if exists) before overwriting
    Rename-Item -Path $env:UserProfile\Documents\WindowsPowerShell\profile.ps1 `
        -NewName profile.ps1.bak -Force -ErrorAction SilentlyContinue
    
    "`nCreating PowerShell profile"
    xcopy z:\HostShare\NewVM\Resources\WindowsPowerShell $env:UserProfile\Documents\WindowsPowerShell /s /e /i /y
    if ($?) {
        "Successfully created PowerShell profile"
    }
    else {
        "There was an error creating PowerShell profile"
    }

    "`nDisplaying Date/Time settings Control Panel applet"
    Start-Process -FilePath "control" -ArgumentList "timedate.cpl" -Wait
    "Done"
}

Main

"`nPress a key to restart Windows [Esc to cancel]"
$r = Invoke-PauseWithEscape

if ($r) {
    Restart-Computer
}
