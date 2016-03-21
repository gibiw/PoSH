[void][Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")

# определение функций#############################################################################################################
$PSfileRoot = "C:\Users\gridnev\OneDrive\GitHub\PoSH\Preparing the infrastructure"
$rootpath=$PSfileRoot+"\Config.xml"
$logpath1=$PSfileRoot+"\logOU.txt"
$logpath2=$PSfileRoot+"\logCMP.txt"
$logpath3=$PSfileRoot+"\logUsers.txt"
$imagepath=$PSfileRoot+"\logo.jpg"

try {
    [xml] $Config = Get-Content $rootpath -Encoding UTF8
    }
catch [System.Exception] {
    LogAdd ("Ошибка при импорте конфигурации: " +$Error[0])
    break   
    }
$settingsOU = $Config.selectnodes(‘Main/CreateOU’)
$settingsCMP = $Config.selectnodes(‘Main/CreateCMP’)
$settingsUser = $Config.selectnodes(‘Main/CreateUsers’) 
$settingsUtil = $Config.selectnodes(‘Main/UtilSettings’)


$Error[0]=$null
#Создание графического интерфейса
Function Create_label($label,$caption,$left,$top,$width,$height,$panel,$a)
                       { 
                        $label.Location = New-Object System.Drawing.Point($left, $top)
                        $label.Size = New-Object System.Drawing.Size($width, $height)
                        $label.text = $caption
                        $label.font = $font
                        $Panel.Controls.add($label)
                        if($a){$label.autoSize =$true}
                        }


# Функция транслитизации для OU
function tr {
    param([string]$inString)
    $Translit = @{ 
    [char]' ' = "_"
    [char]'-' = "_"
    [char]'(' = "_"
    [char]')' = "_"
    [char]'а' = "a"
    [char]'А' = "A"
    [char]'б' = "b"
    [char]'Б' = "B"
    [char]'в' = "v"
    [char]'В' = "V"
    [char]'г' = "g"
    [char]'Г' = "G"
    [char]'д' = "d"
    [char]'Д' = "D"
    [char]'е' = "e"
    [char]'Е' = "E"
    [char]'ё' = "yo"
    [char]'Ё' = "Yo"
    [char]'ж' = "zh"
    [char]'Ж' = "Zh"
    [char]'з' = "z"
    [char]'З' = "Z"
    [char]'и' = "i"
    [char]'И' = "I"
    [char]'й' = "y"
    [char]'Й' = "Y"
    [char]'к' = "k"
    [char]'К' = "K"
    [char]'л' = "l"
    [char]'Л' = "L"
    [char]'м' = "m"
    [char]'М' = "M"
    [char]'н' = "n"
    [char]'Н' = "N"
    [char]'о' = "o"
    [char]'О' = "O"
    [char]'п' = "p"
    [char]'П' = "P"
    [char]'р' = "r"
    [char]'Р' = "R"
    [char]'с' = "s"
    [char]'С' = "S"
    [char]'т' = "t"
    [char]'Т' = "T"
    [char]'у' = "u"
    [char]'У' = "U"
    [char]'ф' = "f"
    [char]'Ф' = "F"
    [char]'х' = "h"
    [char]'Х' = "H"
    [char]'ц' = "c"
    [char]'Ц' = "C"
    [char]'ч' = "ch"
    [char]'Ч' = "Ch"
    [char]'ш' = "sh"
    [char]'Ш' = "Sh"
    [char]'щ' = "sch"
    [char]'Щ' = "Sch"
    [char]'ъ' = ""
    [char]'Ъ' = ""
    [char]'ы' = "y"
    [char]'Ы' = "Y"
    [char]'ь' = ""
    [char]'Ь' = ""
    [char]'э' = "e"
    [char]'Э' = "E"
    [char]'ю' = "yu"
    [char]'Ю' = "Yu"
    [char]'я' = "ya"
    [char]'Я' = "Ya"
    }
    $outCHR=""
    foreach ($CHR in $inCHR = $inString.ToCharArray())
        {
        if ($Translit[$CHR] -cne $Null ) 
            {$outCHR += $Translit[$CHR]}
        else
            {$outCHR += $CHR}
        }
    Write-Output $outCHR
    }
#функция транслита для пользователей
function translit {
    param([string]$inString)
    $Translit = @{ 
    [char]'а' = "a"
    [char]'А' = "A"
    [char]'б' = "b"
    [char]'Б' = "B"
    [char]'в' = "v"
    [char]'В' = "V"
    [char]'г' = "g"
    [char]'Г' = "G"
    [char]'д' = "d"
    [char]'Д' = "D"
    [char]'е' = "e"
    [char]'Е' = "E"
    [char]'ё' = "yo"
    [char]'Ё' = "Yo"
    [char]'ж' = "zh"
    [char]'Ж' = "Zh"
    [char]'з' = "z"
    [char]'З' = "Z"
    [char]'и' = "i"
    [char]'И' = "I"
    [char]'й' = "y"
    [char]'Й' = "Y"
    [char]'к' = "k"
    [char]'К' = "K"
    [char]'л' = "l"
    [char]'Л' = "L"
    [char]'м' = "m"
    [char]'М' = "M"
    [char]'н' = "n"
    [char]'Н' = "N"
    [char]'о' = "o"
    [char]'О' = "O"
    [char]'п' = "p"
    [char]'П' = "P"
    [char]'р' = "r"
    [char]'Р' = "R"
    [char]'с' = "s"
    [char]'С' = "S"
    [char]'т' = "t"
    [char]'Т' = "T"
    [char]'у' = "u"
    [char]'У' = "U"
    [char]'ф' = "f"
    [char]'Ф' = "F"
    [char]'х' = "h"
    [char]'Х' = "H"
    [char]'ц' = "c"
    [char]'Ц' = "C"
    [char]'ч' = "ch"
    [char]'Ч' = "Ch"
    [char]'ш' = "sh"
    [char]'Ш' = "Sh"
    [char]'щ' = "sch"
    [char]'Щ' = "Sch"
    [char]'ъ' = ""
    [char]'Ъ' = ""
    [char]'ы' = "y"
    [char]'Ы' = "Y"
    [char]'ь' = ""
    [char]'Ь' = ""
    [char]'э' = "e"
    [char]'Э' = "E"
    [char]'ю' = "yu"
    [char]'Ю' = "Yu"
    [char]'я' = "ya"
    [char]'Я' = "Ya"
    }
    $outCHR=""
    foreach ($CHR in $inCHR = $inString.ToCharArray())
        {
        if ($Translit[$CHR] -cne $Null ) 
            {$outCHR += $Translit[$CHR]}
        else
            {$outCHR += $CHR}
        }
    Write-Output $outCHR

    }
#Функция логов (пример, LogAdd ("Текст"))
function LogAdd($msg)
	{
	$Logs.text = $Logs.text + $msg + [char]13
	$msg="" # нах не нужно, но меня пугает.
     	}
 # Функция определения переменных для создания OU
function OU {
    $OU=$InputFName.text
    $name= (Tr "$($OU)").ToUpper()
    $Result1.Text=$name
    $Result2.Text=$settingsOU.NameGroupn+$name+$settingsOU.NameGroupk
    }
# Функция создания OU и групп
function createOU {
    $logs.Text = $null
    $progressBar.minimum = 1
    $progressBar.maximum = 5
    $progressBar.step = 1
    $Path1=$settingsOU.PathCreateGroups
    $path2=$settingsOU.PathCreateServers
    $members=$settingsOU.DefaultAddMember
    $Name=$Result1.Text
    $OU=$InputFName.text
    $groupname=$settingsOU.NameGroupn+$name+$settingsOU.NameGroupk
    $path3=$settingsOU.PathCreateGroup+$name+','+$settingsOU.PathCreateGroups
    LogAdd ("Импортируем модуль AD")
    Start-Sleep -Seconds 1
    Import-Module Activedirectory
    $progressBar.performstep()
    LogAdd ("Модуль AD импортирован")
    Start-Sleep -Seconds 1
    LogAdd ("Создаем OU "+$OU)
    Start-Sleep -Seconds 1
    $Error[0]=$null
    New-ADOrganizationalUnit -Name $Name -Description $OU -Path $Path1
    $progressBar.performstep()
    Start-Sleep -Seconds 1
    if($Error[0]){LogAdd ("Ошибка при создании OU в группах: " +$Error[0])}
    $Error[0]=$null
    New-ADOrganizationalUnit -Name $Name -Description $OU -Path $path2
    $progressBar.performstep()
    Start-Sleep -Seconds 1
    if($Error[0]){LogAdd ("Ошибка при создании OU в серверах: " +$Error[0])}
    LogAdd ("Создаем группу "+$groupname)
    Start-Sleep -Seconds 1
    $Error[0]=$null
    New-ADGroup -Path $path3 -Name $groupname -GroupScope Universal -GroupCategory Security
    $progressBar.performstep()
    Start-Sleep -Seconds 1
    if($Error[0]){LogAdd ("Ошибка при создании группы: " +$Error[0])}
    $member=$members -split ','
    foreach ($memb in $member){
        $Error[0]=$null
        Get-ADGroup $groupname | Add-ADGroupMember -Members $memb
        Start-Sleep -Seconds 1
        if($Error[0]){LogAdd ("Ошибка при добавлении $memb в группу $groupname : " +$Error[0])}
        }
    $progressBar.performstep()
    Start-Sleep -Seconds 1
    LogAdd ("OUs и группы созданы")
    get-date >> $logpath1
    $Logs.text >> $logpath1
    }
# Функция кнопки "Обзор" и вывода текста в бокс ListBox (создание компов)
function Browse {
    $ListBox.Items.clear()
    Add-Type -AssemblyName System.Windows.Forms
    $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{
        Multiselect = $true
        }
    [void]$FileBrowser.ShowDialog()
    $InputFName4.Text=$FileBrowser.FileNames
    $comps = Import-Csv -Delimiter ";" -Path $InputFName4.Text | select computername,is
    $ListBox.Items.AddRange($comps.computername)
    $gdeOUr.Text = $comps.is | select -First 1
    }
# Функция кнопки "Обзор" и вывода текста в бокс ListBox (создание пользователей)
function Browse1 {
    $ListBox1.Items.clear()
    Add-Type -AssemblyName System.Windows.Forms
    $FileBrowser1 = New-Object System.Windows.Forms.OpenFileDialog -Property @{
        Multiselect = $true
        }
    [void]$FileBrowser1.ShowDialog()
    $Inputu.Text=$FileBrowser1.FileNames
    $us = Import-Csv -Delimiter ";" -Path $Inputu.Text | select Name,ou
    $ListBox1.Items.AddRange($us.name)
    $gdeOUru.Text =  $us.ou| select -First 1
    }
# Функция кнопки "Обзор" для выбора куда сохранить ключи
function browseFolder{
    $browse.ShowDialog()
    $keysr.text = $browse.selectedPath
    }
# Функция кнопки "Обзор" для выбора куда сохранить архивы
function browseFolderf{
    $browsef.ShowDialog()
    $filesr.text = $browsef.selectedPath
    }
# Функция создания записей в ДНС
function new-dnsrecord { 
    param( 
        [string]$server, 
        [string]$fzone, 
        [string]$rzone, 
        [string]$computer, 
        [string]$address, 
        [string]$alias, 
        [string]$maildomain, 
        [int]$priority, 
        [switch]$arec, 
        [switch]$ptr, 
        [switch]$cname, 
        [switch]$mx 
    ) 
    ## split the server fqdn and address 
        $srvr = $server -split "\." 
        $addr = $address -split "\." 

        $rec = [WmiClass]"\\$($srvr[0])\root\MicrosoftDNS:MicrosoftDNS_ResourceRecord"  
    ## 
    ## create records 
    ##  
    ## A 
        if ($arec){ 
            $text = "$computer IN A $address"  
            $rec.CreateInstanceFromTextRepresentation($server, $fzone, $text)  
        } 
    ## CNAME 
        if ($cname){ 
            $text = "$alias IN CNAME $computer"  
            $rec.CreateInstanceFromTextRepresentation($server, $fzone, $text)  
        } 
    ## PTR 
        if ($ptr){ 
            $text = "$($addr[3]).$rzone IN PTR $computer"  
            $rec.CreateInstanceFromTextRepresentation($server, $rzone, $text)  
        } 
    ## MX 
    if ($mx){ 
        $text = "$maildomain IN MX $priority $computer"  
        $rec.CreateInstanceFromTextRepresentation($server, $fzone, $text)  
        } 
        }
#Функций создания учетных записей компьютеров
function createCMP {
    [CmdletBinding()]
    param(
        # Почтовый сервер для отправки почты на внутреннее адреса 
        [Parameter(Mandatory=$true)]
        [string]
        $SMTPServerInternal=$settingsUtil.SMTPServerInternal,
        
        # Порт почтового сервера для отправки почты на внутреннее адреса
        [Parameter(Mandatory=$true)]
        [string]
        $SMTPServerInternalPort=$settingsUtil.SMTPServerInternalPort,
        
        # Использование SSL для отправки на внутреннее адреса
        [Parameter(Mandatory=$true)]
        [string]
        $SMTPServerInternalSSL=$settingsUtil.SMTPServerInternalSSL,
        
        # Адрес для отправки сообщений по внутреней почте
        [Parameter(Mandatory=$true)]
        [string]
        $InternalAddress=$settingsUtil.InternalAddress,
        
        # Зона на ДНС сервере, в которой будут создаваться А записи linux серверов
        [Parameter(Mandatory=$true)]
        [string]
        $DNSZone=$settingsCMP.DNSZone,
        
        # Сервер, который хостит необходимую ДНС зону (DNSZone)
        [Parameter(Mandatory=$true)]
        [string]
        $DNSServer=$settingsCMP.DNSServer,
        
        # Группа рассылки, на которую будут отправлены файлы ключей
        [Parameter(AttributeValues)]
        [string]
        $KeyRecipient=$settingsCMP.KeyRecipient
       
        )
    begin{
        $logs.text = $null
        try {
            LogAdd ("Импортируем модуль AD")
            if((Get-Module).name -cnotcontains 'ActiveDirectory'){
                Import-Module ActiveDirectory -ErrorAction Stop
                }   
            }#end try
        catch [System.Exception] {
            LogAdd ( 'Ошибка при загрузке модуля Active Directory: ' + $_ )
            break 
            }#end catch
        try {
            $comps = Import-Csv -Delimiter ";" -Path $InputFName4.Text -ErrorAction Stop
            }#end try
        catch [System.Exception] {
            LogAdd ('Не удалось загрузить параметры из файла: ' + $_)
            break
            }#end catch
        }#end begin

    Process {
        $progressBar1.minimum = 0
        $progressBar1.maximum =3+$comps.ComputerName.count*2
        $progressBar1.step = 1
        $OU = $Comps.IS | select -First 1
        $folder = $ou
        $groupname = $settingsCMP.NameGroupn+$OU+$settingsCMP.NameGroupk
        $groupname1 = $OU+$settingsCMP.NameGroupk
        $folderPath = $keysr.text +"\"+$folder
        LogAdd ("Создаем папку "+$ou)
        $progressBar1.performstep()
        Start-Sleep -Seconds 1
        if(Test-Path -Path $folderPath){LogAdd ("Папка $ou уже существует")}
        else{ 
            try {
                New-Item -Path $folderPath -ItemType "directory" -ErrorAction Stop
                LogAdd ("Папка $ou создана")
                }#end try
            catch [System.Exception] {
                LogAdd ("Ошибка при создании папки: " + $_)
                break
                }#end catch
            
            }#end else
        LogAdd ("Получаем информацию о группе "+$GroupName)
        Start-Sleep -Seconds 1
        try {
            $CanonicalName = (Get-ADGroup -Filter {Name -like $groupname -or Name -like $groupname1} -Properties canonicalname -ErrorAction Stop).DistinguishedName
            }#end try
        catch [System.Exception] {
            LogAdd ("Ошибка при поиске группы: " +$_)
            break
            }#end catch
        $txtPath = $folderPath+"\"+$GroupName+".txt"
        Start-Sleep -Seconds 1
        $CanonicalName > $txtPath
        $dnsZone = “passport.local”
        $progressBar1.performstep()
        Start-Sleep -Seconds 1
        LogAdd ("Начинаем создавать учетки")
        Foreach($CurrentComputer in $Comps) {
            $ComputerName = $CurrentComputer.ComputerName
            $hostA = $ComputerName +".passport.local"
            $msSFU30NisDomain = $CurrentComputer.msSFU30NisDomain
            $SamAccountName = $CurrentComputer.SamAccountName
            $fullName = $SamAccountName
            $OU = $CurrentComputer.OU
            $Description = $CurrentComputer.Description
            $ipHostNumber = $CurrentComputer.ipHostNumber
            $IP = $ipHostNumber
            try {
                New-ADComputer –Name $ComputerName -SamAccountName $SamAccountName –Path $OU -Description $Description `
                -OtherAttributes @{msSFU30NisDomain = $msSFU30NisDomain;ipHostNumber = $ipHostNumber} -ErrorAction Stop
                LogAdd ("Учетная запись $ComputerName создана")
                }#end try
            catch [System.Exception] {
                LogAdd ("Ошибка при создании компьютера $SamAccountName : " +$_)
                continue
                }#end catch
            try {
               if((Get-Module).name -cnotcontains 'DnsServer'){
                    Import-Module -Name DnsServer
                    }#end if
               Add-DnsServerResourceRecordA -Name $SamAccountName -ZoneName $DNSZone -AllowUpdateAny -IPv4Address $IP -ComputerName $DNSServer -ErrorAction Stop   
               LogAdd ("Запись компьютера $ComputerName добавлена в DNS")
               }#end try
            catch [System.Exception] {
               LogAdd ("Ошибка при добавлении записи компьютера $SamAccountName в ДНС: " + $_)
               continue 
               }#end catch
            $progressBar1.performstep()
            Start-Sleep -Seconds 1
            }#end foreach 

        Start-Sleep -Seconds 30
        LogAdd ("Начинаем создавать ключи")
        Foreach($CurrentComputer in $Comps) {
            $SamAccountName = $CurrentComputer.SamAccountName
            $fullName = $SamAccountName
            $fullName = "host/"+$fullName+".passport.local@PASSPORT.LOCAL"
            $keypath = $folderPath+"\"+$SamAccountName+".keytab"
            $keyhost = "PASSPORT\"+$SamAccountName+"$"
            setspn -a $fullName $SamAccountName
            setspn -L $SamAccountName
            echo y | ktpass /princ $fullName /out $keypath /crypto all /ptype KRB5_NT_PRINCIPAL -desonly /mapuser $keyhost +rndPass
            LogAdd ("Ключ для компьютера $SamAccountName создан")
            $progressBar1.performstep()
            Start-Sleep -Seconds 1
            }#end foreach
        if ($CheckBox1.Checked -eq $true) {
                    cd $keysr.text
                    $SevenZipExecutablePath = "C:\Program files\7-Zip\7z.exe"
                    $Arg1="a"
                    $Arg2="$folder.7z"
                    $Arg3=$folderPath
                    & $SevenZipExecutablePath ($Arg1,$Arg2,$Arg3)
                    $Subject = "Ключи для ИС "+$folder
                    $Attachments = "$folderPath\$folder.7z"
                    $Encoding = [System.Text.Encoding]::UTF8
                    $Error[0]=$null
                    $body = "Ключи во вложении"
                    if($SMTPServerInternalSSL -eq $true){
                        try {
                            send-mailmessage -SmtpServer $SMTPServerInternal -From InternalAddress -Subject $Subject -To $KeyRecipient -Body $body -Attachments $attachments -DeliveryNotificationOption OnSuccess -Port $SMTPServerInternalPort -Encoding $Encoding -UseSsl
                            LogAdd ("Ключи успешно отправлены")    
                            }#end try
                        catch [System.Exception] {
                            LogAdd ("Ошибка при отправке сообщения с ключами : " + $_)
                            }#end catch    
                        }#end if
                    else {
                        try {
                            send-mailmessage -SmtpServer $SMTPServerInternal -From InternalAddress -Subject $Subject -To $KeyRecipient -Body $body -Attachments $attachments -DeliveryNotificationOption OnSuccess -Port $SMTPServerInternalPort -Encoding $Encoding
                            LogAdd ("Ключи успешно отправлены")    
                            }#end try
                        catch [System.Exception] {
                            LogAdd ("Ошибка при отправке сообщения с ключами : " + $_)
                            }#end catch    
                       }#end else
                    }#end if
        $progressBar1.performstep()
        LogAdd ("Ключи созданы! Готово")
        get-date >> $logpath2
        $Logs.text >> $logpath2
        }#end process
    }#end function
#функиция авторизации для отправки сообщения
function Check {
    if (!$CheckBox.Checked) {$logName.Enabled = $false; $InputFpass.Enabled = $false} 
    else {$logName.Enabled = $true; $InputFpass.Enabled = $true}
    }
#Функция создания пользователей
function createuser {
    $logs.Text =$null
    $SMTPServerExternal=$settingsUtil.SMTPServerExternal
    $SMTPServerExternalPort=$settingsUtil.SMTPServerExternalPort
    $SMTPServerInternal=$settingsUtil.SMTPServerInternal
    $SMTPServerInternalPort=$settingsUtil.SMTPServerInternalPort
    $InternalAddress=$settingsUtil.InternalAddress
    $body1=$settingsUser.Body1
    $body2=$settingsUser.Body2
    $body3=$settingsUser.Body3
    $Subject1=$settingsUser.Subject1
    $Subject2=$settingsUser.Subject2
    $Subject3=$settingsUser.Subject3
    $fileuser=$settingsUser.filetext
    LogAdd ("Импортируем модуль AD")
    Import-Module ActiveDirectory
    LogAdd ("Модуль AD импортирован")
    $users = Import-CSV $Inputu.Text –Delimiter “;” -Encoding UTF8
    $progressBar2.minimum = 0
    $progressBar2.maximum =(2+$users.name.count)
    $progressBar2.step = 1
    $sendemail=$false
    $sendsyd = $false
    $from=$null
    $mycreds=$null
    $from = $logName.text
    $secpasswd1 = $InputFpass.text
    if ($secpasswd1 -and $from) {
        $from111=($from -split '@')[0]
        $secpasswd = ConvertTo-SecureString "$secpasswd1" -AsPlainText -Force
        $mycreds = New-Object System.Management.Automation.PSCredential ($from111, $secpasswd)
        }
    if ($from) {
                $sendemail=$true
            }
    if ($CheckBox2.Checked -eq $true ){
    $sendsyd = $true
    }
    LogAdd ("Начинаем создание пользователей")
    $progressBar2.performstep()
    Start-Sleep -Seconds 1
    foreach ($User in $Users){    
        $Password = get-random -count 11 -input (48..57 + 65..90+ 48..57+36..46+ 97..122) | % -begin { $pass = $null } -process {$pass += [char]$_} -end {$pass}
        $OUtemp = $user.OU
        $OU = "OU=Users,OU="+ $OUtemp +",OU=Company,OU=DataCenterEM01,DC=passport,DC=local" 
        $Detailedname = $User.name
        # Генерация пароля на архив
        $Psw = Get-Random -Maximum 9999 -Minimum 1000
        $Dname = $Detailedname -split ' '
        $UserFirstname = $Dname[0]
        $EmailAddress = $User.EmailAddress
        $Description = $User.Description
        $Initials=$Dname[2]
        $Name = $Dname[1]
        $Group = $user.Group
        if($group -match ','){
            $group = $group -split ','
            }
        $dnsroot  = (Get-ADDomain).DNSRoot
        $DescriptionOU=$User.OUDescription
        # Приминение функции Translit
        if ($Initials){
            $SAM = (Translit "$($UserFirstname)$($Name[0])$($Initials[0])").ToLower()
            }
        else{
            $SAM = (Translit "$($UserFirstname)$($Name[0])").ToLower()
            }
        $samlog=$sam
        # Создание OU для пользователя
        $ispath="OU="+$OUtemp+",OU=company,OU=DataCenterEM01,DC=passport,DC=local"
        try{
        Get-ADOrganizationalUnit -Identity $ispath -ErrorAction stop
        }
        Catch{
            New-ADOrganizationalUnit -Name $OUtemp -Path "OU=company,OU=DataCenterEM01,DC=passport,DC=local"
            New-ADOrganizationalUnit -Name Users -Path $ispath
            New-ADOrganizationalUnit -Name Groups -Path $ispath
            if($DescriptionOU){Get-ADOrganizationalUnit -SearchBase "OU=company,OU=DataCenterEM01,DC=passport,DC=local" -SearchScope OneLevel -Filter {name -eq $OUtemp} | Set-ADOrganizationalUnit -Description $DescriptionOU}
            }
        # Создание группы если необходимо
        $is=$user.Is
        $folderPath = $filesr.text+"\"+$is
        New-Item -Path $folderPath -ItemType "directory"
        $gpn = $user.new_group
        $gpou = $user.Groupou
        if ($gpn){
            $des = "Пользователи"+" "+$is
            New-ADGroup -Name $gpn -Path $gpou -GroupScope Universal -Description $des
            }

        # Проверка на наличие пользователя
        $tempuser=Get-ADUser -Filter {Samaccountname -like $sam} -ErrorAction Ignore
        # Если пользователь есть, то
        if ($tempuser){
                Function yes {
                    $global:sam=$newsam.text
                    $form1.Hide() = $true
                    }
                Function off {
                    $global:sam="11NET22"
                    $form1.Hide() = $true
                    }
                $tu = Get-ADUser -Filter {Samaccountname -like $sam} -Properties mail | select Name,SamAccountName,mail
                $nameusertext=$tu.name
                $samusertext=$tu.SamAccountName
                $mailusertext=$tu.mail
        
                #Объявление формы ошибки
                $Form1 = New-Object Windows.Forms.Form
                $Form1.Height  = 350
                $Form1.Width = 380
                $Form1.Text = "ВНИМАНИЕ!"
                $Form1.Icon = $Icon
                $Form1.AutoSize =$true
                $Form1.AutoSizeMode = "GrowOnly"
                $Form1.StartPosition = "CenterScreen"
        
                create_label ($operror = New-Object windows.Forms.Label) "Обнаружен пользователь со следующими параметрами:" 8 5 240 15 $Form1 a
                create_label ($nameUsert = New-Object windows.Forms.Label) 'Имя:' 8 25 240 150 $Form1 a
                create_label ($nameUser = New-Object windows.Forms.TextBox) "$nameusertext" 65 23 300 25 $Form1  
                $nameUser.ReadOnly = "true"
                create_label ($samusert = New-Object windows.Forms.Label) 'Логин:' 8 50 240 150 $Form1 a
                create_label ($samuser = New-Object windows.Forms.TextBox) "$samusertext" 65 48 300 25 $Form1 
                $samuser.ReadOnly = "true"
                create_label ($mailusert = New-Object windows.Forms.Label) 'E-Mail:' 8 75 240 150 $Form1 a
                create_label ($mailuser = New-Object windows.Forms.TextBox) "$mailusertext" 65 73 300 25 $Form1 
                $mailuser.ReadOnly = "true"

                create_label ($operror1 = New-Object windows.Forms.Label) "А Вы хотите создать пользователя с" 8 105 240 15 $Form1 a
                create_label ($nameUsert1 = New-Object windows.Forms.Label) 'Именем:' 8 125 240 150 $Form1 a
                create_label ($nameUser1 = New-Object windows.Forms.TextBox) "$Detailedname" 65 123 300 25 $Form1  
                $nameUser1.ReadOnly = "true"
                create_label ($samusert1 = New-Object windows.Forms.Label) 'Логином:' 8 150 240 150 $Form1 a
                create_label ($samuser1 = New-Object windows.Forms.TextBox) "$sam" 65 148 300 25 $Form1 
                $samuser1.ReadOnly = "true"
                create_label ($mailusert1 = New-Object windows.Forms.Label) 'E-Mailом:' 8 175 240 25 $Form1 a
                create_label ($mailuser1 = New-Object windows.Forms.TextBox) "$EmailAddress" 65 173 300 25 $Form1 
                $mailuser1.ReadOnly = "true"

                $texttemp=@"
            Если это тотже самый пользователь, то нажмите Отмена 
                или введите новый логин и нажмите Создать:
"@
                
                create_label ($operror1 = New-Object windows.Forms.Label) $texttemp 30 210 240 15 $Form1 a
                create_label ($newsamtext = New-Object windows.Forms.Label) 'Новый логин:' 8 245 240 25 $Form1 a
                create_label ($newsam = New-Object windows.Forms.TextBox) "" 85 243 280 25 $Form1  

                # кнопка отмена
                create_label ($buttonoff = New-Object system.Windows.Forms.Button ) 'Отмена' 220 280 100 30 $Form1
                $buttonoff.Add_Click($Function:off) 
                # кнопка создания
                create_label ($buttoncrt = New-Object system.Windows.Forms.Button ) 'Создать' 50 280 100 30 $Form1  
                $buttoncrt.Add_Click($Function:yes)
                $Form1.Add_Shown({$Form1.Activate()})
                $Form1.ShowDialog()
                }
        else {$global:sam=$sam}
        if ($global:sam -ne "11NET22"){
            $sam=$global:sam
            }
        Else {$sam =$null}
        if($sam){
                LogAdd ("Создаем учетку $sam")
                $Error[0]=$null
                New-ADUser -Name $Detailedname -SamAccountName $SAM -UserPrincipalName ($sam + "@" + $dnsroot) -DisplayName $Detailedname -GivenName $Name -Surname $UserFirstname `
                -AccountPassword (ConvertTo-SecureString $Password -AsPlainText -Force) -Enabled $true -Path $OU -EmailAddress $EmailAddress -Description $Description `
                -OtherAttributes @{msSFU30NisDomain = "passport";gidnumber="10000";loginShell="/bin/bash"} -PasswordNeverExpires $True
                if($Error[0]){LogAdd ("Ошибка при создании пользователя $sam : " +$Error[0])}
                else {LogAdd ("Пользователь $sam успешно создан")} 
                #Добавляем созданого пользователя в группу
                $Error[0]=$null
                if($group){
                foreach ($groupone in $group){
                Add-ADGroupMember -Identity $Groupone -Members $SAM
                if($Error[0]){LogAdd ("Ошибка при добавлении пользователя $sam в группу $Group : " +$Error[0])}
                }
                }
                if ($sendsyd -eq $true){
                    $Encoding = [System.Text.Encoding]::UTF8

                    $body=@"
                    Создана учтеная запись для пользователя: $Detailedname
                    Логин: $SAM
                    Пароль: $Password
"@
                    send-mailmessage -SmtpServer $SMTPServerInternal -From $InternalAddress -Subject 'Задания на изменение' -To access@e-moskva.ru -Body $body -DeliveryNotificationOption OnSuccess -Port $SMTPServerInternalPort -Encoding $Encoding
                    LogAdd ("Данные отправлены на адрес access@e-moskva.ru")       
                    } 
                Else{
                # Генерируем файл для пользователя
                $txtPath = $folderPath+"\"+$EmailAddress+".txt"
                $inFile = "Login:" + $SAM + "     " + "Password:" + $Password
                $inst=$fileuser -replace 'SAM',$sam
                $inst > $txtPath
                $inFile >> $txtPath
                $txtPath1 = $folderPath+"\"+"Users"+" "+$is+".txt"
                $inFile1 = $Detailedname + "  " + $inFile +"     " + "E-mail:" + $EmailAddress + "     " + "Пароль от архива:" + $Psw
                $inFile1 >> $txtPath1
                # Запуск батника для создания запароленых архивов
                cd $folderPath
                $SevenZipExecutablePath = "C:\Program files\7-Zip\7z.exe"
                $Arg1="a"
                $Arg2="$SAM.7z"
                $Arg3=$txtPath
                $Arg4="-p$Psw"
                & $SevenZipExecutablePath ($Arg1,$Arg2,$Arg3,$Arg4)
                if ($sendemail -eq $true) {
                    LogAdd ("Отправляем сообщение")
                    $to = $EmailAddress
                    $bodyto = $user.body
                    $afolder=$folderPath+"\$sam.7z" 
                    $body=switch($bodyto){
                    "1" {$Body1 -replace 'is',$is }
                    "2" {$body2 -replace 'is',$is }
                    "3" {$body3}
                    } 
                if ($bodyto -eq 1){
                    $Subject=$Subject1 -replace 'is',$is
                    $Attachments = "C:\Work\New_users\For Email\OEM - быстрый старт.pdf","C:\Work\New_users\For Email\Типовая анкета мониторингу OEM.XLSX",$afolder
                    }
                elseif($bodyto -eq 2){
                    $Subject = $Subject2 -replace 'is',$is
                    $Attachments = $afolder
                    }            
                elseif($bodyto -eq 3){
                    $Subject = $Subject3
                    }
                $Encoding = [System.Text.Encoding]::UTF8
                $Error[0]=$null
                send-mailmessage -SmtpServer $SMTPServerExternal -From $from -Subject $Subject -To $to -Body $body -Credential $mycreds -Attachments $attachments -DeliveryNotificationOption OnSuccess -Port $SMTPServerExternalPort -UseSsl -Encoding $Encoding
                if($Error[0]){LogAdd ("Ошибка при отправке сообщения пользователю $sam : " +$Error[0])}
                
        }
        }
        }
        else # Если пользователь есть, то пишем ошибку в лог
        {

        LogAdd ("Пользователь с логином $samlog уже существует")
        }
        $progressBar2.performstep()
        Start-Sleep -Seconds 15
        }
                    $progressBar2.performstep()
                    LogAdd ("Пользователи созданы")
                    get-date >> $logpath3
    $Logs.text >> $logpath3
    } 
#функция поиска пользователя
function usersearch{
    $logs.Text =$null
    $ListBoxuse111r.Items.clear()
    $Inputpswdtext11.Clear()
    $finduser=$Inputpswdtext.Text
    $filter="(SamAccountName -like '*$finduser*') -or (Name -like '*$finduser*')"
    $user=Get-ADUser -Filter $filter -Properties mail| select Name,SamAccountName,mail
    if ($user.name.count -eq '0'){$ListBoxuse111r.Items.AddRange("Пользователь не найден")}
    elseif($user.name.count -eq '1'){
            $vivoduser=$user.Name,$user.SamAccountName,$user.mail
            $global:fiorestuser=$user.Name
            $Global:resetuserpassword=$user.SamAccountName
            $ListBoxuse111r.Items.AddRange($vivoduser)
            $Inputpswdtext11.Text=$user.mail
            }
    else{
        
        $spisokuserov=$user.Name
        #Объявление формы
                Function off {
                    $global:ListBoxuse111r.Items.AddRange("Пользователь не найден")
                    $form1.Hide() = $true
                    $global:Inputpswdtext11.Clear()
                    }
                Function yes {
                    $global:trylogin=$nameUser.SelectedItem
                    $form1.Hide() = $true
                    }
                $Form1 = New-Object Windows.Forms.Form
                $Form1.Height  = 350
                $Form1.Width = 380
                $Form1.Text = "ВНИМАНИЕ!"
                $Form1.Icon = $Icon
                $Form1.AutoSize =$true
                $Form1.AutoSizeMode = "GrowOnly"
                $Form1.StartPosition = "CenterScreen"
                
                create_label ($operror = New-Object windows.Forms.Label) "Обнаружены следующие пользователи:" 8 5 240 15 $Form1 a
                create_label ($nameUser = New-Object System.Windows.Forms.ListBox) "" 8 23 350 250 $Form1  
                $nameUser.Items.AddRange($spisokuserov)
                            
                # кнопка отмена
                create_label ($buttonoff = New-Object system.Windows.Forms.Button ) 'Отмена' 220 280 100 30 $Form1
                $buttonoff.Add_Click($Function:off) 
                # кнопка создания
                create_label ($buttoncrt = New-Object system.Windows.Forms.Button ) 'Выбрать' 50 280 100 30 $Form1  
                $buttoncrt.Add_Click($Function:yes)
                $Form1.Add_Shown({$Form1.Activate()})
                $Form1.ShowDialog()
                $user=$user | where {$_.Name -eq $global:trylogin}
                $vivoduser=$user.Name,$user.SamAccountName,$user.mail
                $ListBoxuse111r.Items.AddRange($vivoduser)
                $Inputpswdtext11.Text=$user.mail
                $global:fiorestuser=$user.Name
                $Global:resetuserpassword=$user.SamAccountName
                }
    LogAdd ("Данные по пользователю получены")
    }
#функция сброса пароля
function resetpassword{
    $sendemail=$false
    $from=$null
    $mycreds=$null
    $SMTPServerExternal=$settingsUtil.SMTPServerExternal
    $SMTPServerExternalPort=$settingsUtil.SMTPServerExternalPort
    $from = $logName111.text
    $secpasswd1 = $InputFpass111.text
    $fileuser=$settingsUser.filetext
    if ($from) {
                $sendemail=$true
            }
    if ($secpasswd1 -and $from) {
        $from111=($from -split '@')[0]
        $secpasswd = ConvertTo-SecureString "$secpasswd1" -AsPlainText -Force
        $mycreds = New-Object System.Management.Automation.PSCredential ($from111, $secpasswd)
        }
    $Password = get-random -count 11 -input (48..57 + 65..90+ 48..57+36..46+ 97..122) | % -begin { $pass = $null } -process {$pass += [char]$_} -end {$pass}
    $Psw = Get-Random -Maximum 9999 -Minimum 1000
    Set-ADAccountPassword $Global:resetuserpassword -NewPassword (ConvertTo-SecureString -AsPlainText -String $Password -force)
    LogAdd ("Пароль сброшен")
    $EmailAddress=$Inputpswdtext11.Text
    $sam=$Global:resetuserpassword
                # Генерируем файл для пользователя
                $txtPath = "C:\Work\New_users\Reset_password\"+$EmailAddress+".txt"
                $inFile = "Login:" + $sam + "     " + "Password:" + $Password
                $inst=$fileuser -replace 'SAM',$sam
                $inst > $txtPath
                $inFile >> $txtPath
                $txtPath1 = "C:\Work\New_users\Reset_password\Users.txt"
                $inFile1 = $global:fiorestuser + "  " + $inFile +"     " + "E-mail:" + $EmailAddress + "     " + "Пароль от архива:" + $Psw
                $inFile1 >> $txtPath1
                # Запуск батника для создания запароленых архивов
                cd C:\Work\New_users\Reset_password\
                $SevenZipExecutablePath = "C:\Program files\7-Zip\7z.exe"
                $Arg1="a"
                $Arg2="$sam.7z"
                $Arg3=$txtPath
                $Arg4="-p$Psw"
                & $SevenZipExecutablePath ($Arg1,$Arg2,$Arg3,$Arg4)
                if ($CheckBox11.Checked) {
                    $body=@"
            Добрый день.

            Вам отправлены новые учетные данные для авторизации в домене passport.local
            Учетные данные для авторизации во вложении, в соответствии с практикой передачи конфиденциальных данных сведения находятся в архиве с паролем, пароль на архив готовы передать по телефону в подписи письма.

            С уважением,

            Управление системных и прикладных сервисов
            ГБУ «Инфогород»

            Тел.: +7(495) 989-80-34  (1354,1398,1317) 
"@
                    $Subject='Новые учетные данные для домена passport.local'
                    $Attachments = "C:\Work\New_users\Reset_password\$sam.7z"
                    $Encoding = [System.Text.Encoding]::UTF8
                    send-mailmessage -SmtpServer $SMTPServerExternal -From $from -Subject $Subject -To $EmailAddress -Body $body -Credential $mycreds -Attachments $attachments -DeliveryNotificationOption OnSuccess -Port $SMTPServerExternalPort -UseSsl -Encoding $Encoding
                    LogAdd ("Письмо отправлено")
                    }

    }
function Check1 {
    if (!$CheckBox11.Checked) {$logName111.Enabled = $false; $InputFpass111.Enabled = $false} 
    else {$logName111.Enabled = $true; $InputFpass111.Enabled = $true}
    }

#Иконка
$Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($PSHOME + "\powershell.exe")
#Объявление основной формы
$Form = New-Object Windows.Forms.Form
$Form.Height  = 550
$Form.Width = 480
$Form.Text = "Подготовка инфраструктуры"
$Form.Icon = $Icon
$Form.AutoSize =$true
$Form.AutoSizeMode = "GrowOnly"
$Form.StartPosition = "CenterScreen"

#Объявление вкладок#############################################################################################################
create_label ($TabControl = New-Object System.Windows.Forms.TabControl) '_' -5 -2 480 350 $Form

#Первая вкладка#################################################################################################################
create_label ($TabPage1 = New-Object System.Windows.Forms.TabPage) 'Создание OU' 1 1 1 1 $TabControl
#Объявление формы для ввода названия ИС
create_label ($labFName = New-Object windows.Forms.Label) 'Введите название ИС:' 8 15 240 15 $TabPage1 a
create_label ($InputFName = New-Object windows.Forms.TextBox) '' 8 35 240 25 $TabPage1
$InputFName.add_TextChanged($Function:OU)
#Вывод результата функции OU
create_label ($labFName1 = New-Object windows.Forms.Label) 'Будут созданы:' 8 75 240 15 $TabPage1
create_label ($labFName2 = New-Object windows.Forms.Label ) 'OU' 8 105 30 15 $TabPage1 a
create_label ($Result1 = New-Object windows.Forms.TextBox ) '' 50 102 200 25 $TabPage1
$Result1.ReadOnly = "true"
create_label ($labFName3 = New-Object windows.Forms.Label ) 'Группа' 8 145 41 15 $TabPage1 a
create_label ($Result2 = New-Object windows.Forms.TextBox ) '' 50 142 200 25 $TabPage1
$Result2.ReadOnly = "true"
#Кнопка создания OU
create_label ($button1 = New-Object Windows.Forms.Button ) 'Создать OU' 8 180 240 25 $TabPage1 
$button1.add_click($Function:createOU)
create_label ($progressBar = New-Object System.Windows.Forms.ProgressBar) '' 8 220 240 25 $TabPage1 
$progressBar.visible = $true
create_label ($PictureBox = New-Object System.Windows.Forms.PictureBox) '' 280 30 240 25 $TabPage1 a
$PictureBox.Load($imagepath)

#Вторая вкладка#################################################################################################################
create_label ($TabPage2 = New-Object System.Windows.Forms.TabPage) 'Создание Linux-серверов' 1 1 1 1 $TabControl
#Кнопка для обзора
create_label ($button2 = New-Object Windows.Forms.Button) 'Обзор' 370 23 80 25 $TabPage2 
$button2.add_click($Function:Browse)
#Объявление формы пути файла
create_label ($labFName4 = New-Object windows.Forms.Label ) 'Введите путь:' 8 5 240 15 $TabPage2 a
create_label ($InputFName4 = New-Object windows.Forms.TextBox ) '' 8 25 350 25 $TabPage2 
# Список серверов, которые будут созданы.
create_label ($labFName5 = New-Object windows.Forms.Label ) 'Будут созданы сервера:' 8 50 350 15 $TabPage2 a
create_label ($ListBox = New-Object System.Windows.Forms.ListBox) '' 8 70 240 150 $TabPage2
# В какой OU будут созданы сервера
create_label ($gdeOU = New-Object windows.Forms.Label) 'В OU:' 260 50 240 150 $TabPage2 a
create_label ($gdeOUr = New-Object windows.Forms.TextBox) '' 260 70 100 25 $TabPage2 
$gdeOUr.ReadOnly = "true"
#Отправка сообщения
create_label ($CheckBox1 = New-Object System.Windows.Forms.CheckBox ) 'Отправка ключей' 260 100 100 25 $TabPage2 a
$CheckBox1.Checked = $false
#Объявление формы пути для сохранения ключей
create_label ($keys = New-Object windows.Forms.Label ) 'Сохранить ключи в папке:' 8 220 240 150 $TabPage2 a
create_label ($keysr = New-Object windows.Forms.TextBox ) '' 8 240 350 25 $TabPage2 
$browse = new-object system.windows.Forms.FolderBrowserDialog
$browse.RootFolder = [System.Environment+SpecialFolder]'MyComputer'
$browse.ShowNewFolderButton = $false
$browse.selectedPath = "C:\"
$browse.Description = "Обзор"
create_label ($buttonb = New-Object system.Windows.Forms.Button) 'Обзор' 370 238 80 25 $TabPage2 
$buttonb.Add_Click($Function:BrowseFolder)
create_label ($buttoncreate = New-Object system.Windows.Forms.Button) 'Создать' 370 288 80 25 $TabPage2  
$buttoncreate.Add_Click($Function:createCMP)
create_label ($progressBar1 = New-Object System.Windows.Forms.ProgressBar) '' 8 288 350 25 $TabPage2 
$progressBar1.visible = $true

#Третья вкладка#################################################################################################################
create_label ($TabPage3 = New-Object System.Windows.Forms.TabPage) 'Создание пользователей' 1 1 1 1 $TabControl
#Кнопка для обзора
create_label ($buttonu = New-Object Windows.Forms.Button) 'Обзор' 370 23 80 25 $TabPage3 
$buttonu.add_click($Function:Browse1)
#Объявление формы пути файла
create_label ($labFName4 = New-Object windows.Forms.Label) 'Введите путь:' 8 5 80 25 $TabPage3 a
create_label ($Inputu = New-Object windows.Forms.TextBox) '' 8 25 350 25 $TabPage3 a
# Список пользователей, которые будут созданы.
create_label ($labFName6 = New-Object windows.Forms.Label) 'Будут созданы учетные записи:' 8 50 350 25 $TabPage3 a
create_label ($ListBox1 = New-Object System.Windows.Forms.ListBox) '' 8 70 240 150 $TabPage3 a
# В какой OU будут созданы пользователи
create_label ($gdeOU = New-Object windows.Forms.Label) 'В OU:' 260 50 50 250 $TabPage3 a
create_label ($gdeOUru = New-Object windows.Forms.TextBox ) '' 260 70 100 25 $TabPage3 
$gdeOUru.ReadOnly = "true"
#Где сохранить пароли
create_label ($files = New-Object windows.Forms.Label ) 'Сохранить архивы с УЗ в папке:' 8 220 100 25 $TabPage3 a
create_label ($filesr = New-Object windows.Forms.TextBox ) '' 8 240 350 25 $TabPage3 
$browsef = new-object system.windows.Forms.FolderBrowserDialog
$browsef.RootFolder = [System.Environment+SpecialFolder]'MyComputer'
$browsef.ShowNewFolderButton = $false
$browsef.selectedPath = "C:\"
$browsef.Description = "Обзор"
create_label ($buttonbf = New-Object system.Windows.Forms.Button ) 'Обзор' 370 238 80 25 $TabPage3 
$buttonbf.Add_Click($Function:BrowseFolderf)
# кнопка создания
create_label ($buttoncreateu = New-Object system.Windows.Forms.Button ) 'Создать' 370 288 80 25 $TabPage3 
$buttoncreateu.Add_Click($Function:createuser)
#Отправка сообщения
create_label ($CheckBox = New-Object System.Windows.Forms.CheckBox ) 'Отправка E-mail' 260 100 100 25 $TabPage3 a
$CheckBox.Checked = $false
$CheckBox.Add_Click($Function:Check)
create_label ($CheckBox2 = New-Object System.Windows.Forms.CheckBox ) 'СУУД' 380 100 100 25 $TabPage3 a
$CheckBox2.Checked = $false
create_label ($log = New-Object windows.Forms.Label ) 'Введите e-mail:' 260 120 100 25 $TabPage3 a
create_label ($logName = New-Object windows.Forms.TextBox ) '' 260 140 200 25 $TabPage3 
$logName.add_TextChanged($Function:Check)
create_label ($labFpass = New-Object windows.Forms.Label ) 'Введите пароль:' 260 170 100 25 $TabPage3 a
create_label ($InputFpass = New-Object windows.Forms.TextBox ) '' 260 190 200 25 $TabPage3 
$InputFpass.PasswordChar = "*"
$InputFpass.add_TextChanged($Function:Check)
$logName.Enabled = $false
$InputFpass.Enabled = $false
create_label ($progressBar2 = New-Object System.Windows.Forms.ProgressBar) '' 8 288 350 25 $TabPage3 
$progressBar2.visible = $true

######Четвертая вкладка##############################
create_label ($TabPage4 = New-Object System.Windows.Forms.TabPage) 'Сброс пароля' 1 1 1 1 $TabControl
#Объявление формы для ввода ФИО пользователя
create_label ($pswdtext = New-Object windows.Forms.Label) 'Введите ФИО или логин пользователя:' 8 15 240 15 $TabPage4 a
create_label ($Inputpswdtext = New-Object windows.Forms.TextBox) '' 8 35 350 25 $TabPage4
# Информация о найденом пользователе.
create_label ($labFNameuser111 = New-Object windows.Forms.Label ) 'Информация о пользователе:' 8 60 350 15 $TabPage4 a
create_label ($ListBoxuse111r = New-Object System.Windows.Forms.ListBox) '' 8 80 240 150 $TabPage4
#Кнопка поиска пользователя
create_label ($button1111 = New-Object Windows.Forms.Button ) 'Найти' 370 32 80 25 $TabPage4 
$button1111.add_click($Function:usersearch)
#Объявление формы для ввода e-mail
create_label ($pswdtext11 = New-Object windows.Forms.Label) 'Введите e-mail, если он отличается от указанного:' 8 230 100 25 $TabPage4 a
create_label ($Inputpswdtext11 = New-Object windows.Forms.TextBox) '' 8 250 350 25 $TabPage4
# кнопка сброса
create_label ($buttoncreateu11 = New-Object system.Windows.Forms.Button ) 'Сбросить пароль' 330 288 120 25 $TabPage4 
$buttoncreateu11.Add_Click($Function:resetpassword)
#отправка пароля
create_label ($CheckBox11 = New-Object System.Windows.Forms.CheckBox ) 'Отправка E-mail' 260 65 100 25 $TabPage4 a
$CheckBox11.Checked = $false
$CheckBox11.Add_Click($Function:Check1)
create_label ($log111 = New-Object windows.Forms.Label ) 'Введите e-mail:' 260 90 100 25 $TabPage4 a
create_label ($logName111 = New-Object windows.Forms.TextBox ) '' 260 110 200 25 $TabPage4 
$logName111.add_TextChanged($Function:Check1)
create_label ($labFpass111 = New-Object windows.Forms.Label ) 'Введите пароль:' 260 140 100 25 $TabPage4 a
create_label ($InputFpass111 = New-Object windows.Forms.TextBox ) '' 260 160 200 25 $TabPage4 
$InputFpass111.PasswordChar = "*"
$InputFpass111.add_TextChanged($Function:Check1)
$logName111.Enabled = $false
$InputFpass111.Enabled = $false
#Логи
create_label ($Logs = New-Object windows.Forms.RichTextBox  ) '' 0 350 475 200 $Form 
$Logs.ReadOnly = "true"

$Form.Add_Shown({$Form.Activate()})
$Form.ShowDialog()
