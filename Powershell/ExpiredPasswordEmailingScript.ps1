#specifies log path and file
$LogPath = 'C:\ExpPassEmailUsrsLOG' + $(get-date -f MM-dd-yyyy) + '.txt'
#starts logging everything outputted to console
start-transcript $LogPath

# bypass this error Send-MailMessage : The remote certificate is invalid according to the validation procedure
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = { return $true }



#gets the Name, AD account name, email address, and AD attribute - UserPasswordExpiryTimeComputed (tells when the password is going to expire)
$results = Get-ADUser -filter {Enabled -eq $True -and PasswordNeverExpires -eq $False -and emailaddress -like '*@[Insert Domain Name].com'} –Properties 'DisplayName', 'SamAccountName', 'Emailaddress','msDS-UserPasswordExpiryTimeComputed' | Select-Object -Property 'Displayname','SamAccountName', 'Emailaddress',@Name='ExpiryDate';Expression=([datetime]::FromFileTime($_.'msDS-UserPasswordExpiryTimeComputed')}}


#gets the date of when the password is going to expire
$EndDate = $results.ExpiryDate[0]

#gets current date
$StartDate=(GET-DATE)

#gets th time difference between the 2 dates
$TimeResults = NEW-TIMESPAN –Start $StartDate –End $EndDate


#declares some arrays
$ExpiredPassUsrRpt = @()

$AboutExpiredPassUsrRpt = @()

#loops through all the user in results
foreach ($user in $results) {

#gets the date of when the password is going to expire
$EndDate = $user.ExpiryDate
#gets current date
$StartDate = (GET-DATE)
#gets th time difference between the 2 dates
$TimeResults = NEW-TIMESPAN –Start $StartDate –End $EndDate

#declares subject of email
$sub = 'Your Windows Password Expires in ' + $TimeResults.Days + ' Days'
#declares Body of the email
$body = 'Hello ' + $user.Displayname + ',
' + 'Your Windows Password Expires in ' + $TimeResults.Days + ' days. Please press and hold CTRL + ALT + DELETE on your key board and select 'Change A Password' option to change your password
-IT BOT'

#checks if password will expire in 14 days
if ($TimeResults.Days -eq 14) {
#sends email
Send-MailMessage -To $user.Emailaddress -bcc 'Insert email address here ' -From 'Insert email address here ' -Subject $sub -Body $body -SmtpServer ex1 -UseSSL

}
#checks if password will expire in 7 days
elseif ($TimeResults.Days -eq 7) {

#sends email
Send-MailMessage -To $user.Emailaddress -bcc 'Insert email address here ' -From 'Insert email address here ' -Subject $sub -Body $body -SmtpServer ex1 -UseSSL
}

#checks if password will expire in 5 days
elseif ($TimeResults.Days -eq 5) {
#sends email
Send-MailMessage -To $user.Emailaddress -bcc 'Insert email address here ' -From 'Insert email address here ' -Subject $sub -Body $body -SmtpServer ex1 -UseSSL

}

#checks if password will expire in 3 days
elseif ($TimeResults.Days -eq 3) {
#sends email

Send-MailMessage -To $user.Emailaddress -bcc 'Insert email address here ' -From 'Insert email address here ' -Subject $sub -Body $body -SmtpServer ex1 -UseSSL

}
#checks if password will expire in 1 day

elseIf ($TimeResults.Days -eq 1) {

#sends email
Send-MailMessage -To $user.Emailaddress -bcc 'Insert email address here ' -From 'Insert email address here ' -Subject $sub -Body $body -SmtpServer ex1 -UseSSL

}
#builds out row to be added to report
$Row = New-Object -Typename PSObject
$Row | Add-Member -MemberType NoteProperty -name Displayname -Value $user.Displayname
$Row | Add-Member -MemberType NoteProperty -name ExpiryDate -Value $user.ExpiryDate
$Row | Add-Member -MemberType NoteProperty -name Emailaddress -Value $user.Emailaddress
$Row | Add-Member -MemberType NoteProperty -name DaysTilExp -Value $TimeResults.Days
#adds users info to report
$AboutExpiredPassUsrRpt += $Row

}

#filters out users who have expired passwords
$ExpiredPassUsrRpt = $AboutExpiredPassUsrRpt | WHERE-OBJECT {$_.DaysTilExp -LT 0}

#checks if the list is not empty
If ( ![string]::IsNullOrEmpty($ExpiredPassUsrRpt.DaysTilExp[0]) ) {
#ignores validation check so it can send out an email
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = { return $true }
#exports expired report to CSV
$ExpiredPassUsrRpt | Export-csv -Path 'C:\Windows\Temp\ExpiredPassUsrRpt.csv'
#sends out the email
Send-MailMessage -To 'Insert email address here ' -From 'Insert email address here ' -Subject 'Users With Expired Passwords' -Body ' ' -SmtpServer ex1 -UseSSL -Attachments 'C:\Windows\Temp\ExpiredPassUsrRpt.csv'


}

#gets total number of log files and subtract 20 to see if it needs to delete any
$count = ((Get-ChildItem -Path [insert log file folder path here]\*.txt | select Name, LastWriteTime | Sort-Object LastWriteTime).count - 20)
#path of where the script lives
$DirPath = 'insert log file folder path here\*.txt'

#gets all log files names minus 20 of the newest log files are excluded
$filesToDel = Get-ChildItem -Path $DirPath | select Name, LastWriteTime | Sort-Object LastWriteTime -descending| select-object -Last $count

#loops through and deletes all old log files
foreach ($file in $filesToDel) {

#compiles path to where the log files live
$path = '[insert log path here]\' + $file.Name
#removes log files
Remove-Item –path $path

}

#stops logging of the script
stop-transcript
