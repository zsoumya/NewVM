. $PSScriptRoot\Utils\AppUtils.ps1
. $PSScriptRoot\Utils\OSUtils.ps1
. $PSScriptRoot\Utils\Utils.ps1

function Main {
    if (-not (Test-CoreOS)) {
        "`nSetting cursor to Black Extra Large"
        Set-BlackExtraLargeCursor
        if ($?) {
            "Successfully set cursor to Black Extra Large"
        }
        else {
            "There was an error setting cursor to Black Extra Large"
		}
		
		"`nSetting preferred folders on start menu"
		Set-PreferredStartMenuFolders
		if ($?) {
			"Successfully set preferred folders on start menu"
		}
		else {
			"There was an error setting preferred folders on start menu"
		}
		
		if (-not ((Get-OSName).StartsWith("Microsoft Windows 10"))) {
            "`nTurning off auto-launch of Server Manager during logon"
            Set-LaunchServerManagerAtLogon -off
            if ($?) {
                "Successfully turned off auto-launch of Server Manager during logon"
            }
            else {
                "There was an error turning off auto-launch of Server Manager during logon ($($error[0].Exception.Message))"
            }
        }
	}
	
	"`nConfiguring preffered Notepad++ settings"
	Set-PrefferedNPPSettings
    if ($?) {
		"Successfully configured preffered Notepad++ settings"
    }
    else {
		"There was an error configuring preffered Notepad++ settings"
    }
	
	"`nConfiguring date and time formats"
    Set-DateTimeFormats -shortDateFormat "MM/dd/yyyy" -timeFormat "HH:mm:ss" -shortTimeFormat "HH:mm"
    if ($?) {
        "Successfully configured date and time formats"
    }
    else {
        "There was an error configuring date and time formats"
    }
}

Main

"`nPress a key to restart Windows [Esc to cancel]"
$r = Invoke-PauseWithEscape

if ($r) {
    Restart-Computer
}
