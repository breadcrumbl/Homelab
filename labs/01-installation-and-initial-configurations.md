# Lab 1: Installation and Initial Configuration

## 1. Objective

Install Fedora Server on physical hardware and configure the machine for basic Linux system administration.

The objectives were to:

- Install a Linux server operating system.
- Establish an administrative user account.
- Configure network connectivity over Wi-Fi.
- Update installed software and perform initial system health checks.

## 2. Background

**Linux distribution:** Fedora Server provides the Linux kernel, system utilities, and package management tools required to operate a server.

**Administrative privileges:** `sudo` allows authorised users to execute commands with elevated privileges without routinely logging in as root.

**Networking:** Network interfaces allow a machine to communicate with other devices over a network.

**SSH (Secure Shell):** SSH provides encrypted remote terminal access, allowing an administrator to manage a server from another computer.

**Package management:** DNF installs, updates, and manages software packages and their dependencies on Fedora.

**systemd:** systemd manages services and other system units. Its command-line tools allow administrators to inspect and manage system services.

**daemon** : a background program that runs without you having to interact with it.

## 3. Procedure

### 3.1 Install Fedora Server and configure the administrative account

Installed Fedora Server 44 on a Dell OptiPlex 7060 Micro, replacing the previous Windows installation. The machine has an Intel Core i5-8500T processor, 16 GB RAM, and a 256 GB NVMe SSD.

Installation steps:
1. Download Fedora Media Writer for Windows (.exe) on Windows workstation and wrote the image to a USB.
2. With the USB plugged in, power up the PC, open the boot menu (by repeatedly pressing F12 immediately after the power was turned on), and select “Test this media & install Fedora 44” (which tests the USB before installing - takes longer but is safer than just choosing install).
3. Configure the installation destination to the PC SSD, select "shrink or remove exsisting partitions" and select "delete all" to remove the previously installed Windows partition.
4. Configur a user account (username: serveradmin) and left root disabled.
Rebooted then logged in with the username and password just set up. 

### 3.2 Configure network connectivity

PC connected to router via ethernet cable. To set up Wi-Fi:

1. `nmcli device status`: check Fedora detects a Wi-Fi adapter. It does, named: `wl01`, which is disconnected.
2. `nmcli device wifi list`: list Wi-Fis server can see.
3. `sudo nmcli --ask device wifi connect <Wi-Fi Name> ifname wlo1`: attempts to connect to Wi-Fi
    - `--ask`: prompts user for required info (e.g. password) rather than including it in the command
    - `device wifi connect`: tells Fedora to connect to a wireless network
    - `ifname wlo1`: specifies interface obtained before. If nothing specified, Fedora would choose. Fine here as only one choice but good practice to specify.
4. Verification: `nmcli device status` now shows `wlo1` as connected.
5. `nmcli connection show`: lists NetworkManagers saved connection profiles. Check my Wi-Fi is on list. It is.
6. `nmcli -f NAME,AUTOCONNECT connection show`: check NetworkManager is configured to automatically connect to that network. It is. 

### 3.3 Update the system

Update Fedora:
1. `sudo dnf upgrade --refresh`: 
    - `upgrade`: upgrade installed packages
    - `--refresh`: refreshing repository metadata before checking for updates
2. `sudo systemctl daemon-reload`: tells systemd to reload its service configuration files (to recognise the latest definitions after upgrading)

### 3.4 Check system health

A simple 3-step system health check:
1. `systemctl --failed`: check if Fedora has related any failed services. Result `0 loaded units listed` confirms it doesn't.
2. `df -h`: checks available disk space; shows your disk space and mounted filesystems (disk free -human-readable).

```
Filesystem               Size  Used Avail Use% Mounted on
/dev/mapper/fedora-root   15G  2.7G   13G  18% /
devtmpfs                 7.7G     0  7.7G   0% /dev
tmpfs                    7.8G     0  7.8G   0% /dev/shm
efivarfs                 256K   91K  161K  37% /sys/firmware/efi/efivars
tmpfs                    3.1G  4.7M  3.1G   1% /run
tmpfs                    7.8G     0  7.8G   0% /tmp
/dev/nvme0n1p2           2.0G  466M  1.5G  24% /boot
/dev/nvme0n1p1           599M  8.0M  591M   2% /boot/efi
none                     1.0M     0  1.0M   0% /run/credentials/getty@tty1.service
tmpfs                    1.6G  4.0K  1.6G   1% /run/user/1000
none                     1.0M     0  1.0M   0% /run/credentials/systemd-journald.service
none                     1.0M     0  1.0M   0% /run/credentials/systemd-resolved.service
```

3. `free -h`: check memory usage (like df but shows RAM and swap memory usage rather than storage).

```total        used        free      shared  buff/cache   available
Mem:            15Gi       842Mi        12Gi       4.9Mi       2.1Gi        14Gi
Swap:          8.0Gi          0B       8.0Gi
```

Results: No systems failed and memory usage looks good. However, only 15GB of 256GB drive is allocated to the root system. This can be expanded in a different lab. 

## 4. Verification

| Check | Evidence |
|---|---|
| Operating system | `cat /etc/fedora-release` reported Fedora release 44. |
| Current user | `whoami` returned `serveradmin`. |
| Network interfaces | `ip -brief address` showed `wlo1` as `UP` with `192.168.0.222/24`, and `eno2` as `DOWN`. |
| Failed systemd units | `systemctl --failed` reported zero failed units at the time of inspection. |
| System information | `hostnamectl` confirmed Fedora Linux 44 Server Edition and the x86-64 architecture. |

## 5. Commands Used

## 6. Troubleshooting

No specific installation failure or unresolved problem was recorded for this lab.

During subsequent inspection, `hostnamectl` showed that the transient hostname was `localhost` and no static hostname was configured. Configuring a persistent hostname was identified as a future improvement.

The initial storage investigation also revealed that the root logical volume was only 15 GB despite substantial unused capacity in the LVM volume group. This will be resolved in a seperate lab.

## 7. Outcome and Lessons Learned

Outcomes:
- Fedora successfully downloaded onto the hardware
- Administritive user set up 
- Connected to Wi-Fi
- Performed health check for failed services, disk, and memory usage

Lessons Learned:
- How to download and configure a Linux server onto hardware using a USB keyboard and the TV as a monitor
- Leaving root disabled and using `sudo` to access administrator privlidges
- 

## 8. Future Work

- Configure and verify a persistent hostname.
- Document storage management and LVM operations in a separate lab.