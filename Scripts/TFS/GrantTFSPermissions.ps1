Import-Module -Name Carbon

$domainName = "OLYMPUS"
$userNames = @("TFSService", "TFSBuild")

$userNames | ForEach-Object -Process {
	Grant-Privilege -Identity "$domainName\$_" -Privilege SeServiceLogonRight
}