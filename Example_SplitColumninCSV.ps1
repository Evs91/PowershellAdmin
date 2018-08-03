#
# Script.ps1
#
#.idx extension

$files = Get-ChildItem -Path .\ -Filter *.csv

ForEach ($indexfile in $files) {
    

    #Select all headers - need to define all of them since this is a 'headless' CSV
    $fixthisvar = Import-Csv -Path $indexfile.Name -Header nnumber,rnumber2,number2,firstname middlename,lastname,field1,field2,field3,field4,field5,field6 |
        select nnumber,rnumber2,number2,firstnamemiddlename,lastname,field1,field2,field3,field4,field5,field6

    #Function to replace space with a comma
    $twoname = $fixthisvar.firstnamemiddlename -split " "

    $fixthisvar.firstnamemiddlename = $twoname[0]
    $fixthisvar | ConvertTo-Csv -NoTypeInformation | % {$_ -replace '"',""} ` | Select-Object -Skip 1 | Out-File -FilePath $indexfile.Name -Force

    }