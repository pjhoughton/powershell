# Powershell Functions related to documentation creation
function Export-ControllerScriptDocumentation {
<#
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
#>
    param (
        [Parameter(Mandatory = $false)]
        [string]$FolderPath,

        [Parameter(Mandatory = $false)]
        [string]$MarkdownOutputPath,

        [Parameter(Mandatory = $false)]
        [string]$HtmlOutputPath
    )

    # Start Markdown file
    "# Controller Scripts Documentation Extraction" | Out-File -FilePath $MarkdownOutputPath -Encoding UTF8

    # Start HTML file (NO PATH SHOWN)
    $htmlHeader = @"
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Controller Scripts Documentation</title>
    <style>
        body { font-family: Arial, sans-serif; padding: 20px; background: #f9f9f9; }
        h1 { color: #2c3e50; }
        h2 { color: #34495e; }
        pre { background: #eeeeee; padding: 10px; border-radius: 5px; overflow-x: auto; }
        code { font-family: Consolas, monospace; color: #2c3e50; }
    </style>
</head>
<body>
<h1>Controller Scripts Documentation</h1>
<p><strong>Extracted from controller script files</strong></p>
"@
    $htmlHeader | Out-File -FilePath $HtmlOutputPath -Encoding UTF8

    # Process each .ps1 file
    Get-ChildItem -Path $FolderPath -Filter *.ps1 | ForEach-Object {
        $file = $_
        $lines = Get-Content -Path $file.FullName
        $commentBlock = @()

        foreach ($line in $lines) {
            if ($line.Trim().StartsWith("#")) {
                $commentBlock += $line.TrimEnd()
            } elseif ($commentBlock.Count -gt 0) {
                break
            }
        }

        # Write to Markdown
        "## Script: $($file.Name)`n" | Out-File -FilePath $MarkdownOutputPath -Append -Encoding UTF8
        '```powershell' | Out-File -FilePath $MarkdownOutputPath -Append -Encoding UTF8
        $commentBlock | Out-File -FilePath $MarkdownOutputPath -Append -Encoding UTF8
        '```' | Out-File -FilePath $MarkdownOutputPath -Append -Encoding UTF8
        "" | Out-File -FilePath $MarkdownOutputPath -Append -Encoding UTF8

        # Write to HTML (escaped)
        $escapedBlock = $commentBlock -join "`n" -replace '&', '&amp;' -replace '<', '&lt;' -replace '>', '&gt;'
@"
<h2>Script: $($file.Name)</h2>
<pre><code>$escapedBlock</code></pre>
"@ | Out-File -FilePath $HtmlOutputPath -Append -Encoding UTF8
    }

    # Finalize HTML
    "</body>`n</html>" | Out-File -FilePath $HtmlOutputPath -Append -Encoding UTF8

    Write-Host "Documentation written:"
    Write-Host " - Markdown: $MarkdownOutputPath"
    Write-Host " - HTML    : $HtmlOutputPath"
}
function Export-FunctionHelpDocumentation {
<#
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
#>
    param (
        [Parameter(Mandatory=$true)]
        [string]$Path,

        [Parameter(Mandatory=$true)]
        [string]$MarkdownOutputPath,

        [Parameter(Mandatory=$true)]
        [string]$HtmlOutputPath
    )

    # Determine which files to process
    if (Test-Path $Path) {
        if ((Get-Item $Path).PSIsContainer) {
            $filesToProcess = Get-ChildItem -Path $Path -Filter *.ps1 -File | Select-Object -ExpandProperty FullName
        } else {
            $filesToProcess = @($Path)
        }
    } else {
        Write-Error "Path '$Path' does not exist."
        return
    }

    $allFunctions = @()

    foreach ($file in $filesToProcess) {
        try {
            $content = Get-Content $file -Raw -Encoding UTF8
        } catch {
            Write-Warning "Failed to read file '$file': $_"
            continue
        }

        $pattern = '(?ms)^function\s+([a-zA-Z0-9_-]+)\s*\{(.*?)^\}'
        [regex]::Matches($content, $pattern) | ForEach-Object {
            $funcName = $_.Groups[1].Value
            $funcBody = $_.Groups[2].Value

            $helpPattern = '(?s)<#(.*?)#>'
            $help = if ($funcBody -match $helpPattern) {
                $matches[1].Trim()
            } else {
                "No help block found."
            }

            $allFunctions += [PSCustomObject]@{
                Name = $funcName
                Help = $help
                File = $file
            }
        }
    }

    # Markdown output
    "# PowerShell Function Documentation`n`nExtracted Extraction" | Out-File -FilePath $MarkdownOutputPath -Encoding UTF8
    foreach ($func in $allFunctions) {
        "## Function: $($func.Name)`n*From: $(Split-Path $func.File -Leaf)*`n" | Out-File -FilePath $MarkdownOutputPath -Append -Encoding UTF8
        '```powershell' | Out-File -FilePath $MarkdownOutputPath -Append -Encoding UTF8
        $func.Help | Out-File -FilePath $MarkdownOutputPath -Append -Encoding UTF8
        '```' | Out-File -FilePath $MarkdownOutputPath -Append -Encoding UTF8
        "" | Out-File -FilePath $MarkdownOutputPath -Append -Encoding UTF8
    }

    # -------------------------------
    # UPDATED HTML HEADER (NO PATH)
    # -------------------------------
    $htmlHeader = @"
<!DOCTYPE html>
<html>
<head>
    <meta charset='UTF-8'>
    <title>PowerShell Function Documentation</title>
    <style>
        body { font-family: Arial, sans-serif; padding: 20px; background: #f9f9f9; }
        h1 { color: #2c3e50; }
        h2 { color: #34495e; }
        pre { background: #eeeeee; padding: 10px; border-radius: 5px; overflow-x: auto; }
        code { font-family: Consolas, monospace; color: #2c3e50; }
        .hidden { display: none; }
        button { background: #3498db; color: white; border: none; padding: 5px 10px; border-radius: 3px; cursor: pointer; margin-bottom: 10px; }
        button:hover { background: #2980b9; }
    </style>
    <script>
        function toggleDetails(sectionId, buttonId) {
            var section = document.getElementById(sectionId);
            var button = document.getElementById(buttonId);

            if (section.classList.contains('hidden')) {
                section.classList.remove('hidden');
                button.innerText = 'Hide details';
            } else {
                section.classList.add('hidden');
                button.innerText = 'Click for details';
            }
        }
    </script>
</head>
<body>
<h1>PowerShell Function Documentation</h1>
<p><strong>Generated from PowerShell source files</strong></p>
"@
    $htmlHeader | Out-File -FilePath $HtmlOutputPath -Encoding UTF8

    # -------------------------------
    # UPDATED PER-FUNCTION HTML BLOCK
    # -------------------------------
    foreach ($func in $allFunctions) {
        $escapedHelp = $func.Help -replace '&', '&amp;' -replace '<', '&lt;' -replace '>', '&gt;'

        $sectionId = "help_$($func.Name)"
        $buttonId  = "btn_$($func.Name)"

@"
<h2>Function: $($func.Name)</h2>
<p><em>From: $(Split-Path $func.File -Leaf)</em></p>
<button id='$buttonId' onclick="toggleDetails('$sectionId','$buttonId')">Click for details</button>
<pre id='$sectionId' class='functionHelp hidden'><code>$escapedHelp</code></pre>
"@ | Out-File -FilePath $HtmlOutputPath -Append -Encoding UTF8
    }

    "</body>`n</html>" | Out-File -FilePath $HtmlOutputPath -Append -Encoding UTF8

    Write-Host "Documentation written:"
    Write-Host " - Markdown: $MarkdownOutputPath"
    Write-Host " - HTML    : $HtmlOutputPath"
}