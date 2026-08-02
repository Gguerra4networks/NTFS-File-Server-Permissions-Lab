# NTFS Lab SOP — File Creation Quick Reference

This is a patch for the SOP. Every section below (`backend.tf`, `main.tf`, each PowerShell script, etc.) appears in the original document as just a filename label above a code block, with no instruction telling you to actually create that file first. That's the gap that caused the `backend.tf : term not recognized` error. This doc fixes it by giving you the exact command to run before pasting in each file's contents.

**The pattern is always the same three steps:**
1. Create the empty file
2. Open it in Notepad
3. Paste in the content from the SOP, save, close

---

## Step 2 — Terraform Files

Run these from inside your `ntfs-lab-terraform` folder, confirm with `pwd` first if unsure.

```powershell
New-Item -ItemType File -Name "backend.tf"
notepad backend.tf
```
Paste in the `backend.tf` contents from the SOP, save, close.

```powershell
New-Item -ItemType File -Name "versions.tf"
notepad versions.tf
```
Paste in the `versions.tf` contents, save, close.

```powershell
New-Item -ItemType File -Name "variables.tf"
notepad variables.tf
```
Paste in the `variables.tf` contents, save, close.

```powershell
New-Item -ItemType File -Name "main.tf"
notepad main.tf
```
Paste in the `main.tf` contents. This is the longest file, VMs, VNet, NSG, NICs, public IPs. Save, close.

```powershell
New-Item -ItemType File -Name "keyvault.tf"
notepad keyvault.tf
```
Paste in the `keyvault.tf` contents, save, close.

```powershell
New-Item -ItemType File -Name "outputs.tf"
notepad outputs.tf
```
Paste in the `outputs.tf` contents, save, close.

```powershell
New-Item -ItemType File -Name "terraform.tfvars.example"
notepad terraform.tfvars.example
```
Paste in the template, save, close. This one is safe to commit to git as-is, it has no real secrets in it.

```powershell
New-Item -ItemType File -Name ".gitignore"
notepad .gitignore
```
Paste in the `.gitignore` contents, save, close.

**Sanity check before moving on:**
```powershell
ls
# Expect: backend.tf, versions.tf, variables.tf, main.tf, keyvault.tf,
# outputs.tf, terraform.tfvars.example, .gitignore, and the scripts folder
```

---

## Step 6 — PowerShell Scripts

These all go **inside** the `scripts` subfolder. Move into it first:

```powershell
cd scripts
```

Then repeat the same pattern for each one:

```powershell
New-Item -ItemType File -Name "00-promote-dc.ps1"
notepad 00-promote-dc.ps1
```
Paste in the script contents, save, close.

```powershell
New-Item -ItemType File -Name "01-create-ad-users-groups.ps1"
notepad 01-create-ad-users-groups.ps1
```
Paste in, save, close.

```powershell
New-Item -ItemType File -Name "02-configure-shares-and-permissions.ps1"
notepad 02-configure-shares-and-permissions.ps1
```
Paste in, save, close.

```powershell
New-Item -ItemType File -Name "03-configure-rdp-gpo.ps1"
notepad 03-configure-rdp-gpo.ps1
```
Paste in, save, close.

```powershell
New-Item -ItemType File -Name "04-domain-join.ps1"
notepad 04-domain-join.ps1
```
Paste in, save, close.

```powershell
New-Item -ItemType File -Name "05-verify-ad.ps1"
notepad 05-verify-ad.ps1
```
Paste in, save, close.

```powershell
New-Item -ItemType File -Name "05-verify-shares.ps1"
notepad 05-verify-shares.ps1
```
Paste in, save, close.

```powershell
New-Item -ItemType File -Name "06-add-rdp-users.ps1"
notepad 06-add-rdp-users.ps1
```
Paste in, save, close.

Then move back up a level before continuing with the rest of the SOP:
```powershell
cd ..
```

**Sanity check:**
```powershell
ls scripts
# Expect all 8 .ps1 files listed above
```

---

## Step 7 — The Orchestration Script

One more file, sits in the root folder, not inside `scripts`:

```powershell
New-Item -ItemType File -Name "configure-lab.ps1"
notepad configure-lab.ps1
```
Paste in the contents, save, close.

---

## Faster Alternative

If retyping 16 files by hand isn't how you want to spend the next hour, the `ntfs-lab-terraform.zip` from earlier in this conversation already has every one of these files created and filled in correctly. Extract it and copy the contents into this folder, matching up against your existing `scripts` subfolder, and you can skip straight to `terraform init`.
