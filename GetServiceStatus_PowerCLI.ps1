$vCenterCreds = (Get-Credential)
$vCenter = (Read-Host -Prompt "IP or Hostname of vCenter")
$VMUsername = (Read-Host -Prompt "VM Guest Username")
$VMPassword = (Read-Host -AsSecureString -Prompt "VM Guest Password" )
$service = (Read-Host -Prompt "Enter Service you are looking for status of i.e. wuauserv")
$VMNameStartsWith = (Read-Host -Prompt "What is your VM name or does it start with") #Accepts wildcards
Connect-VIServer -Server $vCenter -Credential $vCenterCreds

get-vm -Name $VMNameStartsWith | ForEach-Object {
Invoke-VMScript -VM $_ -ScriptText "Get-Service $service" -GuestUser $VMUsername -GuestPassword $VMPassword -ScriptType PowerShell
}

