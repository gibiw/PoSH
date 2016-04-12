#Установка агентов резервного копирования
Param(
    # Путь до файла с параметрами подготовки
    [Parameter(Position=1)]
    [String]
    $Path='C:\work\хлам\comp_new.csv'
    )
    
try {
    # Получаем список серверов из файла
    $comps = Import-Csv -Delimiter ';' -Encoding Unicode -Path $Path -ErrorAction Stop
    }
catch [System.Exception] {
    Write-Host "Ошибка при импорте из файла: $_"
    breake
    }  
Get-Date

#Цикл перебора серверов и запуска установки обновлений
foreach($comp in $comps){
                        $shluzall=$comp.shluzall #шлюз до сервера СРК и сервера с батниками
                        $ServerData=Get-ServerData -servername $comp.ip
                        $admin = $ServerData.HPC_LOG_PASS # логин администратора
                        #if($admin -eq 'root'){$admin='Administrator'}
                        $pass = $ServerData.HPC_PASSWORD # пароль администратора
                        $secpasswd = ConvertTo-SecureString "$pass" -AsPlainText -Force
                        $admincred = New-Object System.Management.Automation.PSCredential($admin,$secpasswd)
                        Invoke-Command -ComputerName $ServerData.HPC_NETWORK_JT_INTERFACE_IP -Credential $admincred -argumentlist $shluzall -ScriptBlock{
                            param($shluzall)
                            #Проверяем наличие маршрута до сервера с батниками
                            $routeall = route print | Select-String -Pattern "172.16.116.194"
                            $route = $routeall -match $shluzall
                            if($route -eq $false){
                                route add -p 172.16.116.194 $shluzall
                                }
                            #Проверяем наличие маршрута до сервера СРК
                            $routeall = route print | Select-String -Pattern "10.127.122.64"
                            $route = $routeall -match $shluzall
                            if($route -eq $false){
                                route add -p 10.127.122.64 mask 255.255.255.192 $shluzall
                                }
                            #Проверяем наличие записей в файле хост
                            $hosts = Get-Content C:\Windows\System32\drivers\etc\hosts
                            if(($hosts | Select-String -Pattern "10.127.122.65") -eq $null){                                    
                                net use w: \\172.16.116.194\Files_For_Scripts /user:passport.local\install_oem Ecnfyjdrf1Futynf2Vjybnjhbyuf3
                                cd W:\
                                .\SRK.bat
                                cd C:\
                                net use w: /delete
                                }
                            }
                        #Проверяем к какому контуру подключать сервер и какие компоненты устанавливать
                        if ($comp.kontur -eq 'new'){
                            if($comp.options -eq 'f'){$file = 'srk-new-file.bat'}
                            if($comp.options -eq 'b'){$file = 'srk-new-file-mssql.bat'}
                            }
                        if ($comp.kontur -eq 'old'){
                            if($comp.options -eq 'f'){$file = 'srk-old-file.bat'}
                            if($comp.options -eq 'b'){$file = 'srk-old-file-mssql.bat'}
                            }
                        #Определяем пути до батников
                        $filebatw = 'W:\'+$file
                        $filebatc = 'C:\'+$file 
                        Invoke-Command -ComputerName $ServerData.HPC_NETWORK_JT_INTERFACE_IP -Credential $admincred -argumentlist $filebatw,$filebatc -ScriptBlock{
                                    param ($filebatw,$filebatc)
                                    #Копируем батник с параметрами установки
                                    $secpasswdwsus = ConvertTo-SecureString "Ecnfyjdrf1Futynf2Vjybnjhbyuf3" -AsPlainText -Force
                                    $admincredwsus = New-Object System.Management.Automation.PSCredential('passport.local\install_oem',$secpasswdwsus)
                                    $user = $admincredwsus.UserName
                                    $net = New-Object -com WScript.Network
                                    $drive = "w:"
                                    $path = "\\172.16.116.194\Files_For_Scripts";
                                    $net.RemoveNetworkDrive($drive)
                                    $net.mapnetworkdrive($drive, $path, "true", $user, $admincredwsus.GetNetworkCredential().Password)
                                    Copy-Item $filebatw -Destination $filebatc -Force
                                    $net.RemoveNetworkDrive($drive)
                                    net use w: /delete
                                    }
                        #Запускаем процесс установки
                        $ip= '\\'+$ServerData.HPC_NETWORK_JT_INTERFACE_IP
                        cd C:\windows\System32
                        .\PsExec.exe $ip -u $admin -p $pass -s -d $filebatc
                        start-sleep -Seconds 30
                        }
# Счетчик процесса выполнения
for ($i=1;$i -le 1000; $i++){
                start-sleep -Seconds 1
                if ($i % 100 -eq 0){
                    $1 ="Выполнено "+$i/10 +"%"
                    $1
                    }
                }
# Цикл настройки на сервере СРК
foreach($comp in $comps){
                        $ServerData = Get-ServerData -servername $comp.ip
                        $admin = $ServerData.HPC_LOG_PASS # логин администратора
                        #if($admin -eq 'root'){$admin='Administrator'}
                        $pass = $ServerData.HPC_PASSWORD # пароль администратора
                        $secpasswd = ConvertTo-SecureString "$pass" -AsPlainText -Force
                        $admincred = New-Object System.Management.Automation.PSCredential($admin,$secpasswd)
                        #Проверяем к какому контуру подключать сервер и какие компоненты устанавливать
                        if ($comp.kontur -eq 'new'){
                            if($comp.options -eq 'f'){$file = 'srk-new-file.bat'}
                            if($comp.options -eq 'b'){$file = 'srk-new-file-mssql.bat'}
                            }
                        if ($comp.kontur -eq 'old'){
                            if($comp.options -eq 'f'){$file = 'srk-old-file.bat'}
                            if($comp.options -eq 'b'){$file = 'srk-old-file-mssql.bat'}
                            }
                        #Определяем путь до батника
                        $filebatc = 'C:\'+$file 
                        #Удаляем батник с сервера, после установки
                        Invoke-Command -ComputerName $ServerData.HPC_NETWORK_JT_INTERFACE_IP -Credential $admincred -argumentlist $filebatc -ScriptBlock{
                                    param ($filebatc)
                                    Remove-Item $filebatc -Force 
                                    }
                        # Получаем хостнем сервера
                        $host1= Invoke-Command -ComputerName $ServerData.HPC_NETWORK_JT_INTERFACE_IP -Credential $admincred -ScriptBlock{$env:COMPUTERNAME}
                        # Определяем IP адрес сервера
                        $ip1=$ServerData.HPC_NETWORK_JT_INTERFACE_IP
                        #Определяем в какой контур подключен сервер и прописываем настройки
                        if ($comp.kontur -eq 'new'){
                                      $ipkontur='172.16.36.17'
                                      $admins = 'Administrator'
                                      $passs = 'SRKPassw0rd'
                                      $secpasswds = ConvertTo-SecureString "$passs" -AsPlainText -Force
                                      $admincreds = New-Object System.Management.Automation.PSCredential($admins,$secpasswds)
                                      Invoke-Command -ComputerName $ipkontur -Credential $admincreds -ArgumentList $host1,$ip1 -ScriptBlock{
                                                        param ($host1,$ip1)
                                                        cd "c:\Program Files\Commvault\Simpana\Base\"
                                                        .\Qlogin.exe -u cmd_ln -clp Cmd_ln125
                                                        .\qoperation execscript -sn DataInterfacePairConfig.sql -si add -si $host1 -si $ip1 -si Mediaagent1-n -si 10.127.122.75
                                                        .\qoperation execscript -sn DataInterfacePairConfig.sql -si add -si $host1 -si $ip1 -si Mediaagent2-n -si 10.127.122.76
                                                        .\qoperation execscript -sn DataInterfacePairConfig.sql -si add -si $host1 -si $ip1 -si Commserve -si 10.127.122.80
                                                        .\qoperation execscript -sn DataInterfacePairConfig.sql -si add -si $host1 -si $ip1 -si Mediaagent-n-1 -si 10.127.122.81
                                                        .\qoperation execscript -sn DataInterfacePairConfig.sql -si add -si $host1 -si $ip1 -si Mediaagent-n-2 -si 10.127.122.82
                                                        .\qoperation execscript -sn DataInterfacePairConfig.sql -si add -si $host1 -si $ip1 -si Mediaagent-v-3 -si 10.127.122.83
                                                        .\qoperation execscript -sn DataInterfacePairConfig.sql -si add -si $host1 -si $ip1 -si Mediaagent-v-4 -si 10.127.122.84
                                                        .\Qlogout.exe
                                                        }
                                      }
                        if ($comp.kontur -eq 'old'){
                                      $ipkontur='10.126.240.48'
                                      $admins = 'Administrator'
                                      $passs = 'nfrRBio-394'
                                      $secpasswds = ConvertTo-SecureString "$passs" -AsPlainText -Force
                                      $admincreds = New-Object System.Management.Automation.PSCredential($admins,$secpasswds)
                                      Invoke-Command -ComputerName $ipkontur -Credential $admincreds -ArgumentList $host1,$ip1 -ScriptBlock{
                                                        param ($host1,$ip1)
                                                        cd "c:\Program Files\Commvault\Simpana\Base\"
                                                        .\Qlogin.exe -u cmd_ln -clp Cmd_ln125
                                                        .\qoperation execscript -sn DataInterfacePairConfig.sql -si add -si $host1 -si $ip1 -si is29-commserve -si 10.127.122.65
                                                        .\qoperation execscript -sn DataInterfacePairConfig.sql -si add -si $host1 -si $ip1 -si Mediaagent-1 -si 10.127.122.67
                                                        .\qoperation execscript -sn DataInterfacePairConfig.sql -si add -si $host1 -si $ip1 -si Mediaagent-2 -si 10.127.122.69
                                                        .\Qlogout.exe
                                                        }

                                      }

                        start-sleep -Seconds 10
                        }

Write-host "Агенты СРК установлены на все серверы"
Get-Date