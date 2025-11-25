# Signed Commit Guide (Module 1 Requirement)

Follow one method below, then make a signed commit and push before (or after) tagging `assign3mod1handin`.

## Option A: SSH Signing (Simplest on Windows)
```powershell
ssh-keygen -t ed25519 -C "your_email@example.com"
# Add public key (~/.ssh/id_ed25519.pub) to GitHub: Settings -> SSH and GPG keys -> New SSH signing key
git config --global gpg.format ssh
git config --global user.signingkey (Get-Content ~/.ssh/id_ed25519.pub)
git config --global commit.gpgsign true
```
Make a signed commit:
```powershell
echo "Signed marker" >> SIGNED.txt
git add SIGNED.txt
git commit -S -m "chore: add signed commit"
git push origin main
```
Verify:
```powershell
git log --show-signature -1
```
GitHub should show a "Verified" badge.

## Option B: GPG Signing
```powershell
gpg --full-generate-key   # RSA 4096, never expires
$kid = (gpg --list-secret-keys --keyid-format=long | Select-String -Pattern "sec" | ForEach-Object { ($_ -split "/")[1].Split(" ")[0] })
gpg --armor --export $kid > pubkey.asc
# Upload pubkey.asc contents to GitHub: Settings -> SSH and GPG keys -> New GPG Key
git config --global user.signingkey $kid
git config --global commit.gpgsign true
```
Signed commit:
```powershell
echo "Signed marker" >> SIGNED.txt
git add SIGNED.txt
git commit -S -m "chore: add signed commit"
git push origin main
```
Verify:
```powershell
git log --show-signature -1
```

## After Signed Commit
Tag only when workflow + security scan succeed:
```powershell
git tag -a -m "Completed assign3 module1." assign3mod1handin
git push origin assign3mod1handin
```
