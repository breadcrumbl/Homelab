# Lab 5: Linux Firewall and Network Security 

## 1. Objective

The objective of this lab is to develop a foundational understanding of Linux network security by learning how to inspect, configure and verify the firewall on a Fedora Linux server using firewalld. Objectives:

- Understand the purpose of a host-based firewall and how it protects a Linux server from unwanted network access.
- Inspect active firewall zones, network interfaces, permitted services and configured ports.
- Distinguish between services permitted by the firewall and processes actually listening for network connections.
- Configure, test and remove firewall rules using firewall-cmd, understanding the difference between runtime and permanent configurations.
- Investigate listening network sockets and associate them with their respective processes or services.
- Understand how the firewall, SSH access and SELinux contribute to the server's overall security.
- Apply the principle of least privilege by allowing only the network services required for the server's intended purpose.
- Verify configuration changes and document the results using appropriate Linux administration commands.

Lab deliverable: produce a short network security assessment of your Fedora server containing:
- The active firewall zone and the network interface associated with it.
- A list of permitted services and explicitly configured ports.
- A list of listening network sockets and their associated processes, where identifiable.
- The results of one controlled firewall-rule test.
- An explanation of how firewall rules, listening services, SSH authentication and SELinux work together.
- A final assessment identifying unnecessary exposure or configuration changes that may be appropriate.

## 2. Background

### SELinux

SELinux (Eecurity-Enforced Linux) is a mandatory access-control system. It can restrict what a process is allowed to do, even when ordinary Linux file permissions might otherwise permit it.

### Host-based firewalls

A firewall is a security mechanism that controls network traffic according to a defined set of rules. A host-based firewall runs on an individual computer or server and helps control the traffic reaching or leaving that system.

For a Linux server, a firewall helps reduce the number of network services that other devices can access. For example, a server may run SSH for remote administration and a web server for hosting a website. If SSH is required but a database service should only be accessible locally, the firewall can help restrict network access to those services.

A firewall is not a replacement for secure authentication, software updates or correct application configuration. It is one layer of a broader security strategy.

### `firewalld` and `firewall-cmd`

- `firewalld`: the command Fedora uses as its dynamic firewall management service. It provides an interface for managing firewall rules without requiring an administrator to manually construct the underlying packet-filtering rules.
- `firewall-cmd`: the command-line interface used to inspect and modify the configuration managed by firewalld.For example, an administrator can use it to determine which zone is active, which services are permitted, and whether a particular port has been explicitly opened.

Understanding the distinction between the firewall service and its command-line interface is important: firewalld manages the firewall, while firewall-cmd allows the administrator to interact with that management service.

### Firewall zones

`firewalld` organises firewall rules into zones, which represent different levels of trust for network connections. A network interface or connection can be associated with a particular zone, and that zone determines which traffic is permitted.

Common examples include:
- `public`: intended for networks where other computers should not automatically be trusted.
- `home`: intended for networks where the administrator trusts other devices to a greater degree.
- `FedoraServer`: a zone intended for server deployments, with its own predefined rules.

A zone is not a physical network or a separate firewall. It is a collection of rules applied to traffic associated with that zone.

In this lab, the FedoraServer zone currently associated with the server's Wi-Fi interface, `wlo1`, was inspected and it's existing rules assessed before making any changes.


### Services, ports and listening sockets

Understanding the relationship between firewall rules and network services is central to this lab.
- A port: a numbered endpoint used by network protocols to direct traffic to the appropriate application or service. For example, SSH commonly uses TCP port 22.
- A service: in firewalld terminology, a predefined set of firewall rules associated with a network service, typically including its protocol and port requirements.
- A listening socket: a network endpoint on which a process is waiting for incoming connections. The `ss` utility can display these sockets and, with appropriate privileges, the associated processes.

These concepts are related but not interchangeable:
- A firewall rule permitting a port does not necessarily mean an application is listening on it.
- An application listening on a port does not necessarily mean remote devices can reach it.
- A service can be reachable only if the application is listening and the network path and applicable security rules allow the connection.
For this reason, checking the firewall alone is insufficient when assessing network exposure. Must also inspect listening sockets and test connectivity where appropriate.

### Runtime and permanent configuration

`firewalld` distinguishes between its current runtime configuration and its permanent configuration.
- Runtime configuration represents the rules currently applied by the running firewall. Changes made only to runtime configuration are not retained when the firewall is restarted.
- Permanent configuration represents the rules saved for future application, including after a firewall reload or restart.

This distinction allows administrators to test changes before committing them permanently. However, runtime changes can still affect active network access immediately, so they must be made carefully.

During this lab, temporary changes are used to demonstrate how firewall rules affect connectivity. The results were verified and then the test rule removed when no longer required.

### Firewall, SSH and SELinux

Linux security involves several complementary controls.
| Security mechanism | Primary purpose |
|---|---|
| `firewalld` | Controls network traffic according to firewall rules. |
| SSH authentication | Controls who can authenticate to a remote shell. |
| SELinux	| Enforces mandatory access-control policies over processes and resources. |
| Linux file permissions | Control access to files and directories. |
| Service configuration |	Determines what applications expose and how they behave. |

These mechanisms address different risks. For example, allowing SSH through the firewall does not mean every user can log in, and a correctly configured firewall does not guarantee that an exposed application is secure.

### Least privilege and network exposure

The principle of least privilege means granting only the access required for a system to fulfil its intended purpose. For a server, this includes limiting both the services running on the machine and the network traffic permitted to reach them.

Every unnecessary listening service or overly broad firewall rule can increase the server's attack surface. A well-administered system therefore requires an understanding of which services are necessary, which interfaces expose them, and which devices should be able to access them.

The aim is not to close every port indiscriminately. It is to establish a deliberate, documented configuration that supports the server's intended uses while minimising unnecessary exposure.

## 3. Procedure 

### 3.0 Safety requirement

Because the server is administered remotely over SSH, the current SSH session will be kept open while experimenting. Must verify that any proposed changes preserve access before applying them, and avoid exposing administrative services to the public internet.

### 3.1 Inspect SELinux

- `getenforce`
    - Purpose: Get status of SELinux 
        - `Enforcing`: policies are actively enforced
        - `Permissive`: violations are logged but not blocked
        - `Disabled`: SELinux is not enforcing policies
    - Result: `Enforcing`

### 3.2 Inspect the firewall

Check the firewall status:
- `sudo systemctl status firewalld`: asks systemd for the status of the firewall service. Press q to exit the status display. Important results:
    - `Loaded : loaded`: systemd knows about the service and where its unit file is located.
    - `enabled`: whether the service is configured to start automatically at boot.
    - `Active : active (running)`: the service is currently running.
- To ask for specific info: 
    - `systemctl is-active firewalld`: checks whether firewall service is running. `active` -> it is!
    - `systemctl is-enabled firewalld`: checks whether firewall service is configured to start automatically on boot. `enabled` -> it is!

- `firewall-cmd --version`
    - Purpose: reports `firewalld` version.
    - Result: 2.4.4

  - `sudo firewall-cmd --state`
    - Purpose: reports whether `firewalld` is running.
    - Result: `Running`

- `sudo firewall-cmd --get-default-zone`
    - Purpose: Checks the default zone, which is the zone assigned by default when a connection or interface has no other applicable zone assignment (it does not necessarily mean every interface is using that zone).
    - Result: `FedoraServer`
    - Interpretation: 

### 3.3 Inspect the active zones and interfaces

- `sudo firewall-cmd --get-zones`
    - Purpose: Lists the available zones (does not mean all those zones are active).
    - Result: FedoraServer FedoraWorkstation block dmz drop external home internal nm-shared public trusted work
- `sudo firewall-cmd --get-active-zones`
    - Purpose: List active zones.
    - Result: Wi-Fi interface active
    ```
    FedoraServer (default)
        interfaces: wlo1
    ```
- `sudo firewall-cmd --zone=FedoraServer --list-all`
    - Prupose: Inspect the active zone runtime configuration.
```
FedoraServer (default, active)
  target: default
  ingress-priority: 0
  egress-priority: 0
  icmp-block-inversion: no
  interfaces: wlo1
  sources: 
  services: cockpit dhcpv6-client ssh
  ports: 
  protocols: 
  forward: yes
  masquerade: no
  forward-ports: 
  source-ports: 
  icmp-blocks: 
  rich rules: 
```
Permitted services:
- ssh: remote CL access.
- cockpit: browser-based server administration. 
- dhcpv6-client: support for obtaining IPv6 network configuration.

`forward : yes`
- Indicates that the firewalld zone has its zone-level forwarding setting enabled.
- This does not necessarily mean the server is acting as a router. Actual packet forwarding also depends on other configuration, including the Linux kernel's forwarding settings.
- `sysctl net.ipv4.ip_forward`
    - Purpose: Inspects the system-wide IPv4 forwarding setting. 
    - Result: 0 
    - Interpretation: The kernel does not forward IPv4 packets between network interfaces.
- `sysctl net.ipv6.conf.all.forwarding`:
    - Purpose: Inspects the system-wide IPv6. 
    Result: 0 
    - Interpretation: IPv6 forwarding is disabled for all interfaces through this global setting.
- Conclusion: Though the firewall zone's settings permit forwarding, the server itself is not configured to route IPv4 or IPv6 packets.

### 3.4 Runtime vs permanent firewall configuration

- `sudo firewall-cmd --permanent --zone=FedoraServer --list-all`
    - Purpose: Inspect the active zone permanent configuration.
    - Result:
    ```
    FedoraServer (default)
    target: default
    ingress-priority: 0
    egress-priority: 0
    icmp-block-inversion: no
    interfaces: 
    sources: 
    services: cockpit dhcpv6-client ssh
    ports: 
    protocols: 
    forward: yes
    masquerade: no
    forward-ports: 
    source-ports: 
    icmp-blocks: 
    rich rules: 
    ```


Inspecting using `vimdiff` (not needed here as small enough to do by eye but good to know for larger files):
1. Save runtime and permanent config outputs to files:
    `sudo firewall-cmd --zone=FedoraServer --list-all > /tmp/firewall-runtime.txt`
    `sudo firewall-cmd --permanent --zone=FedoraServer --list-all > /tmp/firewall-permanent.txt`
2. `vimdiff /tmp/firewall-runtime.txt /tmp/firewall-permanent.txt`: open side by side in with Vim. Highlighted sections show differences. 
3. `rm /tmp/firewall-runtime.txt /tmp/firewall-permanent.txt`: clean up the temp files

Results: the runtime `FedoraServer` zone lists `wlo1` as an assigned interface while active the permanent zone does not.

Further investigation

- `sudo firewall-cmd --get-default-zone`
    - Result: `FedoraServer`
    - Interpretation: `FedoraServer` is the default firewalld zone.

- `sudo firewall-cmd --get-active-zones`
    - Result: `FedoraServer (default)`, with `wlo1` listed under `interfaces`.
    - Interpretation: The Wi-Fi interface is currently assigned to the `FedoraServer` zone at runtime.

- `nmcli -f NAME,DEVICE,TYPE connection show --active` 
    - Purpose: identifies active NetworkManager connections and their associated devices.

- `nmcli -f connection.id,connection.interface-name,connection.zone connection show "WIFI_NAME"`
    - Purpose: Inspects the specified NetworkManager connection profile to identify its connection name, associated network interface, and explicitly configured firewalld zone.
    - Result: The connection uses interface `wlo1`, but `connection.zone` is `--`.
    - Interpretation: No firewall zone is explicitly configured in the NetworkManager connection profile.

- `sudo firewall-cmd --permanent --path-zone=FedoraServer`
    - Purpose: Display path to permanent zone config file
    - Result: `/etc/firewalld/zones/FedoraServer.xml`

- `sudo cat /etc/firewalld/zones/FedoraServer.xml`
    - Purpose: Open permanent zone config file in console for inspection.
    - Result: 
    ```
    <?xml version="1.0" encoding="utf-8"?>
    <zone>
    <short>Public</short>
    <description>For use in public areas. You do not trust the other computers on networks to not harm your computer. Only selected incoming connections are accepted.</description>
    <service name="ssh"/>
    <service name="dhcpv6-client"/>
    <service name="cockpit"/>
    <forward/>
    </zone>
    ```
    - Interpretation: no `<interface name="wlo1"/>` -> The interface is not explicitly bound to this zone in this file.

- `sudo firewall-cmd --get-zone-of-interface=wlo1`
    - Result: `FedoraServer`

- `sudo firewall-cmd --permanent --get-zone-of-interface=wlo1`
    - Result: `no zone`

Conclusion
- The runtime configuration assigns `wlo1` to `FedoraServer`, which is also the default zone. However, the permanent zone configuration does not explicitly list the interface, and the active NetworkManager connection profile has no explicit zone configured. 
- Not neccessarily a vulnerability but further investigation required to understand the effective zone assignment after a firewalld reload, network reconnection or configuration change.
- No configuration changes were made during this investigation.

### 3.5 Inspect listening sockets

- `sudo ss -tulpn`: display socket info (`ss`):
    - `-t`: TCP
    - `-u`: UDP
    - `-l`: listening
    - `-p`: process using each socket (if available)
    - `-n`: numeric address and port numbers instead of resolving names
Results:
```
Netid State  Recv-Q Send-Q Local Address:Port  Peer Address:Port Process                                                          
udp   UNCONN 0      0            0.0.0.0:5355       0.0.0.0:*     users:(("systemd-resolve",pid=597,fd=12))                       
udp   UNCONN 0      0         127.0.0.54:53         0.0.0.0:*     users:(("systemd-resolve",pid=597,fd=20))                       
udp   UNCONN 0      0      127.0.0.53%lo:53         0.0.0.0:*     users:(("systemd-resolve",pid=597,fd=18))                       
udp   UNCONN 0      0          127.0.0.1:323        0.0.0.0:*     users:(("chronyd",pid=767,fd=4))                                
udp   UNCONN 0      0               [::]:5355          [::]:*     users:(("systemd-resolve",pid=597,fd=14))                       
udp   UNCONN 0      0              [::1]:323           [::]:*     users:(("chronyd",pid=767,fd=5))                                
tcp   LISTEN 0      128          0.0.0.0:22         0.0.0.0:*     users:(("sshd",pid=939,fd=6))                                   
tcp   LISTEN 0      4096   127.0.0.53%lo:53         0.0.0.0:*     users:(("systemd-resolve",pid=597,fd=19))                       
tcp   LISTEN 0      4096         0.0.0.0:5355       0.0.0.0:*     users:(("systemd-resolve",pid=597,fd=13))                       
tcp   LISTEN 0      4096      127.0.0.54:53         0.0.0.0:*     users:(("systemd-resolve",pid=597,fd=21))                       
tcp   LISTEN 0      128             [::]:22            [::]:*     users:(("sshd",pid=939,fd=7))                                   
tcp   LISTEN 0      4096               *:9090             *:*     users:(("systemd",pid=1,fd=112))                                
tcp   LISTEN 0      4096            [::]:5355          [::]:*     users:(("systemd-resolve",pid=597,fd=15))  
```

- `Recv-Q`: data received but not yet read by the application, or queued connection requests for a listening TCP socket.
- `Send-Q`: for a listening TCP socket, the configured limit for queued connection requests; for established sockets, it represents data queued for sending.

Interpretation:

| Protocol | Local address:port	| Process | Purpose / assessment |
|--------|--------|--------|--------|
TCP | 0.0.0.0:22, [::]:22 | sshd |	SSH; required for remote administration; listening on all local IPv4 and IPv6 addresses. |
TCP/UDP |	127.0.0.53:53, 127.0.0.54:53 |	systemd-resolve	| Local DNS resolver; loopback only. |
TCP/UDP |	0.0.0.0:5355, [::]:5355 |	systemd-resolve |	LLMNR; review whether necessary. |
UDP |	127.0.0.1:323, [::1]:323 |	chronyd |	Time synchronisation-related socket; loopback only; expected system service. |
TCP	| *:9090 |	systemd |	Likely Cockpit socket; confirm service status and firewall need. |

Addresses:
- 0.0.0.0: listening on all local IPv4 addresses
- 127.0.0.1/8: reserved for loopback addresses (CDIR: first 8 bits fixed as network prefix, 127)
    - A loopback addresses is an address that a computer uses to communicate with itself.
    - `ip address show lo`: displays loopback network interface `lo` and it's range 127.0.0.1/8
    - `ping -c 3 127.0.0.1`: sends 3 packets to own machine. Result: all packets transmitted and receieved -> local loopback works.
- *: wildcard address, where the service on a port is not restricted to a specific address in the diaplyed output.

Ports:
- tcp/22: SSH's default; listening on all local IPv4 and IPv6 addresses.
- 9090: Cockpit's default web-management port. Process is `systemd` not `cockpit` which is consistent with systemd socket activation (systemd can hold the listening socket and start Cockpit when a connection arrives).
    - `systemctl status cockpit.socket`: checks socket statis. Result: `loaded`, `enabled` and `active`.
    - `systemctl status cockpit.service`: checks service statice. Result: `loaded`, `static` and `inactive (dead)`.
    - `sudo firewall-cmd --zone=FedoraServer --query-service=cockpit`: checks whether the cockpit service is permitted by the firewall in the FedoraServer zone. Result: `yes`.
    - Summary: socket is ready but service is dead until systemd receieves a connection and wakes it. 
- tcp and udp/53: `systemd-resolved` handles DNS name resolution; bound to loopback addresses.
- tcp and udp/5355: LLMNR (Link-Local Multicast Name Resolution) allows devices on a local network to resolve certain names without conventional DNS.
    - `resolvectl status`: inspects LLMNR configuration. Can look in more detail in a potential security hardening lab but important results for now:
        - `Protocols: LLMNR=resolve`: enabled in resolve-mode
- udp/323: default port for Chrony's command / monitoring interface, which communicates with the Chrony daemon `chronyd`. This daemon is a Linux service that maintains the system clock's synchronisation with reference time sources

### 3.6 Controlled firewall test

Important: keep current SSH session open throughout. Verify nothing changes access via SSH.

1. Record the baseline:  
    `sudo firewall-cmd --zone=FedoraServer --query-port=45678/tcp`
    `sudo firewall-cmd --permanent --zone=FedoraServer --query-port=45678/tcp` 
    - Purpose: Checks whether TCP port 45678 is explicitly allowed in the FedoraServer zone's runtime and permanent configuration.
    - Result: `no` and `no`
    - Interpretation: Confirms it isn't. This is the expected result as we have not added a test rule allowing it yet.
2. `sudo firewall-cmd --zone=FedoraServer --add-port=45678/tcp`
    - Purpose: Add a temp runtime rule
    - Result: `success`
    - Interpretation: Expected result.
3. Verify the difference by running the command in step 1 again.
    - Result: `yes` and `no`
    - Interpretation: Verifies port 45678/tcp has temporarily been added to the runtime allowed interfaces but not the permanent configuration.
4. `sudo firewall-cmd --zone=FedoraServer --remove-port=45678/tcp`
    - Purpose: Remove the temp rule.
    - Result: `success`
    - Interpretation: Expected result.
5. Verify the cleanup by running the commands from step 1 again.
    - Result: `no` and `no`
    - Interpretation: Confirms temp rule has been removed.

Results Summary:

| Stage |	Runtime rule |	Permanent rule |
|----|----|----|
| Before test |	no |	no |
| After adding temporary rule |	yes	| no |
| After cleanup |	no	| no |

Conclusion: Difference between runtime and permanent configuration demonstrated. 

## 4. Verification

Check to make sure firewall status is the same as before the lab.

- `sudo firewall-cmd --zone=FedoraServer --list-all`
    - Result: no changes from inspection at beginning of lab.
- `sudo firewall-cmd --permanent --zone=FedoraServer --list-all`
    - Result: no changes from inspection at beginning of lab.
- `sudo firewall-cmd --state`
    - Result: `running`

Conclusion: Firewall is in tact.

## 5. Commands Used

## 6. Troubleshooting

## 7. Outcome and Lessons Learned

Outcomes
- SELinux, the firewall, and sockets inspected.
- Simple controlled firewall test carried out.
- Verified no permanent changes to firewall configuration.

Lessons Learned
- How to check the status of SELinux.
- How to check the status and active zones of a firewall.
- How to interpret the socket results from `ss`.
- Difference between runtime and permanent firewall zone configurations.
- How to add and remove a service to and from the runtime firewall zone's permitted devices.
- Streaming results to a text file and comparing two text files with `vimdiff`.

## 8. Future Work

- Deactivate Cockpit if don't need it
- Inspect and potentially disable LLMNR
- Investigate difference between runtime and permament firewall configuration for the `wlo1` interface