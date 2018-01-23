#Constant Variables
$OutputFile = "LastLogonDate.csv"   #The CSV Output file that is created, change for your purposes
$Office365Username = ""
$Office365Password = ""
#Main
Function Main {

	#Remove all existing Powershell sessions
	Get-PSSession | Remove-PSSession
	
	#Call ConnectTo-ExchangeOnline function with correct credentials
	ConnectTo-ExchangeOnline -Office365AdminUsername $Office365Username -Office365AdminPassword $Office365Password			
	
	#Prepare Output file with headers
	Out-File -FilePath $OutputFile -InputObject "UserPrincipalName,LastLogonDate" -Encoding UTF8
	

		#No input file found, gather all mailboxes from Office 365
		$objUsers = get-mailbox -ResultSize Unlimited | select UserPrincipalName
    for ($i=0; $i -le $objUsers.Count-1; $i++){
        Write-Progress -Activity "Found $($objUsers.Count)" -status "Users Prepared $i" -percentComplete ($i / $objUsers.Count*100)
        $strUserPrincipalName = $objUsers[$i].UserPrincipalName
        $objUserMailbox = get-mailboxstatistics -Identity $strUserPrincipalName | Select LastLogonTime
		#Check if they have a last logon time. Users who have never logged in do not have this property
		if ($objUserMailbox.LastLogonTime -eq $null -or $objUserMailbox.LastLogonTime -lt (Get-Date).AddDays(-30))
		{
            $strLastLogonTime = $objUserMailbox.LastLogonTime
			$strUserDetails = "$strUserPrincipalName,$strLastLogonTime"
		    write-host "$strUserPrincipalName : $strLastLogonTime"
		    #Append the data to file
		    Out-File -FilePath $OutputFile -InputObject $strUserDetails -Encoding UTF8 -append
		}
    }
	#Clean up session
	Get-PSSession | Remove-PSSession
}

function ConnectTo-ExchangeOnline
{   
	Param( 
		[Parameter(
		Mandatory=$true,
		Position=0)]
		[String]$Office365AdminUsername,
		[Parameter(
		Mandatory=$true,
		Position=1)]
		[String]$Office365AdminPassword

    )
		
	#Encrypt password for transmission to Office365
	$SecureOffice365Password = ConvertTo-SecureString -AsPlainText $Office365AdminPassword -Force    
	
	#Build credentials object
	$Office365Credentials  = New-Object System.Management.Automation.PSCredential $Office365AdminUsername, $SecureOffice365Password
	
	#Create remote Powershell session
	$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $Office365credentials -Authentication Basic �AllowRedirection    	

	#Import the session
    Import-PSSession $Session -AllowClobber | Out-Null
}


# Start script
. Main