# Remaining Setup Steps for Autograder Submission

## Status
✅ Code ready for autograder  
✅ Tag `assign3mod1handin` created locally  
✅ Workflows configured  
✅ Scripts fixed (PowerShell 5.1 compatible)  
❌ Repository push blocked (remote URL placeholder)  
❌ GitHub authentication required  

## Required Actions

### 1. Authenticate GitHub CLI
```powershell
gh auth login
```
- Choose: **GitHub.com**
- Protocol: **HTTPS** (or SSH if keys configured)
- Authenticate with: **Paste token** or **Web browser**
- Token URL: https://github.com/settings/tokens/new (scopes: `repo`, `workflow`)

### 2. Create Repository
Option A - Via GitHub CLI (after auth):
```powershell
gh repo create ep3523-spec/appsec-assign3-mod1 --public --source . --remote origin
```

Option B - Via Web:
1. Go to https://github.com/new
2. Owner: `ep3523-spec` (or your GitHub username)
3. Repository name: e.g., `appsec-assign3-mod1`
4. Visibility: Public (or private if required)
5. Leave empty (no README initialization)
6. Create repository

Then set remote:
```powershell
git remote set-url origin https://github.com/YOUR_USERNAME/YOUR_REPO.git
git remote -v
```

### 3. Push Branch and Tag
```powershell
git push -u origin main
git push origin assign3mod1handin
```

If tag push fails (created before initial branch push), recreate:
```powershell
git tag -d assign3mod1handin
git tag -a -m "Completed assign3 module1." assign3mod1handin
git push origin assign3mod1handin
```

### 4. Add GitHub Actions Secrets
Go to: `https://github.com/YOUR_USERNAME/YOUR_REPO/settings/secrets/actions`

Add these secrets:
- `DOCKERHUB_USERNAME`: Your Docker Hub username
- `DOCKERHUB_TOKEN`: Docker Hub access token or password
- `DOCKER_REPO`: `assign3` (or your image repo name)
- `DJANGO_SECRET_KEY`: Strong random secret (50+ chars, alphanumeric + special)

Generate Django secret:
```powershell
# Python method
python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"

# Or PowerShell random
-join ((65..90) + (97..122) + (48..57) + (33,35,37,38,42,43,45,61,63,64) | Get-Random -Count 50 | ForEach-Object {[char]$_})
```

### 5. Verify Workflow
After pushing `main`, check GitHub Actions:
```
https://github.com/YOUR_USERNAME/YOUR_REPO/actions
```
Workflow "Build and Push Django Image" should run on self-hosted runner.

### 6. (Optional) Update Kubernetes Secrets
Before deploying to cluster, replace base64 placeholders in `GiftcardSite/k8/django-secrets.yaml`:

```powershell
# Generate base64 values
$secretKey = "your_real_django_secret"
$mysqlPass = "your_real_mysql_root_password"
[Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($secretKey))
[Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($mysqlPass))
```

Update `data` fields in django-secrets.yaml, then:
```powershell
kubectl apply -f GiftcardSite/k8/django-secrets.yaml
```

## Autograder Readiness Checklist
- [x] `settings.py` requires `DJANGO_SECRET_KEY` (no fallback)
- [x] `django-deploy.yaml` references secret via `secretKeyRef`
- [x] `django-secrets.yaml` named `django-secret`
- [x] Single replica deployments (baseline)
- [x] Workflow on `self-hosted` runner
- [x] Tag `assign3mod1handin` exists locally
- [ ] Repository exists on GitHub
- [ ] Main branch pushed
- [ ] Tag pushed
- [ ] Secrets configured in GitHub
- [ ] Workflow successfully executes

## Quick Commands Reference
```powershell
# Check status
git status
git remote -v
git tag
gh auth status

# Create repo (after gh auth login)
gh repo create ep3523-spec/appsec-assign3-mod1 --public --source . --remote origin

# Push
git push -u origin main
git push origin assign3mod1handin

# Verify
gh repo view
gh run list
```

## Notes
- Lint warnings about missing secrets are expected until secrets are added to GitHub
- `prepare-grading.ps1` can automate validation: `powershell -ExecutionPolicy Bypass -File .\scripts\prepare-grading.ps1 -SkipBuild -SkipK8s -TagNow`
- All critical files conform to autograder baseline expectations
