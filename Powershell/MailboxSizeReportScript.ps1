#specifies log path and file
$LogPath = 'C:\PFScripts\EmailMailBoxScript\EmailScriptLOG' + $(get-date -f MM-dd-yyyy) + '.txt'
#starts logging everything outputted to console
start-transcript $LogPath

# creating a remote power shell session into exchange server to get exchange tools
$sessionOption = New-PSSessionOption -SkipRevocationCheck -SkipCACheck -SkipCNCheck
$Session = New-PSSession -Configurationname Microsoft.Exchange -ConnectionUri http://[server name]/powershell/ -Authentication Kerberos -AllowRedirection -SessionOption $sessionOption

Import-PSSession $Session

#imports exchange tools needed for script
Add-PSSnapin Microsoft.Exchange.Management.PowerShell.E2010

#gets a list of all users and their email
$AdUsers = Get-Recipient -RecipientType usermailbox -Filter {EmailAddresses -like '*@[domain_Name here].com'} | Select name, PrimarySmtpAddress, SamAccountname

#declares array for data storage
#MailBoxStatisticsReport will store current mailbox sizes
$MailBoxStatisticsReport = @()
#this will store people are going to be emailed to IT for their mailbox size ratio for being too big
$MailBoxWarnUserReport = @()

#loops through all list one user at a time
Foreach ( $user in $AdUsers ) {


#gets total mailbox size
$TotalSizeMB = Get-MailboxStatistics $user.SamAccountname | Select TotalItemSize

#gets current mailbox size
$SgleUsrMBStatistic = Get-Mailbox $user.SamAccountname

#depending on how the mailbox size is get, this checks for that by checking for a flag
If ($SgleUsrMBStatistic.UseDatabaseQuotaDefaults -eq $TRUE ) {

#gets the database default size
$temp = Get-MailboxDatabase -Server ex1 | select ProhibitSendReceiveQuota
#stores that value later to be used
$SgleUsrMBStatistic.prohibitsendreceivequota = $temp.ProhibitSendReceiveQuota.Tostring()

#$SgleUsrMBStatistic.prohibitsendreceivequota = '2.3 gb'
}

#did this to filter out rows that did not contain email addresses
If ($SgleUsrMBStatistic.prohibitsendreceivequota.ToString() -ne $null) {

#creating object for row
$row = New-Object -Typename PSObject
#creating another row for adding to the oversized ratio mailbox report
$rowForToBigMBRpt = New-Object -Typename PSObject

#adds data to the first row
$row | Add-Member -MemberType NoteProperty -name Name -Value $user.Name.ToString()
$row | Add-Member -MemberType NoteProperty -name Email -Value $user.PrimarySmtpAddress.ToString()
$row | Add-Member -MemberType NoteProperty -name SamAccountname -Value $user.SamAccountname.ToString()
$row | Add-Member -MemberType NoteProperty -name MailBoxSize -Value $TotalSizeMB.TotalItemSize.ToString()
$row | Add-Member -MemberType NoteProperty -name MaxMailBoxSize -Value $SgleUsrMBStatistic.prohibitsendreceivequota.ToString()

#regular expression to pull data value from string for current mailbox size
$TotalSizeMbINT = [regex]::matches($TotalSizeMB.TotalItemSize.ToString(),'\d+.GB|\d+\.\d+.GB|\d+.MB|\d+\.\d+.MB').value
#splits data value into an array based on space EX: 1gb to 1, Gb
$TotalSizeMbINT = $TotalSizeMbINT.split()


#determines if data value is GB or MB, this will later be used to calculate ratio differently if MB
$TotalSizeMB_GBorMB = [regex]::matches($TotalSizeMB.TotalItemSize.ToString(), 'GB|MB').value
#regular expression to pull data value from string for MAX mailbox size
$MaxMBSizeInt = [regex]::matches($SgleUsrMBStatistic.prohibitsendreceivequota.ToString(),'\d+.GB|\d+\.\d+.GB|\d+.MB|\d+\.\d+.MB').value
#splits data value into an array based on space EX: 1gb to 1, Gb
$MaxMBSizeInt = $MaxMBSizeInt.split()

#if value is MB, it needs to be converted before the ratio can be calculated, Gb is already in that format
If ($TotalSizeMB_GBorMB -eq 'MB') {
#used for testing purposes
$TotalSizeMbINT[0]

# converts the MB value to a GB format (decimal)
$TotalSizeMbINT = $TotalSizeMbINT[0] / 1000



}
#calculates the Mailbox ratio
$MBRatio = $TotalSizeMbINT[0] / $MaxMBSizeInt[0]

#if ratio over .5, it builds another row to be added to the Oversized Mailbox ratio email attachment report
If ($MBRatio -ge .5) {

$rowForToBigMBRpt | Add-Member -MemberType NoteProperty -name Name -Value $user.Name.ToString()
$rowForToBigMBRpt | Add-Member -MemberType NoteProperty -name Email -Value $user.PrimarySmtpAddress.ToString()
$rowForToBigMBRpt | Add-Member -MemberType NoteProperty -name ADname -Value $user.SamAccountname.ToString()
$rowForToBigMBRpt | Add-Member -MemberType NoteProperty -name MailBoxSize -Value $TotalSizeMB.TotalItemSize.ToString()
$rowForToBigMBRpt | Add-Member -MemberType NoteProperty -name MaxMailBoxSize -Value $SgleUsrMBStatistic.prohibitsendreceivequota.ToString()
$rowForToBigMBRpt | Add-Member -MemberType NoteProperty -name MailBoxRatio -Value $MBRatio
#adds row to the report
$MailBoxWarnUserReport += $rowForToBigMBRpt


}



#adds first row to Current MailBoxStatisticsReport
$MailBoxStatisticsReport += $row

}

#resets all the variables
$TotalSizeMB = $null
$SgleUsrMBStatistic = $null
$temp = $null
$row = $null
$rowForToBigMBRpt = $null
$TotalSizeMbINT = $null
$TotalSizeMB_GBorMB = $null
$MaxMBSizeInt = $null
$TotalSizeMbINT = $null
$MBRatio = $null


}


#preparing the body of email
$body = $MailBoxWarnUserReport

#exporting array to be reattached to email as a CSV
$MailBoxWarnUserReport | Export-Csv -Path 'C:\XXXXXXX\OversizedMailBoxUsers.csv'

#send email if there are any mailbox ratios over 50%
If ($MailBoxWarnUserReport.MailBoxRatio[0] -ge 0.5) {

#sends the actual email
Send-MailMessage -To 'email address to email' -From 'From sending email address' -Subject 'Mail Box Ratio User Over Usage' -Body ' ' -SmtpServer ex1 -UseSSL -Attachments 'C:\Windows\temp\OversizedMailBoxUsers.csv'

}


#kills remote power shell session
Remove-PSSession -Session $Session


#gets total number of log files and subtract 20 to see if it needs to delete any
$count = ((Get-ChildItem -Path C:\PFScripts\EmailMailBoxScript\*.txt | select Name, LastWriteTime | Sort-Object LastWriteTime).count - 20)
#path of where the script lives
$DirPath = 'Path of where the script lives\*.txt'

#gets all log files names minus 20 of the newest log files are excluded
$filesToDel = Get-ChildItem -Path $DirPath | select Name, LastWriteTime | Sort-Object LastWriteTime -descending| select-object -Last $count

#loops through and deletes all old log files
foreach ($file in $filesToDel) {

#compiles path to where the log files live
$path = 'Path of where the script lives\' + $file.Name
#removes log files
Remove-Item –path $path

}




#stops logging of the script
stop-transcript