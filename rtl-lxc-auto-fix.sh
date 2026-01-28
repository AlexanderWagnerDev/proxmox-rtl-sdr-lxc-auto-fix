#!/bin/bash
# Auto RTL-SDR USB Passthrough Fixer for Proxmox LXC
# Automatically detects RTL2838 USB path changes and updates LXC config
# GitHub: YOUR_USERNAME/rtl-sdr-proxmox-auto-fix
# License: MIT

CTID=6056  # Change to your LXC container ID

# Clean lsusb parse to get bus/device (e.g. "001/042")
CURRENT_STICK=$(lsusb 2>/dev/null | grep "0bda:2838" | sed 's/.*Bus \([0-9]\+\) Device \([0-9]\+\):.*/\1\/\2/')

[ -z "$CURRENT_STICK" ] && { 
  echo "$(date): No RTL2838 stick found" 
  exit 0 
}

CONF_PATH="/etc/pve/lxc/${CTID}.conf"

# Extract current config path from LXC config
CURRENT_CONF_LINE=$(grep "lxc.mount.entry: /dev/bus/usb/" "$CONF_PATH" 2>/dev/null | head -1)
CURRENT_CONF=$(echo "$CURRENT_CONF_LINE" | sed -n 's|.*\/dev\/bus\/usb\/\([0-9]\+\/[0-9]\+\).*|\1|p')

echo "$(date): RTL-Stick=$CURRENT_STICK | Config=$CURRENT_CONF"

# Exit if paths match (no action needed)
if [[ "$CURRENT_STICK" == "$CURRENT_CONF" ]]; then
  echo "$(date): Path OK - no restart needed"
  exit 0
fi

echo "$(date): Path changed! Fixing $CURRENT_STICK"

# Remove old USB passthrough lines from config
sed -i '/lxc.cgroup2.devices.allow: c 189:.*/d' "$CONF_PATH"
sed -i '/lxc.mount.entry: \/dev\/bus\/usb\//d' "$CONF_PATH"

# Add new USB passthrough config
echo "lxc.cgroup2.devices.allow: c 189:* rwm" >> "$CONF_PATH"
NEW_PATH="/dev/bus/usb/$CURRENT_STICK"
echo "lxc.mount.entry: $NEW_PATH dev/bus/usb/$CURRENT_STICK none bind,optional,create=file" >> "$CONF_PATH"

# Set permissions (chmod 666) after udev settles
sleep 3
if [ -e "$NEW_PATH" ]; then
  chmod 666 "$NEW_PATH"
  echo "$(date): chmod 666 $NEW_PATH OK"
else
  echo "$(date): Waiting for $NEW_PATH (post container start)"
fi

# Restart container to apply new config
/usr/sbin/pct reboot "$CTID" &
echo "$(date): FIXED! Container $CTID restarted with new path $CURRENT_STICK"
