<#
.SYNOPSIS
    Wraps a PowerShell function to give more user-friendly output/screen logging.
.DESCRIPTION
    Write-FunctionCallToHost wraps an existing PowerShell function (or simple block of script) to give a more user-friendly output. Optionally suppresses output from the wrapped function.
    See: https://tomssl.com/2018/03/06/write-functioncalltohost-a-simple-cross-platform-powershell-function-wrapper
    Usage: Call Write-FunctionCallToHost to get nicer output from your functions.
.EXAMPLE
    C:\PS> Write-FunctionCallToHost -FunctionToCall $function:NameOfFunctionHere -InitialMessage "Calling a function" -SuppressOutput 1
    Wraps the NameOfFunctionHere function, displaying a message before and after execution and suppressing output from the called function.
.EXAMPLE
    C:\PS> Write-FunctionCallToHost -InitialMessage "Running inline script" -FunctionToCall {Write-Output test}
    Wraps a simple block of script.
.NOTES
    Author: Tom Chantler
    Date:   6th March, 2018
.LINK
    https://tomssl.com/2018/03/06/write-functioncalltohost-a-simple-cross-platform-powershell-function-wrapper
#>
function Write-FunctionCallToHost {
    param(
        [scriptblock] $FunctionToCall, # The name of the function to call
        [Hashtable] $Parameters, # The parameters to pass to the function. If any of your parameters need to be evaluated at runtime, you need to wrap them in single quotes. e.g. $var becomes '$var'
        [string] $InitialMessage = "About to do a thing", # The initial logging message
        [string] $FinalMessage = "done", # The final logging message, defaults to "done"
        [bool] $SuppressOutput = $true # Suppress all output from the wrapped function  
    )
    # We use Write-Host as we want to write information to the screen (and we want to use different colours, etc)
    # NOTE that we can't redirect Write-Host (to a file, for example).
    Write-Host $lineBreak -ForegroundColor DarkGray
    $sb = [scriptblock]::Create(".{$FunctionToCall} $(&{$args} @params)")

    if ($SuppressOutput){
        Write-Host $InitialMessage"... " -NoNewline
        Invoke-Command -ScriptBlock $sb | Out-Null # Output suppression can't suppress Write-Host commands, but will suppress Write-Output.
    } else {
        Write-Host $InitialMessage"... "
        Invoke-Command -ScriptBlock $sb
    }

    Write-Host @tick
    Write-Host " "$FinalMessage
}

# Supporting variables
$lineBreak = "-" * 80
$tick = @{
  Object = [Char]8730
  ForegroundColor = 'Green'
  NoNewLine =$true
}

Export-ModuleMember -Function Write-FunctionCallToHost