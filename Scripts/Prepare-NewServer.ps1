    # Подготовка сервера
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
    
    # Цикл настройки
    foreach($comp in $comps){
        $shluzwsus=$comp.shluzwsus # Шлюз до сервера всус
        $shluzall=$comp.shluzall # Шлюз до остальных серверов
        $ad=$comp.ad # Добавление в домен или нет
        $is=$comp.is # Название ИС
        #получаем учетные данные для авторизации на удаленном сервере
        $ServerData=Get-ServerData -servername $comp.ip
        $admin = $ServerData.HPC_LOG_PASS # логин администратора
        $pass = $ServerData.HPC_PASSWORD # пароль администратора
        $ipmgmt=$ServerData.HPC_NETWORK_JT_INTERFACE_IP # менеджмент IP 
        $secpasswd = ConvertTo-SecureString "$pass" -AsPlainText -Force
        $admincred = New-Object System.Management.Automation.PSCredential($admin,$secpasswd)
        Invoke-Command -ComputerName $ServerData.HPC_NETWORK_JT_INTERFACE_IP -Credential $admincred -argumentlist $shluzwsus,$shluzall,$is,$ipmgmt,$ad -ScriptBlock{
            param(
                $shluzwsus,
                $shluzall,
                $is,
                $ipmgmt,
                $ad
                )
            Write-Host 'Прописываем маршруты'    
            route delete -p 10.126.240.47 | Out-Null
            route add -p 10.126.240.47 $shluzwsus
            route delete -p 172.16.156.17 | Out-Null
            route add -p 172.16.156.17 mask 255.255.255.255 $shluzall
            route delete -p 172.16.116.194 | Out-Null
            route add -p 172.16.116.194 mask 255.255.255.255 $shluzall
            route delete -p 10.127.122.64 | Out-Null
            route add -p 10.127.122.64 mask 255.255.255.192 $shluzall
            route delete -p 10.126.126.137 | Out-Null
            route add -p 10.126.126.137 $shluzall
            route delete -p 10.126.89.36 | Out-Null
            route add -p 10.126.89.36 mask 255.255.255.255 $shluzall
            route delete -p 10.126.89.37 | Out-Null
            route add -p 10.126.89.37 mask 255.255.255.255 $shluzall
            route delete -p 10.126.242.0 | Out-Null
            route add -p 10.126.242.0 mask 255.255.255.192 $shluzall
            
            Write-Host 'Активируем ОС'
            $OSVersion=(Get-WmiObject -Class Win32_OperatingSystem).caption
            if($OSVersion -match "2008 R2 Standard"){$key = 'YC6KT-GKW9T-YTKYR-T4X34-R7VHC'}
            if($OSVersion -match "2008 R2 Enterprise"){$key = '489J6-VHDMP-X63PK-3K798-CPX3Y'}
            if($OSVersion -match "2012 R2 Standard"){$key = 'D2N9P-3P6X9-2R39C-7RTCD-MDVJX'}
            if($OSVersion -match "2012 R2 Datacenter"){$key = 'W3GGN-FT8W3-Y4M27-J84CP-Q3VJ9'}
            cscript $env:windir\System32\slmgr.vbs /ipk $key
            cscript $env:windir\System32\slmgr.vbs /skms 10.126.240.47:1688 
            cscript $env:windir\System32\slmgr.vbs /ato 
            
            Write-Host 'Подключаем к серверу WSUS'
            reg add HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate /v WUServer /t REG_SZ /d http://10.126.240.47 /f
            reg add HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate /v WUStatusServer /t REG_SZ /d http://10.126.240.47 /f
            reg add HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate /v TargetGroupEnabled /t REG_dword /d 00000001 /f
            reg add HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate /v TargetGroup /t REG_SZ /d "$is" /f
            reg add HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU /v UseWUServer /t REG_dword /d 00000001 /f
            reg add HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU /v NoAutoUpdate /t REG_dword /d 00000000 /f
            reg add HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU /v AUOptions /t REG_dword /d 00000002 /f
            reg add HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU /v ScheduledInstallDay /t REG_dword /d 00000007 /f
            reg add HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU /v ScheduledInstallTime /t REG_dword /d 00000003 /f
            reg add HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU /v DetectionFrequencyEnabled /t REG_dword /d 00000001 /f
            reg add HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU /v DetectionFrequency /t REG_dword /d 00000016 /f
            reg add HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU /v NoAutoRebootWithLoggedOnUsers /t REG_dword /d 00000001 /f
            Get-Service wuauserv | Stop-Service -Force -PassThru
            reg delete HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate /v PingID /f | Out-Null
            reg delete HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate /v AccountDomainSid /f | Out-Null
            reg delete HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate /v SusClientId /f | Out-Null
            reg delete HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate /v SusClientIDValidation  /f | Out-Null
            Get-Service wuauserv | Start-Service -PassThru
            wuauclt.exe /resetauthorization /detectnow
            
            Write-Host 'Настраиваем подключение к NTP серверу'
            Get-Service W32Time | Stop-Service -Force -PassThru
            w32tm /config /syncfromflags:manual /manualpeerlist:10.126.126.137
            Get-Service W32Time | Start-Service -PassThru
            
            Write-Host 'Расширяем файловую систему'
            $drives=Get-WmiObject -Class win32_diskdrive
            foreach($drive in $drives){
                        $indexdrive = $drive.Index
                        $fullsize=$drive.size
                        $partitions=Get-WmiObject -Class win32_diskpartition | select * | where {$_.DiskIndex -eq $indexdrive}
                        if($partitions){
                            $sizepartitionsum=0
                            foreach($partition in $partitions){
                                $sizepartitionsum=$sizepartitionsum + $partition.size
                                }
                            $disksizenotused = $fullsize - $sizepartitionsum
                            $disksizenotused ="{0:N0}" -f ($disksizenotused/ 1GB)
                            if($disksizenotused -le 1){
                                $statusdisk = 'True'
                                }
                            else{
                                "rescan","select volume 2","extend" | diskpart
                                }
                        }
                        else{
                            "rescan","select disk $indexdrive","create partition primary","assign","format fs=ntfs label='Data drive' quick" | diskpart
                            }
                        }
            if($ad -eq 'y'){
                    write-host 'Включаем в домен'
                    $DNS_DC='172.16.116.194','10.126.126.137'
                    $adapter=Get-WmiObject -class "Win32_NetworkAdapterConfiguration"  | Where {$_.IPAddress -Match $ipmgmt}
                    $adapter.SetDNSServerSearchOrder($DNS_DC) | Out-Null
                    $domain = "passport.local"
                    $password = "LSNM6mbaCK5wAeVu18sm0XR9pZavoPfm8R9pZavoPfm8uJdxyVXkNv2g" | ConvertTo-SecureString -asPlainText -Force
                    $username = "$domain\add_computer" 
                    $credential = New-Object System.Management.Automation.PSCredential($username,$password)
                    Add-Computer -DomainName $domain -Credential $credential -PassThru
                    Restart-Computer -Force
                    }
            }
        }
    
        




