Tunnel Manager v6 — Extended Description

Tunnel Manager v6 is a professional, interactive shell script for Linux that allows you to easily create, manage, and monitor IPv6 tunnels. It supports multiple tunnel types including 6to4, IPIP6, and GRE1, all presented in a user-friendly, color-coded terminal interface.

Features

Create and configure tunnels

6to4 tunnel with optional local and remote IPv4

IPIP6 tunnel (IPv6-over-IPv6)

GRE1 tunnel (IPv6-over-IPv6 GRE)

Networking & Firewall setup

Enable IPv4 & IPv6 forwarding

Automatic iptables NAT and forwarding rules

Set MTU for all tunnels

Monitor tunnels

Display status of all tunnels with IPv4 and IPv6 addresses

✔ Installed / ✖ Not Installed indicators

Remove tunnels easily with a single option

Fully interactive and color-coded terminal menu

Shows author info & YouTube reference

Requirements

Linux system with root privileges

iproute2 package installed (ip command)

Bash shell (≥ 4.0 recommended)

Installation

Clone the repository or download the script:

git clone https://github.com/YourUsername/tunnel-manager.git
cd tunnel-manager
chmod +x tunnel-manager-v6.sh

Usage

Run the script with root privileges:

sudo ./tunnel-manager-v6.sh


Use the interactive menu to create, configure, monitor, or delete tunnels.

Notes

Local and remote IPs for 6to4 tunnels are optional; if left empty, only the IPv6 address will be configured.

MTU is automatically set to 1400 for all tunnels.

Networking & Firewall option configures iptables rules for NAT and forwarding automatically.

If you want, I can also write a short, catchy GitHub README intro that immediately grabs attention and looks professional for viewers.

Do you want me to do that?
