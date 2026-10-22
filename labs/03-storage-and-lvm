# Lab 3: Expanding the Root Logical Volume with LVM

## 1. Objective

On installation and initial configuration of the Fedora server, it was found that although the server had a 256 GB SSD, the root filesystem (/) initially had only 15 GiB of space allocated to it. The objective of this lab is to investigate and resolve this issue by:

Objectives:
- Inspect the disk, partition, and filesystem layout.
- Understand how LVM manages storage.
- Identify the unused capacity within the volume group.
- Expand the root logical volume to use the available capacity.
- Resize the filesystem and verify that the additional space was usable.
 
## 2. Background

### Block devices, paritions, and filesystems

- Linux represents storage devices as block devices, which are devices or virtual storage volumes that read and write data in blocks (e.g. physical SSDs, partitions, virtual volumes).
- A partition is a region of physical disk space
- A filesystem is the structure that organises data on a storage device, including files, directories, permissions and metadata


### LVM

LVM (Logical Volume Mananger) provides a flexible way to allocate and manage storage. It separates the physical storage device from the logical volumes that filesystems use. 

There are four layers:
- Layer 1 - PV (Physical Volume): a storage device or partition that LVM has prepared for use.
- Layer 2 - VG (Volume Group): a pool of storage made from one or more physical volumes
- Layer 3 - LV (Logical Volume): a virtual block device allocated from the volume group's storage pool.
- Layer 4 - Filesystem: The structure used by Linux to organise files and directories on a block device. It must have sufficient capacity to make use of the expanded logical volume.

LVM allows a logical volume to be expanded without repartitioning the physical SSD, provided sufficient free capacity is available in its volume group.


## 3. Procedure 

### 3.1 Identify the problem

`df -h` results:

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

The tmpfs are temporary filesystems held in RAM and do not consume SSD space. The main paritions are:

**`/`, the root directory**
- Every file and directory on the system is organised beneath it.
- It contains most of the OS and, by default, most of the software that will be installed.

**`/boot`**
- The boot files needed to start Linux 
- Included the Linux kernal (the core of the OS); initramfs (a temporary initial filesystem containing drivers and tools needed early in boot), and boot-related configurations.

**`/boot/efi:`**
- EFI System Partition (ESP), which contains EFI (Extensible Firmware Interface) bootloader programs and related files that the computer's firmware can execute before Linux starts
- Note UEFI (Unified EFI) is the modern replacement for the older firmware standard BIOS
- BIOS (Basic Input/Output System) firmware built into a computer's motherboard that runs when you turn the computer on, before the operating system starts


The root filesystem (i.e. the filesystem mounted at `/`, which is accessible by `/dev/mapper/fedora-root `) is reported at 15 GB.

### 3.2 List the block devices

`lsblk`: list block devices; shows the physical drive, its partitions and logical volumes.

```
NAME            MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
zram0           251:0    0     8G  0 disk [SWAP]
nvme0n1         259:0    0 238.5G  0 disk
├─nvme0n1p1     259:1    0   600M  0 part /boot/efi
├─nvme0n1p2     259:2    0     2G  0 part /boot
└─nvme0n1p3     259:3    0 235.9G  0 part
  └─fedora-root 252:0    0    15G  0 lvm
```

Note RM and RO mean removable and read-only where 0 means no, 1 means yes.

The results show that there are two 
- `zram0`: compressed RAM-based swap (memory to provide swap space)
- `nvme0n1`: physical SSD
    - `nvme`: a device that uses the NVMe storage interface
    - 0: the first NVMe controller
    - `n1`: namespace 1, a logical storage device presented by that controller
- The SSD has three partitions, p1/2/3, corresponding to `boot/efi`, `boot`, and root.
- Inside the root partition is an LVM logical volume called `fedora-root`

### 3.3 Inspect each layer

1. `sudo pvs`: shows physical volumes, which devices LVM uses and their sizes

```
  PV             VG     Fmt  Attr PSize    PFree
  /dev/nvme0n1p3 fedora lvm2 a--  <235.89g <220.89g
```

There is one PV, `/dev/nvme0n1p3`, the SSD partition available to LVM which belongs to the `fedora` VG.

2. `sudo vgs`: shows the volume groups and how much storage they have available for allocation

```
  VG     #PV #LV #SN Attr    VSize    VFree
  fedora   1   1   0 wz--n-- <235.89g <220.89g
```

- `VSize`: the total capacity available in the volume group.
- `VFree`: the capacity not currently allocated to logical volumes.
- `#LV`: the number of logical volumes in the group.

There is one VG `fedora`, which is a pool of 235.89 GB with 220.89 GB free i.e. there is 220.89 GB of free LVM storage that can be allocated to the root LV.

3. `sudo lvs`: shows the logical volumes managed by LVM, if any, and their sizes

```
  LV   VG     Attr       LSize  Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  root fedora -wi-ao---- 15.00g
```

There is one LV `fedora-root`, the root logical volume, accessible at `/dev/fedora/root` and mounted at `/`, the root.


### 3.4 Expand the root volume and filesystem

`sudo lvextend -r -l +100%FREE /dev/fedora/root`: allocated remaining free space to `/`
- `lvextend`: extend LV.
- `-r`: also resize the filesystem contained in the volume (as this is separate from LV so wouldn’t be automatically resized).
- `-l`: specify the amount using logical-volume extents 
LVM divides its storage into allocation units called extents; argument will be expressed in logical extents or as a percentage of available extents (e.g. 100%FREE). An uppercase `-L` would specify size in GB e.g. `-L 50G`
- `+100%FREE`: allocate all currently free space in the volume group to this logical volume

## 4. Verification

`df -h /`: checks the usable capacity of your root filesystem.
```
Filesystem               Size  Used Avail Use% Mounted on
/dev/mapper/fedora-root  236G  6.9G  229G   3% /
```

Results show the root filesystem has successfully expanded from 15 GB to 236 GB.

## 5. Commands Used

## 6. Troubleshooting

No command errors or other troubleshooting incidents were recorded during the resize operation.

## 7. Outcome and Lessons Learned

Outcomes:
- Successfully resized the root filesystem

Lessons learned:
- Physical capacity and filesystem capacity are different.
- LVM seperates storage into four layers. They make managing and allocating storage easier by splitting into LVs which are allocated storage from a pool or available storage called a VG.
- Expanding the LV and expanding the filesystem are two seperate things but can be done in one command using the `-r` option.

## 8. Future Work