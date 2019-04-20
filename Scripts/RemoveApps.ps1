. $PSScriptRoot\Utils\Utils.ps1

function Main {
	$apps = @(
		"*ActiproSoftwareLLC*",
		"*Autodesk*",
		"*BubbleWitch*",
		"*CandyCrush*",
		"*CyberLink*",
		"*Disney*",
		"*DragonMania*",
		"*Drawboard*",
		"*Duolingo*",
		"*EclipseManager*",
		"*Facebook*",
		"*FarmVille*",
		"*flaregames*",
		"*Flipboard*",
		"*GAMELOFTS*",
		"*HiddenCity*",
		"*MysteryofShadows*",
		"*iHeartRadio*",
		"*KeeperSecurity*",
		"*king.com.*",
		"*MarchofEmpires*",
		"*Minecraft*",
		"*Netflix*",
		"*PandoraMediaInc*",
		"*PicsArt-PhotoStudio*",
		"*Playtika*",
		"*ShazamEntertainmentLtd*",
		"*Spotify*",
		"*TheNewYorkTimes*",
		"*ThumbmunkeysLtd*",
		"*TuneIn*",
		"*Twitter*",
		"*WinZip*",
		"*Wunderkinder*",
		"*Wunderlist",
		"*XINGAG*",
		"DolbyLaboratories.DolbyAccess",
		"Microsoft.3DBuilder",
		"Microsoft.Appconnector",
		"Microsoft.BingFinance",
		"Microsoft.BingFoodAndDrink",
		"Microsoft.BingHealthAndFitness",
		"Microsoft.BingNews",
		"Microsoft.BingSports",
		"Microsoft.BingTravel",
		"Microsoft.BingWeather",
		"Microsoft.CommsPhone",
		"Microsoft.ConnectivityStore",
		"Microsoft.FreshPaint",
		"Microsoft.Getstarted",
		"Microsoft.Messaging",
		"Microsoft.Microsoft3DViewer",
		"Microsoft.MicrosoftOfficeHub",
		"Microsoft.MicrosoftPowerBIForWindows",
		"Microsoft.MicrosoftSolitaireCollection",
		"Microsoft.MicrosoftStickyNotes",
		"Microsoft.MSPaint",
		"Microsoft.NetworkSpeedTest",
		"Microsoft.Office.OneNote",
		"Microsoft.Office.Sway",
		"Microsoft.OneConnect",
		"Microsoft.People",
		"Microsoft.Print3D",
		"Microsoft.SkypeApp",
		"Microsoft.Wallet",
		"Microsoft.WindowsAlarms",
		"Microsoft.WindowsCamera",
		"Microsoft.WindowsFeedbackHub",
		"Microsoft.WindowsMaps",
		"Microsoft.WindowsPhone",
		"Microsoft.WindowsReadingList",
		"Microsoft.WindowsSoundRecorder",
		"Microsoft.Xbox.TCUI",
		"Microsoft.XboxApp",
		"Microsoft.XboxGameOverlay",
		"Microsoft.XboxIdentityProvider",
		"Microsoft.XboxSpeechToTextOverlay",
		"Microsoft.ZuneMusic",
		"Microsoft.ZuneVideo",
		"microsoft.windowscommunicationsapps"
	)
	
	$provisionedApps = Get-AppxProvisionedPackage -Online | Where-Object -FilterScript {
		Test-ContainsLike -array $apps -item $_.DisplayName
	}
	
	"Found $($provisionedApps.Length) provisioned packages"
	
	$provisionedApps | ForEach-Object -Process {
		"Uninstalling provisioned app: $($_.DisplayName)"
		$_ | Remove-AppxProvisionedPackage -Online -AllUsers
		
		Get-AppxPackage -Name $_.DisplayName -AllUsers | Remove-AppxPackage
		Get-AppxPackage -Name $_.DisplayName | Remove-AppxPackage -AllUsers
		Get-AppxPackage -Name $_.DisplayName | Remove-AppxPackage
		Start-Sleep -Seconds 1
	}
		
	"Removing unneeded installed apps"
	$apps | ForEach-Object -Process {
		if ($_.Contains("*")) {
			"Uninstalling apps like `"$_`" from all users"
		}
		else {
			"Uninstalling app `"$_`" from all users"
		}
			
		Get-AppxPackage -Name $_ -AllUsers | Remove-AppxPackage
		Start-Sleep -Seconds 1
	}
}

Main

"`nPlease wait till all pending processing is complete."
"`nPress a key to exit script"
$null = Invoke-Pause
