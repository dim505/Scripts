#imports the necessary libraries
Add-PSsnapin Microsoft.Exchange.Management.PowerShell.E2010
#specifies log path and file
$LogPath = '[Insert File Path]\RemoveDisabledAccountsFromAddressBookLOG' + $(get-date -f MM-dd-yyyy) + '.txt'
#starts logging everything outputted to console
start-transcript $LogPath

#imports module needed to interface with AD
import-module activedirectory

#imports exceptions list
$users = Import-Csv -path ' [Insert File Path]\RemoveDisabledAccountsFromAddressBookExcptList.txt' -Header 'user'
#pulls a list of all disabled accounts in AD
$resultss = Search-ADAccount -AccountDisabled
#turns array into array list so items can be removed from it, by default array returned from Search-ADaccount cannot be modified
$results = New-Object System.Collections.ArrayList(,$resultss)

#loops through list of exception users and removes them from final list of users that are going to be hidden from the address book
foreach ($user in $users) {


#loops through disabled users list
for ($i = 0; $i -lt $results.count; $i++ ) {


#checking to see if these is a match
If ($user.user.trim() -eq $results.SamAccountName[$i]){

#if there is a match, it removes it from the disabled users list
$results.removeat($i)



}

}

}

#loops through the list

foreach ($user in $results) {

#clears the AD attribute flags necessary to start hiding the user from the address book
Set-ADUser $user.SamAccountName -Clear ShowinAddressBook, msExchHideFromAddressLists

#finishes the process of hiding the user by setting the final flag
Set-ADUser $user.SamAccountName -Add @{msExchHideFromAddressLists='TRUE'}


}

#sends an email to IT to let someone know the script ran
Send-MailMessage -To '[insert email address here]' -From '[insert email address here]' -Subject 'Removed Disabled Accounts from Addressbook Script Ran' -Body ' ' -SmtpServer [insert email server here] -UseSSL

#stops logging of the script
stop-transcript

