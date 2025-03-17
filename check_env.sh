#!/bin/bash
# filepath: /home/hpe/get_system_info.sh
# This script outputs Linux system information in markdown format

# Get Hardware Information

# CPU info
CPU=$(lscpu | grep 'Model name' | awk -F':' '{print $2}' | sed 's/^[ \t]*//')
CPU=${CPU:-N/A}

# Memory info
Memory=$(free -h | awk '/^Mem:/{print $2}')
Memory=${Memory:-N/A}

# Disk info (list sizes of all disk devices)
Disk=$(lsblk -d -o NAME,SIZE | grep -v "NAME" | awk '{print $2}' | paste -sd ", " -)
Disk=${Disk:-N/A}

# NIC info (non-loopback network interfaces)
NIC=$(ip -o link show | awk -F': ' '{print $2}' | grep -v "^lo$" | paste -sd ", " -)
NIC=${NIC:-N/A}

# Server Model from dmidecode (may require sudo)
ServerModel=$(sudo dmidecode -s system-product-name 2>/dev/null)
ServerModel=${ServerModel:-N/A}

# Get Software Information

# OS info
if [ -f /etc/os-release ]; then
  OS=$(grep '^PRETTY_NAME=' /etc/os-release | cut -d= -f2 | tr -d '"')
else
  OS="N/A"
fi

# Kernel version
Kernel=$(uname -r)
Kernel=${Kernel:-N/A}

# Check if DPDK is installed (using dpdk-devbind if exists)
if command -v dpdk-devbind >/dev/null 2>&1; then
  DPDK="Installed"
else
  DPDK="Not installed"
fi

# Check if LinuxPTP is installed (using ptp4l if exists)
if command -v ptp4l >/dev/null 2>&1; then
  LinuxPTP="Installed"
else
  LinuxPTP="Not installed"
fi

# Get gNB Branch and Tag from git if in a git repository
read -p "Please enter the path to your git repository: " git_path
if [ -d "$git_path/.git" ]; then
    gNBBranch=$(cd "$git_path" && git symbolic-ref --short -q HEAD 2>/dev/null)
    gNBBranch=${gNBBranch:-"develop"}
    # Try to get the tag if the current commit is tagged
    gNBTag=$(cd "$git_path" && git describe --tags --exact-match 2>/dev/null)
    gNBTag=${gNBTag:-"N/A"}
else
    gNBBranch="N/A"
    gNBTag="N/A"
fi

# Output in Markdown format

echo "### gNB"
echo ""
echo "**Hardware:**"
echo ""
echo "| Item | Info |"
echo "| --- | --- |"
echo "| CPU | ${CPU} |"
echo "| Memory | ${Memory} |"
echo "| Disk | ${Disk} |"
echo "| NIC | ${NIC} |"
echo "| Server Model | ${ServerModel} |"
echo ""
echo "**Software:**"
echo ""
echo "| **Item** | **Info** |"
echo "| --- | --- |"
echo "| OS | ${OS} |"
echo "| Kernel | ${Kernel} |"
echo "| DPDK | ${DPDK} |"
echo "| LinuxPTP | ${LinuxPTP} |"
echo "| gNB Branch | ${gNBBranch} |"
echo "| gNB Tag | ${gNBTag} |"