# This will execute CxConsole and then execute CxSASTShowResults.ps1
# 
# Usage: CxSASTRunScan.ps1 
#   -CxServer <CxSAST Server URL>
#   -projectName <fully qualified project name>             
#   -CxToken <auth token>
#   -sourceLocation <folder with source>
#   -preset <CxSAST Preset>
#   -isIncremental <true | false>
#   -isPrivate <true | false>
#   -Comment <Comment text>
#   -pathExclude <exclude folder list>
#   -filesExclude <exclude file list> 

param (
    [Parameter(Mandatory=$true)][string]$cxServer, #<CxSAST Server URL>
    [Parameter(Mandatory=$true)][string]$projectName, #<fully qualified project name>             
    [Parameter(Mandatory=$true)][string]$cxToken, #<auth token>
    [Parameter(Mandatory=$true)][string]$sourceLocation, #<folder with source>
    [Parameter()][string]$preset = "Checkmarx Default", #<CxSAST Preset>
    [Parameter()][string]$isIncremental = "Yes", #<true | false>
    [Parameter()][string]$isPrivate = "No", #<true | false>
    [Parameter()][string]$commentText = "", #<Comment text>
    [Parameter()][string]$pathExclude = "", #<exclude folder list>
    [Parameter()][string]$filesExclude = "", #<exclude file list>
    [Parameter()][string]$resultsFile = $PWD.Path + "/cx_results.xml" #results file; usually no need to overwrite 
)

# We expect CxSASTShowResults.ps1 script to be located in the same folder as this one
[string]$displayResultScript = Split-Path -parent $PSCommandPath;
$displayResultScript += "/CxSASTShowResults.ps1"

[string]$message = "Running CxSAST Scan on project " + $projectName
Write-Output $message

#Construct CxConsole arguments based on the parameters passed to the script
[string]$command_args = "scan -v -CxServer " + $cxServer + " -ProjectName " + $projectName + " -CxToken " + $cxToken
$command_args += " -LocationType folder -LocationPath `"" + $sourceLocation + "`" -Preset `"" + $preset + "`""

if($isIncremental -eq "Yes") {
    $command_args += " -Incremental"
}

if($isPrivate -eq "Yes") {
    $command_args += " -Private"
}

if($commentText -ne "")  {
    $command_args += " -Comment `"" + $commentText + " `""
}

if($pathExclude -ne "")  {
    $command_args += " -LocationPathExclude `"" + $pathExclude + " `""
}

if($filesExclude -ne "")  {
    $command_args    += " -LocationFilesExclude `"" + $filesExclude + " `""
}

$command_args += " -ReportXML " + $resultsFile

#Get CxConsole script location from the CX_CONSOLE environment variable 
[string]$console_command = ${env:CX_CONSOLE}
$message = "Running command:`n" + $console_command + "`nwith arguments:`n" + $command_args
Write-Debug $message

#Execute CxScan and wait for results
[string]$expression = $console_command + " " + $command_args
$global:LASTEXITCODE = 0
try {
    Invoke-Expression -Command $expression
}
catch {
    #TODO: Output more detailed diagnostics based on return code
    Write-Error "Error executing scan! Exit code: " + $LASTEXITCODE + " See https://checkmarx.atlassian.net/wiki/spaces/KC/pages/914096139/CxSAST+CxOSA+Scan+v8.9.0 for more details."
}

#if scan completed successfully, display results
if($LASTEXITCODE -eq 0) {
    try {
        $expression = $displayResultScript + " -results_file " + $resultsFile
        Write-Output "Running command " + $expression
        Invoke-Expression -Command $expression
    }
    catch {
        Write-Error "Error displaying scan results!"
        Write-Error "Exception: $($_.Exception.Message)"
    } 
}