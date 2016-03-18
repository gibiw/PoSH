$group = get-adgroup -Filter {GroupCategory -eq "Security"} -SearchBase "ou=IS_OEM,ou=Groups,ou=DataCenterEM01,DC=passport,DC=local" | Select SamAccountName | Export-Csv C:\New_users\test.csv –Delimiter “;” -Encoding UTF8

$2 = Import-Csv C:\New_users\test.csv –Delimiter “;”

foreach ($gp in $2) 
{
$1 = $gp.SamAccountName

 Get-ADGroupMember -Identity $1 -recursive | select Name | Export-csv C:\New_users\Groups\$1.csv -Encoding UTF8 } 

