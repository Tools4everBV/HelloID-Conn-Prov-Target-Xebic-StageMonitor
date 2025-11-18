##########################################################
# HelloID-Conn-Prov-Target-Xebic-Xebic-StageMonitor-Create
# PowerShell V2
##########################################################

# Enable TLS1.2
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor [System.Net.SecurityProtocolType]::Tls12

#region functions
function Resolve-XebicStageMonitorError {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [object]
        $ErrorObject
    )
    process {
        $httpErrorObj = [PSCustomObject]@{
            ScriptLineNumber = $ErrorObject.InvocationInfo.ScriptLineNumber
            Line             = $ErrorObject.InvocationInfo.Line
            ErrorDetails     = $ErrorObject.Exception.Message
            FriendlyMessage  = $ErrorObject.Exception.Message
        }
        if (-not [string]::IsNullOrEmpty($ErrorObject.ErrorDetails.Message)) {
            $httpErrorObj.ErrorDetails = $ErrorObject.ErrorDetails.Message
        }
        elseif ($ErrorObject.Exception.GetType().FullName -eq 'System.Net.WebException') {
            if ($null -ne $ErrorObject.Exception.Response) {
                $streamReaderResponse = [System.IO.StreamReader]::new($ErrorObject.Exception.Response.GetResponseStream()).ReadToEnd()
                if (-not [string]::IsNullOrEmpty($streamReaderResponse)) {
                    $httpErrorObj.ErrorDetails = $streamReaderResponse
                }
            }
        }
        try {
            $errorDetailsObject = ($httpErrorObj.ErrorDetails | ConvertFrom-Json)
            $httpErrorObj.FriendlyMessage = ($errorDetailsObject.errors.psobject.Properties.Value | ForEach-Object { $_ }) -join " "
        }
        catch {
            $httpErrorObj.FriendlyMessage = "Error: [$($httpErrorObj.ErrorDetails)] [$($_.Exception.Message)]"
        }
        Write-Output $httpErrorObj
    }
}
#endregion

try {
    # Initial Assignments
    $outputContext.AccountReference = 'Currently not available'

    $pair = "$($actionContext.Configuration.ClientId):$($actionContext.Configuration.ClientSecret)"
    $encoded = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes($pair))

    $getTokenParams = @{
        Uri     = "$($actionContext.Configuration.TokenBaseUrl)/connect/token"
        Method  = 'POST'
        Body    = @{
            grant_type = "password"
            username   = $($actionContext.Configuration.Username)
            password   = $($actionContext.Configuration.Password)
        }
        Headers = @{
            Authorization  = "Basic $encoded"
            "Content-Type" = "application/x-www-form-urlencoded"
        }
    }
    $token = Invoke-RestMethod @getTokenParams
    $headers = @{
        'Authorization' = "Bearer $($token.access_token)"
        'Content-Type'  = 'application/json'
    }

    if (-not($actionContext.DryRun -eq $true)) {
        Write-Information 'Creating Xebic-StageMonitor account'
        $actionContext.Data | Add-Member -MemberType NoteProperty -Name 'Bron' -Value 'HelloID' -Force
        $createAccountParams = @{
            Uri         = "$($actionContext.Configuration.BaseUrl)/orm/medewerker"
            Method      = 'PUT'
            Body        = $actionContext.Data | ConvertTo-Json
            ContentType = 'application/json;charset=utf-8'
            Headers     = $headers
        }
        $null = Invoke-RestMethod @createAccountParams
    }
    else {
        Write-Information '[DryRun] Create Xebic-StageMonitor account, will be executed during enforcement'
    }
    $outputContext.success = $true
    $outputContext.AuditLogs.Add([PSCustomObject]@{
            Message = 'Create account was successful.'
            IsError = $false
        })
}
catch {
    $outputContext.success = $false
    $ex = $PSItem
    if ($($ex.Exception.GetType().FullName -eq 'Microsoft.PowerShell.Commands.HttpResponseException') -or
        $($ex.Exception.GetType().FullName -eq 'System.Net.WebException')) {
        $errorObj = Resolve-XebicStageMonitorError -ErrorObject $ex
        $auditMessage = "Could not create Xebic-StageMonitor account. Error: $($errorObj.FriendlyMessage)"
        Write-Warning "Error at Line '$($errorObj.ScriptLineNumber)': $($errorObj.Line). Error: $($errorObj.ErrorDetails)"
    }
    else {
        $auditMessage = "Could not create Xebic-StageMonitor account. Error: $($ex.Exception.Message)"
        Write-Warning "Error at Line '$($ex.InvocationInfo.ScriptLineNumber)': $($ex.InvocationInfo.Line). Error: $($ex.Exception.Message)"
    }
    $outputContext.AuditLogs.Add([PSCustomObject]@{
            Message = $auditMessage
            IsError = $true
        })
}