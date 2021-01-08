#specifies log path and file
$LogPath = 'C:\AutoWebSiteBackUpLog_' + $(get-date -f MM-dd-yyyy) + '.csv'
#starts logging everything outputted to console
start-transcript $LogPath
#specifies FTP user name
$user = 'FTP User Name'
#get FTP acct password from secure hash stored in text file and converted to readable text
$password = Get-Content 'Path to secure password String' | ConvertTo-SecureString
#specifies URL + path to destination folder to download
$url = 'FTP Site to where to download folder '
#path on local computer to download files
$DestDownloadFold = 'Path of destination folder download'

#created new object containing FTP Credentials
$credentials = New-Object System.Management.Automation.PsCredential($user,$password)

#function to download FTP files
function Get_FTP_Files ($url,$credentials) {

#Makes a request to a Uniform Resource Identifier (URI).
$request = [Net.WebRequest]::Create($url)

#Represents the FTP protocol method that gets a short listing of the files on an FTP server.
$request.Method = [System.Net.WebRequestMethods+FTP]::ListDirectory

#passes the FTP credentials
$request.Credentials = $credentials

#creates response object
$response = $request.GetResponse()
#returns the data stream from the Internet resource as an object
$reader = New-Object IO.StreamReader $response.GetResponseStream()
#returns all lines of a stream, gets all the file names
while(-not $reader.EndOfStream) {
$reader.ReadLine()
}

#disposes objects to free up memory
$reader.Close()

$response.Close()


}

#calls function to get all the files to download
$files = Get_FTP_Files -url $url -credentials $credentials


#creates objects that provides methods for sending data to and receiving data from a URL
$webclient = New-Object System.Net.WebClient
#passes credentials
$webclient.Credentials = $credentials

#gets current date
$date = Get-Date -format 'yyyy-MM-dd'
#creates destination folder name
$folderName = $date + ' Website Backup'
#creates destination folder path
$DestDownloadFold = $DestDownloadFold + $folderName + '\'

#creates that destination folder
md -Path $DestDownloadFold

#loops through the list of files to download each file
Foreach ($file in $files) {

#forms full URL path
$UrlFilePath = $url + $file

#forms full path of where the file is going to be downloaded
$FullDestPath = $DestDownloadFold + $file

#downloads the file/folder
$webclient.DownloadFile($UrlFilePath, $FullDestPath)
}


#gets total number of folders downloaded from FTP Site and subtract 20 to see if it needs to delete any
$count = ((Get-ChildItem -Path 'Path of destination download folder download' | select Name, LastWriteTime | Sort-Object LastWriteTime).count - 20)
#this is the download folder path of the FTP files
$DirPath = 'Path of FTP download folder'

#if there are folders to delete, they will go here
$filesToDel = Get-ChildItem -Path $DirPath | select Name, LastWriteTime | Sort-Object LastWriteTime -descending| select-object -Last $count

#loops through and deletes all downloaded folders except 20 of the most recent downloads
foreach ($file in $filesToDel) {


$path = 'Path of FTP download folder' + $file.Name
Remove-Item –path $path -Force -Recurse -ErrorAction SilentlyContinue

}

#gets total number of log files and subtract 20 to see if it needs to delete any
$count = ((Get-ChildItem -Path C:\PowerShellScripts\AutoWebSiteBackUp\*.txt | select Name, LastWriteTime | Sort-Object LastWriteTime).count - 20)

$DirPath = 'Folder Path to log Location + \*.txt'
#gets all the log files to delete
$filesToDel = Get-ChildItem -Path $DirPath | select Name, LastWriteTime | Sort-Object LastWriteTime -descending| select-object -Last $count

#loops through and deletes logs except 20 of the most recent logs
foreach ($file in $filesToDel) {


$path = 'Folder Path to Script Location ' + $file.Name
Remove-Item –path $path

}

#stops logging
stop-transcript