#Switch to administrator level
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }

#Loading VMware Snap
Add-PSSnapin VMware.VimAutomation.Core  
  
$vcenter="87.201.216.178"  

#Connect to vcenter server  
connect-viserver $vcenter  

#Get-VM | Where-Object {$_.powerstate -eq ‘PoweredOn’} | select Name | ConvertTo-Csv -NoTypeInformation | % { $_ -replace '"', ""}  | out-file C:\scripts\poweredonvms.csv
 
#Import vm name from csv file  
Import-Csv C:\poweredonvms.csv |  
foreach {  
    $strNewVMName = $_.name  
  
    #Generate a view for each vm to determine power state  
    $vm = Get-View -ViewType VirtualMachine -Filter @{"Name" = $strNewVMName}  
  
    #If vm is powered on then VMware Tools status is checked  
           if ($vm.Runtime.PowerState -ne "PoweredOff") {  
               if ($vm.config.Tools.ToolsVersion -ne 0) {  
  
                   Write-Host "Graceful OS shutdown ++++++++ $strNewVMName ----"  
                   Shutdown-VMGuest $strNewVMName -Confirm:$false  
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
Sleep 10  


Write-Host "Shutdown Complete"

#Disconnect vcenter server  
disconnect-viserver $vcenter -Confirm:$false  