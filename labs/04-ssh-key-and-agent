# Lab 4: SSH Key-Based Authentication and SSH Agent Configuration

## 1. Objective

- Configure secure SSH key-based access from Windows to Fedora Server.
- Use an SSH alias to simplify login.
- Reduce repeated passphrase prompts using an SSH agent.

## 2. Background

### SSH

SSH (Secure Shell) is a network protocol used to establish an encrypted connection between a client and a remote computer. It allows users to execute commands, administer systems and transfer files securely over a network.

In this lab, SSH is used to connect from a Windows laptop to a Fedora Server homelab. The SSH client runs on Windows, while the SSH server (sshd) runs on Fedora and handles incoming connection requests. The Fedora firewall permits SSH connections, and the server is accessed using the serveradmin account.

SSH supports several authentication methods, including password authentication and public key authentication. This lab focuses on public key authentication while retaining password authentication as an alternative.

### Public Key Authentication

Public key authentication uses a mathematically related pair of cryptographic keys:

- Private key: Kept securely on the client and used to prove possession of the key pair. It must not be shared.

- Public key: Installed on the remote server and used to verify authentication attempts made with the corresponding private key.

When a client attempts to authenticate, the SSH server checks whether the client can prove possession of a private key corresponding to an authorised public key. The private key itself is not transmitted to the server.

On Fedora, authorised public keys are commonly stored in the user's ~/.ssh/authorized_keys file. For this lab, the public key is installed for the serveradmin account, allowing the corresponding private key to authenticate SSH connections.

### Private Key Passphrases

A private key can be protected by a passphrase. This adds a layer of protection because someone who obtains the private key file cannot necessarily use it without knowing the passphrase.

A key passphrase is different from the password for the Fedora user account. The passphrase unlocks the private key locally, whereas the account password authenticates the user through password-based SSH authentication.

Using a passphrase-protected private key helps protect the credentials if the key file is copied or stolen. However, repeatedly entering the passphrase can become inconvenient when making frequent SSH connections.

### SSH Configuration and Host Aliases

SSH client configuration files allow connection settings to be stored and reused. Instead of repeatedly specifying a username, IP address and identity file, a host alias can be configured.

For example, an SSH configuration entry named fedora-server can associate the alias with the server's IP address, the serveradmin account and the appropriate private key. The server can then be accessed using: `ssh fedora-server`

This lab configures SSH aliases in both Windows OpenSSH and MSYS2. These are separate client environments with their own SSH configuration files, even when they use the same underlying private key.

### SSH Agent

An SSH agent is a background process that holds unlocked private key identities in memory and makes them available to compatible SSH clients. After a passphrase-protected key has been added to the agent, the user can authenticate without repeatedly entering the passphrase while the key remains available to the agent.

On Windows, the OpenSSH Authentication Agent service (ssh-agent) provides this functionality. The service can be configured to start automatically, and the private key can be added using ssh-add. The ssh-add -l command lists the identities currently available through the agent.

The agent does not remove the private key's passphrase or replace SSH authentication. Instead, it manages access to the unlocked key during use. Its availability depends on the client being able to communicate with the relevant agent.

Windows OpenSSH and MSYS2 use separate SSH client environments. Although both can use the same private key file, they do not necessarily share access to the same agent. In this setup, the Windows SSH agent is used with PowerShell, while MSYS2 continues to connect independently.

### Security Considerations

Private key security depends on protecting both the key file and access to the agent. The private key should be stored in a suitable location, with file permissions that prevent unauthorised users from reading it. Windows OpenSSH may reject private keys whose permissions are too permissive.

The SSH agent should also be understood as a convenience mechanism rather than a substitute for securing the private key. Anyone who can access an unlocked agent may potentially use its loaded identities to authenticate to authorised systems, subject to the agent and key configuration.

This lab combines public key authentication, appropriate private key permissions, reusable SSH client configuration and the Windows SSH agent to create a practical and maintainable remote administration workflow.

## 3. Procedure 

### 3.1 Add existing MSYS2 key to Fedora server

Already have a key pair used by MSYS2 Bash on the Windows workstation used for GitHub. Add this to Fedora server:

1. In MSYS2 UCRT64 terminal: `ls -la ~/.ssh` lists all .ssh files
2. `cat ~/.ssh/id_ed25519.pub`: display public key.
3. `ssh-copy-id -i ~/.ssh/id_ed25519.pub serveradmin@192.168.0.222`: copy key to Fedora.
4. `ssh serveradmin@192.168.0.222`: confirm can log in on Bash terminal - works!

### 3.2 Make existing SSH key accessible by PowerShell

Move key from MSYS2 directory to Windows /.ssh then configure GitHub to use it in MSYS2. 

1. In MSYS2 `cygpath -w ~/.ssh`: gets path to Windows .ssh directory.
In PowerShell:
Make it work for Windows. 
2. `Get-Command ssh`: checks which SSH client PowerShell uses. Result: Windows OpenSSH.
3. `New-Item -ItemType Directory -Force "$HOME\.ssh"`: creates .ssh directory if it doesn't exist. Already exists for me but good to know.
4. Set source and destination
    `$source = "<path to .ssh>.ssh"`
    `$dest = "$HOME\.ssh"`
5. Check the files and confirm the destination doesn't contain a key pair that will be overwritten. 
    `Get-ChildItem $source`
    `Get-ChildItem $dest`
6. Move the pair:
    `Move-Item "$source\id_ed25519" "$dest\id_ed25519"`
    `Move-Item "$source\id_ed25519.pub" "$dest\id_ed25519.pub"`
7. Inspect the private key:
    `$key = "$HOME\.ssh\id_ed25519"`: assign private key's path to key.
    `$me = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name`: gets identify of currently logged in user.
    `icacls $key`: inspect the ACL (access control list):
```
BUILTIN\Administrators:(F)
NT AUTHORITY\SYSTEM:(F)
BUILTIN\Users:(RX)
NT AUTHORITY\Authenticated Users:(M)
```
Note: The F, RX and M abbreviations mean Full control, Read and execute, and Modify, respectively. The last entry means other users can read or modify my key.
8. Secure the key
    `icacls $key /inheritance:r`: disables inheritance and removes inherited permissions so that if the directory grants access to a broad group, the private key will not inherit that access.
    `icacls $key /remove "BUILTIN\Users" "NT AUTHORITY\Authenticated Users"`: explicity remove access to the last group.
    `icacls $key /grant:r "${me}:(R)"`: grant the current account reas-access.
9. Inspect the ACL (access control list) again using`icacls $key`. Updated successfully!
```
<me>:(R)
BUILTIN\Administrators:(F)
NT AUTHORITY\SYSTEM:(F)
```

10. In PowerShell `ssh -i "$HOME\.ssh\id_ed25519" serveradmin@192.168.0.222`: test the result! Works! Can now login with SSH password.

### 3.3 Configure MSYS2 so GitHub can access moved key

In MYSY2 test whether key stil works by trying to upload something to git up (this is what key was being used for). 
```
git@github.com: Permission denied (publickey).
fatal: Could not read from remote repository.
```

Permission denied! Let's fix.

In MYSY2:
1. `ssh -i "$(cygpath -u "$USERPROFILE")/.ssh/id_ed25519" -T git@github.com`: try to use key from Windows .ssh directory (where we just moved the key). Successfully authenticated - works!
2. `which ssh`: check which SSH executable Git uses
3. `cygpath -u "$USERPROFILE"`: prints user directory in MSYS2 format
4. `code ~/.ssh/config`: open MYSY2 SSH configuration file. Didn't exist for me so creating one.
5. Add, but using the path from step 3
```
Host github.com
    IdentityFile /c/Users/Example/.ssh/id_ed25519
    IdentitiesOnly yes
```
6. `ssh -T git@github.com`: test GitHub. Success!
7. Try to upload again (reconfirming result). Success!

### 3.4 Configure client aliases

Instead of using `ssh serveradmin@192.168.0.222` can use a simpler login such as `ssh fedora-server`.

In PowerShell:
1. `New-Item -ItemType File -Force "$HOME\.ssh\config"`: create config file for Windows SSH.
2. `notepad $HOME\.ssh\config`: open config file in notepad app and add:
```
Host fedora-server
    HostName 192.168.0.222
    User serveradmin
    IdentityFile ~/.ssh/id_ed25519
    IdentitiesOnly yes
```
3. `ssh fedora-server`: test connection. Works!!

In MSYS2:
1. `cygpath -u "$USERPROFILE"`: get Windows username
2. `code ~/.ssh/config`: open MSYS2 config file and addd underneath existing block:
```
Host fedora-server
    HostName 192.168.0.222
    User serveradmin
    IdentityFile /c/Users/YOUR_USERNAME/.ssh/id_ed25519
    IdentitiesOnly yes
```
3. `ssh fedora-server`: test connection. Works!!

### 3.5 Configure the Windows SSH agent

Windows includes an SSH agent service called ssh-agent. It stores unlocked keys in memory so SSH can use them without asking for the passphrase repeatedly.

1. Run PowerShell as administrator.
2. `Set-Service ssh-agent -StartupType Automatic`: configures Windows to start the agent automatically when needed at startup.
3. `Start-Service ssh-agent`: starts the service now, without requiring a reboot.
4. `Get-Service ssh-agent`: verify service is running. Result `Running` shows it is.
5. `ssh-add "$HOME\.ssh\id_ed25519"`: add key to agent (asks to confirm passphrase).
6. Verify the agent has the key:
    `ssh-add -l`: lists the idenitities (private keys) currently loaded to the agent.
    `ssh-add -L`: lists public keys.
7. `ssh fedora-server`: test Fedora connection. Should connect without being prompted for password. Works!

NOTE: the agent holds the unlocked key in memory, rather than removing the passphrase from the key file. You may need to add the key again after a restart, depending on your Windows agent setup.

## 4. Verification

## 5. Commands Used

## 6. Troubleshooting

When setting up a key pair for SSH log in, some changes had to be made so that PowerShell could use the existing key pair in the MSYS2 directory which was being used for GitHub. The steps taken were:
1. Move the key pair from the MSYS2 directry to the standard Windows .ssh directory
2. Secure the key
3. Add a config file to MSYS2 /.shh directory telling GitHub where to find the key now.

## 7. Outcome and Lessons Learned

Outcomes:
- Can use SSH to access the Fedora server in both PowerShell and MSYS2 terminals.
- Can use simplified command `ssh fedora-server` to access server in in both PowerShell and MSYS2 terminals by setting up an alias.
- Can access the Fedora server in PowerShell without typing in a passphrase using an SSH agent.

Lessons Learned:
- An SSH key pair can be shared across multiple uses (e.g. GitHub and Fedora server).
- Broad user-group permissions should be removed for the private key.
- Can use an SSH agent to hold the unlocked key so the passphrase doesn't need to be typed in every time. 

## 8. Future Work