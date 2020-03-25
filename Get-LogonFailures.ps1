<#
.SYNOPSIS
This is a script to find the most recent user login failuers on a computer
.DESCRIPTION
The script searches the windows security event logs for events created because of login failures.
It will then output the accounts that attempted to login starting with the more recent.
The output will include the domain\user and time attempted
.EXAMPLE
        Get-Logonfailure terminalserver
    This will start outputing the most recent login failures to 'terminalserver'
.NOTES
Can/will only go back as far as the event log is big
.LINK
no link
#>
function Get-LogonFailure
{
      param($ComputerName)
      try
      {
          Get-EventLog -LogName security -EntryType FailureAudit -InstanceId 4625 -ErrorAction Stop @PSBoundParameters | 
                  ForEach-Object {
                    $domain, $user = $_.ReplacementStrings[6,5]
                    $time = $_.TimeGenerated
                    "Logon Failure: $domain\$user at $time"
                }
      }
      catch
      {
            if ($_.CategoryInfo.Category -eq 'ObjectNotFound')
            {
                  Write-Host "No logon failures found." -ForegroundColor Green
            }
            else
            {
                  Write-Warning "Error occured: $_"
            }

      }

} 
