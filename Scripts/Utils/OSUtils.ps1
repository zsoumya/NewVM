function Test-CoreOS {
    $regKey = "HKLM:/Software/Microsoft/Windows NT/CurrentVersion"
    return (Get-ItemProperty -Path $regKey).InstallationType -eq "Server Core"
}

function Get-OSName {
    return (Get-WmiObject win32_operatingsystem).Caption.Trim()
}

function Restart-Explorer {
	Stop-Process -Name "explorer" -Force -ErrorAction SilentlyContinue
}

function Disable-UAC {
    $uacPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
    New-ItemProperty -Path $uacPath -Name "EnableLUA" -PropertyType "DWORD" -Value 0 -Force | Out-Null
}

function Set-Telemetry {
    param (
        [int] $telemetryValue
    )

    $telemetryPath = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\DataCollection"
    New-ItemProperty -Path $telemetryPath -Name "AllowTelemetry" -PropertyType "DWORD" `
        -Value $telemetryValue -Force | Out-Null
}

function Set-DateTimeFormats {
    param (
        [string] $shortDateFormat,
        [string] $timeFormat,
        [string] $shortTimeFormat
    )

    $regionalSettingsPath = "HKCU:\Control Panel\International"

    New-ItemProperty -Path $regionalSettingsPath -Name "sShortDate" `
        -PropertyType "String" -Value $shortDateFormat -Force | Out-Null
    New-ItemProperty -Path $regionalSettingsPath -Name "sTimeFormat" `
        -PropertyType "String" -Value $timeFormat -Force | Out-Null
    New-ItemProperty -Path $regionalSettingsPath -Name "sShortTime" `
        -PropertyType "String" -Value $shortTimeFormat -Force | Out-Null
}

function Remove-UnnecessaryScheduledTasks {
    $tasksPath = "\Microsoft\XblGameSave\"

    $ErrorActionPreference = "Stop"

    @("XblGameSaveTask", "XblGameSaveTaskLogon") | `
        Where-Object -FilterScript {
            (Get-ScheduledTask -TaskName $_ -ErrorAction SilentlyContinue) -ne $null
        } | `
        ForEach-Object -Process {
            Stop-ScheduledTask -TaskName $_ -TaskPath $tasksPath | Out-Null
            Disable-ScheduledTask -TaskName $_ -TaskPath $tasksPath | Out-Null
            Unregister-ScheduledTask -TaskName $_ -TaskPath $tasksPath -Confirm:$false | Out-Null
        }
    
    $schedService = New-Object -ComObject Schedule.Service
    $schedService.Connect()
    $rootFolder = $schedService.GetFolder("\")
    $rootFolder.DeleteFolder("Microsoft\XblGameSave", $null)
}

enum WallPaperStyle {
    Fill
    Fit
    Stretch
    Tile
    Center
    Span
}

function Set-WallPaper {
    # Fill    : WPS = 10; TWP: 0
    # Fit     : WPS =  6; TWP: 0
    # Stretch : WPS =  2; TWP: 0 
    # Tile    : WPS =  0; TWP: 1
    # Center  : WPS =  0; TWP: 0
    # Span    : WPS = 22; TWP: 0

    param (
        [string] $path,
        [WallPaperStyle] $style
    )

    switch ($style) {
        "Fill" {
            $wallPaperStyle = "10"
            $tileWallPaper = "0"
        }

        "Fit" {
            $wallPaperStyle = "6"
            $tileWallPaper = "0"
        }
 
        "Stretch" {
            $wallPaperStyle = "2"
            $tileWallPaper = "0"
        }
  
        "Tile" {
            $wallPaperStyle = "0"
            $tileWallPaper = "1"
        }
  
        "Center" {
            $wallPaperStyle = "0"
            $tileWallPaper = "0"
        }
  
        "Center" {
            $wallPaperStyle = "22"
            $tileWallPaper = "0"
        }
      
        default {
            $wallPaperStyle = "10"
            $tileWallPaper = "0"
        }
    }

    $wallPaperRegPath = "HKCU:\Control Panel\Desktop"

    New-ItemProperty -Path $wallPaperRegPath -Name "WallPaper" -PropertyType "String" -Value $path -Force | Out-Null
    New-ItemProperty -Path $wallPaperRegPath -Name "WallpaperStyle" -PropertyType "String" -Value $wallPaperStyle -Force | Out-Null
    New-ItemProperty -Path $wallPaperRegPath -Name "TileWallpaper" -PropertyType "String" -Value $tileWallPaper -Force | Out-Null

    rundll32 user32.dll, UpdatePerUserSystemParameters
}

function Set-FileExtensions {
    param (
        [Parameter(ParameterSetName="on")]
        [switch] $on,
        [Parameter(ParameterSetName="off")]
        [switch] $off
    )

    if ($on) {
        $flag = 0
    }

    if ($off) {
        $flag = 1
    }

    New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" `
        -PropertyType "DWORD" -Value $flag -Force | Out-Null
	
	Restart-Explorer
}

function Set-UsePowershellOnWinX {
    param (
        [Parameter(ParameterSetName="on")]
        [switch] $on,
        [Parameter(ParameterSetName="off")]
        [switch] $off
    )

    if ($on) {
        $flag = 0
    }

    if ($off) {
        $flag = 1
    }

    New-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "DontUsePowerShellOnWinX" `
        -PropertyType "DWORD" -Value $flag -Force | Out-Null
	
	Restart-Explorer
}

function Set-UIExtendedColors {
    $themesPath1 = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize"
    $themesPath2 = "HKCU:\SOFTWARE\Microsoft\Windows\DWM"

    New-ItemProperty -Path $themesPath1 -Name "EnableTransparency" -PropertyType "DWORD" -Value 1 -Force | Out-Null
    New-ItemProperty -Path $themesPath1 -Name "ColorPrevalence" -PropertyType "DWORD" -Value 1 -Force | Out-Null
    New-ItemProperty -Path $themesPath2 -Name "ColorPrevalence" -PropertyType "DWORD" -Value 1 -Force | Out-Null
    New-ItemProperty -Path $themesPath1 -Name "AppsUseLightTheme" -PropertyType "DWORD" -Value 0 -Force | Out-Null
	
	Restart-Explorer
}

function Set-ControlPanelSmallIconView {
    $controlPanelPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel"
    $valueNames = @("AllItemsIconView", "StartupPage")

    New-Item -Path $controlPanelPath -Force -ErrorAction Stop | Out-Null

    $valueNames | ForEach-Object -Process {
        New-ItemProperty -Path $controlPanelPath -Name $_ -PropertyType "DWORD" -Value 1 -Force | Out-Null
    }
	
	Restart-Explorer
}

function Set-QuietHours {
    param (
        [Parameter(ParameterSetName="on")]
        [switch] $on,
        [Parameter(ParameterSetName="off")]
        [switch] $off
    )

    if ($on) {
        $flag = 0
    }

    if ($off) {
        $flag = 1
    }

    $path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Notifications\Settings"
    $valueName = "NOC_GLOBAL_SETTING_TOASTS_ENABLED"

    New-Item -Path $path -Force -ErrorAction Stop | Out-Null
    New-ItemProperty -Path $path -Name $valueName -PropertyType "DWORD" -Value $flag -Force | Out-Null
	
	Restart-Explorer
}

function Set-OpenExplorerInThisPCMode {
    New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "LaunchTo" `
        -Value 1 -PropertyType "DWORD" -Force | Out-Null
	
	Restart-Explorer
}

function Hide-RecycleBin {
    param (
        [switch] $show
    )

    $hide = if ($show) { 0 } else { 1 }

    $recycleBinPaths = @(
        "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu",
        "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel"
    )
    $recycleBinValueName = "{645FF040-5081-101B-9F08-00AA002F954E}"

    $recycleBinPaths | ForEach-Object -Process {
        New-Item -Path $_ -Force | Out-Null
        New-ItemProperty -Path $_ -Name $recycleBinValueName -PropertyType "DWORD" -Value $hide -Force | Out-Null
    }
	
	Restart-Explorer
}

function Set-DesktopIconSize {
    param (
        [int] $iconSize
    )

    if (Test-Path -Path "HKCU:\Software\Microsoft\Windows\Shell\Bags\1\Desktop" -ErrorAction Stop)
    {
        Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\Shell\Bags\1\Desktop -Name IconSize -Value $iconSize
    }
    elseif (Test-Path -Path "HKCU:\Control Panel\Desktop\WindowMetrics" -ErrorAction Stop)
    {
        Set-ItemProperty -Path "HKCU:\Control Panel\Desktop\WindowMetrics" -Name "Shell Icon Size" -Value $IconSize
    }
	
	Restart-Explorer
}

function Set-VolumeSysTrayIcon {
    param (
        [Parameter(ParameterSetName="on")]
        [switch] $on,
        [Parameter(ParameterSetName="off")]
        [switch] $off
    )

    if ($on) {
        $flag = 0
    }

    if ($off) {
        $flag = 1
    }

    $ErrorActionPreference = "Stop"

    $path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer"

    New-Item -Path $path -Force | Out-Null
    New-ItemProperty -Path $path -Name "HideSCAVolume" -PropertyType "DWORD" -Value $flag -Force | Out-Null
	
	Restart-Explorer
}

function New-LocalAdmin {
    param (
        [Parameter(Mandatory=$true)]
        [string]       $userName,

        [Parameter(Mandatory=$true)]
        [string]       $fullName,

        [Parameter(Mandatory=$true)]
        [securestring] $password
    )

    $ErrorActionPreference = "Stop"

    New-LocalUser -AccountNeverExpires -Description $fullName -FullName $fullName `
        -Name $userName -Password $password -PasswordNeverExpires | Out-Null

    Add-LocalGroupMember -Group "Administrators" -Member $userName
}

function Set-StaticIP {
    param (
        [Parameter(Mandatory=$true)]
        [string]   $adapterName,

        [Parameter(Mandatory=$true)]
        [string]   $ipAddress,
        
        [Parameter(Mandatory=$true)]
        [string]   $defaultGateway,
        
        [Parameter(Mandatory=$true)]
        [string[]] $dnsServers
    )

    $ErrorActionPreference = "Stop"

    Remove-NetRoute -DestinationPrefix "0.0.0.0/0" -InterfaceAlias $adapterName -AddressFamily IPv4 -Confirm:$false

    Remove-NetIPAddress -InterfaceAlias $adapterName -AddressFamily IPv4 -Confirm:$false

    New-NetIPAddress -IPAddress $ipAddress -InterfaceAlias $adapterName `
        -DefaultGateway $defaultGateway -AddressFamily "IPv4" -PrefixLength 24 | Out-Null

    Set-DnsClientServerAddress -InterfaceAlias $adapterName -ServerAddresses $dnsServers
}

function Set-UpdateOtherMSProducts {
    param (
        [Parameter(ParameterSetName="on")]
        [switch] $on,
        [Parameter(ParameterSetName="off")]
        [switch] $off
    )

    $ErrorActionPreference = "Stop"

    $serviceManager = New-Object -ComObject "Microsoft.Update.ServiceManager"

    if ($on) {
        $serviceManager.ClientApplicationID = "WindowsUpdate"
        $null = $serviceManager.AddService2("7971f918-a847-4430-9279-4a52d1efe18d", 7, "")
        # $newService = $serviceManager.AddService2("7971f918-a847-4430-9279-4a52d1efe18d", 7, "")
        # $newService.IsPendingRegistrationWithAU # True -> Reboot Required 
    }

    if ($off) {
        $serviceManager.RemoveService("7971f918-a847-4430-9279-4a52d1efe18d")
    }
}

function Set-LaunchServerManagerAtLogon {
    param (
        [Parameter(ParameterSetName="on")]
        [switch] $on,
        [Parameter(ParameterSetName="off")]
        [switch] $off
    )

    if ($on) {
        $flag = 0
    }

    if ($off) {
        $flag = 1
    }

    New-ItemProperty -Path "HKCU:\Software\Microsoft\ServerManager" `
        -Name "DoNotOpenServerManagerAtLogon" -PropertyType "DWORD" -Value $flag -Force | Out-Null
}

function Add-ComputerToWorkGroup {
    param (
        [Parameter(Mandatory=$true)]
        [string]   $workGroupName        
    )

    $computer = Get-WmiObject -Class Win32_ComputerSystem
    if (-not ($computer.PartOfDomain) -and $computer.Workgroup -ne $workGroupName) {
        Add-Computer -WorkGroupName $workGroupName
    }
}

function Add-ComputerToDomain {
    param (
        [Parameter(Mandatory=$true)]
        [string] $domainName,

        [Parameter(Mandatory=$true)]
        [string] $domainAdmin,

        [Parameter(Mandatory=$true)]
        [string] $dnsIpAddress,

        [Parameter(Mandatory=$true)]
        [string] $netAdapterName,
        
        [Parameter(Mandatory=$true)]
        [AllowEmptyString()]
        [AllowNull()]
        [string] $newMachineName
    )

    $ErrorActionPreference = "Stop"

    Set-DnsClientServerAddress -InterfaceAlias $netAdapterName -ServerAddresses $dnsIpAddress

    if (-not ((Get-OSName).StartsWith("Microsoft Windows 10"))) {
        Install-WindowsFeature -Name RSAT-AD-PowerShell
	}
	
	if (-not ($domainAdmin -match "^.+\\.+$")) {
		
	}
	
	if ($newMachineName) {
        Add-Computer -DomainName $domainName -NewName $newMachineName -Credential $domainAdmin -Restart -Force
    }
    else {
        Add-Computer -DomainName $domainName -Credential $domainAdmin -Restart -Force
    }
}

function New-ADLocalAdmin {
    param (
        [Parameter(Mandatory=$true)]
        [AllowEmptyString()]
        [AllowNull()]
        [string]       $domainName,

        [Parameter(Mandatory=$true)]
        [string]       $userName,

        [Parameter(Mandatory=$true)]
        [string]       $displayName,

        [Parameter(Mandatory=$true)]
        [securestring] $password
    )
	
	$ErrorActionPreference = "Stop"

    if (-not $domainName) {
        $computer = Get-WmiObject -Class Win32_ComputerSystem
        if ($computer.PartOfDomain) {
            $domainName = $computer.Domain
        }
        else {
            Write-Error -Message "Domain name not specificied and cannot be inferred"
            return
        }
	}
	
	$domainNetBiosName = (Get-ADDomain -Identity $computer.Domain).NetBIOSName
	
	try {
		$user = Get-ADUser -Identity $userName -ErrorAction SilentlyContinue
	}
	catch {
		$user = $null
	}
	
	if ($user -eq $null) {
		New-ADUser -AccountPassword $password -Description $displayName -DisplayName $displayName -GivenName $displayName `
				   -Name $userName -PasswordNeverExpires $true -SamAccountName $userName -UserPrincipalName "$userName@$domainName" `
				   -Enabled $true
	}
	else {
		Write-Warning -Message "Skipping domain user creation because user already exists"	
	}
	
	$localPrincipal = Get-LocalGroupMember -Group "Administrators" -Member "$domainNetBiosName\$userName" -ErrorAction SilentlyContinue
	if ($localPrincipal -eq $null) {
		Add-LocalGroupMember -Group "Administrators" -Member $userName
	}
	else {
		Write-Warning -Message "Domain user already member of local Administators group"
	}
}

function Set-BlackExtraLargeCursor {
    $cursors = @{
        "(Default)" = @("Windows Black (extra large)", "String");
        # "ContactVisualization" = @(0x00000001, "DWord");
        # "GestureVisualization" = @(0x0000001f, "DWord");
        # "Scheme Source" = @(0x00000002, "DWord");
        "AppStarting" = @("%SystemRoot%\cursors\wait_rl.cur", "ExpandString");
        "Arrow" = @("%SystemRoot%\cursors\arrow_rl.cur", "ExpandString");
        "Hand" = @("", "ExpandString");
        "Help" = @("%SystemRoot%\cursors\help_rl.cur", "ExpandString");
        "No" = @("%SystemRoot%\cursors\no_rl.cur", "ExpandString");
        "NWPen" = @("%SystemRoot%\cursors\pen_rl.cur", "ExpandString");
        "SizeAll" = @("%SystemRoot%\cursors\move_rl.cur", "ExpandString");
        "SizeNESW" = @("%SystemRoot%\cursors\size1_rl.cur", "ExpandString");
        "SizeNS" = @("%SystemRoot%\cursors\size4_rl.cur", "ExpandString");
        "SizeNWSE" = @("%SystemRoot%\cursors\size2_rl.cur", "ExpandString");
        "SizeWE" = @("%SystemRoot%\cursors\size3_rl.cur", "ExpandString");
        "UpArrow" = @("%SystemRoot%\cursors\up_rl.cur", "ExpandString");
        "Wait" = @("%SystemRoot%\cursors\busy_rl.cur", "ExpandString");
        "Crosshair" = @("%SystemRoot%\cursors\cross_rl.cur", "ExpandString");
        "IBeam" = @("%SystemRoot%\cursors\beam_rl.cur", "ExpandString")
    }

    $cursors.Keys | ForEach-Object -Process {
        New-ItemProperty -Path "HKCU:\Control Panel\Cursors" -Name $_ `
            -PropertyType $cursors[$_][1] -Value $cursors[$_][0] -Force | Out-Null
    }

    $methodSig = @"
    [DllImport("user32.dll", EntryPoint = "SystemParametersInfo")]
    public static extern bool SystemParametersInfo(
                     uint uiAction,
                     uint uiParam,
                     uint pvParam,
                     uint fWinIni);
"@

    $cursorRefresh = Add-Type -MemberDefinition $methodSig -Name WinAPICall -Namespace SystemParamInfo -PassThru
    $null = $cursorRefresh::SystemParametersInfo(0x0057, 0, $null, 0)
}

function Set-CortanaTakbarButton {
    param (
        [Parameter(ParameterSetName="full")]
        [switch] $full,
        [Parameter(ParameterSetName="icon")]
        [switch] $icon,
        [Parameter(ParameterSetName="off")]
        [switch] $off
    )

    if ($full) {
        $flag = 2
    }

    if ($icon) {
        $flag = 1
    }

    if ($off) {
        $flag = 0
    }

    $path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search"

    New-ItemProperty -Path $path -Name "SearchboxTaskbarMode" -PropertyType "DWord" -Value $flag -Force | Out-Null
	
	Restart-Explorer
}

function Set-TaskViewButton {
    param (
        [Parameter(ParameterSetName="on")]
        [switch] $on,
        [Parameter(ParameterSetName="off")]
        [switch] $off
    )

    if ($on) {
        $flag = 1
    }

    if ($off) {
        $flag = 0
    }
    
    $path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"

    New-ItemProperty -Path $path -Name "ShowTaskViewButton" -PropertyType "DWord" -Value $flag -Force | Out-Null
	
	Restart-Explorer
}

function Set-PeopleTaskbarButton {
    param (
        [Parameter(ParameterSetName="on")]
        [switch] $on,
        [Parameter(ParameterSetName="off")]
        [switch] $off
    )

    if ($on) {
        $flag = 1
    }

    if ($off) {
        $flag = 0
    }
    
    $ErrorActionPreference = "Stop"

    $path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People"

    New-Item -Path $path -Force | Out-Null
    New-ItemProperty -Path $path -Name "PeopleBand" -PropertyType "DWORD" -Value $flag -Force | Out-Null
	
	Restart-Explorer
}

function Disable-OneDrive {
    $ErrorActionPreference = "Stop"

    $path = "HKLM:\Software\Policies\Microsoft\Windows\OneDrive"

    New-Item -Path $path -Force | Out-Null
    New-ItemProperty -Path $path -Name "DisableFileSyncNGSC" -PropertyType "DWORD" -Value 1 -Force | Out-Null
}

function Set-PreferredStartMenuFolders {
    $path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\CloudStore\Store\Cache\DefaultAccount\`$`$windows.data.unifiedtile.startglobalproperties\Current"
	[byte[]]$data = `
		0x02,0x00,0x00,0x00,0x9b,0xaf,0xc1,0xf1,0xe0,0xaf,0xd3,0x01,0x00,0x00,0x00,0x00,0x43,0x42, `
		0x01,0x00,0xc5,0x28,0xf3,0x04,0xcb,0x32,0x0a,0x06,0x05,0x86,0x91,0xcc,0x93,0x05,0x24,0xaa, `
		0xa3,0x01,0x44,0xc3,0x84,0x01,0x66,0x9f,0xf7,0x9d,0xb1,0x87,0xcb,0xd1,0xac,0xd4,0x01,0x00, `
		0x05,0xbc,0xc9,0xa8,0xa4,0x01,0x24,0x8c,0xac,0x03,0x44,0x89,0x85,0x01,0x66,0xa0,0x81,0xba, `
		0xcb,0xbd,0xd7,0xa8,0xa4,0x82,0x01,0x00,0x05,0xce,0xab,0xd3,0xe9,0x02,0x24,0xda,0xf4,0x03, `
		0x44,0xc3,0x8a,0x01,0x66,0x82,0xe5,0x8b,0xb1,0xae,0xfd,0xfd,0xbb,0x3c,0x00,0x05,0xaf,0xe6, `
		0x9e,0x9b,0x0e,0x24,0xde,0x93,0x02,0x44,0xd5,0x86,0x01,0x66,0xbf,0x9d,0x87,0x9b,0xbf,0x8f, `
		0xc6,0xd4,0x37,0x00,0x05,0xc4,0x82,0xd6,0xf3,0x0f,0x24,0x8d,0x10,0x44,0xae,0x85,0x01,0x66, `
		0x8b,0xb5,0xd3,0xe9,0xfe,0xd2,0xed,0xb1,0x94,0x01,0x00,0x05,0xca,0xe0,0xf6,0xa5,0x07,0x24, `
		0xca,0xf2,0x03,0x44,0xe8,0x9e,0x01,0x66,0x8b,0xad,0x8f,0xc2,0xf9,0xa0,0x87,0xd4,0xbc,0x01, `
		0x00,0xc2,0x3c,0x01,0x00

    New-ItemProperty -Path $path -Name "Data" -PropertyType "Binary" -Value $data -Force | Out-Null
	
	Restart-Explorer
}

function Remove-ConsumerFeatures {
	$values = @(
		"ContentDeliveryAllowed",
		"OemPreInstalledAppsEnabled",
		"PreInstalledAppsEnabled",
		"PreInstalledAppsEverEnabled",
		"SilentInstalledAppsEnabled",
		"SoftLandingEnabled",
		"SubscribedContent-310093Enabled",
		"SubscribedContent-338388Enabled",
		"SubscribedContent-338389Enabled",
		"SubscribedContentEnabled",
		"SystemPaneSuggestionsEnabled"
	)
	
	$path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
	
	$values | ForEach-Object -Process {
		New-ItemProperty -Path $path -Name $_ -PropertyType "DWord" -Value 0 -Force
	}
	
	Remove-Item -Path "$path\Subscriptions" -Recurse -Force
	Remove-Item -Path "$path\SuggestedApps" -Recurse -Force
	
	$path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Cloud Content"
	
	New-Item -Path $path -Force
	New-ItemProperty -Path $path -Name "DisableWindowsConsumerFeatures" -PropertyType "DWord" -Value 1 -Force
	
	Restart-Explorer
}

function Show-RunAsDifferentUserOnStart {
	param (
		[Parameter(ParameterSetName = "on")]
		[switch]$on,
		[Parameter(ParameterSetName = "off")]
		[switch]$off,
		[switch]$logoff
	)
	
	if ($on) {
		$flag = 1
	}
	
	if ($off) {
		$flag = 0
	}
	
	$ErrorActionPreference = "Stop"
	
	$path = "HKCU:\Software\Policies\Microsoft\Windows\Explorer"
	
	New-Item -Path $path -Force | Out-Null
	New-ItemProperty -Path $path -Name "ShowRunAsDifferentUserInStart" -PropertyType "DWord" -Value $flag -Force | Out-Null
	
	if ($logoff) {
		logoff
	}
	else {
		Write-Warning -Message "Settings updated pending logoff"
	}
}

function Set-ShutdownEventTracker {
	param (
		[Parameter(ParameterSetName = "on")]
		[switch]$on,
		[Parameter(ParameterSetName = "off")]
		[switch]$off
	)
	
	if ($on) {
		$flag = 1
	}
	
	if ($off) {
		$flag = 0
	}
	
	$ErrorActionPreference = "Stop"
	
	$path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Reliability"
	$names = @("ShutdownReasonOn", "ShutdownReasonUI")
	
	New-Item -Path $path -Force | Out-Null
	
	$names | ForEach-Object -Process {
		New-ItemProperty -Path $path -Name $_ -PropertyType "DWord" -Value $flag -Force | Out-Null
	}	
}