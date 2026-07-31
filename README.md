# Lab 05: NTFS File Server with Terraform, Active Directory, and Group-Based Permissions

A hands-on Azure lab that builds a domain-joined Windows file server from scratch using Terraform, then proves that NTFS permissions actually match a real department org chart. Written up so every step is documented, not just clicked through.

## What this lab demonstrates

- Infrastructure as Code with Terraform (VNet, NSG, VMs, Key Vault, remote state)
- Active Directory Domain Services: OUs, security groups, users
- NTFS and SMB share permissions layered per security group with `(OI)(CI)` inheritance
- Azure Key Vault with RBAC authorization for credential storage, no plaintext passwords
- Automated PASS/FAIL verification scripts instead of manual checking
- Group Policy as a backup access-control path

## Architecture

| Machine | Role |
|---|---|
| **DC01** | Domain controller, DNS, and Group Policy for `lab.local` |
| **FS01** | File server hosting Finance, HR, Sales, and IT shares with per-group NTFS permissions |
| **CLIENT01** | Windows 11 workstation used to test each user's actual access |

All three sit in one VNet behind an NSG that only allows inbound RDP from the deployer's own IP. There is no open WinRM; every configuration script is pushed through `az vm run-command` over the Azure VM agent instead.

## Permission model

Group membership drives access. HR gets read-only visibility into Finance for cross-department reporting; every other department is isolated to its own share; IT has full control everywhere.

| User | Group | Finance | HR | Sales | IT |
|---|---|---|---|---|---|
| sarah.jones | GRP_Finance | Modify | — | — | — |
| mike.brown | GRP_Finance | Modify | — | — | — |
| lisa.white | GRP_HR | Read | Modify | — | — |
| tom.davis | GRP_Sales | — | — | Modify | — |
| john.smith | GRP_IT | Full Control | Full Control | Full Control | Full Control |

## Key technical details

- **Remote state first.** The Azure storage account for Terraform state is created before any `.tf` file references it, so there's never a chicken-and-egg step.
- **No wildcard RDP.** `rdp_source` has no default value. Terraform refuses to run until a real IP is supplied, so the NSG can never accidentally open to the whole internet.
- **Key Vault RBAC.** `enable_rbac_authorization = true` is required on the vault. Skip it and every secret read or write silently returns a 403, even when the role assignment looks correct in the Azure portal.
- **Bitwise permission verification.** Windows often combines multiple NTFS rights into a single flags value, so the verification script uses a bitwise `-band` comparison against `[System.Security.AccessControl.FileSystemRights]` rather than an exact string match, which would produce false failures.

## Acronyms used in this lab

| Term | Meaning |
|---|---|
| NTFS | New Technology File System, Windows' native filesystem that enforces file and folder permissions |
| SMB | Server Message Block, the network protocol behind Windows file shares |
| AD / AD DS | Active Directory / Active Directory Domain Services |
| OU | Organizational Unit |
| GPO / GPMC | Group Policy Object / Group Policy Management Console |
| ACL / ACE | Access Control List / Access Control Entry |
| VNet / NSG | Virtual Network / Network Security Group |
| RBAC | Role-Based Access Control |
| IaC | Infrastructure as Code |
| (OI)(CI) | Object Inherit / Container Inherit (icacls inheritance flags) |
| WinRM | Windows Remote Management |

## Acronyms used in this lab

| Term | Meaning |
|---|---|
| NTFS | New Technology File System, Windows' native filesystem that enforces file and folder permissions |
| SMB | Server Message Block, the network protocol behind Windows file shares |
| AD / AD DS | Active Directory / Active Directory Domain Services |
| OU | Organizational Unit |
| GPO / GPMC | Group Policy Object / Group Policy Management Console |
| ACL / ACE | Access Control List / Access Control Entry |
| VNet / NSG | Virtual Network / Network Security Group |
| RBAC | Role-Based Access Control |
| IaC | Infrastructure as Code |
| (OI)(CI) | Object Inherit / Container Inherit (icacls inheritance flags) |
| WinRM | Windows Remote Management |
| RDP | Remote Desktop Protocol, used to open a full remote screen session on port 3389 |
| GRP_ prefix | Not an industry acronym, just this lab's naming convention for its AD security groups (GRP_Finance, GRP_HR, GRP_Sales, GRP_IT) |

**Ports used in this lab:**
- **3389 (RDP)** — the only inbound port the NSG opens, and only from the deployer's own IP. This is how you remote into DC01, FS01, or CLIENT01.
- **5985 (WinRM)** — the port PowerShell remoting normally uses. The NSG never opens it, which is why every configuration script is pushed through `az vm run-command` (over the Azure VM agent) instead of a WinRM session.

## Running this lab in VS Code

VS Code isn't required, everything here is plain text and works fine in any editor plus a terminal, but it's a convenient single place to edit and run the lab.

1. Install the **HashiCorp Terraform**, **PowerShell**, and **Azure Account** extensions from the Extensions panel.
2. Open the project folder: `code "$HOME\ntfs-lab-terraform"`
3. Use the integrated terminal (`` Ctrl+` ``) for every command in the SOP, `az login`, `terraform init/plan/apply`, and running `configure-lab.ps1`. It's the same PowerShell shell, just inside the editor.
4. The Terraform extension adds syntax highlighting and inline validation for `.tf` files, so a malformed block (like attributes separated by commas instead of new lines) gets flagged before you ever run `terraform init`.
5. `terraform` and `az` still need to be installed on the machine itself. VS Code edits and runs the commands; it doesn't replace either tool.
6. Step 9 (RDP testing) opens outside VS Code either way, since a full remote desktop session isn't something an editor can host.

## Build steps (summary)

1. Create the Terraform remote state storage account
2. Scaffold the project folder (`.tf` files, `scripts/` subfolder)
3. Write the Terraform files: networking, VMs, Key Vault, outputs
4. Set `terraform.tfvars` and the admin password environment variable
5. `terraform init` / `plan` / `apply` (about 22–24 resources, 10–15 minutes)
6. Write the PowerShell scripts: promote DC, create AD objects, configure shares/NTFS, configure GPO, domain join, verify AD, verify shares, add RDP users
7. Write the orchestration script that pushes every script to the right VM via `az vm run-command`
8. Run `configure-lab.ps1`, fully unattended (15–20 minutes)
9. RDP in as each test user and confirm access matches the permission table above
10. Stop the VMs (no compute charge) or `terraform destroy` when done

Full step-by-step SOP with every file's exact contents: see `NTFS_Lab_SOP_Final_Reviewed.docx` in this repo.

## Screenshots

*Add screenshots here: `terraform apply` output, Azure resource group, AD Users and Computers showing the OUs/groups, the four SMB shares on FS01, and one RDP session proving an access-denied result.*

## Lessons learned

- Terraform HCL requires one attribute per line inside a block; comma-separating attributes on a single line (a common copy/paste artifact) is invalid syntax and fails at `terraform validate`.
- `New-Object` constructor calls should use the `-ArgumentList` parameter rather than inline parentheses immediately after the type name, which is unreliable across PowerShell versions.
- The gap between "the portal shows the role assignment" and "the resource actually respects it" is a real and common source of cloud security debugging time, especially with Key Vault's legacy-vs-RBAC access models.

---

Part of a sequential home-lab series: Active Directory → Wireshark → Splunk SIEM → ServiceNow ITSM → **NTFS File Server (Terraform)**.
