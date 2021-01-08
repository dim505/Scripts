#specifies log path and file
$LogPath = 'C:\PowerShellScripts\APIDnsBackUp\DnsScriptBackUpLog' + $(get-date -f MM-dd-yyyy) + '.txt'
#starts logging everything outputted to console
start-transcript $LogPath

#gets current date
$Date = Get-Date | Select-Object -Property Date # | Export-Csv -Path C:\Windows\Temp\DnsAPI.csv -NoTypeInformation -Append


#Gets DNS properties from a web page on the Internet
$ApiCall1 = Invoke-WebRequest -UseBasicParsing -Uri https://api.hackertarget.com/dnslookup/?q=[insert name here.com] | Select-Object -Property Content
$ApiCall2 = Invoke-WebRequest -UseBasicParsing -Uri https://api.hackertarget.com/dnslookup/?q=[insert name here.com] | Select-Object -Property Content
$ApiCall3 = Invoke-WebRequest -UseBasicParsing -Uri https://api.hackertarget.com/dnslookup/?q=[insert name here.com] | Select-Object -Property Content
#creating object for row
$RForApiCal = New-Object -Typename PSObject
#adds data to the first row
$RForApiCal | Add-Member -MemberType NoteProperty -name Date -Value $Date
$RForApiCal | Add-Member -MemberType NoteProperty -name ApiCall1 -Value $ApiCall1
$RForApiCal | Add-Member -MemberType NoteProperty -name ApiCall2 -Value $ApiCall2
$RForApiCal | Add-Member -MemberType NoteProperty -name ApiCall3 -Value $ApiCall3

#exports row to CSV
$RForApiCal | Export-Csv -Path 'C:\PowerShellScripts\APIDnsBackUp\MayhewDomainApiCall.csv' -Append

#gets total number of log files and subtract 20 to see if it needs to delete any
$count = ((Get-ChildItem -Path C:\PowerShellScripts\APIDnsBackUp\*.txt | select Name, LastWriteTime | Sort-Object LastWriteTime).count - 20)
#gets all log files in script directory
$DirPath = 'Folder Path to Script Location + \*.txt'

#gets all log files names minus 20 of the newest log files are excluded
$filesToDel = Get-ChildItem -Path $DirPath | select Name, LastWriteTime | Sort-Object LastWriteTime -descending| select-object -Last $count

#loops through and deletes all old log files
foreach ($file in $filesToDel) {
#compiles path to where the log files live
$path = 'C:\PowerShellScripts\APIDnsBackUp\' + $file.Name
#removes log files
Remove-Item –path $path

}

#stops logging of the script
stop-transcript