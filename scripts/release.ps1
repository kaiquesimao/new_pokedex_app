#!/usr/bin/env pwsh
<#
.SYNOPSIS
  Bump app version on the current PR branch (no GitHub Release yet).

.DESCRIPTION
  Updates pubspec.yaml (x.y.z+build), commits, and pushes the current branch.
  Does NOT create or push a git tag — the GitHub Release (Releases tab) and
  Play upload run only after this version reaches master (Release Android
  creates the vX.Y.Z tag + release when attaching APK/AAB).

.PARAMETER Bump
  Semver part to bump: patch | minor | major.
  Build number (+N) always increments by 1.

.PARAMETER DryRun
  Print actions without changing files or git state.

.EXAMPLE
  .\scripts\release.ps1 patch

.EXAMPLE
  .\scripts\release.ps1 minor -DryRun
#>
[CmdletBinding()]
param(
  [Parameter(Position = 0, Mandatory = $true)]
  [ValidateSet('patch', 'minor', 'major')]
  [string] $Bump,

  [switch] $DryRun
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot '..')
Set-Location $repoRoot

function Get-PubspecVersion {
  $line = Get-Content -Path 'pubspec.yaml' |
    Where-Object { $_ -match '^version:\s*' } |
    Select-Object -First 1
  if (-not $line) {
    throw 'Could not find version: in pubspec.yaml'
  }
  if ($line -notmatch '^version:\s*(\d+)\.(\d+)\.(\d+)\+(\d+)\s*$') {
    throw "Unexpected version format: $line (expected x.y.z+build)"
  }
  [pscustomobject]@{
    Major = [int]$Matches[1]
    Minor = [int]$Matches[2]
    Patch = [int]$Matches[3]
    Build = [int]$Matches[4]
    Line  = $line
  }
}

function Format-Version([int] $Major, [int] $Minor, [int] $Patch, [int] $Build) {
  "{0}.{1}.{2}+{3}" -f $Major, $Minor, $Patch, $Build
}

$branch = (git rev-parse --abbrev-ref HEAD).Trim()
if ($branch -eq 'HEAD') {
  throw 'Detached HEAD - check out a branch before releasing.'
}

if (-not $DryRun) {
  $gitStatus = git status --porcelain
  if ($gitStatus) {
    throw "Working tree is not clean. Commit or stash changes first.`n$gitStatus"
  }
}

$current = Get-PubspecVersion
$major = $current.Major
$minor = $current.Minor
$patch = $current.Patch
$build = $current.Build + 1

switch ($Bump) {
  'major' { $major += 1; $minor = 0; $patch = 0 }
  'minor' { $minor += 1; $patch = 0 }
  'patch' { $patch += 1 }
}

$oldVersion = Format-Version $current.Major $current.Minor $current.Patch $current.Build
$newVersion = Format-Version $major $minor $patch $build
$nameOnly = "{0}.{1}.{2}" -f $major, $minor, $patch
$tag = "v$nameOnly"

Write-Host "Branch:  $branch"
Write-Host "Bump:    $Bump"
Write-Host "Version: $oldVersion -> $newVersion"
Write-Host "Tag:     $tag (created later on master by Release Android — not now)"

if ($DryRun) {
  Write-Host 'Dry run - no changes made.'
  exit 0
}

# Read/write UTF-8 explicitly. Windows PowerShell Get-Content defaults to the
# system ANSI code page and mojibakes non-ASCII (e.g. pubspec description).
$utf8NoBom = New-Object System.Text.UTF8Encoding $false
$pubspecPath = Join-Path $repoRoot 'pubspec.yaml'
$pubspec = [System.IO.File]::ReadAllText($pubspecPath, $utf8NoBom)
$updated = [regex]::Replace(
  $pubspec,
  '(?m)^version:\s*\d+\.\d+\.\d+\+\d+\s*$',
  "version: $newVersion",
  1
)
if ($updated -eq $pubspec) {
  throw 'Failed to replace version line in pubspec.yaml'
}
[System.IO.File]::WriteAllText($pubspecPath, $updated, $utf8NoBom)

git add pubspec.yaml
git commit -m "chore: bump version to $newVersion"

Write-Host "Pushing $branch (no tag)..."
git push -u origin HEAD

Write-Host @"

Done. Bumped to $newVersion on $branch (no GitHub Release yet).
After the PR merges to master, Release Android creates tag $tag + the GitHub
Release and uploads to Play (internal + beta by default).
"@
