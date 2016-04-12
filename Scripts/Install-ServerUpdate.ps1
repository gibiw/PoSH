# Установка всех доступных обновлений для пула серверов
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

get-date

#Учетные данные для WSUS
$secpasswdwsus = ConvertTo-SecureString "^Gfbcv5R" -AsPlainText -Force
$admincredwsus = New-Object System.Management.Automation.PSCredential('Administrator',$secpasswdwsus)

#Переводим данные в массив, для удобства отрабоки с следующем цикле
$array = @()
foreach($comp in $comps){
    $ServerData=Get-ServerData -servername $comp.ip
    $obj = New-Object PSObject -Property @{
        ip=$ServerData.HPC_NETWORK_JT_INTERFACE_IP
        login=$ServerData.HPC_LOG_PASS
        pass=$ServerData.HPC_PASSWORD
        shluzwsus=$ServerData.shluzwsus
        shluzall=$ServerData.shluzall
        }
    $array+=$obj 
    }
#Цикл перебора и запуска задания обновления
do{
    foreach($comp in $array){
        $ip=$comp.ip #IP адрес компьютера
        Write-host "Начинаем процесс обновления сервера $ip"
        $shluzwsus=$comp.shluzwsus #шлюз до сервера обновления
        $shluzall=$comp.shluzall #шлюз до сервера с батниками
        $admin = $comp.login #логин администратора
        $pass = $comp.pass #пароль администратора
        $secpasswd = ConvertTo-SecureString "$pass" -AsPlainText -Force
        $admincred = New-Object System.Management.Automation.PSCredential($admin,$secpasswd)
        #Запрашиваем хост нейм тачки
        $hostname = Invoke-Command -ComputerName $comp.ip -Credential $admincred -ScriptBlock{$env:COMPUTERNAME}
        #Проверяем количество неустановленых обновлений
        $upadateneed = Invoke-Command -ComputerName 10.126.240.47 -Credential $admincredwsus -ArgumentList $hostname -ScriptBlock{
            param($hostname)
            [reflection.assembly]::LoadWithPartialName("Microsoft.UpdateServices.Administration")|out-null
            $wsus = [Microsoft.UpdateServices.Administration.AdminProxy]::GetUpdateServer();
            $compstatus= $wsus.SearchComputerTargets($hostname)
            $compstatusupdate = $compstatus.GetUpdateInstallationSummary().NotInstalledCount + $compstatus.GetUpdateInstallationSummary().FailedCount
            Return $compstatusupdate
            }
        # Если не все обновления установлены, то запускаем процесс установки
        if ($upadateneed -ne 0){
            # Проверяем, не устанавливаются ли в настоящий момент обновления
            $proccesowner = Invoke-Command -ComputerName $comp.ip -Credential $admincred -ScriptBlock{Get-Process | where {$_.name -eq 'powershell'}}
            # Если обновления не устанавливаются, то запускаем процесс установки
            if($proccesowner -eq $null){
                Write-host "Осталось установить обновлений: $upadateneed"
                Invoke-Command -ComputerName $comp.ip -Credential $admincred -ArgumentList $shluzwsus,$shluzall -ScriptBlock{
                    param($shluzwsus,$shluzall)
                    # Проверяем наличие маршрута до сервера WSUS
                    $routewsus = route print | Select-String -Pattern "10.126.240.47"
                    $route = $routewsus -match $shluzwsus
                    if($route -eq $false){
                        route delete -p 10.126.240.47
                        route add -p 10.126.240.47 $shluzwsus
                        }
                    # Проверяем наличие маршрута до сервера с батниками
                    $routeall = route print | Select-String -Pattern "172.16.116.194"
                    $route = $routeall -match $shluzall
                    if($route -eq $false){
                        route add -p 172.16.116.194 $shluzall
                        }
                    # Проверяем наличие модуля для установки обновлений
                    $moduleupdate = ls C:\Windows\System32\WindowsPowerShell\v1.0\Modules | where {$_.name -eq "PSWindowsUpdate"}
                    if($moduleupdate -eq $null){
                        net use w: \\172.16.116.194\Files_For_Scripts /user:passport.local\install_oem Ecnfyjdrf1Futynf2Vjybnjhbyuf3
                        Copy-Item W:\PSWindowsUpdate -Recurse -Destination C:\Windows\System32\WindowsPowerShell\v1.0\Modules -Force
                        net use w: /delete
                        }
                   # Проверяем наличие батника, который запускает процесс обновления
                   $bat = ls c:\ |where {$_.name -eq 'installupdate.bat'}
                   if($bat -eq $null){
                        net use w: \\172.16.116.194\Files_For_Scripts /user:passport.local\install_oem Ecnfyjdrf1Futynf2Vjybnjhbyuf3
                        Copy-Item W:\installupdate.bat -Recurse -Destination C:\installupdate.bat -Force
                        net use w: /delete
                        }
                   }
                #Запускаем батник с помощью PSExec от имени SYSTEM
                $ip= '\\'+$comp.ip
                cd C:\Windows\system32
                .\PsExec.exe $ip -u $admin -p $pass -s -d C:\installupdate.bat
                }
            # Если процесс обновления еще идет, то сообщяем об этом
            else{
               Write-host "Обновления еще устанавливаются. Осталось установить обновлений: $upadateneed"
               }
            }
        # Если установлены уже все обновления, то исключаем сервер из массива серверов
        else{
            Write-host "Все обновления на сервер $ip установлены. Исключаем его из пула серверов"
            Invoke-Command -ComputerName $comp.ip -Credential $admincred -scriptblock {Remove-Item C:\installupdate.bat -Force}
            $array = $array | where {$_.ip -ne $comp.ip}
            }
        }
    # Счетчик процесса выполнения
    if($array.count -ne '0'){
        $j=40
        for ($i=1;$i -le 600; $i++){
            start-sleep -Seconds 1
            if ($i % 60 -eq 0){  
                $1 ="Выполнено "+($i+$j)/10 +"%"
                $j=$j+40    
                $1
                }
            }
        }
    }
until($array.count -eq 0)
Write-host "Все сервера обновлены"
get-date