 # This will parse the CxSAST XML file and output results in a format interpreted by Visual Studio Code problem  mapper
 #
 # Usage: CxSASTShowResults -results_file <path-to-xml-results>
 param (
    [Parameter(Mandatory=$true)][string]$results_file
 )
 
 #Configure these values at your own risk!
 #VSC default issue type
 [string] $default_type = "info"
 #separator character to be used in results display.  MUST match the pattern used in tasks.json file!
 [char]$separator=';'
 #task 'code' - will be displayed by VSC next to the problem and can be used to filter and search problem list
 [string]$code="CxSAST"

#error text color
[System.ConsoleColor]$error_color = [System.ConsoleColor]::Red
# no-error text color
[System.ConsoleColor]$ok_color = [System.ConsoleColor]::Green
 
 #Parse XML file into an object
 try {
    [xml]$results = get-content $results_file
 }
 catch {
    Write-Error "Error parsing $results_file"
    Write-Error "Exception: $($_.Exception.Message)"
    exit
 }
 
 [string]$project_name = $results.CxXMLResults.ProjectName
 [string]$message = "Displaying results for project " + $project_name + "`n"
 Write-Output $message

 #Find all new vulnerabilities; modify the following line as needed
 [Object []]$Vulns = $results.CxXMLResults.Query.Result
 #[Object []]$Vulns = $results.CxXMLResults.Query.Result | Where-Object {$_.Status -eq "New"}
 
 [int]$issue_count = 0 
 #For each vulnerability, format a message and write to stdout 
 Foreach ($Vuln in $Vulns) {
	if($Vuln.FalsePositive -eq "False") {
		[string]$object = ""
		#For data flows with more than one node, provide filename, line number of the destination node (sink)
		#Otherwise, provide the filename, line number of the source node (source)
		#Column number is useless as it doesn't take tab size into account, and therfore does not align with what's on the screen
		if($Vuln.Path.ChildNodes.Count -gt 1) {
			[Object]$destination = $Vuln.Path.LastChild
			$message = $destination.FileName + $separator + $destination.Line
			$object = $destination.Name
		} elseif($Vuln.Path.ChildNodes.Count -eq 1)  {
			[Object]$origin = $Vuln.Path.FirstChild
			$message = $origin.FileName + $separator + $origin.Line
			$object = $origin.Name
		}
		
		#Set issue priority
		#Change mapping as needed
		[string]$type = $default_type
		if($Vuln.Severity -eq "High") {
			$type = "error"
		}
		elseif($Vuln.Severity -eq "Medium") {
			$type = "warning"
		}
		elseif($Vuln.Severity -eq "Low") {
			$type = "info"
		}
		elseif($Vuln.Severity -eq "Information") {
			$type = "info"
		}
		else {
			$type = $default_type
		}
		$message += $separator + $type
		
		#Add vulnerability name and object (variable or method) name
		#deep link to the vulnerability information in the portal isn't displayed as a link, so no need to add it
		#$message += $separator + $Vuln.ParentNode.name + " [`"" + $Vuln.DeepLink + "`"]"
		$message += $separator + $Vuln.ParentNode.name + "-" + $Vuln.ParentNode.group + " (" + $object + ")"
		
		#add tool code 
		$message += $separator + $code
		
		Write-Output $message
		$issue_count++
	}
 }
 
 if($issue_count -gt 0) {
	$message = "`n" + $issue_count + " issues detected. See full results at: " + $results.CxXMLResults.DeepLink
	Write-Host $message -ForegroundColor $error_color
} else {
	$message = "No issues detected"
	Write-Host $message -ForegroundColor $ok_color
}
 