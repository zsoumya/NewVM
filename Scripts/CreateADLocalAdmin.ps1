. $PSScriptRoot\Utils\OSUtils.ps1

function Main {
    param (
        [Parameter(Mandatory=$true)]
        [AllowEmptyString()]
        [AllowNull()]
        [string]       $domainName,

        [Parameter(Mandatory=$true)]
        [string]       $userName,

        [Parameter(Mandatory=$true)]
        [string]       $displayName,

        [Parameter(Mandatory=$true)]
        [securestring] $password
    )

    New-ADLocalAdmin -domainName $domainName -userName $userName -displayName $displayName -password $password
}

Main