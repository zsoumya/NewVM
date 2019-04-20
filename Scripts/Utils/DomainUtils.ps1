function Test-ValidDomainName {
	[OutputType([bool])]
	param (
		[Parameter(Mandatory = $true)]
		[string] $domainName
	)
	
	$validDomainRegex = "(?=^.{4,253}$)(^((?!-)[a-zA-Z0-9-]{1,63}(?<!-)\.)+[a-zA-Z]{2,63}$)"
	return $domainName -match $validDomainRegex
}
