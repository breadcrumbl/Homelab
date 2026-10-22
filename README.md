# Linux Systems Administration Homelab

A practical Linux systems administration portfolio built around a physical home server running Fedora Server. The project documents system configuration, storage management, remote administration, security hardening, troubleshooting, and automation.

## Objectives

- Develop practical Linux system administration skills on a physical machine.
- Understand Linux storage, networking, processes, services, permissions, and system security.
- Administer a server remotely using SSH.
- Document configuration decisions, verification procedures, and troubleshooting steps.
- Build repeatable administrative procedures and Bash scripts.
- Create evidence of practical skills relevant to Linux administration, infrastructure, and DevOps roles.

## Hardware and operating system

| Component | Specification |
|---|---|
| Hardware | Dell OptiPlex 7060 Micro |
| CPU | Intel Core i5-8500T |
| Memory | 16 GB RAM |
| Storage | 256 GB SSD |
| Operating system | Fedora Server 44 |
| Administration workstation | Microsoft Surface Pro 7 running Windows 11 |
| Remote administration | OpenSSH over Wi-Fi |

## Work completed

### 1. Installation and initial configuration

- Installed Fedora Server on the physical machine, replacing the previous Windows installation.
- Created an administrative user account, `serveradmin`.
- Configured Wi-Fi connectivity.
- Enabled and verified the SSH service for remote administration.
- Confirmed that SSH access continued to work with the Ethernet cable disconnected.

### 2. System updates and service checks

- Updated installed packages using `dnf upgrade --refresh`.
- Reloaded systemd's unit configuration following package-update notices.
- Checked for failed systemd units using `systemctl --failed`.

### 3. Storage management and LVM

- Investigated the disk layout using `lsblk` and `df`.
- Used `pvs`, `vgs`, and `lvs` to inspect LVM physical volumes, volume groups, and logical volumes.
- Identified that the root logical volume was using only 15 GiB despite substantial free capacity in the volume group.
- Expanded the root logical volume and filesystem using `lvextend -r -l +100%FREE`.
- Verified that the root filesystem now provides approximately 236 GiB of capacity.

### 4. Initial security review

- Verified that SELinux was in `Enforcing` mode.
- Confirmed that `firewalld` was active.
- Inspected the active firewall zone and its permitted services.
- Listed listening TCP and UDP sockets using `ss -tulpn`.
- Identified services requiring further investigation as part of the security review.

## Current security posture

The server has several important baseline protections enabled, including SELinux enforcement and an active firewall. SSH is available for remote administration.

The security review is ongoing. Remaining work includes reviewing exposed services, confirming the purpose and exposure of listening ports, assessing firewall rules, and documenting appropriate hardening changes without disrupting remote access.

## Planned work

- [ ] Document the hardware, operating system, and network configuration.
- [ ] Review Linux users, groups, file ownership, and permissions.
- [ ] Learn to inspect and manage processes and systemd services.
- [ ] Complete the firewall and SELinux review.
- [ ] Practise log analysis and service troubleshooting.
- [ ] Establish a documented update and backup procedure.
- [ ] Develop a Bash server health-check script.
- [ ] Store the documentation and scripts in Git.
- [ ] Deploy a small service to demonstrate administration of a real workload.

## Documentation approach

Each practical lab will document:

1. **Objective:** What the task is intended to achieve.
2. **Background:** Relevant Linux concepts and terminology.
3. **Procedure:** Commands used and the reason for each step.
4. **Verification:** Evidence that the configuration or change worked.
5. **Troubleshooting:** Problems encountered and how they were resolved.
6. **Lessons learned:** What the task demonstrates about Linux administration.

This repository records completed work separately from planned work so that the documentation reflects the actual state of the server.
