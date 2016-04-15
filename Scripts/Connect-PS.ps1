Param(
    # Server name
    [Parameter(Mandatory=$true)]
    [string]
    $servername
    )
$ServerData=get-ServerData -servername $servername

$secpasswd = ConvertTo-SecureString $ServerData.HPC_PASSWORD -AsPlainText -Force
$admincred = New-Object System.Management.Automation.PSCredential($ServerData.HPC_LOG_PASS,$secpasswd)
Enter-PSSession -ComputerName $ServerData.HPC_NETWORK_JT_INTERFACE_IP -Credential $admincred
