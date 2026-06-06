<#
.SYNOPSIS
    Installs the Astrum custom skills into the user-global Claude Code skills dir.

.DESCRIPTION
    For every skill folder under .\skills, creates a directory junction at
    ~/.claude/skills/<name> pointing back to this repo, so edits in the repo
    are picked up by Claude Code on the next session start.

    Directory junctions need NO admin rights and NO Developer Mode (unlike
    symlinks), and work across drives. If junction creation ever fails, the
    script falls back to copying the folder and warns you that future repo
    edits won't auto-propagate until you re-run install.

.PARAMETER Copy
    Force copy mode instead of junctions.

.EXAMPLE
    ./install.ps1
    ./install.ps1 -Copy
#>
[CmdletBinding()]
param(
    [switch]$Copy
)

$ErrorActionPreference = 'Stop'

$repoSkills = Join-Path $PSScriptRoot 'skills'
$targetRoot = Join-Path $env:USERPROFILE '.claude\skills'

if (-not (Test-Path $repoSkills)) {
    throw "No 'skills' folder found at $repoSkills"
}

if (-not (Test-Path $targetRoot)) {
    New-Item -ItemType Directory -Path $targetRoot -Force | Out-Null
}

$skills = Get-ChildItem -Path $repoSkills -Directory
if ($skills.Count -eq 0) {
    Write-Warning "No skills to install under $repoSkills"
    return
}

foreach ($skill in $skills) {
    $target = Join-Path $targetRoot $skill.Name

    if (Test-Path $target) {
        Remove-Item $target -Recurse -Force
    }

    $linked = $false
    if (-not $Copy) {
        try {
            New-Item -ItemType Junction -Path $target -Target $skill.FullName -ErrorAction Stop | Out-Null
            $linked = $true
            Write-Host "linked  $($skill.Name) -> $($skill.FullName)" -ForegroundColor Green
        }
        catch {
            Write-Warning "Junction failed for $($skill.Name): $($_.Exception.Message). Falling back to copy."
        }
    }

    if (-not $linked) {
        Copy-Item -Path $skill.FullName -Destination $target -Recurse -Force
        Write-Host "copied  $($skill.Name) (re-run install after repo edits)" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "Done. Restart Claude Code so it picks up the skills." -ForegroundColor Cyan
