$CsvFilePath = "C:\Scripts\CR_Employees_FullFile_to_Azure_AD Dec 2017.csv"
$ReportFilePath = "C:\Scripts\Report.csv"
$csvFile = import-csv -Path $CsvFilePath -Delimiter ';' -ErrorAction Stop
$ReportArray = @()
foreach($user in $csvFile){
    $samaccountname = $user.'Logon Name'
    if($samaccountname -ne ""){
        $aduser = get-AdUser -Filter {(Samaccountname -like $samaccountname)} -Properties StreetAddress,City,State,PostalCode,employeeType,extensionAttribute1,extensionAttribute3,extensionAttribute4,EmployeeNumber -ErrorAction Ignore
        if($aduser -ne $null){
            $obj = New-Object PSObject -Property @{
                    LogonName = $samaccountname
                    FirstName = $user.'First Name'
                    LastName = $user.'Last Name'
                    DisplayName = $user.'Display Name'
                    Email = $user.Email
                    OldStreetAddress = $aduser.StreetAddress
                    NewStreetAddress = $user.'street address'
                    OldCity = $aduser.City
                    NewCity = $user.City
                    OldState = $aduser.State
                    NewState = $user.State
                    OldPostalCode = $aduser.PostalCode
                    NewPostalCode = $user.'Post Code'
                    OldExtensionAttribute4 = $aduser.extensionAttribute4
                    NewExtensionAttribute4 = $user.extensionAttribute4
                    OldEmployeeType = $aduser.employeeType
                    NewEmployeeType = $user.employeeType
                    OldExtensionAttribute1 = $aduser.extensionAttribute1
                    NewExtensionAttribute1 = $user.ExtensionAttribute1
                    OldExtensionAttribute3 = $aduser.extensionAttribute3
                    NewExtensionAttribute3 = $user.ExtensionAttribute3
                    OldEmployeeNumber = $aduser.EmployeeNumber
                    NewEmployeeNumber = $user.'Employee Number'
            }
            $aduser.StreetAddress = $user.'street address'
            $aduser.City = $user.City
            $aduser.State = $user.State
            $aduser.PostalCode = $user.'Post Code'
            Set-ADUser -Identity $aduser

	        if($aduser.extensionAttribute4 -ne $null){
			    Set-ADUser -Identity $aduser -Clear "extensionAttribute4"
		    }
            if($user.extensionAttribute4 -ne ""){
                Set-ADUser -Identity $aduser -Add @{"extensionAttribute4"=$user.extensionAttribute4}
            }            

            if($aduser.employeeType -ne $null){
		        Set-ADUser -Identity $aduser -Clear "employeeType"
		    }
            if($user.employeeType -ne ""){
                Set-ADUser -Identity $aduser -Add @{"employeeType"=$user.employeeType}
            }            

            if($aduser.extensionAttribute1 -ne $null){
		        Set-ADUser -Identity $aduser -Clear "extensionAttribute1"
		    }
            if($user.ExtensionAttribute1 -ne ""){
                Set-ADUser -Identity $aduser -Add @{"extensionAttribute1"=$user.ExtensionAttribute1}
            }            

            if($aduser.extensionAttribute3 -ne $null){
		        Set-ADUser -Identity $aduser -Clear "extensionAttribute3"
		    }
            if($user.ExtensionAttribute3 -ne ""){
                Set-ADUser -Identity $aduser -Add @{"extensionAttribute3"=$user.ExtensionAttribute3}
            }            

            if($aduser.EmployeeNumber -ne $null){
		        Set-ADUser -Identity $aduser -Clear "EmployeeNumber"
		    }  
            if($user.'Employee Number' -ne ""){
                Set-ADUser -Identity $aduser -Add @{"EmployeeNumber"=$user.'Employee Number'}
            }           
	    }
	    else{
	        Write-Host "The user $samaccountname not found." -ForegroundColor Yellow
            $obj = New-Object PSObject -Property @{
                    LogonName = $samaccountname
                    FirstName = "User not found"
                    LastName = ""
                    DisplayName = ""
                    Email = ""
                    OldStreetAddress = ""
                    NewStreetAddress = ""
                    OldCity = ""
                    NewCity = ""
                    OldState = ""
                    NewState = ""
                    OldPostalCode = ""
                    NewPostalCode = ""
                    OldExtensionAttribute4 = ""
                    NewExtensionAttribute4 = ""
                    OldEmployeeType = ""
                    NewEmployeeType = ""
                    OldExtensionAttribute1 = ""
                    NewExtensionAttribute1 = ""
                    OldExtensionAttribute3 = ""
                    NewExtensionAttribute3 = ""
                    OldEmployeeNumber = ""
                    NewEmployeeNumber = ""
            }
	    }
	    $ReportArray +=$obj
    }
    else{
        Write-Host "The user $user has incorrect data." -ForegroundColor Red
    }
}
$ReportArray |Select LogonName,FirstName,LastName,DisplayName,Email,OldStreetAddress,NewStreetAddress,OldCity,NewCity,OldState,NewState,OldPostalCode,NewPostalCode,OldExtensionAttribute1,NewExtensionAttribute1, 
`OldExtensionAttribute3,NewExtensionAttribute3,OldExtensionAttribute4,NewExtensionAttribute4,OldEmployeeType,NewEmployeeType,OldEmployeeNumber,NewEmployeeNumber| Export-Csv -Path $ReportFilePath -Delimiter ';' -NoTypeInformation -Force -Encoding Unicode