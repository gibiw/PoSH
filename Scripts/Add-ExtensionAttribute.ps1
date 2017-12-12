$csvFile = import-csv -Path "C:\Temp\LIST.csv" -Delimiter ',' -ErrorAction Stop | select -First 1
foreach($user in $csvFile){
    $mail = $user.Email
    $samaccountname = $user.'Logon Name'
	try{
		$aduser = get-AdUser -Filter {(UserPrincipalName -like $mail) -or (Samaccountname -like $samaccountname)} -Properties extensionAttribute4 -ErrorAction Ignore

		if($aduser -ne $null){
			if($aduser.extensionAttribute4 -ne $null){
			    Set-ADUser -Identity $aduser -Clear "extensionAttribute4"
			}
			Set-ADUser -Identity $aduser -Add @{"extensionAttribute4"=$user.employeeType}
		}
		else{
		    Write-Host "The user $mail ($samaccountname) has incorected data: $aduser" -ForegroundColor Yellow
		}
	}
	catch{
		Write-Host "The user $mail ($samaccountname) has incorected data: $aduser" -ForegroundColor Yellow
	}
}