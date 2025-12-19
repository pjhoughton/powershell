# PowerShell Function Documentation

Extracted Extraction
## Function: Export-ControllerScriptDocumentation
*From: documentation.ps1*

```powershell
.SYNOPSIS
    Extracts top comment blocks from PowerShell controller scripts and generates both Markdown and HTML summaries.

.DESCRIPTION
    This function scans all `.ps1` files in a specified folder, extracts the initial comment block,
    and writes formatted Markdown and HTML files summarizing each script.

.PARAMETER FolderPath
    The path to the folder containing the controller `.ps1` scripts.

.PARAMETER MarkdownOutputPath
    The full path to the output Markdown file.

.PARAMETER HtmlOutputPath
    The full path to the output HTML file.

.EXAMPLE
    Export-ControllerScriptDocumentation -FolderPath "C:\Scripts\Controllers" `
        -MarkdownOutputPath "C:\Scripts\README_Controller_Scripts.md" `
        -HtmlOutputPath "C:\Scripts\README_Controller_Scripts.html"

.NOTES
```

## Function: Export-FunctionHelpDocumentation
*From: documentation.ps1*

```powershell
.SYNOPSIS
    Extracts help blocks from PowerShell functions and generates Markdown and HTML documentation.

.DESCRIPTION
    Works with a single PS1 file or a folder containing multiple PS1 files in the same directory.
    Generates one combined Markdown and HTML file with documentation for all functions found.

.PARAMETER Path
    Path to a single PS1 file or a folder containing PS1 files.

.PARAMETER MarkdownOutputPath
    Where to save the generated Markdown file.

.PARAMETER HtmlOutputPath
    Where to save the generated HTML file.

.NOTES
```

## Function: Update-GitHubRepos
*From: git.ps1*

```powershell
.SYNOPSIS
Runs 'git pull' on all Git repositories under a root directory.

.DESCRIPTION
Iterates through each subdirectory of the specified root path.
If the folder contains a Git repository (.git folder), it performs
a 'git pull' to fetch and merge the latest changes from the remote.

Git output written to STDERR is redirected to STDOUT to prevent
PowerShell from reporting false NativeCommandError messages.

.PARAMETER RootPath
The root directory containing Git repositories.
Defaults to the value of $GitHubRoot.

.EXAMPLE
Update-GitHubRepos

Runs git pull on all Git repositories under the default GitHub root.

.EXAMPLE
Update-GitHubRepos -RootPath "D:\Repos"

Runs git pull on all Git repositories under D:\Repos.

.NOTES
Requirements:
- Git for Windows installed
- git.exe available on PATH
- PowerShell 5.1 compatible
```

## Function: Get-GitRepoStatus
*From: git.ps1*

```powershell
.SYNOPSIS
Displays a clean or dirty status for all Git repositories under a root directory.

.DESCRIPTION
Get-GitRepoStatus iterates through each subdirectory of the specified root path.
If a directory contains a Git repository (.git folder), the function runs
'git status --porcelain' to determine whether the working tree has uncommitted
changes.

Repositories are reported as:
- CLEAN: No uncommitted or untracked files
- DIRTY: One or more uncommitted or untracked files exist

.PARAMETER RootPath
The root directory containing one or more Git repositories.
Defaults to the value of $GitHubRoot.

.EXAMPLE
Get-GitRepoStatus

Displays CLEAN or DIRTY status for all Git repositories in the default GitHub root.

.EXAMPLE
Get-GitRepoStatus -RootPath "D:\Repos"

Displays CLEAN or DIRTY status for all Git repositories under D:\Repos.

.OUTPUTS
None.
This function writes status information directly to the host.

.NOTES
Requirements:
- Git for Windows installed
- git.exe available on PATH
- PowerShell 5.1 compatible

Uses 'git status --porcelain' for reliable, script-friendly output.
```

