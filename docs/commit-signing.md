# Commit Signing Guidance (GPG & SSH)

## GPG Setup (Recommended)
1. Install GPG (Windows: use gpg4win or Chocolatey package).
2. Generate key:
   ```powershell
   gpg --full-generate-key
   ```
   - Type: RSA and RSA
   - Size: 4096
   - Expiry: Optional
3. List key ID:
   ```powershell
   gpg --list-secret-keys --keyid-format=long
   ```
4. Export public key for GitHub:
   ```powershell
   gpg --armor --export YOURKEYID
   ```
   Add output at GitHub > Settings > SSH and GPG keys > New GPG key.
5. Configure git:
   ```powershell
   git config --global user.signingkey YOURKEYID
   git config --global commit.gpgsign true
   git config --global gpg.program "C:\Program Files (x86)\GnuPG\bin\gpg.exe"
   ```
6. Signed commit test:
   ```powershell
   git commit -S -m "Signed test"
   git push
   ```
   GitHub should show "Verified".

## SSH Signing (Alternate)
Requires enabling SSH signing beta in GitHub.
```powershell
ssh-keygen -t ed25519 -C "you@example.com"
# Add ~/.ssh/id_ed25519.pub as both an SSH auth key and signing key.
git config --global gpg.format ssh
git config --global user.signingkey ~/.ssh/id_ed25519.pub
git config --global commit.gpgsign true
```

## Troubleshooting
- If signature not recognized: ensure public key uploaded and email matches commit author.
- If VS Code strips signature: disable any extensions rewriting commits.
- To re-sign last commit:
  ```powershell
  git commit --amend -S
  ```

## Verification
```powershell
git log -1 --show-signature
```