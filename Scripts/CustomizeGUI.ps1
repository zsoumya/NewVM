. $PSScriptRoot\Utils\OSUtils.ps1
. $PSScriptRoot\Utils\Utils.ps1

function Main {
    "`nDisabling Internet Explorer Enhanced Security Configuration (ESC)"
    Disable-InternetExplorerESC
    if ($?) {
        "Successfully disabled Internet Explorer ESC"
    }
    else {
        "There was an error disabling Internet Explorer ESC"
    }

    Start-Sleep -Seconds 1

    "`nRemoving Volume Control icon from System Tray"
    Set-VolumeSysTrayIcon -off
    if ($?) {
        "Successfully removed Volume Control icon from System Tray"
    }
    else {
        "There was an error removing Volume Control icon from System Tray"
    }

    Start-Sleep -Seconds 1

    "`nHiding Recycle Bin from Desktop"
    Hide-RecycleBin
    if ($?) {
        "Successfully hidden Recycle Bin from Desktop"
    }
    else {
        "There was an error hiding Recycle Bin from Desktop"
    }

    Start-Sleep -Seconds 1
    
    "`nDisabling Game Bar tips"
    Disable-GameBarTips | Out-Null
    if ($?) {
        "Successfully disabled Game Bar tips"    
    }
    else {
        "There was an error disabling Game Bar tips"
    }

    Start-Sleep -Seconds 1

    "`nSetting task bar properties (Locked, Size: Small, Dock: Bottom, Combine: Always)"
    Set-TaskbarOptions -Lock -Size Small -Dock Bottom -Combine Always
    if ($?) {
        "Successfully set task bar properties"
    }
    else {
        "There was an error setting task bar properties"
    }

    Start-Sleep -Seconds 1

    "`nSetting Explorer properties (ShowFileExtension, ExpandToOpenFolder)"
    Set-WindowsExplorerOptions -EnableShowFileExtensions -EnableExpandToOpenFolder
    if ($?) {
        "Successfully set Explorer properties"
    }
    else {
        "There was an error setting Explorer properties"
    }

    Start-Sleep -Seconds 1

    "`nSetting desktop icon size to `"small`""
    Set-DesktopIconSize -iconSize 32
    if ($?) {
        "Successfully set desktop icon size"
    }
    else {
        "There was an error setting desktop icon size"
    }

    Start-Sleep -Seconds 1

    "`nSetting cursor to Black Extra Large"
    Set-BlackExtraLargeCursor
    if ($?) {
        "Successfully set cursor to Black Extra Large"
    }
    else {
        "There was an error setting cursor to Black Extra Large"
    }

    Start-Sleep -Seconds 1

    "`nConfiguring Explorer to open in `"This PC`" view"
    Set-OpenExplorerInThisPCMode
    if ($?) {
        "Successfully configured Explorer to open in `"This PC`" view"
    }
    else {
        "There was an error configuring Explorer to open in `"This PC`" view"
    }

    Start-Sleep -Seconds 1

    "`nTurning on quiet hours"
    Set-QuietHours -on
    if ($?) {
        "Successfully turned on quiet hours"
    }
    else {
        "There was an error turning on quiet hours"
    }

    Start-Sleep -Seconds 1

    "`nConfiguring Control Panel to open in `"Small Icon`" view"
    Set-ControlPanelSmallIconView
    New-Item -Path $controlPanelPath -Force -ErrorAction SilentlyContinue | Out-Null
    if ($?) {
        "Successfully configured Control Panel to open in `"Small Icon`" view"
    }
    else {
        "There was an error configuring Control Panel to open in `"Small Icon`" view"
    }

    Start-Sleep -Seconds 1

    "`nConfiguring UI extended colors"
    Set-UIExtendedColors
    if ($?) {
        "Successfully configured UI extended colors"
    }
    else {
        "There was an error configuring UI extended colors"
    }

    Start-Sleep -Seconds 1

    "`nRemoving Task View button from task bar"
    Set-TaskViewButton -off
    if ($?) {
        "Successfully removed Task View button from task bar"
    }
    else {
        "There was an error removing Task View button from task bar"
    }

    Start-Sleep -Seconds 1

    "`nSetting preferred folders on start menu"
    Set-PreferredStartMenuFolders
    if ($?) {
        "Successfully set preferred folders on start menu"
    }
    else {
        "There was an error setting preferred folders on start menu"
    }

    Start-Sleep -Seconds 1

    if ((Get-OSName).StartsWith("Microsoft Windows 10")) {
        "`nRemoving Cortana from taskbar"
        Set-CortanaTakbarButton -off
        if ($?) {
            "Successfully removed Cortana from taskbar"
        }
        else {
            "There was an error removing Cortana from taskbar"
        }

        Start-Sleep -Seconds 1

        "`nRemoving People button from taskbar"
        Set-PeopleTaskbarButton -off
        if ($?) {
            "Successfully removed People button from taskbar"
        }
        else {
            "There was an error removing People button from taskbar"
        }

        Start-Sleep -Seconds 1

        "`nDisabling OneDrive"
        Disable-OneDrive
        if ($?) {
            "Successfully disabled OneDrive (pending restart)"
        }
        else {
            "There was an error disabling OneDrive"
        }
		
		Start-Sleep -Seconds 1
		
		"`Turning off consumer features"
		Remove-ConsumerFeatures
        if ($?) {
			"Successfully turned off consumer features"
        }
        else {
			"There was an error turning off consumer features"
        }		
    }

    New-Item -ItemType Directory -Path "C:\WP" -Force -ErrorAction SilentlyContinue | Out-Null
    Copy-Item -Path "Z:\HostShare\NewVM\Resources\Wallpaper.jpg" -Destination "C:\WP\" -Force -ErrorAction SilentlyContinue

    "`nChanging wallpaper"
    Set-WallPaper -path "C:\WP\Wallpaper.jpg" -style Fill
    if ($?) {
        "Successfully changed wallpaper (pending restart)"
    }
    else {
        "There was an error changing wallpaper"
    }
	
	Start-Sleep -Seconds 1
	
	"`nTurning off Shutdown Event Tracker"
	Set-ShutdownEventTracker -off
    if ($?) {
		"Successfully turned off Shutdown Event Tracker"
    }
    else {
		"There was an error turning off Shutdown Event Tracker"
    }
	
    # Start-Sleep -Seconds 1

    # "`nTurning on show file extensions"
    # Set-FileExtensions -on
    # if ($?) {
    #     "Successfully turned on show file extensions"
    # }
    # else {
    #     "There was an error turning on show file extensions"
    # }

    # Start-Sleep -Seconds 1

    # "`nConfiguring PowerShell instead of Command Prompt on Win+X"
    # Set-UsePowershellOnWinX -on
    # if ($?) {
    #     "Successfully configured PowerShell instead of Command Prompt on Win+X"
    # }
    # else {
    #     "There was an error configuring PowerShell instead of Command Prompt on Win+X"
    # }
}

Main

"Press a key to restart Windows [Esc to cancel]"
$r = Invoke-PauseWithEscape

if ($r) {
    Restart-Computer
}
