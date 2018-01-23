$Office365Username = ""
$Office365Password = ""

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
	$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $Office365credentials -Authentication Basic –AllowRedirection    	

	#Import the session
    Import-PSSession $Session -AllowClobber | Out-Null
}


Get-PSSession | Remove-PSSession
ConnectTo-ExchangeOnline -Office365AdminUsername $Office365Username -Office365AdminPassword $Office365Password		

# Get Distribution Groups
$objDistributionGroups = Get-DistributionGroup -ResultSize Unlimited  
$objDistributionGroups | where {$_.Name -eq "GROUPNAME"}

# Get Dynamic Distribution Group

$DDG = Get-DynamicDistributionGroup | where {$_.Name -eq "GROUPNAME"}
$users = Get-Recipient -RecipientPreviewFilter $DDg.RecipientFilter -ResultSize Unlimited


