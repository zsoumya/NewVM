. $PSScriptRoot\Utils\DomainUtils.ps1

function Main {
    param (
        [Parameter(Mandatory=$true)]
        [string]   $domainName,

        [Parameter(Mandatory=$true)]
        [AllowEmptyString()]
        [AllowNull()]
        [string]   $domainNetBiosName
    )

    if (-not (Test-ValidDomainName -domainName $domainName)) {
        Write-Error -Message "Invalid domain name format"
        return
    }
		
	if (-not $domainNetBiosName) {
        $domainNetBiosName = $domainName.Split(".")[0]
        Write-Warning -Message "`nDomain NetBios name not specified. Using computed value: `"$domainNetBiosName`""
    }

    "`nInstalling Windows feature `"AD-Domain-Services`""
    Install-WindowsFeature -Name "AD-Domain-Services" -IncludeManagementTools -Confirm:$false -ErrorAction SilentlyContinue
    if ($?) {
        "Successfully installed Windows feature `"AD-Domain-Services`""
    }
    else {
        Write-Error -Message "Error: $($Error[0].Exception.Message)"
        return
    }

    "`nCreating domain `"$domainName`""
    Install-ADDSForest -DomainName $domainName -DomainNetbiosName $domainNetBiosName -InstallDns -Force -ErrorAction SilentlyContinue
    if ($?) {
        "Successfully created domain `"$domainName`""
    }
    else {
        Write-Error -Message "Error: $($Error[0].Exception.Message)"
        return
    }
}

Main