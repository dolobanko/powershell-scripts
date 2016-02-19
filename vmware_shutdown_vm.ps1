#Switch to administrator level

If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))

{   
$arguments = "& '" + $myinvocation.mycommand.definition + "'"
Start-Process powershell -Verb runAs -ArgumentList $arguments
Break
}

#Create directory for vmlist file

New-Item -ItemType directory -Force -Path C:\scripts\

#Loading VMware Snap
Add-PSSnapin VMware.VimAutomation.Core  
  
$vcenter="87.201.216.178"  

#Connect to vcenter server  
connect-viserver $vcenter  

Get-VM | Where-Object {$_.powerstate -eq ‘PoweredOn’} | select Name | ConvertTo-Csv -NoTypeInformation | % { $_ -replace '"', ""}  | out-file C:\scripts\poweredonvms.csv
 
#Import vm name from csv file  
Import-Csv C:\scripts\poweredonvms.csv |  
foreach {  
    $strNewVMName = $_.name  
  
    #Generate a view for each vm to determine power state  
    $vm = Get-View -ViewType VirtualMachine -Filter @{"Name" = $strNewVMName}  
  
    #If vm is powered on then VMware Tools status is checked  
           if ($vm.Runtime.PowerState -ne "PoweredOff") {  
               if ($vm.config.Tools.ToolsVersion -ne 0) {  
  
                   Write-Host "Graceful OS shutdown ++++++++ $strNewVMName ----"  
                   Stop-VMGuest $strNewVMName -Confirm:$false  
                   write-host "Sleeping ..." 
		   Sleep 10
               }  
               else {  
  
                    Write-Host "Force VM shutdown ++++++++ $strNewVMName ----"  
		    Stop-VM $strNewVMName -Confirm:$false  
		    write-host "Sleeping ..." 
		    Sleep 10
                              
               }  
           }  
}  
  
write-host "Sleeping ..."  
Sleep 600  

#Set ESXi host in maintance mode
Set-VMhost -VMhost $vcenter -State Maintenance
Sleep 15

#Shutdown ESXi
Get-VMhost | Foreach {Get-View $_.ID} | Foreach {$_.ShutdownHost_Task($TRUE)}

Write-Host "Shutdown Complete"

#Disconnect vcenter server  
disconnect-viserver $vcenter -Confirm:$false  

# Exit
Write-Host -NoNewLine "Press any key to quit..."

$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")