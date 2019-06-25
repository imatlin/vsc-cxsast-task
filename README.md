# vsc-cxsast-task
Note: This integration is provided AS-IS, with no warranty expressed or implied.  
You are allowed to use the software, subject to the conditions specified in the LICENSE file.

CxSAST Integration with Visual Studio Code

VS Code is a popular code editor developed by Microsoft and released under open source license for Windows, MacOS and Linux operating systems. The editor is available here: https://code.visualstudio.com/. At the time of this writing, there is no Checkmarx plugin for VS Code. However, it is possible to launch a scan from within VS Code using custom task integration.

Running CxSAST scan from within VS Code

Prerequisites:
- Java installed and configured on the workstation
- CxConsole installed and working on the workstation. CxConsole (CLI) can be downloaded from https://www.checkmarx.com/plugins/.
- A valid CLI Token. You can retrieve your token using CLI command:
         
           runCxConsole.[cmd | sh] GenerateToken -v -CxUser USERNAME -CxPassword PASSWORD -CxServer CX_SERVER
           
  The token will appear in the CLI's output.  Save it to a file or write it down on paper.
- PowerShell Core installed and configured on workstation.  PowerShell Core is a cross-platform task automation and configuration management framework from Microsoft, consisting of a command-line shell and associated scripting language.  More information is available here: https://docs.microsoft.com/en-us/powershell/.  Note, scripts are compatible with full-featured PowerShell on Windows.

Installation and Configuration
Since custom tasks are configured per project (or workplace folder in VS Code lingo), some per-project configuration is needed.
 
- Set environment variables: CX_TOKEN needs to contain your authentication token; CX_CONSOLE should point to the platform-appropriate console file (runCxConsole.cmd on Windows, runCxConsole.sh on Linux and MacOS)
- Copy the task files to a location of your own choosing.  Default is C:\cxsast-task on Windows and ~/bin/cxsast-task on Limux/MacOS.  The location can be adjusted in the tasks.json file.
- For each project you need to scan with CxSAST:
         - Merge sample-tasks.json file with the tasks.json file located inside the .vscode folder, typically off the root of the project.  If there is no tasks.json in that folder, copy the sample file over and rename it to tasks.json. If the folder does not exist, go to Terminal | Configure Tasks, select "Generate tasks.json from template", and then choose "Custom...". 
         - Adjust tasks.json settings: location of the CxSAST server, team and project name, the preset to be used, folder and file exclsions (if any), and comments to be used as part of the scan.

After the above steps are done, new tasks will be available under the "Terminal | Run Task…" menu: "Run CxSAST Analysis" and "Display CxSAST Results".  The former task will execute a new CxSAST scan on the currently open project. Modified files are automatically saved prior to task execution, so the latest changes are scanned.  The latter task displays locally stored results of the last scan performed on the project *using custom task*. It is useful for re-populating results after IDE restart.

Known Issues
- Issues with common sinks are merged by VS Code.  For that reason, the number of detected issues in the summary may not correspond to the number of problems shown by VS Code.
- Authentication token is stored in an environment variable, and is visible in the terminal window.
- When listing multiple folders or file patters for exclusion, you must add a space after each comma, e.g., "test, samples".  This is because VS Code won't quote the string otherwise, which breaks the script.
- No help or vulnerability description is provided.

