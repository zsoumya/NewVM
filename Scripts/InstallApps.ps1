. $PSScriptRoot\Utils\AppUtils.ps1

function Main {
    "`nInstalling Chocolatey"
    Install-Chocolatey
    "`nSuccessfully installed Chocolatey"

    "`nInstalling Apps"
    Install-CommonChocoApps
    "`nSuccessfully installed Apps"

    "`nInstalling O&O RegEditor"
    Install-OORegEditor
    "`Successfully installed O&O RegEditor"

    $appLinks = @{
        "7zFM.exe"     = "C:\Program Files\7-Zip\7zFM.exe";
        "np.exe"       = "C:\Program Files\Notepad3\Notepad3.exe";
        "ccleaner.exe" = "C:\Program Files\CCleaner\CCleaner.exe";
        "ev.exe"       = "C:\Program Files\Everything\Everything.exe";
        "explorer.exe" = "C:\ProgramData\chocolatey\lib\Explorerplusplus\x64\Explorer++.exe";
        "opera.exe"    = "C:\Program Files\Opera\launcher.exe";
        "ph.exe"       = "C:\Program Files\Process Hacker 2\ProcessHacker.exe";
        "reged.exe"    = "C:\Apps\OORegEditor\OORegEdt.exe";
        "npp.exe"      = "C:\Program Files\Notepad++\notepad++.exe";
    }

    "`nCreating application links"
    Add-Links -linkPath "C:\Links" -appLinks $appLinks
    "`Successfully creating application links"
}

Main
"Please run C:\ProgramData\chocolatey\bin\RefreshEnv.cmd to refresh the PATH"
