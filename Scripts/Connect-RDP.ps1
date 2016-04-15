Param(
    # Server name
    [Parameter(Mandatory=$true)]
    [string]
    $servername
    )
$ServerData=get-ServerData -servername $servername

function Connect-Mstsc {
    [cmdletbinding(SupportsShouldProcess,DefaultParametersetName="UserPassword")]
    param (
        [Parameter(Mandatory=$true,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            Position=0)]
        [Alias("CN")]
            [string[]]$ComputerName,
        [Parameter(ParameterSetName="UserPassword",Mandatory=$true,Position=1)]
        [Alias("U")] 
            [string]$User,
        [Parameter(ParameterSetName="UserPassword",Mandatory=$true,Position=2)]
        [Alias("P")] 
            [string]$Password,
        [Parameter(ParameterSetName="Credential",Mandatory=$true,Position=1)]
        [Alias("C")]
            [PSCredential]$Credential,
        [Alias("A")]
            [switch]$Admin

    )

    begin {
        [string]$MstscArguments = ''
        switch ($true) {
            {$Admin} {$MstscArguments += '/admin '}

        }

        if ($Credential) {
            $User = $Credential.UserName
            $Password = $Credential.GetNetworkCredential().Password
        }
    }
    process {
        foreach ($Computer in $ComputerName) {
            $ProcessInfo = New-Object System.Diagnostics.ProcessStartInfo
            $Process = New-Object System.Diagnostics.Process
            
            # Remove the port number for CmdKey otherwise credentials are not entered correctly
            if ($Computer.Contains(':')) {
                $ComputerCmdkey = ($Computer -split ':')[0]
            } else {
                $ComputerCmdkey = $Computer
            }

            $ProcessInfo.FileName = "$($env:SystemRoot)\system32\cmdkey.exe"
            $ProcessInfo.Arguments = "/generic:TERMSRV/$ComputerCmdkey /user:$User /pass:$Password"
            $ProcessInfo.WindowStyle = [System.Diagnostics.ProcessWindowStyle]::Hidden
            $Process.StartInfo = $ProcessInfo
            if ($PSCmdlet.ShouldProcess($ComputerCmdkey,'Adding credentials to store')) {
                [void]$Process.Start()
            }

            $ProcessInfo.FileName = "$($env:SystemRoot)\system32\mstsc.exe"
            $ProcessInfo.Arguments = "$MstscArguments /v $Computer"
            $ProcessInfo.WindowStyle = [System.Diagnostics.ProcessWindowStyle]::Normal
            $Process.StartInfo = $ProcessInfo
            if ($PSCmdlet.ShouldProcess($Computer,'Connecting mstsc')) {
                [void]$Process.Start()
            }
        }
    }
}

Connect-Mstsc -ComputerName $ServerData.HPC_NETWORK_JT_INTERFACE_IP -User $ServerData.HPC_LOG_PASS -Password $ServerData.HPC_PASSWORD 