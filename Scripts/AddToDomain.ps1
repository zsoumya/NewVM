. $PSScriptRoot\Utils\DomainUtils.ps1
. $PSScriptRoot\Utils\OSUtils.ps1

function Main {
    param (
        [Parameter(Mandatory=$true)]
        [string] $domainName,

        [Parameter(Mandatory=$true)]
        [string] $domainAdmin,

        [Parameter(Mandatory=$true)]
        [string] $dnsIpAddress,
        
        [Parameter(Mandatory=$true)]
        [AllowEmptyString()]
        [AllowNull()]
        [string] $newMachineName
    )
	
	if (-not (Test-ValidDomainName -domainName $domainName)) {
		Write-Error -Message "Invalid domain name format"
		return
	}
	
	if (-not ($domainAdmin.Contains("\"))) {
		$domainNetBiosName = $domainName.Split(".")[0]
		$domainAdmin = $domainNetBiosName + "\" + $domainAdmin
		Write-Warning -Message "`nDomain admin name is not qualified. Using computed value: `"$domainAdmin`""
	}
	
    "`nAdding this computer to domain `"$domainName`""
    Add-ComputerToDomain -domainName $domainName -domainAdmin $domainAdmin -dnsIpAddress $dnsIpAddress `
        -netAdapterName "ETHERNET0" -newMachineName $newMachineName
    if ($?) {
        "Successfully added this computer to domain"
    }
    else {
        "There was an error adding this computer to domain"
    }
}

Main