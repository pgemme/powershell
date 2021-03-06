<#
.Synopsis
   Searches through all of the Windows Event Logs (not just the Application, System, and Security) over a period of time.
.DESCRIPTION
   This script will output all the events that have been generated in that time period. Should work remotely as well. At the end of the script by default it stores a credential and launches the function. Ignore this if would rather follow some of the examples.

.EXAMPLE
        $cred = Get-credential
        Get-All-WinEvents -password $cred -ServerName <servername>

   The above example will store credentials into $cred as to save from having to type in each time, then search for all Windows Events on <servername> in the last 15 minutes
.EXAMPLE
        $cred = Get-credential
        el -password $cred -ServerName Server5
    
    The above example will store credentials into $cred as to save from having to type in each time, then search for all Windows Events that happened on Server5 in the last 15 minutes
.EXAMPLE
        $StartDate = Get-date "2/3/2020 6:05 PM"
        $EndDate = Get-Date "2/3/2020 9:10 PM"
        $cred = Get-credential
        Get-All-WinEvents -StartDate $StartDate -EndDate $EndDate -password $cred -ServerName "FileServer4"

    The above example will search all of FileServer4's event logs for that specific 5 minute time period
.EXAMPLE
        Get-All-WinEvents -StartDate "4/3/2018 6:05 PM" -EndDate Get-Date "4/3/2018 6:10 PM" -ServerName "FileServer4"

    The above example is identical to the example above it, except it will prompt for a username/password and without pre-defined variables
.NOTES
    It still needs updating for a better time selection option - and better ways to output the results.
    StartDate and Enddate need to be in format: 6/23/2017 12:15 PM
    There are some other formats that work, can use [datetime]$variable to test

    by: Patrick Gemme
    date: 2/6/2014  
#>
Function Get-All-WinEvents
{
    param
    (
        $StartDate = [DateTime]::Now.AddMinutes(-15),
        #$StartDate,
        $EndDate = [DateTime]::Now,
        #$EndDate,
        [System.Management.Automation.PSCredential]$password,
        $ServerName
    )
    Set-Alias el Get-All-WinEvents
    Set-Alias ev Get-All-WinEvents
    if (!$ServerName){
        $ServerName = Read-host "Server Name:"
        }
    if (!$password){
        $password = get-credential
    }
	if (!$StartDate){
		$StartDate = Read-Host "Start Date (mm/dd/yyyy 00:00 PM)"
	}
	if (!$EndDate){
		$EndDate = Read-Host "End Date (mm/dd/yyyy 00:00 AM)"
	}
    $lognames = get-winevent -listlog * -computername $ServerName -credential $password | Select-Object -expandproperty Logname
    $EventStartDate = Get-Date $StartDate
    $EventEndTime = Get-Date $EndDate

    foreach ($log in $lognames){
    $EventCritea = @{logname = $log; StartTime=$EventStartDate; EndTime=$EventEndTime}
    get-winevent -computername $ServerName -credential $password -FilterHashTable $EventCritea -ErrorAction SilentlyContinue
    }
    
} 
if([string]::IsNullOrEmpty($cred)){
    $cred = Get-credential
}
Get-All-WinEvents -password $cred
