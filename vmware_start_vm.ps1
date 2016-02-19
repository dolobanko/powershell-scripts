Add-PSSnapin VMware.VimAutomation.Core  
  
$vcenter="87.201.216.178"  

#Connect to vcenter server  
connect-viserver $vcenter  

#Exit ESXi maintance mode

#Get-VMHost | Set-VMHost -State Connected

#Import vm name from csv file  
Import-Csv C:\scripts\poweredonvms.csv | 

foreach {  
    $strNewVMName = $_.name  

    #Generate a view for each vm to determine power state  
    $vm = Get-View -ViewType VirtualMachine -Filter @{"Name" = $strNewVMName}  
  
    #If vm is powered off - run VM  
           if ($vm.Runtime.PowerState -eq "PoweredOff")  {  
                
                  Write-Host "Starting VM $strNewVMName ----"  
                  Start-VM $strNewVMName -Confirm:$false  
                  Write-Host "Starting ..." 
		  Sleep 20

                  }  
}