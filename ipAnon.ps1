Param (
    [Parameter(Mandatory=$True)]
    $keyFile,
    [Parameter(Mandatory=$True)]
    $inputFile,
    [Parameter(Mandatory=$True)]
    [string]$privFrom,
    [Parameter(Mandatory=$True)]
    [string]$privTo)
$ErrorActionPreference = "Stop"

$hash = @{}
$output = @()

# check for existing key file
function checkExisting {
    if (Test-Path -Path $keyFile -PathType Leaf){
        $keys = Import-Csv -Path $keyFile | Measure-Object
        if ($keys.Length -gt 0) {
            $keys = Import-Csv -Path $keyFile
            foreach($k in $Keys){
                $hash.Add(($k).Original,($k).Randomized)
            }
        }
        $message = "[+] Existing keyFile has been loaded"
    } else {
        $message = "[-] No existing keyFile has been found"
    }
    return $message
}

# source: https://stackoverflow.com/questions/8365537/checking-for-a-range-in-powershell
Function isIpAddressInRange {
    param(
        [string] $ipAddress,
        [string] $fromAddress,
        [string] $toAddress)
    $ip = [system.net.ipaddress]::Parse($ipAddress).GetAddressBytes()
    [array]::Reverse($ip)
    $ip = [system.BitConverter]::ToUInt32($ip, 0)
    
    $from = [system.net.ipaddress]::Parse($fromAddress).GetAddressBytes()
    [array]::Reverse($from)
    $from = [system.BitConverter]::ToUInt32($from, 0)
    
    $to = [system.net.ipaddress]::Parse($toAddress).GetAddressBytes()
    [array]::Reverse($to)
    $to = [system.BitConverter]::ToUInt32($to, 0)
    
    $from -le $ip -and $ip -le $to
}

function randomIP {
    param(
        [string] $ip
        )
    # check ip random IP already exists
    $dup = 0
    while ($dup -eq 0){
        # If IP = intern (10.0.0.0/24)
        if (isIpAddressInRange $ip $privFrom $privTo){
            # then set IP to 1.x.x.x
            $string = (1..254 | Get-Random -count 3) -join "."
            $random = "1.$($string)"
        } else {
            # else set IP to 2-254.x.x.x
            $random = (2..254 | Get-Random -count 4) -join "."
        }
        if (!$hash.ContainsKey($random)) {
            $dup = 1
        }
    }
    return $random
}

function saveKey {
    param(
        [hashtable] $hash)
        $hash.GetEnumerator() |
        Select-Object -Property @{N='Original';E={$_.Key}},
            @{N='Randomized';E={$_.Value}} |
        Export-Csv -NoTypeInformation -Path $keyFile
}

# __main__
checkExisting
$ips = Get-Content -Path $inputFile

foreach ($ip in $ips) {
    # check if IP in $hash (key)
    if ($hash.ContainsKey($ip)){
        # if ip in hash, set ip to value
        $output += $hash.$ip
    }else{
    # if not in $hash randomize IP and add to hash
        $value = randomIP $ip
        $hash.Add($ip,$value)
        $output += $value
    }
}
# save key file
saveKey $hash

# print
$output | Group-Object | format-table -Property Name, Count