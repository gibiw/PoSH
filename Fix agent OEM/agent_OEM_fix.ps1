﻿function fix_oem {
    Param ($ip,$pass,$log,$ke)
    #$info =$upadateneed
    $secpasswd = ConvertTo-SecureString "$pass" -AsPlainText -Force
    $admincred = New-Object System.Management.Automation.PSCredential($log,$secpasswd)
    Invoke-Command -ComputerName $ip -Credential $admincred -ArgumentList $ke,$ip -ScriptBlock{
            param ($ke,$ip)
            # Проверка статуса агента
            Write-Host "Проверяем статус"
            $statusOEM = C:\agentOEM\agent_inst\bin\emctl.bat status agent
            #Если все хорошо, то завершаем скрипт
            if($statusOEM -like 'Agent is Running and Ready'){
                $statusOEM
                Write-Host 'Все хорошо'
                }#end if
            # Если агент не запущен, то пробуем его запустить 
            elseif($statusOEM -like 'Agent is Not Running'){
                    $start = C:\agentOEM\agent_inst\bin\emctl.bat start agent
                    if($start -match 'service was started successfully'){
                        Write-host 'Агент успешно восстановлен запуском службы'
                        }#end if
                    else{
                        #Проверяем корректность файла хост
                        $hosts = Get-Content C:\Windows\System32\drivers\etc\hosts
                        #Проверяем наличие записи о КЕ
                        $line = $hosts | Select-String -Pattern $ke
                        #Если запись скрыта, то исправляем
                        if($Line.Line -match '#'){
                                $Linefix=$Line.line -replace '#',''
                                $hosts = $hosts -replace $Line.line,$Linefix
                                Set-Content C:\Windows\System32\drivers\etc\hosts -Value $hosts
                                }#enf if
                        #Если записи нет, то добавляем запись
                        if(!$line){
                                $hosts=$hosts+"$ip $env:COMPUTERNAME $ke"
                                Set-Content C:\Windows\System32\drivers\etc\hosts -Value $hosts
                                }#end if
                        $start = C:\agentOEM\agent_inst\bin\emctl.bat start agent
                        if($start -match 'service was started successfully'){
                            Write-host 'Агент успешно восстановлен правкой файла hosts'
                            }#end if
                        else{
                            Write-host 'Агент восстановить не удалось'
                            }#end else
                        }#end else
                    }#end elseif
            #Если битый perl, то восстанавливаем
            elseif($statusOEM -eq $null){
                        #Проверяем наличие маршрута до сервера 172,16,116,194, где находятся корректные папки bin и perl
                        $route = route print | Select-String -Pattern "172.16.116.194"
                        if($route){
                                #Подлкючаем сетевой диск для разорхивирования файлов 
                                net use w: \\172.16.116.194\12.1.0.5.0_AgentCore_233 /user:passport.local\install_oem Ecnfyjdrf1Futynf2Vjybnjhbyuf3
                                #Распаковка архива
                                W:\7za920\7za.exe e w:\bin.zip -oC:\agentOEM\core\12.1.0.4.0\perl\bin -y
                                #Запускаем агент мониторинга
                                $start = C:\agentOEM\agent_inst\bin\emctl.bat start agent
                                if($start -match 'service was started successfully'){
                                    Write-host 'Агент успешно восстановлен заменой папки bin'
                                    }#end if
                                    #Если не удалось запустить, то заменяем папку perl
                                else{
                                    #Распаковка архива
                                    W:\7za920\7za.exe e w:\perl.zip -oC:\agentOEM\core\12.1.0.4.0\perl -y
                                    #Запускаем агент мониторинга
                                    $start = C:\agentOEM\agent_inst\bin\emctl.bat start agent
                                    if($start -match 'service was started successfully'){
                                        Write-host 'Агент успешно восстановлен заменой папки perl'
                                        }#end if
                                    else{
                                        Write-host 'Агент восстановить не удалось'
                                        }#end else
                                    }#end else        
                                #Отключаем сетевой диск
                                net use w: /delete
                                }#end if
                        #Сообщяем, что маршрута нет
                        else{
                            Write-host 'Нет маршрута до сервера 172.16.116.194'
                            }#end else
                        }#end elseif
            }#end scriptblock
    }
$hostname=read-host -Prompt "Введите КЕ"
$secpasswdwsus = ConvertTo-SecureString "^Gfbcv5R" -AsPlainText -Force
$admincredwsus = New-Object System.Management.Automation.PSCredential('Administrator',$secpasswdwsus)
$upadateneed = Invoke-Command -ComputerName 10.126.240.47 -Credential $admincredwsus -ArgumentList $hostname -ScriptBlock{
    param($hostname)
    function Get-DatabaseData{
        [CmdletBinding()]
        param (
            [Parameter(Mandatory=$true)]
            [string]$servername
            )
        if($hostname[0] -match "[\d]" -and $hostname -match "\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}"){
            $query = "SELECT * FROM server_info_new where HPC_NETWORK_JT_INTERFACE_IP like '$servername'"
            }#end if
        elseif($hostname[0] -match "[a-z]" -and $hostname -match "\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}"){
            $query = "SELECT * FROM server_info_new where LOGICAL_NAME like '$servername'"
            }#end elseif
        else{
            $query = "SELECT * FROM server_info_new where HPC_HOST_NAME like '$servername'"
            }#end else

        $dataSource = "10.126.242.1"
        $database = "Cmdb"
        $user='sa'
        $pwd='Qwe`123'
        $connection = New-Object System.Data.SqlClient.SqlConnection
        $connection.ConnectionString = "Server=$dataSource;Database=$database;uid=$user;pwd=$pwd;Integrated Security=false;"
        $connection.Open()

        $command = $connection.CreateCommand()
        $command.CommandText = $query
        $result = $command.ExecuteReader()
        $table = new-object “System.Data.DataTable”
        $table.Load($result)
        return $table
        }

    Get-DatabaseData -servername $hostname | select *
    }

$ip = $upadateneed.HPC_NETWORK_JT_INTERFACE_IP
$pass = $upadateneed.HPC_PASSWORD
$log = $upadateneed.HPC_LOG_PASS
$ke=$upadateneed.LOGICAL_NAME
fix_oem -ip $ip -pass $pass -log $log -ke $ke