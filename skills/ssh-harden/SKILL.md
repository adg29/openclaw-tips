---
name: ssh-harden
description: Harden a Linux SSH server against brute-force traffic. Disables password auth (key-only), restricts root login to keys, and installs fail2ban with a sensible sshd jail. Use when the user asks to harden SSH, stop brute-force attacks, lock down sshd, reduce auth.log noise, or set up fail2ban on a server.
---

# SSH server hardening

Goal: stop password-based brute-force traffic against `sshd` by enforcing key-only auth and adding fail2ban as a second layer. Run this skill on a server the user has root (or sudo) access to.

## CRITICAL safety check — do not skip

Before touching `sshd_config`, you MUST confirm the current user can still get back in via key after password auth is disabled. If you skip this, you can lock the user out of the server.

Run these in parallel and verify ALL of them before proceeding:

```bash
# 1. Identify who is logged in right now and how
whoami; who am i

# 2. Check that user has authorized_keys with at least one valid key
ls -la ~/.ssh/authorized_keys 2>/dev/null && wc -l ~/.ssh/authorized_keys

# 3. If the user is logging in as root, check root's keys specifically
ls -la /root/.ssh/authorized_keys 2>/dev/null && head -5 /root/.ssh/authorized_keys

# 4. See current effective sshd settings
sshd -T 2>/dev/null | grep -E '^(passwordauthentication|permitrootlogin|pubkeyauthentication|kbdinteractiveauthentication) '
```

**Stop and ask the user to confirm** if any of these are true:
- `authorized_keys` is missing or empty for the login user
- The user can't tell you which key in `authorized_keys` corresponds to their current SSH client
- They are connecting via a console/recovery shell rather than SSH (in which case key auth isn't yet proven to work)

A safe pattern: ask the user to open a SECOND SSH session in another window and confirm it works with their key alone (e.g. by temporarily declining password fallback in their client) BEFORE you reload sshd.

## Step 1 — sshd hardening drop-in

Write a drop-in config rather than editing `/etc/ssh/sshd_config` directly. Drop-ins in `/etc/ssh/sshd_config.d/` are loaded automatically and survive package upgrades cleanly.

```bash
cat > /etc/ssh/sshd_config.d/99-hardening.conf <<'EOF'
PasswordAuthentication no
PermitRootLogin prohibit-password
PubkeyAuthentication yes
KbdInteractiveAuthentication no
ChallengeResponseAuthentication no
EOF
```

Notes on choices:
- `PermitRootLogin prohibit-password` keeps key-based root login working (which the user may rely on) while blocking password attempts. If the user has a non-root sudo user AND wants to disable root entirely, change to `PermitRootLogin no` — but ask first, don't assume.
- `KbdInteractiveAuthentication no` + `ChallengeResponseAuthentication no` close the PAM keyboard-interactive path that some clients fall back to.
- Do NOT set `UsePAM no` — it breaks session setup (motd, env, sudo session tracking) on most distros.

Validate and reload (reload, not restart — reload does not drop existing sessions):

```bash
sshd -t && systemctl reload ssh && \
  sshd -T 2>/dev/null | grep -E '^(passwordauthentication|permitrootlogin|pubkeyauthentication|kbdinteractiveauthentication) '
```

If `sshd -t` fails, do NOT reload. Fix the config first.

The service unit is named `ssh` on Debian/Ubuntu and `sshd` on RHEL/Fedora/Rocky/Alma. If `systemctl reload ssh` fails with "Unit ssh.service not found", try `systemctl reload sshd`.

## Step 2 — fail2ban

Install and configure with a minimal `jail.local` override (do not edit `jail.conf` — it gets replaced on upgrade):

```bash
# Debian/Ubuntu
DEBIAN_FRONTEND=noninteractive apt-get update -qq && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y fail2ban

# RHEL/Rocky/Alma (needs EPEL)
# dnf install -y epel-release && dnf install -y fail2ban
```

```bash
cat > /etc/fail2ban/jail.local <<'EOF'
[DEFAULT]
bantime  = 1h
findtime = 10m
maxretry = 5
backend  = systemd
ignoreip = 127.0.0.1/8 ::1

[sshd]
enabled = true
mode    = aggressive
port    = ssh
EOF

systemctl enable --now fail2ban
systemctl restart fail2ban
sleep 2
fail2ban-client status sshd
```

Backend choice:
- `backend = systemd` works on any distro using journald (modern Debian/Ubuntu/RHEL) and avoids logfile-parsing fragility. If the system uses rsyslog with classic `/var/log/auth.log` and no journald, switch to `backend = auto`.

`mode = aggressive` catches more patterns than failed passwords alone (including weird preauth disconnects from scanners). If the user reports legitimate clients getting banned, drop to `mode = normal`.

## Step 3 — optional escalations (ask before doing)

These are NOT default. Mention them as follow-ups and only apply if the user agrees:

1. **Escalating bans for repeat offenders** — add to `[DEFAULT]` in `jail.local`:
   ```
   bantime.increment = true
   bantime.maxtime   = 1w
   bantime.factor    = 2
   ```
2. **Move sshd off port 22** — eliminates ~99% of scanner noise but requires the user to update every client and any firewall/security-group rule. Add `Port 2222` to the hardening drop-in, open the new port in `ufw`/cloud firewall FIRST, reload sshd, then close 22.
3. **Disable root login entirely** (`PermitRootLogin no`) — only if a non-root sudo user exists and is confirmed working.
4. **UFW / nftables baseline** — if no host firewall is active, propose enabling `ufw` with `allow OpenSSH` and `default deny incoming`.

## Verification — what to report back

After the run, report:
- The effective sshd settings (output of `sshd -T | grep ...` above)
- `fail2ban-client status sshd` showing the jail is active
- A reminder that the user's existing SSH session is unaffected by the reload, but new sessions now require a key
- A note that they should keep this terminal open and open a fresh SSH session in another window to confirm key-only login works before disconnecting

## Common gotchas

- **Cloud images with cloud-init** sometimes ship `/etc/ssh/sshd_config.d/50-cloud-init.conf` that re-enables `PasswordAuthentication yes`. Drop-ins are read in lexical order, so `99-hardening.conf` overrides it — but verify with `sshd -T`, not by reading files.
- **Hetzner/DigitalOcean/etc. rescue consoles** are NOT SSH; they're VNC/serial. Key-auth doesn't apply there, so the user can always recover if they get locked out — mention this if they're nervous.
- **AllowUsers / AllowGroups** in existing config will silently block logins. If `sshd -T | grep -E '^(allowusers|allowgroups) '` returns anything, make sure the user's account is included.
- **SELinux** (RHEL family) may need `setsebool -P ssh_sysadm_login on` for some setups; uncommon but worth knowing if reload succeeds and login still fails.
