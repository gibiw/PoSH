Param(
    [Parameter(Mandatory=$true)]
    [string]
    $Path
    )
$vhds = Get-ChildItem -Path $Path -Recurse -Filter '*.vhd' -ErrorAction SilentlyContinue
if($vhds){
    for ($i=0; $i -le $vhds.Count-1; $i++){
        Write-Host "Progress: $($i+1)/$($vhds.Count)" -ForegroundColor Yellow 
        Write-Host "Prepare: $($vhds[$i].FullName)" -ForegroundColor Yellow        
        $commands=@('select vdisk file="VHDPATH"','attach vdisk readonly','compact vdisk','detach vdisk','exit') -replace 'VHDPATH', $vhds[$i].FullName
        $commands | diskpart   
    }
}