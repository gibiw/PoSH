$UserCredential = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
Import-PSSession $Session
Search-Mailbox -Identity "USER" -SearchQuery 'Subject:"EX2 Logins"' -EstimateResultOnly -DeleteContent
Remove-PSSession $Session