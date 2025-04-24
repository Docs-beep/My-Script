##################################################################################
#                          AD Health Status 
##################################################################################
###########################Define Variables#######################################
$reportpath = ".\AD_Diagnostic.htm" 
if((test-path $reportpath) -like $false)
{
new-item $reportpath -type file
}
$smtphost = "10.145.75.147" 
$from = "DoNotReply@Dbhartiaxa.com" 
$email1 = "ashwin.sahu.ext@bhartiaxa.com"
$timeout = "60"
###############################HTml Report Content############################
$report = $reportpath
Clear-Content $report 
$date =Get-Date -Format G
Add-Content $report  "<td width='10%' align='center'><B> $date  </B></td>"
add-content $report "<BR>"
add-content $report  "<table width='100%' bgcolor='Black'>" 
add-content $report  "<tr>" 
add-content $report  "<font face='tahoma' color='#ff0000' size='10'><strong><a '>Kyndryl</a></strong></font>" 
add-content $report  "<td colspan='7' height='130' align='center' bgcolor='Black'>" 
add-content $report  "<font face='tahoma' color='#ff0000' size='75'><strong>Active Directory Health Report </strong></font>"
add-content $report  "</td>"  
add-content $report  "</tr>"
add-content $report  "</table>"
Add-Content $report "<html>" 
Add-Content $report "<head>" 
Add-Content $report "<meta http-equiv='Content-Type' content='text/html; charset=iso-8859-1'>" 
Add-Content $report '<title>AD Status Report</title>' 
add-content $report '<STYLE TYPE="text/css">' 
add-content $report  "<!--" 
add-content $report  "td {" 
add-content $report  "font-family: Tahoma;" 
add-content $report  "font-size: 11px;" 
add-content $report  "border-top: 1px solid #999999;" 
add-content $report  "border-right: 1px solid #999999;" 
add-content $report  "border-bottom: 1px solid #999999;" 
add-content $report  "border-left: 1px solid #999999;" 
add-content $report  "padding-top: 0px;" 
add-content $report  "padding-right: 0px;" 
add-content $report  "padding-bottom: 0px;" 
add-content $report  "padding-left: 0px;" 
add-content $report  "}" 
add-content $report  "body {" 
add-content $report  "margin-left: 5px;" 
add-content $report  "margin-top: 5px;" 
add-content $report  "margin-right: 0px;" 
add-content $report  "margin-bottom: 10px;" 
add-content $report  "" 
add-content $report  "table {" 
add-content $report  "border: thin solid #ff0000;" 
add-content $report  "}" 
add-content $report  "-->" 
add-content $report  "</style>" 
Add-Content $report "</head>" 
Add-Content $report "<body>" 
add-content $report  "<table width='100%'>" 
add-content $report  "<tr bgcolor='RED'>" 
add-content $report  "<td colspan='7' height='25' align='center'>" 
add-content $report  "<font face='tahoma' color='#FFFFFF' size='4'><strong>Active Directory Health </strong></font>" 
add-content $report  "</td>" 
add-content $report  "</tr>" 
add-content $report  "</table>" 
add-content $report  "<table width='100%'>" 
Add-Content $report  "<tr bgcolor='LightGray'>" 
Add-Content $report  "<td width='5%' align='center'><B>Identity</B></td>" 
Add-Content $report  "<td width='10%' align='center'><B>PingStatus</B></td>" 
Add-Content $report  "<td width='10%' align='center'><B>NetlogonService</B></td>" 
Add-Content $report  "<td width='10%' align='center'><B>NTDSService</B></td>" 
Add-Content $report  "<td width='10%' align='center'><B>DNSServiceStatus</B></td>" 
Add-Content $report  "<td width='10%' align='center'><B>Netlogons</B></td>"
Add-Content $report  "<td width='10%' align='center'><B>ReplicationStatus</B></td>"
Add-Content $report  "<td width='10%' align='center'><B>ServicesStatus</B></td>"
Add-Content $report  "<td width='10%' align='center'><B>AdvertisingStatus</B></td>"
Add-Content $report  "<td width='10%' align='center'><B>FSMOHealth</B></td>"
Add-Content $report  "<td width='10%' align='center'><B>MachineAccount</B></td>"
Add-Content $report "</tr>" 
#####################################Get ALL DC Servers###########################################
$getForest = [system.directoryservices.activedirectory.Forest]::GetCurrentForest()

$DCServers = $getForest.domains | ForEach-Object {$_.DomainControllers} | ForEach-Object {$_.Name} 


################Ping Test###########################################################################

foreach ($DC in $DCServers){
$Identity = $DC
                Add-Content $report "<tr>"
if ( Test-Connection -ComputerName $DC -Count 1 -ErrorAction SilentlyContinue ) {
Write-Host $DC `t $DC `t Ping Success -ForegroundColor Green
 
		Add-Content $report "<td bgcolor= 'White' align=center>  <B> $Identity</B></td>" 
                Add-Content $report "<td bgcolor= 'White' align=center>  <B>Success</B></td>" 
 
 
                ##############Netlogon Service Status################
		$serviceStatus = start-job -scriptblock {get-service -ComputerName $($args[0]) -Name "Netlogon" -ErrorAction SilentlyContinue} -ArgumentList $DC
                wait-job $serviceStatus -timeout $timeout
                if($serviceStatus.state -like "Running")
                {
                 Write-Host $DC `t Netlogon Service TimeOut -ForegroundColor Yellow
                 Add-Content $report "<td bgcolor= 'Yellow' align=center><B>NetlogonTimeout</B></td>"
                 stop-job $serviceStatus
                }
                else
                {
                $serviceStatus1 = Receive-job $serviceStatus
                 if ($serviceStatus1.status -eq "Running") {
 		   Write-Host $DC `t $serviceStatus1.name `t $serviceStatus1.status -ForegroundColor Green 
         	   $svcName = $serviceStatus1.name 
         	   $svcState = $serviceStatus1.status          
         	   Add-Content $report "<td bgcolor= 'White' align=center><B>$svcState</B></td>" 
                  }
                 else 
                  { 
       		  Write-Host $DC `t $serviceStatus1.name `t $serviceStatus1.status -ForegroundColor Red 
         	  $svcName = $serviceStatus1.name 
         	  $svcState = $serviceStatus1.status          
         	  Add-Content $report "<td bgcolor= 'Red' align=center><B>$svcState</B></td>" 
                  } 
                }

##################################################################################################################################################
                ##############NTDS Service Status#################################################################################################
		$serviceStatus = start-job -scriptblock {get-service -ComputerName $($args[0]) -Name "NTDS" -ErrorAction SilentlyContinue} -ArgumentList $DC
                wait-job $serviceStatus -timeout $timeout
                if($serviceStatus.state -like "Running")
                {
                 Write-Host $DC `t NTDS Service TimeOut -ForegroundColor Yellow
                 Add-Content $report "<td bgcolor= 'Yellow' align=center><B>NTDSTimeout</B></td>"
                 stop-job $serviceStatus
                }
                else
                {
                $serviceStatus1 = Receive-job $serviceStatus
                 if ($serviceStatus1.status -eq "Running") {
 		   Write-Host $DC `t $serviceStatus1.name `t $serviceStatus1.status -ForegroundColor Green 
         	   $svcName = $serviceStatus1.name 
         	   $svcState = $serviceStatus1.status          
         	   Add-Content $report "<td bgcolor= 'White' align=center><B>$svcState</B></td>" 
                  }
                 else 
                  { 
       		  Write-Host $DC `t $serviceStatus1.name `t $serviceStatus1.status -ForegroundColor Red 
         	  $svcName = $serviceStatus1.name 
         	  $svcState = $serviceStatus1.status          
         	  Add-Content $report "<td bgcolor= 'Red' align=center><B>$svcState</B></td>" 
                  } 
                }
               #########################################################################################################################################
               ##############DNS Service Status#######################################################################################################
		$serviceStatus = start-job -scriptblock {get-service -ComputerName $($args[0]) -Name "DNS" -ErrorAction SilentlyContinue} -ArgumentList $DC
                wait-job $serviceStatus -timeout $timeout
                if($serviceStatus.state -like "Running")
                {
                 Write-Host $DC `t DNS Server Service TimeOut -ForegroundColor Yellow
                 Add-Content $report "<td bgcolor= 'Yellow' align=center><B>DNSTimeout</B></td>"
                 stop-job $serviceStatus
                }
                else
                {
                $serviceStatus1 = Receive-job $serviceStatus
                 if ($serviceStatus1.status -eq "Running") {
 		   Write-Host $DC `t $serviceStatus1.name `t $serviceStatus1.status -ForegroundColor Green 
         	   $svcName = $serviceStatus1.name 
         	   $svcState = $serviceStatus1.status          
         	   Add-Content $report "<td bgcolor= 'White' align=center><B>$svcState</B></td>" 
                  }
                 else 
                  { 
       		  Write-Host $DC `t $serviceStatus1.name `t $serviceStatus1.status -ForegroundColor Red 
         	  $svcName = $serviceStatus1.name 
         	  $svcState = $serviceStatus1.status          
         	  Add-Content $report "<td bgcolor= 'Red' align=center><B>$svcState</B></td>" 
                  } 
                }
               ##################################################################################################################################

               ####################Netlogons status##############################################################################################
               add-type -AssemblyName microsoft.visualbasic 
               $cmp = "microsoft.visualbasic.strings" -as [type]
               $sysvol = start-job -scriptblock {dcdiag /test:netlogons /s:$($args[0])} -ArgumentList $DC
               wait-job $sysvol -timeout $timeout
               if($sysvol.state -like "Running")
               {
               Write-Host $DC `t Netlogons Test TimeOut -ForegroundColor Yellow
               Add-Content $report "<td bgcolor= 'Yellow' align=center><B>NetlogonsTimeout</B></td>"
               stop-job $sysvol
               }
               else
               {
               $sysvol1 = Receive-job $sysvol
               if($cmp::instr($sysvol1, "passed test NetLogons"))
                  {
                  Write-Host $DC `t Netlogons Test passed -ForegroundColor Green
                  Add-Content $report "<td bgcolor= 'White' align=center><B>Passed</B></td>"
                  }
               else
                  {
                  Write-Host $DC `t Netlogons Test Failed -ForegroundColor Red
                  Add-Content $report "<td bgcolor= 'Red' align=center><B>Fail</B></td>"
                  }
                }
               ########################################################
               ####################Replications status##################
               add-type -AssemblyName microsoft.visualbasic 
               $cmp = "microsoft.visualbasic.strings" -as [type]
               $sysvol = start-job -scriptblock {dcdiag /test:Replications /s:$($args[0])} -ArgumentList $DC
               wait-job $sysvol -timeout $timeout
               if($sysvol.state -like "Running")
               {
               Write-Host $DC `t Replications Test TimeOut -ForegroundColor Yellow
               Add-Content $report "<td bgcolor= 'Yellow' align=center><B>ReplicationsTimeout</B></td>"
               stop-job $sysvol
               }
               else
               {
               $sysvol1 = Receive-job $sysvol
               if($cmp::instr($sysvol1, "passed test Replications"))
                  {
                  Write-Host $DC `t Replications Test passed -ForegroundColor Green
                  Add-Content $report "<td bgcolor= 'White' align=center><B>Passed</B></td>"
                  }
               else
                  {
                  Write-Host $DC `t Replications Test Failed -ForegroundColor Red
                  Add-Content $report "<td bgcolor= 'Red' align=center><B>ReplicationsFail</B></td>"
                  }
                }
               ########################################################
	       ####################Services status##################
               add-type -AssemblyName microsoft.visualbasic 
               $cmp = "microsoft.visualbasic.strings" -as [type]
               $sysvol = start-job -scriptblock {dcdiag /test:Services /s:$($args[0])} -ArgumentList $DC
               wait-job $sysvol -timeout $timeout
               if($sysvol.state -like "Running")
               {
               Write-Host $DC `t Services Test TimeOut -ForegroundColor Yellow
               Add-Content $report "<td bgcolor= 'Yellow' align=center><B>ServicesTimeout</B></td>"
               stop-job $sysvol
               }
               else
               {
               $sysvol1 = Receive-job $sysvol
               if($cmp::instr($sysvol1, "passed test Services"))
                  {
                  Write-Host $DC `t Services Test passed -ForegroundColor Green
                  Add-Content $report "<td bgcolor= 'White' align=center><B>Passed</B></td>"
                  }
               else
                  {
                  Write-Host $DC `t Services Test Failed -ForegroundColor Red
                  Add-Content $report "<td bgcolor= 'Red' align=center><B>ServicesFail</B></td>"
                  }
                }
               ########################################################
	       ####################Advertising status##################
               add-type -AssemblyName microsoft.visualbasic 
               $cmp = "microsoft.visualbasic.strings" -as [type]
               $sysvol = start-job -scriptblock {dcdiag /test:Advertising /s:$($args[0])} -ArgumentList $DC
               wait-job $sysvol -timeout $timeout
               if($sysvol.state -like "Running")
               {
               Write-Host $DC `t Advertising Test TimeOut -ForegroundColor Yellow
               Add-Content $report "<td bgcolor= 'Yellow' align=center><B>AdvertisingTimeout</B></td>"
               stop-job $sysvol
               }
               else
               {
               $sysvol1 = Receive-job $sysvol
               if($cmp::instr($sysvol1, "passed test Advertising"))
                  {
                  Write-Host $DC `t Advertising Test passed -ForegroundColor Green
                  Add-Content $report "<td bgcolor= 'White' align=center><B>Passed</B></td>"
                  }
               else
                  {
                  Write-Host $DC `t Advertising Test Failed -ForegroundColor Red
                  Add-Content $report "<td bgcolor= 'Red' align=center><B>AdvertisingFail</B></td>"
                  }
                }
               ########################################################
	       ####################FSMOCheck status##################
               add-type -AssemblyName microsoft.visualbasic 
               $cmp = "microsoft.visualbasic.strings" -as [type]
               $sysvol = start-job -scriptblock {dcdiag /test:FSMOCheck /s:$($args[0])} -ArgumentList $DC
               wait-job $sysvol -timeout $timeout
               if($sysvol.state -like "Running")
               {
               Write-Host $DC `t FSMOCheck Test TimeOut -ForegroundColor Yellow
               Add-Content $report "<td bgcolor= 'Yellow' align=center><B>FSMOCheckTimeout</B></td>"
               stop-job $sysvol
               }
               else
               {
               $sysvol1 = Receive-job $sysvol
               if($cmp::instr($sysvol1, "passed test FsmoCheck"))
                  {
                  Write-Host $DC `t FSMOCheck Test passed -ForegroundColor Green
                  Add-Content $report "<td bgcolor= 'White' align=center><B>Passed</B></td>"
                  }
               else
                  {
                  Write-Host $DC `t FSMOCheck Test Failed -ForegroundColor Red
                  Add-Content $report "<td bgcolor= 'Red' align=center><B>FSMOCheckFail</B></td>"
                  }
                }
               #########################################################################################################################
                ############################Machin Account ##################################################
                   add-type -AssemblyName microsoft.visualbasic 
               $cmp = "microsoft.visualbasic.strings" -as [type]
               $sysvol = start-job -scriptblock {DCDIAG /test:MachineAccount /s:$($args[0])} -ArgumentList $DC
               wait-job $sysvol -timeout $timeout
               if($sysvol.state -like "Running")
               {
               Write-Host $DC `t MachineAccount Test TimeOut -ForegroundColor Yellow
               Add-Content $report "<td bgcolor= 'Yellow' align=center><B>MachineAccountTimeout</B></td>"
               stop-job $sysvol
               }
               else
               {
               $sysvol1 = Receive-job $sysvol
               if($cmp::instr($sysvol1, "passed test MachineAccount"))
                  {
                  Write-Host $DC `t MachineAccount Test passed -ForegroundColor Green
                  Add-Content $report "<td bgcolor= 'White ' align=center><B>Passed</B></td>"
                  }
               else
                  {
                  Write-Host $DC `t Advertising Test Failed -ForegroundColor Red
                  Add-Content $report "<td bgcolor= 'Red' align=center><B>MachineAccountFail</B></td>"
                  }
                }
              ###########################################################################################################################
                 
              ###########################################################################################################################
} 
else
              {
Write-Host $DC `t $DC `t Ping Fail -ForegroundColor Red
		Add-Content $report "<td bgcolor= 'GainsBoro' align=center>  <B> $Identity</B></td>" 
        Add-Content $report "<td bgcolor= 'Red' align=center>  <B>Ping Fail</B></td>" 
		Add-Content $report "<td bgcolor= 'Red' align=center>  <B>Ping Fail</B></td>" 
		Add-Content $report "<td bgcolor= 'Red' align=center>  <B>Ping Fail</B></td>"
        Add-Content $report "<td bgcolor= 'Red' align=center>  <B>Ping Fail</B></td>"
		Add-Content $report "<td bgcolor= 'Red' align=center>  <B>Ping Fail</B></td>" 
		Add-Content $report "<td bgcolor= 'Red' align=center>  <B>Ping Fail</B></td>"
		Add-Content $report "<td bgcolor= 'Red' align=center>  <B>Ping Fail</B></td>"
		Add-Content $report "<td bgcolor= 'Red' align=center>  <B>Ping Fail</B></td>"
		Add-Content $report "<td bgcolor= 'Red' align=center>  <B>Ping Fail</B></td>"
		Add-Content $report "<td bgcolor= 'Red' align=center>  <B>Ping Fail</B></td>"
        Add-Content $report "<td bgcolor= 'Red' align=center>  <B>Ping Fail</B></td>"
}         
       
} 

Add-Content $report "</tr>"

#############################################################################################################################

###############################Active Directory Information#################################################################
add-content $report  "</style>" 
Add-Content $report "</head>" 
Add-Content $report "<body>" 
add-content $report  "<table width='100%'>" 
add-content $report  "<tr bgcolor='#2F4F4F'>" 
add-content $report  "<td colspan='7' height='25' align='center'>" 
add-content $report  "<font face='Segoe UI' color='#FFFFFF' size='3'><strong>Active Directory Information</strong></font>" 
add-content $report  "</td>" 
add-content $report  "</tr>" 
add-content $report  "</table>"
add-content $report  "<table width='100%'>" 
Add-Content $report  "<tr bgcolor='LightGray'>"
Add-Content $report  "<td width='10%' align='center'><B>Host Name</B></td>"
Add-Content $report  "<td width='10%' align='center'><B>IP Address</B></td>"
Add-Content $report  "<td width='10%' align='center'><B>Operating System</B></td>"
Add-Content $report  "<td width='10%' align='center'><B>Global Catalog</B></td>"
Add-Content $report  "<td width='10%' align='center'><B>Site</B></td>"
Add-Content $report  "<td width='10%' align='center'><B>Forest</B></td>"
Add-Content $report  "<td width='10%' align='center'><B>LDAP Port</B></td>"
Add-Content $report  "<td width='10%' align='center'><B>SSL Port</B></td>"
Add-Content $report  "<td width='10%' align='center'><B>RIDmanger</B></td>" 

add-content $report  "</tr>" 

#########################################################################################################################################

#####################################Domain Servers Information##########################################################################
 Add-Content $report "<tr>"
$ADDomainController1=Get-ADDomainController -Filter * | Select-Object Hostname |ConvertTo-Html -As Table 
$ADDomainController2=Get-ADDomainController -Filter * | Select-Object Ipv4address|ConvertTo-Html -As Table 
$ADDomainController3=Get-ADDomainController -Filter * | Select-Object OperatingSystem|ConvertTo-Html -As Table 
$ADDomainController4=Get-ADDomainController -Filter * | Select-Object isGlobalCatalog|ConvertTo-Html -As Table
$ADDomainController5=Get-ADDomainController -Filter * | Select-Object Site|ConvertTo-Html -As Table
$ADDomainController6=Get-ADDomainController -Filter * | Select-Object Forest|ConvertTo-Html -As Table
$ADDomainController7=Get-ADDomainController -Filter * | Select-Object LdapPort|ConvertTo-Html -As Table
$ADDomainController8=Get-ADDomainController -Filter * | Select-Object SslPort|ConvertTo-Html -As Table

Add-Content $report "<td bgcolor= 'White' '<td width='2%' 'align=Left>  <B> $ADDomainController1</B></td>"
Add-Content $report "<td bgcolor= 'White' '<td width='2%'  align=Left>  <B> $ADDomainController2</B></td>"
Add-Content $report "<td bgcolor= 'White' '<td width='22%' align=Left>  <B> $ADDomainController3</B></td>"
Add-Content $report "<td bgcolor= 'White' align=center>  <B> $ADDomainController4</B></td>"
Add-Content $report "<td bgcolor= 'White' align=center>  <B> $ADDomainController5</B></td>"
Add-Content $report "<td bgcolor= 'White' align=center>  <B> $ADDomainController6</B></td>"
Add-Content $report "<td bgcolor= 'White' align=center>  <B> $ADDomainController7</B></td>"
Add-Content $report "<td bgcolor= 'White' align=center>  <B> $ADDomainController8</B></td>"

####################################################################################################################################

#########################################RID Manger ################################################################################  
               
       add-type -AssemblyName microsoft.visualbasic 
               $cmp = "microsoft.visualbasic.strings" -as [type]
               $sysvol = start-job -scriptblock {DCDIAG /test:RidManager /s:$($args[0])} -ArgumentList $DC
               wait-job $sysvol -timeout $timeout
               if($sysvol.state -like "Running")
               {
               Write-Host $DC `t RidManager Test TimeOut -ForegroundColor Yellow
               Add-Content $report "<td bgcolor= 'Yellow' align=center><B>RidManagerTimeout</B></td>"
               stop-job $sysvol
               }
               else
               {
               $sysvol1 = Receive-job $sysvol
               if($cmp::instr($sysvol1, "passed test RidManager"))
                  {
                  Write-Host $DC `t RidManager Test passed -ForegroundColor Green
                  Add-Content $report "<td bgcolor= 'White ' align=center><B>Passed</B></td>"
                  }
               else
                  {
                  Write-Host $DC `t ARidManager Test Failed -ForegroundColor Red
                  Add-Content $report "<td bgcolor= 'Red' align=center><B>RidManagerFail</B></td>"
                  }
                }
              
#########################################################################################################################################

##########################################Domain Information#############################################################################
add-content $report  "</style>" 
Add-Content $report "</head>" 
Add-Content $report "<body>" 
add-content $report  "<table width='100%'>" 
add-content $report  "<tr bgcolor='#2F4F4F'>" 
add-content $report  "<td colspan='7' height='25' align='center'>" 
add-content $report  "<font face='Segoe UI' color='#FFFFFF' size='3'><strong>Domain Information</strong></font>" 
add-content $report  "</td>" 
add-content $report  "</tr>" 
add-content $report  "</table>" 
add-content $report  "<table width='100%'>" 
Add-Content $report  "<tr bgcolor='LightGray'>"
Add-Content $report  "<td width='10%' align='center'><B>Forest</B></td>"
Add-Content $report  "<td width='10%' align='center'><B>FSMO Domain Wide</B></td>"
Add-Content $report  "<td width='10%' align='center'><B>FSMO Forest Wide</B></td>"
Add-Content $report  "<td width='10%' align='center'><B>AD Site</B></td>"
Add-Content $report  "<td width='10%' align='center'><B>AD Site Link </B></td>"
Add-Content $report  "<td width='10%' align='center'><B>NTP Status </B></td>"


add-content $report  "</tr>"

#####################################DC Servers Information##########################################################

$Forest = Get-ADForest | ConvertTo-Html -As List  -Property Name,ForestMode -Fragment -PreContent "<h2>Forest</h2>"
Add-Content $report "<td bgcolor= 'White' align=center>  <B> $Forest</B></td>"

###############################################FSMO ###################################################################

$fsmo = Get-ADDomain | Select-Object InfrastructureMaster, RIDMaster, PDCEmulator  | ConvertTo-Html -As List -Property InfrastructureMaster, RIDMaster, PDCEmulator  -Fragment -PreContent "<h2> FSMO Domain Wide Roles</h2>" 
Add-Content $report "<td bgcolor= 'White' align=left>  <B> $fsmo</B></td>"


#################################################FSMO##########################################################################

$fsmo1 = Get-ADForest | Select-Object DomainNamingMaster, SchemaMaster  | ConvertTo-Html -As List -Property DomainNamingMaster, SchemaMaster   -Fragment -PreContent "<h2> FSMO Forest Wide Roles</h2>"
Add-Content $report "<td bgcolor= 'White' align=center>  <B> $fsmo1</B></td>"

############################Sites Name#####################################################################################

$ADSite = Get-AdReplicationSite -Filter * | Select Name | ConvertTo-Html -As Table -Property Name -Fragment -PreContent "<h2>AD Sites</h2>"
Add-Content $report "<td bgcolor= 'White' align=center>  <B> $ADSite</B></td>"

############################Site Cost############################################################################################

$ADSiteCost = Get-ADReplicationSiteLink -Filter * |select Name,Cost,ReplicationFrequencyInMinutes | ConvertTo-Html -As List -Property Name,Cost,ReplicationFrequencyInMinutes -Fragment -PreContent "<h2> AD Sites Link Cost</h2>"
Add-Content $report "<td bgcolor= 'White' align=center>  <B> $ADSiteCost</B></td>"

#####################################NTP Status##########################################################

 
foreach($computers in $DC){
$Computers
$ComputerInfo = New-Object System.Object
$ntp = w32tm /query /Source  
$ComputerInfo |Add-Member -MemberType NoteProperty -Name "ServerName" -Value "$Computers" 

$ComputerInfo |Add-Member -MemberType NoteProperty -Name "NTP Source" -Value "$Ntp" 
#$Inventory.Add($ComputerInfo) | Out-Null
 Add-Content $report "<td bgcolor= 'White' align=center>  <B> $ntp </B></td>"

  }

 
#################################################Group policy Information##################################################################
add-content $report  "</style>" 
Add-Content $report "</head>" 
Add-Content $report "<body>" 
add-content $report  "<table width='100%'>" 
add-content $report  "<tr bgcolor='#2F4F4F'>" 
add-content $report  "<td colspan='7' height='25' align='center'>" 
add-content $report  "<font face='Segoe UI' color='#FFFFFF' size='3'><strong>Group policy Information </strong></font>" 
add-content $report  "</td>" 
add-content $report  "</tr>" 
add-content $report  "</table>" 
add-content $report  "<table width='100%'>" 
Add-Content $report  "<tr bgcolor='LightGray'>"
Add-Content $report  "<td width='10%' align='center'><B>Group Policy</B></td>"
Add-Content $report  "<td width='10%' align='center'><B>Group Policy</B></td>"

add-content $report  "</tr>"
#############################################################################################################################################

#######################################################Default Domain PasswordPolicy##########################################################

$DefaultDomainPasswordPolicy= (Get-ADForest ).Domains | %{ Get-ADDefaultDomainPasswordPolicy -Identity $_ }   |ConvertTo-Html  -As List -Property  ComplexityEnabled,DistinguishedName,LockoutDuration,LockoutThreshold,MaxPasswordAge,MinPasswordAge,MinPasswordLength,PasswordHistoryCount,ReversibleEncryptionEnabled  -Fragment -PreContent "<h2>Default Domain PasswordPolicy</h2>"
Add-Content $report "<td bgcolor= 'White' align=Left>  <B> $DefaultDomainPasswordPolicy</B></td>"
$GPO=Get-GPO -all   | select DisplayName, GpoStatus |ConvertTo-Html  -As Table  -Fragment -PreContent "<h2></h2>"
Add-Content $report "<td bgcolor= 'White' align=left>  <B> $GPO</B></td>"



###########################################################################################################

##################################Privilege Users########################################################
add-content $report  "</style>" 
Add-Content $report "</head>" 
Add-Content $report "<body>" 
add-content $report  "<table width='100%'>" 
add-content $report  "<tr bgcolor='#2F4F4F'>" 
add-content $report  "<td colspan='7' height='25' align='center'>" 
add-content $report  "<font face='Segoe UI' color='#FFFFFF' size='3'><strong>Privilege Users</strong></font>" 
add-content $report  "</td>" 
add-content $report  "</tr>" 
add-content $report  "</table>" 
add-content $report  "<table width='100%'>" 
Add-Content $report  "<tr bgcolor='LightGray'>"
Add-Content $report  "<td width='10%' align='center'><B>Privilege Users</B></td>"
Add-Content $report  "<td width='10%' align='center'><B>Password Never Expires</B></td>"

add-content $report  "</tr>"

###########################################Privilege Users##################################################################
$Privilege= Get-ADGroupMember "Domain ADmins" | select Name  |ConvertTo-Html  -As Table -Property  Name  -Fragment -PreContent "<h2>Privilege Users</h2>"
Add-Content $report "<td bgcolor= 'White' align=center>  <B>$Privilege</B></td>"
##############################################Password Never Expires###############################################################

$PasswordNeverExpires=Get-ADUser -filter * -Properties PasswordNeverExpires | select name,PasswordNeverExpires | Where-Object {$_.PasswordNeverExpires -like "True"} |ConvertTo-Html  -As Table -Property  Name  -Fragment -PreContent "<h2>Password Never Expires Users</h2>"
Add-Content $report "<td bgcolor= 'White' align=center>  <B> $PasswordNeverExpires</B></td>"

#############################################################################################

#########################################################Backup ########################################

 add-content $report  "</style>" 
Add-Content $report "</head>" 
Add-Content $report "<body>" 
add-content $report  "<table width='100%'>" 
add-content $report  "<tr bgcolor='#2F4F4F'>" 
add-content $report  "<td colspan='7' height='25' align='center'>" 
add-content $report  "<font face='tahoma' color='#FFFFFF' size='3'><strong>Backup Report</strong></font>" 
add-content $report  "</td>" 
add-content $report  "</tr>" 
add-content $report  "</table>" 
add-content $report  "<table width='100%'>" 
Add-Content $report  "<tr bgcolor='LightGray'>"
Add-Content $report  "<td width='10%' align='center'><B>DC Backup</B></td>"
Add-Content $report  "<td width='10%' align='center'><B>DaysNotBackp</B></td>"
Add-Content $report  "<td width='10%' align='center'><B>Last Backup</B></td>"



add-content $report  "</tr>"
#######################################################Backup###############################################
 $TotNo = 0
$TestStatus = "Passed"
$TestText = ""
$TodaysDate = Get-Date
$IssueOrNot = "No"
$AnyGap = "No"
$AnyOneOk = "No"

$Error.Clear()
[string]$dnsRoot = (Get-ADDomain).DNSRoot
[string[]]$Partitions = (Get-ADRootDSE).namingContexts
$contextType = [System.DirectoryServices.ActiveDirectory.DirectoryContextType]::Domain
$context = new-object System.DirectoryServices.ActiveDirectory.DirectoryContext($contextType,$dnsRoot)
$domainController = [System.DirectoryServices.ActiveDirectory.DomainController]::findOne($context)
IF ($Error.count -eq 0)
	{
	$AnyOneOk = "Yes"
	ForEach($partition in $partitions)
		{
		$domainControllerMetadata = $domainController.GetReplicationMetadata($partition)
		$dsaSignature = $domainControllerMetadata.Item("dsaSignature")

		$R = $($dsaSignature.LastOriginatingChangeTime.DateTime)
		$Z = $TodaysDate
		$FinCom = "Ok"
		$DaysNotBack = (New-TimeSpan -Start $R -End $Z).Days
		IF ($DaysNotBack -ge 7)
			{
			$FinCom = "Partition has NOT been backed up since last 7 days."
			$TestStatus = "Failed"
			$AnyGap = "Yes"
			}

		$ThisSTr = '"'+$Partition+'"'+","+'"'+$($dsaSignature.LastOriginatingChangeTime.DateTime)+'"'+","+$FinCom
	add-content $report  "</tr>"	
Add-Content $report "<td bgcolor= 'White' align=center>  <B> $Partition</B></td>"
Add-Content $report "<td bgcolor= 'White' align=center>  <B> $DaysNotBack</B></td>"
Add-Content $report "<td bgcolor= 'White' align=center>  <B> $R </B></td>"
		$ThisSTR
		}
	}

IF ($AnyGap -eq "Yes")
	{
	$TestStatus = "High"
	$SumVal = ""
	$TestText = "Some AD Partitions have not been backed up since last 7 days."
	}

IF ($AnyGap -eq "No")
	{
	$TestStatus = "Passed"
	$SumVal = ""
	$TestText = "All AD Partitions were backed up recently."

	IF ($AnyOneOk -eq "No")
		{
		$TestStatus = "Error"
		$TestText = "Error Executing Dynamic Pack"
		$SumVal = ""
		}
	}

$STR = $ADTestName +","+$TestStartTime+","+$TestStatus+","+$SumVal +","+$TestText

### Script Ends here ###

#######################################################################################################
##################################Network########################################################
add-content $report  "</style>" 
Add-Content $report "</head>" 
Add-Content $report "<body>" 
add-content $report  "<table width='100%'>" 
add-content $report  "<tr bgcolor='#2F4F4F'>" 
add-content $report  "<td colspan='7' height='25' align='center'>" 
add-content $report  "<font face='Segoe UI' color='#FFFFFF' size='3'><strong>Network Utilization Monitor</strong></font>" 
add-content $report  "</td>" 
add-content $report  "</tr>" 
add-content $report  "</table>" 
add-content $report  "<table width='100%'>" 
Add-Content $report  "<tr bgcolor='LightGray'>"
Add-Content $report  "<td width='10%' align='center'><B>Network Utilization </B></td>"


add-content $report  "</tr>"
###########################################################
# Measure the Network interface IO over a period of half a minute (0.5)

$startTime = get-date
$endTime = $startTime.addMinutes(0.5)
$timeSpan = new-timespan $startTime $endTime

$count = 0
$totalBandwidth = 0

while ($timeSpan -gt 0)
{
   # Get an object for the network interfaces, excluding any that are currently disabled.
   $colInterfaces = Get-CimInstance -class Win32_PerfFormattedData_Tcpip_NetworkInterface |select BytesTotalPersec, CurrentBandwidth,PacketsPersec|where {$_.PacketsPersec -gt 0}

   foreach ($interface in $colInterfaces) {
      $bitsPerSec = $interface.BytesTotalPersec * 8
      $totalBits = $interface.CurrentBandwidth

      # Exclude Nulls (any WMI failures)
      if ($totalBits -gt 0) {
         $result = (( $bitsPerSec / $totalBits) * 100)
         Write-Host "Bandwidth utilized:`t $result %"
         $totalBandwidth = $totalBandwidth + $result
         $count++
      }
   }
   Start-Sleep -milliseconds 100

   # recalculate the remaining time
   $timeSpan = new-timespan $(Get-Date) $endTime
}

"Measurements:`t`t $count"

$averageBandwidth = $totalBandwidth / $count
$value = "{0:N2}" -f $averageBandwidth
Write-Host "Average Bandwidth utilized:`t $value %"
Add-Content $report "<td bgcolor= 'White' align=center>  <B>$averageBandwidth</B></td>"

#######################################################################################################

##################################DC Patch########################################################
add-content $report  "</style>" 
Add-Content $report "</head>" 
Add-Content $report "<body>" 
add-content $report  "<table width='100%'>" 
add-content $report  "<tr bgcolor='#2F4F4F'>" 
add-content $report  "<td colspan='7' height='25' align='center'>" 
add-content $report  "<font face='Segoe UI' color='#FFFFFF' size='3'><strong>DC Patch</strong></font>" 
add-content $report  "</td>" 
add-content $report  "</tr>" 
add-content $report  "</table>" 
add-content $report  "<table width='100%'>" 
Add-Content $report  "<tr bgcolor='LightGray'>"
Add-Content $report  "<td width='10%' align='center'><B>Domain Controller  </B></td>"
Add-Content $report  "<td width='10%' align='center'><B> Connection </B></td>"
Add-Content $report  "<td width='10%' align='center'><B> Last Update Date </B></td>"

add-content $report  "</tr>"
##############################################################DC Patch############################


$ThisStr=”Domain Controller,Connection,Command Status, Number of Updates Applied Since last 30 Days, Last Update Date,Final Status”
$getForest = [system.directoryservices.activedirectory.Forest]::GetCurrentForest()
$DCServers = $getForest.domains | ForEach-Object {$_.DomainControllers} | ForEach-Object {$_.Name} 
$TotNo=0
$ItemCount=0
$TestText = “”
$TestStatus=””
$SumVal = “”
$AnyGap = “No”
$ErrorOrNot = “No”
$AnyOneOk = “No”
$TotDCsInError = 0
Foreach ($ItemName  in $DCServers)
{
$DCConError = “Ok”
$DCConStatus = “Ok”
$ProceedOrNot = “Yes”
$Error.Clear()
#$AllServices = Get-WMIObject Win32_Service -computer $ItemName
IF ($Error.Count -ne 0)
{
$ProceedOrNot = “No”
$TotDCsInError++
$DCConError = $Error[0].Exception.Message
$FinalSTR = $ItemName+”,Not OK: Error: $DCConError”
Add-Content $FinalSTR
}
IF ($ProceedOrNot -eq “Yes”)
{
$ComConError=”Ok”
$Error.Clear()
$TotHotFixes = Get-HotFix -ComputerName $ItemName | Where-Object {$_.Installedon -gt ((Get-Date).Adddays(-30))}
$AnyOneOk=”Yes”
$TotHF = $TotHotFixes.Count
$FinalStatusNow = “OK”
IF ($TotHF -eq 0)
{
$IsHFOk = “No”
$AnyGap = “Yes”
$FinalStatusNow = “WARNING: Domain Controller has not been patched since last 30 days.”
}
$TotHotFixes = Get-HotFix -ComputerName $ItemName | ?{ $_.installedon } | sort @{e={[datetime]$_.InstalledOn}} | select -last 1
$LastNowAll = $TotHotFixes.InstalledOn.DateTime
IF ($AnyGap -eq “Yes”)
{
$TotNo++
}
$ThisSTr = $ItemName+”,”+$DCConError+”,”+$ComConError+”,”+$TotHF+”,”+'”‘+$LastNowAll+'”‘+”,”+$FinalStatusNow

add-content $report  "</tr>"
Add-Content $report "<td bgcolor= 'White' align=center>  <B> $ItemName</B></td>" 
Add-Content $report "<td bgcolor= 'White' align=center>  <B> $DCConError</B></td>"
Add-Content $report "<td bgcolor= 'White' align=center>  <B> $LastNowAll</B></td>"
}
else
{
$ComConError = $Error[0].Exception.Message
$FinalSTR = $ItemName+”,$DCConError,”+$ComConError
Add-Content $FinalSTR
 
}
}
$OthText = “”
IF ($TotDCsInError -ne 0)
{
$OthText = “Some Domain Controllers have not been checked due to connectivity or command issues.”
}
IF ($AnyGap -eq “Yes”)
{
$TestText = “Some domain controllers have not been patched since last 30 days. $OthText”
$SumVal = $TotNo
$TestStatus=”High”
}
IF ($AnyGap -eq “No”)
{
$TestText = “All Domain Controllers have been patching since last 30 days. Please load and check result to ensure Last Pathing Date is current. $OthText”
$SumVal = “”
$TestStatus=”Passed”
IF ($AnyOneOk -eq “No”)
{
$TestText = “Error Executing Dynamic Pack.”
$SumVal = “”
$TestStatus=”Completed with Errors.”
}
}
$STR = $ADTestName +”,”+$TestStartTime+”,”+$TestStatus+”,”+$SumVal +”,”+$TestText

#######################################################################################################

##################################Event ID########################################################
add-content $report  "</style>" 
Add-Content $report "</head>" 
Add-Content $report "<body>" 
add-content $report  "<table width='100%'>" 
add-content $report  "<tr bgcolor='#2F4F4F'>" 
add-content $report  "<td colspan='7' height='25' align='center'>" 
add-content $report  "<font face='Segoe UI' color='#FFFFFF' size='3'><strong>Event ID </strong></font>" 
add-content $report  "</td>" 
add-content $report  "</tr>" 
add-content $report  "</table>" 
add-content $report  "<table width='100%'>" 
Add-Content $report  "<tr bgcolor='LightGray'>"
Add-Content $report  "<td width='10%' align='center'><B>System Error  </B></td>"

add-content $report  "</tr>"
############################################################## Event System Error############################
$EventSE=Get-EventLog -LogName System -EntryType Error -Newest 30 |Select-Object -Property TimeGenerated,EventID,EntryType,Source,Message|Sort-Object EventID -Unique|ConvertTo-Html -As Table 

Add-Content $report "<td bgcolor= 'White' '<td width='2%' 'align=Left>  <B> $EventSE</B></td>"

###################################################################################

##################################Event ID System ########################################################
add-content $report  "</style>" 
Add-Content $report "</head>" 
Add-Content $report "<body>" 
add-content $report  "<table width='100%'>" 
add-content $report  "<tr bgcolor='#2F4F4F'>" 
add-content $report  "<td colspan='7' height='25' align='center'>" 
add-content $report  "<font face='Segoe UI' color='#FFFFFF' size='3'><strong>Event ID </strong></font>" 
add-content $report  "</td>" 
add-content $report  "</tr>" 
add-content $report  "</table>" 
add-content $report  "<table width='100%'>" 
Add-Content $report  "<tr bgcolor='LightGray'>"
Add-Content $report  "<td width='10%' align='center'><B>System Warning  </B></td>"

add-content $report  "</tr>"
#######################################################################
############################################################## Event ID Sysyem ############################
 $EventSW=Get-EventLog -LogName System -EntryType Warning -Newest 30 |Select-Object -Property TimeGenerated,EventID,EntryType,Source,Message|Sort-Object EventID -Unique|ConvertTo-Html -As Table 

 Add-Content $report "<td bgcolor= 'White' '<td width='2%' 'align=Left>  <B> $EventSW</B></td>"

#######################################################################################################

##################################Event ID Application ########################################################
add-content $report  "</style>" 
Add-Content $report "</head>" 
Add-Content $report "<body>" 
add-content $report  "<table width='100%'>" 
add-content $report  "<tr bgcolor='#2F4F4F'>" 
add-content $report  "<td colspan='7' height='25' align='center'>" 
add-content $report  "<font face='Segoe UI' color='#FFFFFF' size='3'><strong>Event ID </strong></font>" 
add-content $report  "</td>" 
add-content $report  "</tr>" 
add-content $report  "</table>" 
add-content $report  "<table width='100%'>" 
Add-Content $report  "<tr bgcolor='LightGray'>"
Add-Content $report  "<td width='10%' align='center'><B>Application Error  </B></td>"

add-content $report  "</tr>"
############################################################## Event ID Application ############################

$EventAE=Get-EventLog -LogName Application -EntryType Error -Newest 30 |Select-Object -Property TimeGenerated,EventID,EntryType,Source,Message|Sort-Object EventID -Unique|ConvertTo-Html -As Table 

Add-Content $report "<td bgcolor= 'White' '<td width='2%' 'align=Left>  <B> $EventAE</B></td>"

#######################################################################################################

##################################Event ID Application ########################################################
add-content $report  "</style>" 
Add-Content $report "</head>" 
Add-Content $report "<body>" 
add-content $report  "<table width='100%'>" 
add-content $report  "<tr bgcolor='#2F4F4F'>" 
add-content $report  "<td colspan='7' height='25' align='center'>" 
add-content $report  "<font face='Segoe UI' color='#FFFFFF' size='3'><strong>Event ID </strong></font>" 
add-content $report  "</td>" 
add-content $report  "</tr>" 
add-content $report  "</table>" 
add-content $report  "<table width='100%'>" 
Add-Content $report  "<tr bgcolor='LightGray'>"
Add-Content $report  "<td width='10%' align='center'><B>Application Warning  </B></td>"

add-content $report  "</tr>"
############################################################## Event ID ############################

$EventAW=Get-EventLog -LogName Application -EntryType Warning -Newest 30 |Select-Object -Property TimeGenerated,EventID,EntryType,Source,Message|Sort-Object EventID -Unique|ConvertTo-Html -As Table 

Add-Content $report "<td bgcolor= 'White' '<td width='2%' 'align=Left>  <B> $EventAW</B></td>"

#############################################################################################
#############################################################################################
Add-content $report  "</table>"
Add-Content $report "</body>" 
Add-Content $report "</html>" 

########################################################################################
#############################################Send Email#################################


$subject = "Active Directory Health Monitor" 
$body = Get-Content ".\AD_Diagnostic.htm" 
$smtp= New-Object System.Net.Mail.SmtpClient $smtphost 
$msg = New-Object System.Net.Mail.MailMessage 
$msg.To.Add($email1)
$msg.from = $from
$msg.subject = $subject
$msg.body = $body 
$msg.isBodyhtml = $true 
$smtp.send($msg) 

########################################################################################

########################################################################################
 
         	
		