. $PSScriptRoot\Utils\OSUtils.ps1
. $PSScriptRoot\Utils\Utils.ps1

$productName = Get-OSName

if ($productName -like "*Windows 10*") {
	"Detected Windows 10"
	$layoutXmlFileName = "Layout_Win10.xml"
}
elseif ($productName -like "*Windows Server 2016*") {
	"Detected Windows Server 2016"
	$layoutXmlFileName = "Layout_Win2016.xml"
}
else {
	"Unrecognized OS: '$productName'. Cannot import Start Layout."
	exit
}

$targetLayoutPath = "C:\Users\Default\AppData\Local\Microsoft\Windows\Shell\LayoutModification.xml"
if (Test-Path -Path $targetLayoutPath -PathType Leaf) {
	Remove-Item -Path $targetLayoutPath -Force
}

$layoutXmlFileName = "Z:\HostShare\NewVM\Resources\Layout\$layoutXmlFileName"
"Importing layout from `"$layoutXmlFileName`""
Import-StartLayout -LayoutPath $layoutXmlFileName -MountPath "C:\"
