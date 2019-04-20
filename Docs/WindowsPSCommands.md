##Useful PowerShell Commands Windows 10, Windows Server and Server Core

####Local User Management

+ ######Create local user getting the password interactively
**`New-LocalUser -AccountNeverExpires -Description "Soumya" -FullName "Soumya" -Name "Soumya" -Password $((Get-Credential -UserName "New User" -Message "Enter password for new user").Password) -PasswordNeverExpires`**

+ ######Add local user to Administrators group
**`Add-LocalGroupMember -Group "Administrators" -Member "Soumya"`**

+ ######Get all users of Administrators group
**`Get-LocalGroupMember -Group "Administrators"`**

+ ######Get all local users
**`Get-LocalUser`**

####Network Adapter Management

+ ######Get all network adapters
**`Get-NetAdapter`**

+ ######Get network adapter by name and address family
**`Get-NetIPAddress -InterfaceAlias "Ethernet0" -AddressFamily "IPv4"`**

+ ######Set new IP address for a named network adapter and address family
**`New-NetIPAddress -IPAddress "192.168.1.10" -InterfaceAlias "Ethernet0" -DefaultGateway "192.168.1.1" -AddressFamily "IPv4" -PrefixLength 24`**

+ ######Get all network adapter bindings for all network adapters
**`Get-NetAdapterBinding`**

+ ######Disable IPv6 for a named network adapter
**`Disable-NetAdapterBinding -Name Ethernet0 -ComponentID ms_tcpip6`**

+ ######Get DNS IPs for all network adapters
**`Get-DnsClientServerAddress`**

+ ######Get DNS IPs for a named network adapter and address family
**`Get-DnsClientServerAddress -InterfaceAlias "Ethernet0" -AddressFamily "IPv4"`**

+ ######Set DNS IPs for a named network adapter and address family
**`Set-DnsClientServerAddress -InterfaceAlias "Ethernet0" -ServerAddresses ("127.0.0.1", "192.168.1.1")`**

	**`Set-DnsClientServerAddress -InterfaceAlias "Ethernet0" -ServerAddresses ("192.168.1.10", "192.168.1.1")`**

####Active Directory Management

+ ######Install Active Directory feature  
**`Import-Module -Name ServerManager`**

	**`Install-WindowsFeature AD-Domain-Services -IncludeManagementTools`**

+ ######Create Active Directory domain
**`Install-ADDSForest -DomainName "OLYMPUS.LOCAL" -DomainNetbiosName "OLYMPUS" -InstallDns`**

+ ######Add user identity to "Domain Admins" group
**`Add-ADGroupMember -Identity "Domain Admins" -Members "Soumya"`**

+ ######Get all members of "Domain Admins" group
**`Get-ADGroupMember -Identity "Domain Admins"`**

+ ######Create new domain user with password hard coded in the command line
**`New-ADUser -AccountPassword $(ConvertTo-SecureString -String "p@55w0rd" -AsPlainText -Force) -Description "TFS Admin" -DisplayName "TFS Admin" -GivenName "TFS-Admin" -Name "TFSAdmin" -PasswordNeverExpires $true -SamAccountName "TFSAdmin" -UserPrincipalName "TFSAdmin@OLYMPUS.LOCAL" -Enabled $true`**

+ ######Get details of a domain user
**`Get-ADUser -Identity Soumya`**

+ ######Delete a domain user
**`Remove-ADUser -Identity TFSAdmin`**

+ ######Add computer to a domain
**`Add-Computer -DomainName "OLYMPUS.LOCAL" [-ComputerName [.|localhost|name]] -Restart -Force`**

+ ######Add current computer to a domain with a new name
**`Add-Computer -DomainName "OLYMPUS.LOCAL" -NewName PERSEUS -Credential $(Get-Credential -Credential OLYMPUS\Soumya) -Restart -Force`**

+ ######Get all computers in a domain
**`Get-ADComputer -Filter *`**

+ ######Remove named computer from a domain
**`Remove-ADComputer -Identity PERSEUS`**

+ ######Get domain password policy details
**`Get-ADDefaultDomainPasswordPolicy -Identity "OLYMPUS.LOCAL"`**

+ ######Set domain password policy details
**`Set-ADDefaultDomainPasswordPolicy -Identity "OLYMPUS.LOCAL" -ComplexityEnabled $false -MinPasswordAge 0 -MaxPasswordAge 0`**

####Privilege management using Carbon

+ ######Install Carbon (Chocolatey command)
**`choco install carbon`**

+ ######Import module Carbon
**`Import-Module Carbon`**

+ ######Get privileges of an user
**`Get-Privilege -Identity "OLYMPUS\TFSAdmin"`**

+ ######Grant "Logon Interactively" privilege to an user
**`Grant-Privilege -Identity "OLYMPUS\TFSAdmin" -Privilege SeInteractiveLogonRight`**

+ ######Revoke "Logon Interactively" privilege from an user
**`Revoke-Privilege -Identity "OLYMPUS\TFSAdmin" -Privilege SeInteractiveLogonRight`**

+ ######Grant "Logon As Service" privilege to an user
**`Grant-Privilege -Identity "OLYMPUS\TFSService" -Privilege SeServiceLogonRight`**

####Install SQL Server on Windows Server Core

Installation using configuration file:  

+ **`D:\setup.exe /ConfigurationFile=Z:\HostShare\NewVM\Resources\SQLServer2017\ConfigurationFile.ini`**

Configure inbound firewall rules for SQL Server connection on port 1433:

+ **`netsh advfirewall firewall add rule name = SQLDbEngineTCP dir = in protocol = tcp action = allow localport = 1433 remoteip = localsubnet profile = DOMAIN`**
