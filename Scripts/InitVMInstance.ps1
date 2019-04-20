. $PSScriptRoot\Utils\OSUtils.ps1
. $PSScriptRoot\Utils\Utils.ps1

function Main {
    param (
        [Parameter(Mandatory=$true)]
        [string]   $hostName, 

        [Parameter(Mandatory=$true)]
        [AllowEmptyString()]
        [AllowNull()]
        [string]   $workGroupName, 
        
        [Parameter(Mandatory=$true)]
        [AllowEmptyString()]
        [AllowNull()]
        [string]   $adminUserName, 
        
        [Parameter(Mandatory=$true)]
        [AllowEmptyString()]
        [AllowNull()]
        [string]   $adminUserFullName,
        
        [Parameter(Mandatory=$true)]
        [AllowEmptyString()]
        [AllowNull()]
        [string]   $ipAddress,
        
        [Parameter(Mandatory=$true)]
        [AllowEmptyString()]
        [AllowNull()]
        [string]   $defaultGateway,
        
        [Parameter(Mandatory=$true)]
        [AllowEmptyCollection()]
        [AllowNull()]
        [string[]] $dnsServers
    )

    "`nActivating Windows"
    Get-ScheduledTask -TaskName "KMSAutoNet" | Start-ScheduledTask
    if ($?) {
        "Successfully activated Windows"
    } else {
        "There was an error activating Windows ($($error[0].Exception.Message))"
    }

    "`nRenaming VM to `"$hostName`""
    Rename-Computer -ComputerName . -NewName $hostName
    if ($?) {
        "Successfully renamed VM"
    }
    else {
        "There was an error renaming VM ($($error[0].Exception.Message))"
    }

    if ($workGroupName) {
        "`nAdding VM to workgroup `"$workGroupName`""
        Add-ComputerToWorkGroup -workGroupName $workGroupName
        if ($?) {
            "Successfully added VM to workgroup"
        }
        else {
            "There was an error adding VM to workgroup ($($error[0].Exception.Message))"
        }
    }
    else {
        "No workgroup name specified: Skipping workgroup configuration"
    }
    
    if ($adminUserName) {
        "`nCreating admin user $adminUserName"
        New-LocalAdmin -userName $adminUserName -fullName $adminUserFullName `
            -password (Get-Credential -UserName "$adminUserName" -Message "Enter password for new user").Password
        if ($?) {
            "Successfully created admin user"
        }
        else {
            "There was an error creating admin user ($($error[0].Exception.Message))"
        }

        "`nListing members of `"Administrators`" group for verification"
        Get-LocalGroupMember -Group "Administrators" | ForEach-Object -Process { $_.Name }
            
        "`nListing all local users for verification"
        Get-LocalUser | ForEach-Object -Process { "{0,-20}|{1,-6}|{2,-30}" -f $_.Name, $_.Enabled, $_.Description }
    }
    
    if ($ipAddress) {
        $netAdapterName = "Ethernet0" # Default name for VMWare Workstation VMs

        "`nSetting IP address of network adapter: $netAdapterName to $ipAddress"
        Set-StaticIP -adapterName $netAdapterName -ipAddress $ipAddress -defaultGateway $defaultGateway -dnsServers $dnsServers
        if ($?) {
            "Successfully set IP address"
        } else {
            "There was an error setting IP address ($($error[0].Exception.Message))"
        }
    }
    else {
        "`nIP Address not provided. Skipping static IP configuration."
    }
}

Main

"`nPress a key to restart Windows [Esc to cancel]"
$r = Invoke-PauseWithEscape

if ($r) {
    Restart-Computer
}
