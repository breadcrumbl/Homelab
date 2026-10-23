# Lab 2: Networking and SSH 

## 1. Objective

The Fedora server is intended to run without a permanently attached monitor or keyboard and to be accessed through a Windows laptop workstation via SSH. At the time, the server was running on a PC connected to a USB keyboard and the TV via a DisplayPort-HDMI cable.

The objectives are:
- Make sure the ssh software is installed
- Configure the ssh server
- Allow SSH through Fedora's firewall
- Remotely access server from laptop workstation over Wi-Fi using SSH 

## 2. Background

### Network interfaces

A network interface is the point through which a computer sends and receives network traffic. The server has three relevant interfaces:
- lo — loopback: A virtual interface used by the computer to communicate with itself. Its IPv4 address is 127.0.0.1.
- eno2 — Ethernet: The server's wired network interface. It was down during the recorded network inspection.
- wlo1 — Wi-Fi: The wireless interface used to connect the server to the home network.

### IP addresses and subnets

An Internet Protocol (IP) address identifies a network interface so that other devices can communicate with it.

The server's recorded IPv4 address was: 192.168.0.222/24

The /24 suffix is the CIDR (Classless Inter-Domain Routing) prefix length. It corresponds to the subnet mask 255.255.255.0, meaning the first 24 bits identify the network portion of the address.

The server and other devices on the same local subnet can communicate directly, subject to network configuration and firewall rules.

The server also had an IPv6 link-local address. Link-local IPv6 addresses are used for communication on the local network link and are not globally routable internet addresses.

### SSH and remote administration

Secure Shell (SSH) provides an encrypted connection to a remote system. It is commonly used by Linux administrators to access a shell, execute commands and manage servers without needing a monitor or keyboard connected to the server.

The main components are:
- SSH client: The program used on the computer initiating the connection.
- SSH server (sshd): The service running on the remote computer that accepts SSH connections.
- TCP port 22: The standard port used by SSH unless a different port is configured.
- Authentication: The process used to establish that the connecting user is permitted to log in.

On Windows, an SSH client can be used from PowerShell or Windows Terminal. Once connected, commands execute on the remote Fedora server, not on the Windows machine.

### DHCP and reserved IP addressess

DHCP (Dynamic Host Configuration Protocol) is the protocol responsible for handing out internal IP addresses to devices on a network. It pulls from a pool of available addressess. 

DHCP doesn't neccessarily give the same IP address to the same device each time it connects to a network. To make it so a device has the same IP address each time, that address must be reserved so that it is always associated with the MAC address of that device.

## 3. Procedure

### 3.1 Install and configure ssh

1. `sudo dnf install openssh-server`: install the software to use ssh server. Reveals server is already installed.
    - `dnf`: Fedora’s package manager
    - `openssh-sever`: software package containing ssh
2. `sudo systemctl is-active sshd`: check server is running. Result `active` shows it is.

If server was not active, use `sudo systemctl start sshd` to start.

3. `sudo systemctl is-enabled sshd`: check server is configured to start automatically during future boots. Result `enabled` shows it is.

If server was not enabled, use `sudo systemctl enable sshd` or `sudo systemctl enable --now sshd`, which enables and starts service now. 

4. `sudo firewall-cmd --permanent --add-service=ssh`: allows SSH through Fedora's firewall by adding to permanent allowed services list.

    - Note `ssh` here not `sshd`: `ssh` is the client (i.e. the workstation) while `sshd` is the server-side systemd service


### 3.2 Remote access

Get the server's IPv4 address. On the PC:
- `hostname -I`: IPv4 address next to `inet`
- `ip -brief address`: displays each interface, its state, and assigned address. Result shows `wlo1` was UP with both an IPv4 address and an IPv6 link-local address.
On a workstation:
- Access router as administrator by typing in the IP address (2.168.0.1) into a browser and confirming the password
- Find the IP address under connected devices

Result: 192.168.0.222

Note: this IP address can currently change. Will fix this problem later by reserving an IP address for the server via DHCP.

On the Windows workstation:
- Login on workstation using `ssh serveradmin@192.168.0.222` (i.e. `ssh <username>@<IP address>`) in PowerShell and typing in the password. The first time logging asks whether to trust the device: say yes.
- Exit SSH cleanly from workstation using `exit` command.

### 3.3 DHCP reservation

- `ip link show wlo1`: returns Wi-Fi MAC address next to `link/ether`.
- `ip route`: find the router MAC address on the line beginning `default`. 
- `ip -brief address show wlo1`: confirm the server's address (to check in case it has changed since setting up)
- Login into router admin page on browser, find DHCP / reserved addresses section, and reserve an IP address that does is not in conflict with any other reserved addresses for the MAC address of the Wi-Fi.

### 3.4 Permanent hostname

A permanent hostname identifies the device.

- `hostnamectl`: check the current hostname (`localhost`)
- `sudo hostnamectl set-hostname fedora-server`: set the hostname to `fedora-server`
- `hostnamectl`: verify the change has occured

### 3.5 Test network connectivity and DNS

- `ping -c 4 <router-ip>`: test router is reachable (sends 4 packets then stops). All packets transmitted and received.
- `ping -c 4 1.1.1.1`: tests connectivity to a public IP without relying on DNS resolution. All packets transmitted and received.
- `getent ahosts fedoraproject.org`: test DNS resolution. IP address returned so success!


## 4. Verification

| Check | Evidence |
|---|---|
| sshd configuration | `systemctl is-active sshd` and `systemctl is-enabled sshd` showed sshd is running and configured to start automatically on boot. `sudo systemctl status sshd` shows listening on port 22 and successful connection attempts. |
| Remote access | Server successfully accessed from workstation over Wi-Fi using SSH.  |
| Reserved IP address | Confirmed on router admin page. |

## 5. Commands Used

## 6. Troubleshooting

## 7. Outcome and Lessons Learned
Outcomes:
- ssh server successfully installed and configured on Fedora server
- Remote workstation successfully accessed Fedora server over Wi-Fi using SSH

Lessons Learned:
- The difference between the ssh server (sshd) and the ssh client (ssh).
- Multiple ways to check the connectivity and IP address of the Fedora server.
- How to allow services through Fedora's firewall.
- How to reserve a DHCP address for a device.
- How to give a device a permanent hostname.

## 8. Future Work
- Set up an SSH key and agent