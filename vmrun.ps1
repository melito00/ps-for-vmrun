#
#
#
[CmdletBinding(DefaultParametersetName='None')] 
param( 
    [Parameter(Mandatory=$true, ParameterSetName="list", Position=0)]
    [switch]$list,
    [Parameter(Mandatory=$true, ParameterSetName="lsvm", Position=0)]
    [switch]$lsvm,
    [Parameter(Mandatory=$true, ParameterSetName="start", Position=0)]
    [switch]$start,
    [Parameter(Mandatory=$true, ParameterSetName="stop", Position=0)]
    [switch]$stop,
    [Parameter(Mandatory=$true, ParameterSetName="guestip", Position = 0)]
    [switch]$guestip,

    [Parameter(Mandatory=$true, ParameterSetName="start", Position=1)]
    [Parameter(Mandatory=$true, ParameterSetName="stop", Position=1)]
    [Parameter(Mandatory=$true, ParameterSetName="guestip", Position=1)]
    [string]$vmname
)

$vmrun = 'C:\Program Files (x86)\VMware\VMware Workstation\vmrun.exe'
$vmdir = 'C:\work\VMware'

if (Test-Path $vmrun) {
    "$vmrun exists"
}
else {
    "$vmrun does not exist"
    exit 1
}

function getDefinedVM {
    $vms = Get-ChildItem -Path $vmdir -Include *.vmx -Recurse
    $vms
}

$vms = getDefinedVM

# Write-Host $vms
function execLsvm {
    $vms | ForEach-Object {
        $_.BaseName
    }
}


function printHelp {
    Write-Host "vm list"
    Write-Host "vm lsvm"
    Write-Host "vm [start|stop] `"vmname`""
    Write-Host

    # &$vmrun --help

    exit 1
}

function existVM ($vmname) {
    foreach($vm in $vms) {
        # Write-Host $vmname, $vm.BaseName
        if ($vm.BaseName -ceq $vmname) { return $vm }        
    }
    return $false
}

function execStart ($vmname) {
    $targetVM = existVM($vmname)
    if ($targetVM) {
        Write-Host "Start `"$targetVM`""
        &$vmrun start $targetVM nogui
    } else {
        Write-Host "$vmname does not exist!"
        printHelp
    }
}

function execGuestIP ($vmname) {
    $targetVM = existVM($vmname)
    if ($targetVM) {
        Write-Host "Guest IP Address `"$targetVM`""
        &$vmrun getGuestIPAddress $targetVM
    }
    else {
        Write-Host "$vmname does not exist!"
        printHelp
    }
}

function execList {
    &$vmrun list
}

switch ($PSCmdlet.ParameterSetName) {
    "list" { execList; break }
    "lsvm" { execLsvm; break }
    "start" { execStart($vmname); break }
    "stop" { "vm -stop $vmname"; break }
    "guestip" { execGuestIP($vmname); break }
    Default { printHelp; break }
}

exit 0
