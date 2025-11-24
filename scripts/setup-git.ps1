# setup-git.ps1
# Initializes a Git repository in this folder if one does not exist, sets remote 'origin',
# and performs an initial signed commit. Requires GPG signing already configured if branch protection needs it.
# Usage:
#   powershell -ExecutionPolicy Bypass -File .\scripts\setup-git.ps1 -RemoteUrl "https://github.com/owner/repo.git" -Branch main
# Or with SSH:
#   powershell -ExecutionPolicy Bypass -File .\scripts\setup-git.ps1 -RemoteUrl "git@github.com:owner/repo.git" -Branch main
param(
  [Parameter(Mandatory=$true)][string]$RemoteUrl,
  [string]$Branch = "main",
  [switch]$Force
)

Write-Host "[GitSetup] Starting repository setup..." -ForegroundColor Cyan
if (Test-Path .git) {
  if (-not $Force) {
    Write-Warning "Existing .git directory found. Use -Force to reinitialize (will delete current Git metadata)."
    exit 0
  } else {
    Write-Warning "Force reinitialization requested. Removing existing .git directory."; Remove-Item -Recurse -Force .git
  }
}

Write-Host "[GitSetup] Initializing new git repository" -ForegroundColor Cyan
git init
if ($LASTEXITCODE -ne 0) { Write-Error "git init failed"; exit 1 }

Write-Host "[GitSetup] Creating/checkout branch '$Branch'" -ForegroundColor Cyan
git checkout -b $Branch 2>$null
if ($LASTEXITCODE -ne 0) {
  # maybe already exists
  git checkout $Branch
  if ($LASTEXITCODE -ne 0) { Write-Error "Unable to create or switch to branch $Branch"; exit 1 }
}

Write-Host "[GitSetup] Adding remote origin: $RemoteUrl" -ForegroundColor Cyan
git remote add origin $RemoteUrl 2>$null
if ($LASTEXITCODE -ne 0) {
  Write-Warning "Remote add may have failed (already exists). Attempting set-url."; git remote set-url origin $RemoteUrl
}

Write-Host "[GitSetup] Staging all files" -ForegroundColor Cyan
git add .

Write-Host "[GitSetup] Creating initial signed commit" -ForegroundColor Cyan
git commit -S -m "Initial repository setup for autograder" 2>$null
if ($LASTEXITCODE -ne 0) {
  Write-Warning "Signed commit failed. Retrying unsigned (signing key may not be configured)."
  git commit -m "Initial repository setup for autograder"
  if ($LASTEXITCODE -ne 0) { Write-Error "Commit failed"; exit 1 }
}

Write-Host "[GitSetup] Pushing to origin/$Branch" -ForegroundColor Cyan
git push -u origin $Branch
if ($LASTEXITCODE -ne 0) { Write-Error "Initial push failed. Check credentials or remote URL."; exit 1 }

Write-Host "[GitSetup] Done. Repo initialized and pushed." -ForegroundColor Green