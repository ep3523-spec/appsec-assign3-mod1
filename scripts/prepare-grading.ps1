# PowerShell script: prepare-grading.ps1
# Automates local validation steps before pushing and tagging for autograder.
# Run from repository root in PowerShell 5.1 or later.

Write-Host "[Step] Verifying Git repository..." -ForegroundColor Cyan
if (-not (Test-Path .git)) {
    Write-Error "This directory is not a git repository (.git missing). Re-clone before proceeding."; exit 1
}

$inside = (git rev-parse --is-inside-work-tree 2>$null)
if ($LASTEXITCODE -ne 0 -or $inside -ne $true) { Write-Error "Git reports not inside work tree."; exit 1 }

Write-Host "[Step] Checking remote..." -ForegroundColor Cyan
git remote -v | Out-Host
if (-not (git remote)) { Write-Error "No git remote configured. Add origin before proceeding."; exit 1 }

Write-Host "[Step] Checking uncommitted changes..." -ForegroundColor Cyan
$status = git status --porcelain
if ($status) { Write-Host "Uncommitted changes detected:" -ForegroundColor Yellow; $status | Out-Host } else { Write-Host "Working tree clean." -ForegroundColor Green }

Write-Host "[Step] Verifying commit signing setup..." -ForegroundColor Cyan
$lastCommit = git log -1 --show-signature 2>$null
if ($lastCommit -notmatch "Signature") {
    Write-Warning "Last commit not signed or signature not displayed. Ensure GPG/SSH signing configured before final push."
}

Write-Host "[Step] Validating required files..." -ForegroundColor Cyan
$requiredFiles = @(
    "GiftcardSite/GiftcardSite/settings.py",
    "GiftcardSite/k8/django-deploy.yaml",
    "GiftcardSite/k8/django-secrets.yaml",
    "db/k8/db-deployment.yaml",
    ".github/workflows/push-django.yml"
)
$missing = $requiredFiles | Where-Object { -not (Test-Path $_) }
if ($missing) { Write-Error "Missing required files: $($missing -join ', ')"; exit 1 } else { Write-Host "All required files present." -ForegroundColor Green }

Write-Host "[Step] Sanity check: SECRET_KEY logic" -ForegroundColor Cyan
$settingsContent = Get-Content "GiftcardSite/GiftcardSite/settings.py" -Raw
if ($settingsContent -match "insecure-autograder-fallback-key") { Write-Error "Fallback SECRET_KEY still present. Remove for autograder."; exit 1 }
if ($settingsContent -notmatch "DJANGO_SECRET_KEY") { Write-Error "SECRET_KEY env logic missing."; exit 1 }
Write-Host "SECRET_KEY logic OK." -ForegroundColor Green

Write-Host "[Step] Optional: Local docker build (skip with -SkipBuild)" -ForegroundColor Cyan
param(
    [switch]$SkipBuild,
    [switch]$SkipK8s,
    [switch]$TagNow,
    [string]$TagName = "assign3mod1handin"
)

if (-not $SkipBuild) {
    if (-not (Get-Command docker -ErrorAction SilentlyContinue)) { Write-Warning "Docker not found in PATH; skipping image builds." } else {
        Write-Host "Building images..." -ForegroundColor Cyan
        docker build -t nyuappsec/assign3:v0 . || { Write-Error "Django image build failed"; exit 1 }
        docker build -t nyuappsec/assign3-db:v0 db || { Write-Error "DB image build failed"; exit 1 }
        docker build -t nyuappsec/assign3-proxy:v0 proxy || { Write-Error "Proxy image build failed"; exit 1 }
        Write-Host "Images built successfully." -ForegroundColor Green
    }
}

if (-not $SkipK8s) {
    if (-not (Get-Command kubectl -ErrorAction SilentlyContinue)) { Write-Warning "kubectl not found; skipping cluster apply." } else {
        Write-Host "Applying Kubernetes manifests (assuming secret base64 values already updated)..." -ForegroundColor Cyan
        kubectl apply -f GiftcardSite/k8/django-secrets.yaml
        kubectl apply -f db/k8
        kubectl apply -f GiftcardSite/k8
        kubectl apply -f proxy/k8
        Write-Host "Pods:" -ForegroundColor Cyan
        kubectl get pods
    }
}

Write-Host "[Step] Preparing signed commit (if changes exist)..." -ForegroundColor Cyan
if ($status) {
    git add .
    git commit -S -m "Module1: autograder verification"
    if ($LASTEXITCODE -ne 0) { Write-Error "Commit failed."; exit 1 }
} else {
    Write-Host "No changes to commit." -ForegroundColor Green
}

Write-Host "[Step] Pushing main..." -ForegroundColor Cyan
git push origin main
if ($LASTEXITCODE -ne 0) { Write-Error "Push main failed."; exit 1 }
Write-Host "Main branch push OK." -ForegroundColor Green

if ($TagNow) {
    Write-Host "[Step] Creating and pushing tag $TagName ..." -ForegroundColor Cyan
    git tag -a -m "Completed assign3 module1." $TagName
    git push origin $TagName
    if ($LASTEXITCODE -ne 0) { Write-Error "Tag push failed."; exit 1 }
    Write-Host "Tag $TagName pushed successfully." -ForegroundColor Green
} else {
    Write-Host "Skipping tag creation (use -TagNow to enable)." -ForegroundColor Yellow
}

Write-Host "[Done] Preparation complete. Verify GitHub Actions and DockerHub image." -ForegroundColor Green
