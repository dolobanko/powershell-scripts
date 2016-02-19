If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))

{   
$arguments = "& '" + $myinvocation.mycommand.definition + "'"
Start-Process powershell -Verb runAs -ArgumentList $arguments
Break
}

write-host "We are happy admins"
Add-PSSnapin VMware.VimAutomation.Core  

$vcenter="87.201.216.178"  

#Connect to vcenter server  
connect-viserver $vcenter  

#Get-VM | Where-Object {$_.powerstate -eq ‘PoweredOn’} | select Name | ConvertTo-Csv -NoTypeInformation | % { $_ -replace '"', ""}  | out-file C:\poweredonvms.csv
Stop-VMGuest GoldenIm

sleep 10

# Run your code that needs to be elevated here
Write-Host -NoNewLine "Press any key to continue..."

$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
