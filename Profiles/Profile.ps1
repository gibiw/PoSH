#Функция получения данных о серверах
#####################################################################
function Get-ServerData {
    param(
    #Параметр, который должен содержать хостнейм, КЕ или IP адрес сервера 
    [Parameter(Mandatory=$true)]
    [string]$servername
    )
    #Параметры подключения к удаленному серверу
    [string]$usernameremoteserver='.\Administrator'
    [string]$passwordremoteserver='^Gfbcv5R'
    [string]$ipremoteserver='10.126.240.47'
    #Параметры подключения к базу СМДБ
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
