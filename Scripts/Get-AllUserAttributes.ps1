$paramlist = @("DisplayName","EmailAddress","SamAccountName","AccountExpirationDate","accountExpires","AccountLockoutTime","AccountNotDelegated","AllowReversiblePasswordEncryption",
"AuthenticationPolicy","AuthenticationPolicySilo","BadLogonCount","badPasswordTime","badPwdCount","CannotChangePassword","CanonicalName",
"Certificates","City","CN","codePage","Company","CompoundIdentitySupported","Country","countryCode","Created","createTimeStamp","Deleted",
"Department","Description","DistinguishedName","Division","DoesNotRequirePreAuth","dSCorePropagationData",
"EmployeeID","EmployeeNumber","employeeType","Enabled","Fax","GivenName","HomeDirectory","HomedirRequired","HomeDrive","HomePage","HomePhone",
"Initials","instanceType","internetEncoding","isDeleted","KerberosEncryptionType","l","LastBadPasswordAttempt","LastKnownParent",
"lastLogoff","lastLogon","LastLogonDate","lastLogonTimestamp","legacyExchangeDN","LockedOut","lockoutTime","logonCount","LogonWorkstations",
"mail","mailNickname","Manager","MemberOf","MNSLogonAccount","MobilePhone","Modified","modifyTimeStamp","msDS-ExternalDirectoryObjectId",
"msDS-User-Account-Control-Computed","msExchAddressBookFlags","msExchBypassAudit","msExchMailboxGuid","msExchPoliciesExcluded",
"msExchProvisioningFlags","msExchRecipientDisplayType","msExchRecipientSoftDeletedStatus","msExchRecipientTypeDetails","msExchRemoteRecipientType",
"msExchSafeSendersHash","msExchUMDtmfMap","msExchVersion","Name","nTSecurityDescriptor","ObjectCategory","ObjectClass","ObjectGUID",
"objectSid","Office","OfficePhone","Organization","OtherName","PasswordExpired","PasswordLastSet","PasswordNeverExpires","PasswordNotRequired",
"physicalDeliveryOfficeName","POBox","PostalCode","PrimaryGroup","primaryGroupID","PrincipalsAllowedToDelegateToAccount","ProfilePath",
"ProtectedFromAccidentalDeletion","proxyAddresses","publicDelegates","publicDelegatesBL","pwdLastSet","sAMAccountType",
"ScriptPath","sDRightsEffective","ServicePrincipalNames","showInAddressBook","SID","SIDHistory","SmartcardLogonRequired","sn","State",
"StreetAddress","Surname","targetAddress","telephoneNumber","Title","TrustedForDelegation","TrustedToAuthForDelegation","UseDESKeyOnly",
"userAccountControl","userCertificate","UserPrincipalName","uSNChanged","uSNCreated","whenChanged","whenCreated","extensionattribute1",
"extensionattribute2", "extensionattribute3", "extensionattribute4","extensionattribute5","extensionattribute6","extensionattribute7",
"extensionattribute8","extensionattribute9","extensionattribute10","extensionattribute11","extensionattribute12","extensionattribute13",
"extensionattribute14","extensionattribute15")

$allusers = get-aduser -filter * -properties $paramlist -SearchBase "DN"| Sort-Object $paramlist 

$allusers | select $paramlist | Export-Csv -Path "C:\Scripts\ReportAllUsers.csv" -Delimiter ';' -Encoding Unicode -NoTypeInformation -Force