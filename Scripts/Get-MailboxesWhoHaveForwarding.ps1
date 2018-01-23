$UserCredential = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
Import-PSSession $Session

$mailboxes=get-mailbox –resultSize unlimited
$mailboxes | where { $_. forwardTo –ne $NULL }
$mailboxes | where { $_.forwardingSMTPAddress –ne $NULL } | ft name,forwardingSMTPAddress


$rules = $mailboxes | foreach { get-inboxRule –mailbox $_.alias }

$rules | where { ( $_.forwardAsAttachmentTo –ne $NULL  ) –or ( $_.forwardTo –ne $NULL ) –or ( $_.redirectTo –ne $NULL ) } | ft name,identity,ruleidentity,forwardAsAttachmentTo,forwardTo,redirectTo