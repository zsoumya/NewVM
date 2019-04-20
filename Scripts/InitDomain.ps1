function Main {
    param (
        [Parameter(Mandatory=$true)]
        [string]   $domainName,

        [Parameter(Mandatory=$true)]
        [AllowEmptyCollection()]
        [AllowNull()]
        [string[]] $adminUserNames
    )

    if ($adminUserNames) {
        "`nPromoting specified users to Domain Admins"
        Add-ADGroupMember -Identity "Domain Admins" -Members $adminUserNames -Confirm:$false -ErrorAction SilentlyContinue
        if ($?) {
            "Successfully promoting specified users to Domain Admins"
        }
        else {
            Write-Error -Message "Error: $($Error[0].Exception.Message)"
            return
        }
    }
    else {
        "`nNo users to promote to Domain Admins"
    }

    "`nRelaxing domain password policy (for non-production use only)"
    Set-ADDefaultDomainPasswordPolicy -Identity $domainName -ComplexityEnabled $false -MinPasswordAge 0 -MaxPasswordAge 0 -ErrorAction SilentlyContinue
    if ($?) {
        "Successfully relaxed domain password policy"
    }
    else {
        Write-Error -Message "Error: $($Error[0].Exception.Message)"
        return
    }    
}

Main