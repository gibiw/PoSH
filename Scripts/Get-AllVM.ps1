Param(
    [parameter(ValueFromPipeLine = $true)] [ValidateNotNullOrEmpty()][Alias("VMName")]
    $Name = "%"
    )

if((Get-module).Name -notcontains "HyperV"){
    Write-Host "Import module HyperV" -ForegroundColor Green
    Import-module HyperV -ErrorAction Stop
}

if($Name -eq "%"){
    Write-Host "Get all VMs" -ForegroundColor Green
    $Vms = Get-VM
}
else{
    Write-Host "Get VMs with name: $Name" -ForegroundColor Green
    $Vms = @()
    foreach($n in $Name){
        $Vms += Get-VM -Name "$n"
    }    
}

function CompactVhd ([string]$path){
    $commands=@('select vdisk file="VHDPATH"','attach vdisk readonly','compact vdisk','detach vdisk','exit') -replace 'VHDPATH', $path
    $commands | diskpart   
}

if($Vms){
    Write-Host "Found $($Vms.Count) VMs" -ForegroundColor Green
    for ($i=0; $i -le $Vms.Count-1; $i++){
        Write-Host "Progress: $($i+1)/$($Vms.Count)" -ForegroundColor Yellow 
        Write-Host "Prepare: $($Vms[$i].VMElementName)" -ForegroundColor Yellow
        $VmState = (Get-VMSummary -Vm $Vms[$i].VMElementName -ErrorAction SilentlyContinue).EnabledState
        Write-Host "VM State: $VmState" -ForegroundColor Green
        $VmDrive = get-vmdisk -Vm $Vms[$i].VMElementName | where {$_.DriveName -eq "Hard Drive"}
        if($VmDrive){
            if($VmState -eq "Stopped" -or $VmState -eq "Suspended"){
                foreach($drive in $VmDrive){
                    Write-Host "Prepare VDH: $($drive.DiskPath)" -ForegroundColor Green
                    CompactVhd -path $drive.DiskPath
                }
            }
            else{
                Write-Host "Set Vm State to Suspended" -ForegroundColor Green
                Set-VMState -VM $Vms[$i].VMElementName -State 'Suspended' -Wait -ErrorAction SilentlyContinue 
                if((Get-VMSummary -Vm $Vms[$i].VMElementName -ErrorAction SilentlyContinue).EnabledState -eq 'Suspended'){
                    foreach($drive in $VmDrive){
                        Write-Host "Prepare VDH: $($drive.DiskPath)" -ForegroundColor Green
                        CompactVhd -path $drive.DiskPath
                    }
                    if($VmState -eq "Paused"){
                        Write-Host "Return Vm State to Running" -ForegroundColor Green
                        Set-VMState -VM $Vms[$i].VMElementName -State "Running" -Wait -ErrorAction SilentlyContinue 
                    }
                    Write-Host "Return Vm State to $VmState" -ForegroundColor Green
                    Set-VMState -VM $Vms[$i].VMElementName -State $VmState -Wait -ErrorAction SilentlyContinue
                }
                else{
                    Write-Host "Vm State don't change" -ForegroundColor Green
                }                
            } 
        }    
    }
}
else{
    Write-Host "VMs not found" -ForegroundColor Green
}

