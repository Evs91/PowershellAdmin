########
!!!!!
# Please rename the last columns in the csv that comes from Docusign that are labled "group". This will be addressed later but there is an issue where the multiple instances of "Group" cause an issue with the array
!!!!!
########

# Import AD Module
Import-Module activedirectory

#Table Setup

$OutputTable = @{} #currently takes an email as the key and values of "email, permissions, IsADEnabled, IsDocusignEnabled"
$DocusignTable = @{}
$ADTable = @{}

#Variables
$UserOUs = @("") #Comma seperated values with DN information


#Import Docusign users and properties into a table

Import-Csv .\users.csv | ForEach-Object {
  $DocusignTable[$_.UserEmail] = New-Object -Type PSCustomObject -Property @{  #Or is it better to use the APIUsername as the PK?
  'Status' = $_.'Status'
  'FirstName' = $_.'FirstName'
  'LastName' = $_.'Lastname'
  'CompanyName' = $_.'CompanyName'
  'PermissionSet' = $_.'PermissionSet'
  'AllAdmin' = $_.'All Administration Capabilities'
  'DelegatedUserAdmin' = $_.'Delegated Administration - Users and Groups'
  'Email' = $_.'UserEmail'
  'Group1' = $_.'Group1'
  'Group2' = $_.'Group2'
  'Group3' = $_.'Group3'
  'Group4' = $_.'Group4'
  }
}



# Populates ADTable with users in AD OUs specified above
foreach ($x in $UserOUs) {

            $ADUsers = Get-ADUser -Filter * -SearchBase $x -Properties SamAccountName,sn,GivenName,mail,EmailAddress,LastLogonDate,Department,DistinguishedName,CanonicalName,enabled | #query AD for users in the IT group, SFCU Users, and Laptop users OU
                        Select-Object SamAccountName,mail, enabled, Department -ErrorAction SilentlyContinue   

   foreach ($y in $ADUsers) {
     $ADTable[$y.mail] = New-Object -Type PSCustomObject -Property @{  
       'ADUsername' = $y.'SAMAccountName'
       'emailAddress' = $y.'mail'
       'IsEnabled' = $y.'enabled'
       'Department' = $y.'Department'
        }
   }
}

#creates a nested hash table with email addresses as keys and specific permissions and qualities as values. 
foreach ($z in $ADTable.Keys) {
    if($DocusignTable.$z) { 
        #Logic to see if a user is disabled in AD but active in Docusign. Uses statement - If AD Enabled = True and IF DocuSign enabled = True, set variable for "Remove from Docusign to False"
        $RemoveFromDocusign = ""
            if ($ADTable.$z.IsEnabled -eq $DocusignTable.$z) {$RemoveFromDocusign=[Bool]$false
            }
            else{$RemoveFromDocusign=[Bool]$true
                Write-Host "$z needs to be removed from DS"
            }
        $OutputTable.Add("$z", @{"Permissions"=$DocusignTable.$z.PermissionSet; "Department"=$ADTable.$z.Department; "Is DocuSign Admin"=$DocusignTable.$z.AllAdmin;"Is AD Enabled"=$ADTable.$z.IsEnabled;"Needs to be Removed from Docusign"=$RemoveFromDocusign})
    }
    else {
    }
}
