$reportName = "F13"
$allusers = Import-csv -Path "C:\Scripts\Office365_DESKLESSPACK_20171228-194216.csv" -Delimiter ";"
$report = @()
foreach($user in $allusers){
    $mail = $user.UserPrincipalName
    $getUser = Get-ADUser -Filter {UserPrincipalName -eq $mail} -Properties DisplayName, EmailAddress, Country, State, City, extensionAttribute1,employeeType
    if($getUser){
        $report +=$getUser 
    }
}

$report | select DisplayName, EmailAddress, Country, State, City, extensionAttribute1,employeeType | Export-csv -Path "C:\Scripts\$reportName.csv" -Delimiter ";" -Encoding Unicode -NoTypeInformation
