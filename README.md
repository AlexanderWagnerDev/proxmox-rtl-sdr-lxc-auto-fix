# Proxmox RTL-SDR LXC Auto-Fix

Automatically detects and fixes RTL2838 USB device path changes in Proxmox LXC containers. This script solves the common issue where RTL-SDR USB dongles receive new device paths after host reboots, breaking USB passthrough to LXC containers.

## Problem

When using RTL-SDR USB dongles (RTL2838) with Proxmox LXC containers, the USB device path (`/dev/bus/usb/XXX/YYY`) changes after each host reboot. This causes the LXC container to lose access to the USB device because the hardcoded path in the container configuration becomes invalid.

## Solution

This bash script automatically:
- Detects the current RTL2838 USB device path
- Compares it with the configured path in the LXC configuration
- Updates the LXC configuration file when paths don't match
- Sets proper permissions (chmod 666) on the USB device
- Restarts the LXC container to apply changes

## Features

- Automatic detection of RTL2838 USB devices (VID: 0bda, PID: 2838)
- Safe config updates with cleanup of old entries
- Detailed logging with timestamps
- No action taken when paths are already correct
- Handles missing devices gracefully

## Installation

### 1. Download and Install the Script

```bash
wget https://raw.githubusercontent.com/AlexanderWagnerDev/proxmox-rtl-sdr-lxc-auto-fix/main/rtl-lxc-auto-fix.sh -O /usr/local/bin/rtl_auto_fix.sh
chmod +x /usr/local/bin/rtl_auto_fix.sh
```

### 2. Configure Container ID

Edit the script and set your LXC container ID:

```bash
nano /usr/local/bin/rtl_auto_fix.sh
```

Change line 6:
```bash
CTID=6056  # Change to your LXC container ID
```

### 3. Set Up Cronjob

Add a cronjob to run the script every 5 minutes:

```bash
crontab -e
```

Add this line:
```bash
*/5 * * * * /usr/local/bin/rtl_auto_fix.sh >> /var/log/rtl-lxc-auto-fix.log 2>&1
```

This will:
- Run the script every 5 minutes
- Log output to `/var/log/rtl-lxc-auto-fix.log`

### 4. Manual Execution

You can also run the script manually:

```bash
/usr/local/bin/rtl_auto_fix.sh
```

## Requirements

- Proxmox VE host
- RTL-SDR USB dongle (RTL2838 chipset)
- LXC container (not VM)
- Root access on Proxmox host

## How It Works

1. The script uses `lsusb` to detect the current RTL2838 USB device path
2. Reads the LXC container configuration from `/etc/pve/lxc/{CTID}.conf`
3. Compares the detected path with the configured path
4. If paths differ:
   - Removes old USB passthrough configuration lines
   - Adds new configuration with current device path
   - Sets proper permissions on the USB device
   - Reboots the container to apply changes

## Configuration Format

The script manages these configuration lines in your LXC config:

```
lxc.cgroup2.devices.allow: c 189:* rwm
lxc.mount.entry: /dev/bus/usb/001/042 dev/bus/usb/001/042 none bind,optional,create=file
```

## Logging

View the log file:

```bash
# View full log
cat /var/log/rtl-lxc-auto-fix.log

# Follow log in real-time
tail -f /var/log/rtl-lxc-auto-fix.log

# View last 20 lines
tail -n 20 /var/log/rtl-lxc-auto-fix.log
```

## Troubleshooting

### Script reports "No RTL2838 stick found"
- Verify the USB dongle is connected: `lsusb | grep 0bda:2838`
- Check if the device is recognized by the host

### Container doesn't receive updates
- Verify the CTID matches your container ID
- Check if the config file path exists: `/etc/pve/lxc/{CTID}.conf`
- Ensure the cronjob runs with root privileges (use `crontab -e` as root)

### Permissions issues
- The script automatically sets `chmod 666` on the USB device
- If issues persist, check udev rules on the host

### Cronjob not running
- Check cron service: `systemctl status cron`
- Verify cronjob is installed: `crontab -l`
- Check for cron errors: `grep CRON /var/log/syslog`

## License

MIT License - See [LICENSE](LICENSE) file for details

## Contributing

Contributions are welcome! Please feel free to submit pull requests or open issues.

## Author

Alexander Wagner ([@AlexanderWagnerDev](https://github.com/AlexanderWagnerDev))

---

# Proxmox RTL-SDR LXC Auto-Fix (Deutsch)

Erkennt und behebt automatisch RTL2838 USB-Gerätepfad-Änderungen in Proxmox LXC-Containern. Dieses Script löst das häufige Problem, dass RTL-SDR USB-Dongles nach Host-Neustarts neue Gerätepfade erhalten, wodurch die USB-Durchreichung zum LXC-Container nicht mehr funktioniert.

## Problem

Bei der Verwendung von RTL-SDR USB-Dongles (RTL2838) mit Proxmox LXC-Containern ändert sich der USB-Gerätepfad (`/dev/bus/usb/XXX/YYY`) nach jedem Host-Neustart. Dies führt dazu, dass der LXC-Container den Zugriff auf das USB-Gerät verliert, da der fest codierte Pfad in der Container-Konfiguration ungültig wird.

## Lösung

Dieses Bash-Script führt automatisch folgende Schritte aus:
- Erkennung des aktuellen RTL2838 USB-Gerätepfads
- Vergleich mit dem konfigurierten Pfad in der LXC-Konfiguration
- Aktualisierung der LXC-Konfigurationsdatei bei abweichenden Pfaden
- Setzt korrekte Berechtigungen (chmod 666) auf das USB-Gerät
- Startet den LXC-Container neu, um Änderungen anzuwenden

## Features

- Automatische Erkennung von RTL2838 USB-Geräten (VID: 0bda, PID: 2838)
- Sichere Config-Updates mit Bereinigung alter Einträge
- Detailliertes Logging mit Zeitstempeln
- Keine Aktion bei bereits korrekten Pfaden
- Graceful Handling bei fehlenden Geräten

## Installation

### 1. Script herunterladen und installieren

```bash
wget https://raw.githubusercontent.com/AlexanderWagnerDev/proxmox-rtl-sdr-lxc-auto-fix/main/rtl-lxc-auto-fix.sh -O /usr/local/bin/rtl_auto_fix.sh
chmod +x /usr/local/bin/rtl_auto_fix.sh
```

### 2. Container-ID konfigurieren

Script bearbeiten und eigene LXC Container-ID eintragen:

```bash
nano /usr/local/bin/rtl_auto_fix.sh
```

Zeile 6 ändern:
```bash
CTID=6056  # Auf eigene LXC Container-ID ändern
```

### 3. Cronjob einrichten

Cronjob hinzufügen für Ausführung alle 5 Minuten:

```bash
crontab -e
```

Diese Zeile hinzufügen:
```bash
*/5 * * * * /usr/local/bin/rtl_auto_fix.sh >> /var/log/rtl-lxc-auto-fix.log 2>&1
```

Dies führt zu:
- Ausführung des Scripts alle 5 Minuten
- Logging in `/var/log/rtl-lxc-auto-fix.log`

### 4. Manuelle Ausführung

Das Script kann auch manuell ausgeführt werden:

```bash
/usr/local/bin/rtl_auto_fix.sh
```

## Voraussetzungen

- Proxmox VE Host
- RTL-SDR USB-Dongle (RTL2838 Chipset)
- LXC-Container (keine VM)
- Root-Zugriff auf Proxmox-Host

## Funktionsweise

1. Das Script nutzt `lsusb` zur Erkennung des aktuellen RTL2838 USB-Gerätepfads
2. Liest die LXC-Container-Konfiguration aus `/etc/pve/lxc/{CTID}.conf`
3. Vergleicht den erkannten Pfad mit dem konfigurierten Pfad
4. Bei abweichenden Pfaden:
   - Entfernung alter USB-Passthrough-Konfigurationszeilen
   - Hinzufügen neuer Konfiguration mit aktuellem Gerätepfad
   - Setzt korrekte Berechtigungen auf das USB-Gerät
   - Neustart des Containers zur Anwendung der Änderungen

## Konfigurationsformat

Das Script verwaltet diese Konfigurationszeilen in der LXC-Config:

```
lxc.cgroup2.devices.allow: c 189:* rwm
lxc.mount.entry: /dev/bus/usb/001/042 dev/bus/usb/001/042 none bind,optional,create=file
```

## Logging

Log-Datei anzeigen:

```bash
# Gesamtes Log anzeigen
cat /var/log/rtl-lxc-auto-fix.log

# Log in Echtzeit verfolgen
tail -f /var/log/rtl-lxc-auto-fix.log

# Letzte 20 Zeilen anzeigen
tail -n 20 /var/log/rtl-lxc-auto-fix.log
```

## Fehlerbehebung

### Script meldet "No RTL2838 stick found"
- USB-Dongle Verbindung prüfen: `lsusb | grep 0bda:2838`
- Prüfen ob das Gerät vom Host erkannt wird

### Container erhält keine Updates
- CTID mit eigener Container-ID abgleichen
- Config-Dateipfad prüfen: `/etc/pve/lxc/{CTID}.conf`
- Sicherstellen dass der Cronjob mit Root-Rechten läuft (als root `crontab -e` verwenden)

### Berechtigungsprobleme
- Das Script setzt automatisch `chmod 666` auf das USB-Gerät
- Bei anhaltenden Problemen udev-Regeln auf dem Host prüfen

### Cronjob läuft nicht
- Cron-Service prüfen: `systemctl status cron`
- Cronjob-Installation verifizieren: `crontab -l`
- Nach Cron-Fehlern suchen: `grep CRON /var/log/syslog`

## Lizenz

MIT License - Details in der [LICENSE](LICENSE) Datei

## Beiträge

Beiträge sind willkommen! Pull Requests und Issues können gerne eingereicht werden.

## Autor

Alexander Wagner ([@AlexanderWagnerDev](https://github.com/AlexanderWagnerDev))
