function Get-ServerData {
    param(
    [Parameter(Mandatory=$true)]
    [string]$servername
    )
    [string]$usernameremoteserver='.\Administrator'
    [string]$passwordremoteserver='^Gfbcv5R'
    [string]$ipremoteserver='10.126.240.47'
    [string]$dataSource = '10.126.242.1'
    [string]$database = 'Cmdb'
    [string]$DBuser='sa'
    [string]$DBpwd='Qwe`123'   
    
    $secpasswd = ConvertTo-SecureString $passwordremoteserver -AsPlainText -Force
    $admincred = New-Object System.Management.Automation.PSCredential($usernameremoteserver,$secpasswd)
    $ServerData = Invoke-Command -ComputerName $ipremoteserver -Credential $admincred -ArgumentList $servername,$dataSource,$database,$DBuser,$DBpwd -ScriptBlock{
        param(
            $servername,
            $dataSource,
            $database,
            $DBuser,
            $DBpwd                      
            )
        function Get-DatabaseData{
            [CmdletBinding()]
            param (
                [Parameter(Mandatory=$true)]
                [string]$servername,
                [Parameter(Mandatory=$true)]
                [string]$dataSource,
                [Parameter(Mandatory=$true)]
                [string]$database,
                [Parameter(Mandatory=$true)]
                [string]$DBuser,
                [Parameter(Mandatory=$true)]
                [string]$DBpwd
                )
            if($servername[0] -match "[\d]" -and $servername -match "\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}"){
                $query = "SELECT * FROM server_info_new where HPC_NETWORK_JT_INTERFACE_IP like '$servername'"
                }#end if
            elseif($servername[0] -match "[a-z]" -and $servername -match "\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}"){
                $query = "SELECT * FROM server_info_new where LOGICAL_NAME like '$servername'"
                }#end elseif
            else{
                $query = "SELECT * FROM server_info_new where HPC_HOST_NAME like '$servername'"
                }#end else

            $connection = New-Object System.Data.SqlClient.SqlConnection
            $connection.ConnectionString = "Server=$dataSource;Database=$database;uid=$DBuser;pwd=$DBpwd;Integrated Security=false;"
            $connection.Open()

            $command = $connection.CreateCommand()
            $command.CommandText = $query
            $result = $command.ExecuteReader()
            $table = new-object “System.Data.DataTable”
            $table.Load($result)
            return $table
            }

        Get-DatabaseData -servername $servername -dataSource $dataSource -database $database -DBuser $DBuser -DBpwd $DBpwd | select *
        }
    return $ServerData  
    }
function Download-File {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Url,
        [Parameter(Mandatory=$true)]
        [string]$Path    
        )
    $Url | % { 
            $uri = new-Object System.Uri $_ ; 
            $localPath = "$Path\$($uri.Segments[-1])"; 
            $webClient = new-object System.Net.WebClient;
            $webClient.DownloadFile($uri,$localPath); 
            }
    }


$PowerShellScriptsFolder='C:\PowerShellScripts'
$PowerShellScriptsFolderNew='C:\'
$PowerShellScriptsPath='C:\PowerShellScripts\Scripts'
$filesToDownload = "https://github.com/gibiw/PoSH/archive/master.zip"


try{
    if (!(Test-Path -Path $PowerShellScriptsFolder)){
        New-Item -Path $PowerShellScriptsFolderNew -ItemType Directory -Name PowerShellScripts -ErrorAction Stop | Out-Null
        }
    }
catch{
    Write-Host "Error created folder: $_" -ForegroundColor Red
    break
    }


if (!((Get-Item env:path).value -like "*$PowerShellScriptsPath*")){
    $env:path = $env:path + ";$PowerShellScriptsPath"
    } 

if(Test-Path -Path ($PowerShellScriptsFolder+'\version.txt')){
            if((Get-Content -Path ($PowerShellScriptsFolder+'\version.txt')) -ne (Invoke-WebRequest -uri 'https://raw.githubusercontent.com/gibiw/PoSH/master/Version.txt').content){
                if(Test-NetConnection -InformationLevel Quiet -ErrorAction Stop){
                    Download-File -Url $filesToDownload -Path $PowerShellScriptsFolder
                    [System.Reflection.Assembly]::LoadWithPartialName('System.IO.Compression.FileSystem') | Out-Null 
                    [System.IO.Compression.ZipFile]::ExtractToDirectory(($PowerShellScriptsFolder+"\master.zip"), $PowerShellScriptsFolder) 
                    Remove-Item -Path ($PowerShellScriptsFolder+"\master.zip") -Force
                    Copy-Item -Path ($PowerShellScriptsFolder+"\PoSH-master\*") -Destination $PowerShellScriptsFolder -Force -Recurse
                    Remove-Item -Path ($PowerShellScriptsFolder+"\PoSH-master\") -Force -Recurse
                    }
                else{
                    Write-Host "Internet not avalability" -ForegroundColor Red
                    }    
                }
            }
else{
    
    if(Test-NetConnection -InformationLevel Quiet -ErrorAction Stop){
        Download-File -Url $filesToDownload -Path $PowerShellScriptsFolder
        [System.Reflection.Assembly]::LoadWithPartialName('System.IO.Compression.FileSystem') | Out-Null 
        [System.IO.Compression.ZipFile]::ExtractToDirectory(($PowerShellScriptsFolder+"\master.zip"), $PowerShellScriptsFolder) 
        Remove-Item -Path ($PowerShellScriptsFolder+"\master.zip") -Force
        Copy-Item -Path ($PowerShellScriptsFolder+"\PoSH-master\*") -Destination $PowerShellScriptsFolder -Force -Recurse
        Remove-Item -Path ($PowerShellScriptsFolder+"\PoSH-master\") -Force -Recurse
        }
    else{
        Write-Host "Internet not avalability" -ForegroundColor Red
        }
    }

if(!(Test-Path -Path ($PowerShellScriptsPath+'\Psexec.exe'))){
     [System.Reflection.Assembly]::LoadWithPartialName('System.IO.Compression.FileSystem') | Out-Null 
     [System.IO.Compression.ZipFile]::ExtractToDirectory(($PowerShellScriptsFolder+"\Utils\PsExec.zip"),($PowerShellScriptsPath))    
    }

if (!(Test-Path -Path $profile.CurrentUserAllHosts)) {
    New-Item -ItemType file -Path $profile.CurrentUserAllHosts -force
    Copy-Item -Path ($PowerShellScriptsFolder+'\Profiles\Profile.ps1') -Destination $profile.CurrentUserAllHosts -Force
    .$profile.CurrentUserAllHosts
    }
else{
    if((Get-Content -Path $profile.CurrentUserAllHosts | select -First 1) -ne ((Invoke-WebRequest -uri 'https://raw.githubusercontent.com/gibiw/PoSH/master/Profiles/Profile.ps1').content | select -First 1)){
        Copy-Item -Path ($PowerShellScriptsFolder+'\Profiles\Profile.ps1') -Destination $profile.CurrentUserAllHosts -Force
        .$profile.CurrentUserAllHosts
        }
    }