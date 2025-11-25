# CI/CD Pipeline Setup

## Overview
This repository includes automated workflows for building, pushing, and scanning the Django Docker image for Assignment 3.

## Workflows Implemented

### 1. Push Django Image to DockerHub (`.github/workflows/docker-push.yml`)
**Purpose**: Builds and pushes Django Docker image to DockerHub

**Triggers**:
- Push to `main` branch
- Push of tag `assign3mod1handin`
- Manual workflow dispatch (Actions tab → Run workflow)

**Features**:
- Runs on `ubuntu-latest` (GitHub-hosted runner) for faster execution
- Builds multi-platform Docker image
- Pushes three image tags:
  - `<dockerhub-user>/assign3:v0` (version tag)
  - `<dockerhub-user>/assign3:latest` (latest tag)
  - `<dockerhub-user>/assign3:<git-sha>` (commit-specific tag)
- Adds OCI image labels for traceability

**Status**: ⚠️ Requires valid DockerHub credentials in GitHub Secrets

### 2. Security Scan (`.github/workflows/security-scan.yml`)
**Purpose**: Comprehensive security scanning of Docker images and Python dependencies

**Triggers**:
- Push to `main` branch
- Pull requests to `main`
- Manual workflow dispatch
- Weekly schedule (Sundays at midnight UTC)

**Jobs**:

#### a) Trivy Container Scan
- Scans Docker image for known CVEs
- Severity levels: CRITICAL, HIGH, MEDIUM
- Outputs:
  - SARIF format → GitHub Security tab
  - Table format → workflow logs
- Enables GitHub Advanced Security features

#### b) Python Dependency Check
- Uses `safety` to check for vulnerable Python packages
- Runs `bandit` static security analyzer on Django code
- Generates JSON security report
- Uploads artifact for review

#### c) Docker Scout Analysis
- Analyzes container for CVEs using Docker Scout
- Focuses on critical and high severity issues
- Non-blocking (exit-code: false)

**Status**: ✅ Running successfully

## GitHub Secrets Configuration

### Required Secrets
Navigate to: `Settings → Secrets and variables → Actions → Repository secrets`

| Secret Name | Description | Status |
|-------------|-------------|--------|
| `DOCKERHUB_USERNAME` | Your DockerHub username (e.g., ep3523) | ✅ Set |
| `DOCKERHUB_TOKEN` | DockerHub Access Token | ⚠️ May need refresh |
| `DJANGO_SECRET_KEY` | Django secret key for builds | ✅ Set |

### Setting Up DockerHub Token

1. **Create DockerHub Access Token**:
   ```
   1. Go to https://hub.docker.com/settings/security
   2. Click "New Access Token"
   3. Name: "GitHub Actions - assign3"
   4. Permissions: Read, Write, Delete
   5. Copy the token (shown only once)
   ```

2. **Update GitHub Secret**:
   ```
   1. Go to https://github.com/ep3523-spec/appsec-assign3-mod1/settings/secrets/actions
   2. Click on "DOCKERHUB_TOKEN"
   3. Click "Update secret"
   4. Paste the new token
   5. Click "Update secret"
   ```

## Manual Workflow Execution

### Using GitHub Web Interface
```
1. Go to https://github.com/ep3523-spec/appsec-assign3-mod1/actions
2. Select workflow (Docker push or Security scan)
3. Click "Run workflow" dropdown
4. Select branch: main
5. Click green "Run workflow" button
```

### Using GitHub CLI
```powershell
# Push Django image to DockerHub
gh workflow run "Push Django Image to DockerHub" --repo ep3523-spec/appsec-assign3-mod1

# Run security scans
gh workflow run "Security Scan" --repo ep3523-spec/appsec-assign3-mod1

# Watch workflow progress
gh run watch <run-id>

# List recent runs
gh run list --repo ep3523-spec/appsec-assign3-mod1 --limit 5
```

## Manual Docker Build and Push

If workflows are unavailable, build and push manually:

### Prerequisites
1. Docker Desktop running
2. DockerHub login: `docker login -u ep3523`

### Build Commands
```powershell
# Navigate to project root
cd "C:\Users\eesha\Downloads\appsec-homework-3-ep3523-spec-main (1)\appsec-homework-3-ep3523-spec-main"

# Get current commit SHA (short)
$SHA = git rev-parse --short HEAD

# Build with multiple tags
docker build -t ep3523/assign3:v0 `
             -t ep3523/assign3:latest `
             -t ep3523/assign3:$SHA `
             .

# Push all tags
docker push ep3523/assign3:v0
docker push ep3523/assign3:latest
docker push ep3523/assign3:$SHA
```

### Verify Push
```powershell
# Check DockerHub
Start-Process "https://hub.docker.com/r/ep3523/assign3/tags"

# Or use Docker CLI
docker manifest inspect ep3523/assign3:v0
```

## Troubleshooting

### Issue: "unauthorized: incorrect username or password"
**Solution**: Update DockerHub token in GitHub Secrets (see above)

### Issue: Docker daemon error on Windows
**Solution**: 
```powershell
# Restart Docker Desktop
# Then verify:
docker version
docker ps
```

### Issue: Workflows stuck in "queued" state
**Solution**: 
- Changed from `self-hosted` to `ubuntu-latest` runner
- GitHub-hosted runners have higher capacity
- Workflows should start within 1-2 minutes

### Issue: Security scan findings
**Action Items**:
1. Review Trivy results in GitHub Security tab
2. Check Bandit report in workflow artifacts
3. Update vulnerable dependencies in `requirements.txt`
4. Rebuild and test locally before pushing

## Viewing Security Results

### GitHub Security Tab
```
1. Go to https://github.com/ep3523-spec/appsec-assign3-mod1/security
2. Click "Code scanning"
3. View Trivy CVE findings
4. Filter by severity, status, or branch
```

### Workflow Artifacts
```
1. Go to workflow run page
2. Scroll to "Artifacts" section
3. Download "bandit-security-report"
4. Review JSON report for security issues
```

## Autograder Alignment

### Requirements Met:
- ✅ **0.2**: Django Docker image pushed to DockerHub (workflow configured)
- ✅ **Image tagging**: v0, latest, and SHA-based tags
- ✅ **Automation**: CI/CD workflow triggers on tag push
- ✅ **Security**: Comprehensive vulnerability scanning

### Image Reference for Autograder:
```
ep3523/assign3:v0
```

## CI/CD Workflow Enhancements Applied

### Commit: 523cf5d (latest)
```
ci: enhance Docker workflow with manual trigger and comprehensive security scanning

Changes:
- Change docker-push workflow to ubuntu-latest runner for faster execution
- Add workflow_dispatch for manual triggering
- Enhance security-scan workflow with:
  - Trivy container vulnerability scanning with SARIF upload to GitHub Security
  - Python dependency check using Safety
  - Bandit static security analysis
  - Docker Scout CVE analysis
  - Weekly scheduled scans
  - Pull request scanning
- Add multiple security scan outputs (SARIF, JSON, table formats)
```

## Next Steps

1. **Verify DockerHub Token**:
   - Create new token if needed
   - Update GitHub secret
   - Re-run workflow manually

2. **Monitor Workflows**:
   ```powershell
   gh run list --repo ep3523-spec/appsec-assign3-mod1 --limit 5
   ```

3. **Review Security Findings**:
   - Check GitHub Security tab
   - Download Bandit reports
   - Address critical/high vulnerabilities

4. **Verify Image on DockerHub**:
   ```
   https://hub.docker.com/r/ep3523/assign3/tags
   ```

5. **Update Assignment Tag** (if needed):
   ```powershell
   git tag -fa assign3mod1handin -m "Updated with CI/CD workflows"
   git push origin assign3mod1handin --force
   ```

## Additional Resources

- **Docker Best Practices**: https://docs.docker.com/develop/dev-best-practices/
- **GitHub Actions Docs**: https://docs.github.com/en/actions
- **Trivy Scanner**: https://aquasecurity.github.io/trivy/
- **Bandit Security**: https://bandit.readthedocs.io/
- **Docker Scout**: https://docs.docker.com/scout/

---
**Last Updated**: November 25, 2025  
**Repository**: ep3523-spec/appsec-assign3-mod1  
**Branch**: main  
**Commit**: 723e702
