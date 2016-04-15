Param([string]$DomainDNSName,[string]$DomainNETBIOSName,[string]$SafeModeAdminPassword,[string]$credentials)
Import-Module ADDSDeployment
$securePW = ConvertTo-SecureString $SafeModeAdminPassword -AsPlainText -Force
$pass=($credentials -split 'dministrator:')[1]
$secpasswd = ConvertTo-SecureString "$pass" -AsPlainText -Force
$Administrator=$DomainNETBIOSName+'\Administrator'
$admincred = New-Object System.Management.Automation.PSCredential($Administrator,$secpasswd)
$portToCheck=53
$props=@{}
$strComputer = "."
function Get-IPrange { 
    <#  
        .SYNOPSIS   
        Get the IP addresses in a range  
        .EXAMPLE  
        Get-IPrange -start 192.168.8.2 -end 192.168.8.20  
        .EXAMPLE  
        Get-IPrange -ip 192.168.8.2 -mask 255.255.255.0  
        .EXAMPLE  
        Get-IPrange -ip 192.168.8.3 -cidr 24  
        #>  
    
    param(  
        [string]$start,  
        [string]$end,  
        [string]$ip,  
        [string]$mask,  
        [int]$cidr  
        )  
    
    function IP-toINT64 () {  
        param ($ip)  
        
        $octets = $ip.split(".")  
        return [int64]([int64]$octets[0]*16777216 +[int64]$octets[1]*65536 +[int64]$octets[2]*256 +[int64]$octets[3])  
        }  
    
    function INT64-toIP() {  
        param ([int64]$int)  
        
        return (([math]::truncate($int/16777216)).tostring()+"."+([math]::truncate(($int%16777216)/65536)).tostring()+"."+([math]::truncate(($int%65536)/256)).tostring()+"."+([math]::truncate($int%256)).tostring() ) 
        }  
    
    if ($ip) {$ipaddr = [Net.IPAddress]::Parse($ip)}  
    if ($cidr) {$maskaddr = [Net.IPAddress]::Parse((INT64-toIP -int ([convert]::ToInt64(("1"*$cidr+"0"*(32-$cidr)),2)))) }  
    if ($mask) {$maskaddr = [Net.IPAddress]::Parse($mask)}  
    if ($ip) {$networkaddr = new-object net.ipaddress ($maskaddr.address -band $ipaddr.address)}  
    if ($ip) {$broadcastaddr = new-object net.ipaddress (([system.net.ipaddress]::parse("255.255.255.255").address -bxor $maskaddr.address -bor $networkaddr.address))}  
    
    if ($ip) {  
        $startaddr = IP-toINT64 -ip $networkaddr.ipaddresstostring  
        $endaddr = IP-toINT64 -ip $broadcastaddr.ipaddresstostring  
        } 
    else {  
        $startaddr = IP-toINT64 -ip $start  
        $endaddr = IP-toINT64 -ip $end  
        }  
    for ($i = $startaddr; $i -le $endaddr; $i++) {  
        INT64-toIP -int $i  
        } 
    
    }

$DC_exist=Test-Connection -ComputerName $DomainDNSName -Count 1 -Quiet
if (!$DC_exist){
    
    $colItems = Get-WmiObject -class "Win32_NetworkAdapterConfiguration" -computername $strComputer | Where {$_.IPEnabled -Match "True"}
    foreach ($objItem in $colItems) {
       $IPAddress=(($objItem.IPAddress) -split " ")[0]
       $IPSubnet=(($objItem.IPSubnet) -split " ")[0]
       $IPEnabled=$objItem.IPEnabled
       $array_temp=Get-IPrange -ip $IPAddress -mask $IPSubnet
       [string[]]$Address = $array_temp            
       [int]$Threads = 3            
        $JobAddresses = @{}            
        $CurJob = 0            
        $CurAddress = 0            
        while ($CurAddress -lt $Address.count){            
            $JobAddresses[$CurJob] += @($Address[$CurAddress])            
            $CurAddress++            
            if ($CurJob -eq $Threads -1){            
                $CurJob = 0            
                }            
            else{            
                $CurJob++            
                }            
            }            
        for($n=0;$n -le ($Threads-1);$n++){         
            Write-host "Starting job $n, for addresses $($JobAddresses[$n])"            
            Start-Job -ArgumentList $JobAddresses[$n] -ScriptBlock {            
                $ping = new-object System.Net.NetworkInformation.Ping            
                Foreach ($Ip in $Args){            
                    trap {            
                        new-object psobject -Property {
                            Status = "Error: $_"            
                            Address = $Ip            
                            RoundtripTime = 0            
                            }            
                        Continue            
                        }            
                    $ping.send($Ip,1) | select `
                        @{name="Status"; expression={$_.Status.ToString()}},             
                        @{name = "Address"; expression={$Ip}}, RoundtripTime            
                    }            
                } | Out-Null           
            }
        Get-Job  | wait-job | out-null
        $ipaddress=Get-Job  | receive-job -Keep| select status, address, roundtriptime | where {$_.status -eq "success"} | Select -expandproperty Address 
        get-job |remove-job | Out-Null          
        foreach ($obj in $ipaddress) {
          if (Test-Connection -ComputerName $obj -Count 1 -Quiet) {
            try {       
                $var=New-Object System.Net.Sockets.TCPClient -ArgumentList $obj,$portToCheck
                $props = @{
                    Server = $obj
                    }
                }

            catch {
                  continue
                }
            }
          }
       if($props){
               $DNS_DC=New-Object PsObject -Property $props
               $objItem.SetDNSServerSearchOrder($DNS_DC.Server) | Out-Null
               }
       }
    $DC_exist=Test-Connection -ComputerName $DomainDNSName -Count 1 -Quiet
    if (!$DC_exist){
        Install-ADDSForest `
        -DatabasePath "C:\Windows\NTDS" `
        -DomainMode "Win2012" `
        -DomainName $DomainDNSName `
        -DomainNetBIOSName $DomainNETBIOSName `
        -ForestMode "Win2012" `
        -InstallDNS:$true `
        -LogPath "C:\Windows\NTDS" `
        -NoRebootOnCompletion:$true `
        -SYSVOLPath "C:\Windows\SYSVOL" `
        -SafeModeAdministratorPassword $securePW `
        -Force:$true
        }
    else {
        Install-ADDSDomainController `
        -DomainName $DomainDNSName `
        -InstallDns:$true `
        -LogPath "C:\Windows\NTDS" `
        -SysvolPath "C:\Windows\SYSVOL" `
        -SafeModeAdministratorPassword $securePW `
        -NoRebootOnCompletion:$true `
        -Force:$true -credential $admincred
        }

    }
else {
    $DNSinInterface=(Get-WmiObject -class "Win32_NetworkAdapterConfiguration" `
    -computername '.' | Where {$_.IPEnabled -Match "True"}).DNSServerSearchOrder
    $IPDomain=(Test-Connection -ComputerName $DomainDNSName -Count 1).IPV4Address.IPAddressToString
    if($IPDomain -eq $DNSinInterface){ 
                Install-ADDSDomainController `
                -DomainName $DomainDNSName `
                -InstallDns:$true `
                -LogPath "C:\Windows\NTDS" `
                -SysvolPath "C:\Windows\SYSVOL" `
                -SafeModeAdministratorPassword $securePW `
                -NoRebootOnCompletion:$true `
                -Force:$true -credential $admincred
                }
    else{
        $objItem=Get-WmiObject -class "Win32_NetworkAdapterConfiguration" `
        -computername '.' | Where {$_.IPEnabled -Match "True"}
        $objItem.SetDNSServerSearchOrder($null) | Out-Null
        $colItems = Get-WmiObject -class "Win32_NetworkAdapterConfiguration" `
        -computername $strComputer | Where {$_.IPEnabled -Match "True"}
        foreach ($objItem in $colItems) {
        $IPAddress=(($objItem.IPAddress) -split " ")[0]
        $IPSubnet=(($objItem.IPSubnet) -split " ")[0]
        $IPEnabled=$objItem.IPEnabled
        $array_temp=Get-IPrange -ip $IPAddress -mask $IPSubnet
        [string[]]$Address = $array_temp            
        [int]$Threads = 3            
            $JobAddresses = @{}            
            $CurJob = 0            
            $CurAddress = 0            
            while ($CurAddress -lt $Address.count){            
                $JobAddresses[$CurJob] += @($Address[$CurAddress])            
                $CurAddress++            
                if ($CurJob -eq $Threads -1){            
                    $CurJob = 0            
                    }            
                else{            
                    $CurJob++            
                    }            
                }            
            for($n=0;$n -le ($Threads-1);$n++){         
                Write-host "Starting job $n, for addresses $($JobAddresses[$n])"            
                Start-Job -ArgumentList $JobAddresses[$n] -ScriptBlock {            
                    $ping = new-object System.Net.NetworkInformation.Ping            
                    Foreach ($Ip in $Args){            
                        trap {            
                            new-object psobject -Property {            
                                Status = "Error: $_"            
                                Address = $Ip            
                                RoundtripTime = 0            
                                }            
                            Continue            
                            }            
                        $ping.send($Ip,1) | select `
                            @{name="Status"; expression={$_.Status.ToString()}},             
                            @{name = "Address"; expression={$Ip}}, RoundtripTime            
                        }            
                    } | Out-Null           
                }
            Get-Job  | wait-job | out-null
            $ipaddress=Get-Job  | receive-job -Keep| select status, address, roundtriptime | where {$_.status -eq "success"} | Select -expandproperty Address 
            get-job |remove-job | Out-Null          
            foreach ($obj in $ipaddress) {
            if (Test-Connection -ComputerName $obj -Count 1 -Quiet) {
                try {       
                    $var=New-Object System.Net.Sockets.TCPClient -ArgumentList $obj,$portToCheck
                    $props = @{
                        Server = $obj
                        }
                    }

                catch {
                    continue
                    }
                }
            }
        if($props){
                $DNS_DC=New-Object PsObject -Property $props
                $objItem.SetDNSServerSearchOrder($DNS_DC.Server) | Out-Null
                }
        }
        $DC_exist=Test-Connection -ComputerName $DomainDNSName -Count 1 -Quiet
        if (!$DC_exist){
            Install-ADDSForest `
            -DatabasePath "C:\Windows\NTDS" `
            -DomainMode "Win2012" `
            -DomainName $DomainDNSName `
            -DomainNetBIOSName $DomainNETBIOSName `
            -ForestMode "Win2012" `
            -InstallDNS:$true `
            -LogPath "C:\Windows\NTDS" `
            -NoRebootOnCompletion:$true `
            -SYSVOLPath "C:\Windows\SYSVOL" `
            -SafeModeAdministratorPassword $securePW `
            -Force:$true
            }
        else {
            Install-ADDSDomainController `
            -DomainName $DomainDNSName `
            -InstallDns:$true `
            -LogPath "C:\Windows\NTDS" `
            -SysvolPath "C:\Windows\SYSVOL" `
            -SafeModeAdministratorPassword $securePW `
            -NoRebootOnCompletion:$true `
            -Force:$true -credential $admincred
            }
        }
    }




