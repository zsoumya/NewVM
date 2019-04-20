New-ADUser -AccountPassword $(ConvertTo-SecureString -String "p@55w0rd" -AsPlainText -Force) `
		   -Description "TFS Service" -DisplayName "TFS Service" -GivenName "TFS-Service" -Name "TFSService" `
		   -PasswordNeverExpires $true -SamAccountName "TFSService" -UserPrincipalName "TFSService@OLYMPUS.LOCAL" `
		   -Enabled $true;

New-ADUser -AccountPassword $(ConvertTo-SecureString -String "p@55w0rd" -AsPlainText -Force) `
		   -Description "TFS Build" -DisplayName "TFS Build" -GivenName "TFS-Build" -Name "TFSBuild" `
		   -PasswordNeverExpires $true -SamAccountName "TFSBuild" -UserPrincipalName "TFSBuild@OLYMPUS.LOCAL" `
		   -Enabled $true;
