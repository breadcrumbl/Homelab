
| Check | Command | Result |
|---|---|---|
| Firewall is active | `systemctl is-active firewalld` | `active` |
| Frewall is enabled to automatically start on botto | `systemctl is-enabled firewalld` | `enabled` |
| Firewall version | `firewall-cmd --version` | 2.4.4 |
| firewalld is running | `sudo firewall-cmd --state` | `Running` |
| The firewall default zone | `sudo firewall-cmd --get-default-zone` | `FedoraServer` |
| Firewall active zones | `sudo firewall-cmd --get-active-zones` | `FedoraServer` zone applied to `wlo1` interface |



Potential actions for security hardening:
- Deactivate cockpit if don't need it
- Inspect and potentially disable LLMNR
- Investigate difference between runtime and permament firewall configuration for the `wlo1` interface