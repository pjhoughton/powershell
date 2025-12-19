

function Update-GitHubRepos {
<#
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
#>

    param (
        [string]$RootPath = $GitHubRoot
    )

    if (-not (Test-Path $RootPath)) {
        Write-Error "Path not found: $RootPath"
        return
    }

    Get-ChildItem -Path $RootPath -Directory | ForEach-Object {

        $repoPath = $_.FullName
        $gitDir   = Join-Path $repoPath ".git"

        if (Test-Path $gitDir) {

            Write-Host "`nUpdating repo: $($_.Name)" -ForegroundColor Cyan

            Push-Location $repoPath

            # Run git pull and suppress false NativeCommandError output
            git pull 2>&1

            # Optional: check real git failure
            if ($LASTEXITCODE -ne 0) {
                Write-Host "Git pull failed in $($_.Name)" -ForegroundColor Red
            }

            Pop-Location
        }
        else {
            Write-Host "Skipping (not a git repo): $($_.Name)" -ForegroundColor DarkYellow
        }
    }
}
function Get-GitRepoStatus {
<#
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
#>
    param (
        [string]$RootPath = $GitHubRoot
    )

    Get-ChildItem $RootPath -Directory | ForEach-Object {
        $gitDir = Join-Path $_.FullName ".git"

        if (Test-Path $gitDir) {
            Push-Location $_.FullName
            $status = git status --porcelain 2>&1
            Pop-Location

            if ($status) {
                Write-Host "DIRTY  : $($_.Name)" -ForegroundColor Yellow
            }
            else {
                Write-Host "CLEAN  : $($_.Name)" -ForegroundColor Green
            }
        }
    }
}


Get-GitRepoStatus -RootPath C:\Users\paulh\OneDrive\Documents\GitHub



