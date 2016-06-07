workflow On-Modify-SCVMNetwork-Description
{
    param
    (
    )
        
    $VmmConnection = Get-AutomationConnection -Name 'VmmConnection'

    if($VmmConnection -eq $null)
    {
        $errorMessage = "Asset 'VmmConnection' not found. Please ensure an asset name 'VmmConnection' of type PSCredential exists, and has the credentials for service account.";
        $errorMessagel;
        throw $errorMessage;
    }

    $VmmServerName = $VmmConnection.ComputerName
    $SecurePassword = ConvertTo-SecureString -AsPlainText -String $VmmConnection.Password -Force
    $VmmCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $VmmConnection.Username, $SecurePassword

    $LogicalNetwork=Get-AutomationVariable -Name 'LogicalNetwork'

    if($LogicalNetwork -eq $null)
    {
        $errorMessage = "Asset 'LogicalNetwork' not found.  Please ensure an asset name 'LogicalNetwork' of type string variable exists, and has the credentials for service account.";
        $errorMessagel;
        throw $errorMessage;
    }

    $externalIpPool=Get-AutomationVariable -Name 'ExternalIpPool'

    if($LogicalNetwork -eq $null)
    {
        $errorMessage = "Asset 'ExternalIpPool' not found.  Please ensure an asset name 'ExternalIpPool' of type string variable exists, and has the credentials for service account.";
        $errorMessagel;
        throw $errorMessage;
    }
    
    inlinescript 
    {
    	try 
        {
    		Import-Module virtualmachinemanager
        
			$VmmServer = Get-SCVMMServer -ComputerName $Using:VmmServerName -ForOnBehalfOf
            $SCVMNetworks=Get-SCVMNetwork -LogicalNetwork $Using:LogicalNetwork -VmmServer $VmmServer | where {$_.name -ne $Using:LogicalNetwork}

            ## Change description
            
            foreach ($SCVMNetwork in $SCVMNetworks) {
                $Id=$SCVMNetwork.owner
                $discription=(Get-SCVMNetwork -Name $SCVMNetwork -VmmServer $VmmServer| where {$_.owner -eq $id}).Description
                $TemplateDiscription='Owner=UserRole, ExternalIP=No'
                if (!$discription -or $discription -notmatch 'ExternalIP' -or $discription -notmatch 'Owner'){
                    Get-SCVMNetwork -Name $SCVMNetwork -VmmServer $VmmServer | where {$_.owner -eq $id} | Set-SCVMNetwork -Description $TemplateDiscription -VmmServer $VmmServer | out-null
                    }
                $discription=(Get-SCVMNetwork -Name $SCVMNetwork -VmmServer $VmmServer | where {$_.owner -eq $id}).Description
                $Owner=($discription -split 'wner=')[1]
                $Owner=($Owner -split ', ')[0]
                if($Owner -ne $SCVMNetwork.Owner){
                   $newdiscription=$discription -replace $Owner,$SCVMNetwork.Owner
                   Get-SCVMNetwork -Name $SCVMNetwork -VmmServer $VmmServer | where {$_.owner -eq $id} | Set-SCVMNetwork -Description $newdiscription -VmmServer $VmmServer | out-null
                   "SCVMNetwork Name:" + $SCVMNetwork.Name + "  Owner name: " + $SCVMNetwork.Owner
                    
                }
            }

            ## Change ExternalIP
            foreach ($SCVMNetwork in $SCVMNetworks) {
                $Id=$SCVMNetwork.owner
                $NATConnections=(Get-SCVMNetwork -Name $SCVMNetwork -VmmServer $VmmServer | where {$_.owner -eq $id}).NATConnections
                if ($NATConnections){
                    $VmNetworkGateway=Get-SCVMNetworkGateway -VMNetwork $SCVMNetwork -VmmServer $VmmServer | where {$_.NATConnections -match $NATConnections}    
                    $natConnection = (get-SCNATConnection -VMNetworkGateway $VmNetworkGateway -VmmServer $VmmServer).ID
                    $externalIpPoolVar=Get-SCStaticIPAddressPool -IPv4 -Subnet $Using:externalIpPool -VmmServer $VmmServer
                    $ip=(Get-SCIPAddress -StaticIPAddressPool $externalIpPoolVar -VmmServer $VmmServer | where {$_.AssignedToID -eq $natConnection}).Name
                    $discription=(Get-SCVMNetwork -Name $SCVMNetwork -VmmServer $VmmServer | where {$_.owner -eq $id}).Description
                    $ExternalIP=($discription -split 'External')[1]
                    $ExternalIP=($ExternalIP -split '=')[1] 
                    if($ExternalIP -ne $ip){
                        $newdiscription=$discription -replace $ExternalIP,$ip
                        Get-SCVMNetwork -Name $SCVMNetwork -VmmServer $VmmServer | where {$_.owner -eq $id} | Set-SCVMNetwork -Description $newdiscription -VmmServer $VmmServer | out-null
                        "SCVMNetwork Name: " + $SCVMNetwork.Name +"  External IP Address: " + $ip
                    }
                }
            }
           
		}
        catch 
		{
			Throw "Exception: $Error"
		}
		Finally
		{
			$VmmServer.Disconnect()
			$VmmServer = $null
		}
    } -PSComputerName $VmmServerName -PSCredential $VmmCredential 
}

