. $PSScriptRoot\Utils\OSUtils.ps1
. $PSScriptRoot\Utils\Utils.ps1

function Main {
    $productName = Get-OSName

    switch ($productName) {
        "Microsoft Windows 10 Pro" { 
            $unattendXml = "Unattend_Win10Pro.xml"
            break
        }

        "Microsoft Windows Server 2016 Datacenter" {
            $unattendXml = if (Test-CoreOS) { "Unattend_Win2016DtCCore.xml" } else { "Unattend_Win2016DtC.xml" }
            break
        }

        "Microsoft Windows Server 2016 Standard" {
            $unattendXml = if (Test-CoreOS) { "Unattend_Win2016StdCore.xml" } else { "Unattend_Win2016Std.xml" }
            break
        }

        default {
            "Unrecognized OS: '$productName'. Cannot SysPrep."
            exit
        }
    }

    "Detected OS: $productName ($(if (Test-CoreOS) { "Core" } else { "Desktop Experience" }))"
    "About to run SysPrep [Generalize]"
    "Unattended answer file: Z:\HostShare\NewVM\$unattendXml"
    "Press a key to continue or Esc to cancel"

    $r = Invoke-PauseWithEscape
    if ($r) {
        & "C:\Windows\System32\sysprep\sysprep.exe" `
            /oobe /generalize /shutdown "/unattend:Z:\HostShare\NewVM\Resources\UnattendedXml\$unattendXml"
    }
}

Main
