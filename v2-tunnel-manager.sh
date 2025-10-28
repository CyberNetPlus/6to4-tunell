#!/bin/bash
# ────────────────────────────────────────────────
# Tunnel Manager — Minimalist Graphic v8.0
# Author: Cyber Net Plus (Babak Khedri)
# YouTube: https://www.youtube.com/@Cyber_Net_Plus
# ────────────────────────────────────────────────

# Colors and Formatting (Minimalist Palette)
RST='\033[0m'       # Reset
RED='\033[0;31m'    # Red for errors/inactive
GRN='\033[0;32m'    # Green for success/active
YLW='\033[1;33m'    # Yellow for prompts/warnings
BLU='\033[0;34m'    # Blue for menu structure
CYN='\033[0;36m'    # Cyan for headers
WHT='\033[1;37m'    # Bold White for important text
BRED='\033[1;31m'   # Bold Red
BGRN='\033[1;32m'   # Bold Green
BCYN='\033[1;36m'   # Bold Cyan

# Defaults for tunnels
DEFAULT_6TO4_IPV6="fd00:154::2/64"
DEFAULT_LOCAL="fd00:154::2"
DEFAULT_REMOTE="fd00:154::1"
DEFAULT_IPIP_IPV4="192.168.140.2/30"
DEFAULT_GRE_IPV4="192.168.150.2/30"

# ────────────── تابع نمایش وضعیت تونل‌ها (Minimalist) ──────────────
function show_tunnel_status() {
    local TUN=$1
    local TUN_NAME=$2

    echo -e "${CYN}--- ${TUN_NAME} ---${RST}"
    
    if ip link show $TUN &>/dev/null; then
        echo -e "  ${BGRN}Status: ACTIVE ${RST}(Interface: ${WHT}$TUN${RST})"
        
        # IPv4
        local ipv4_addrs=$(ip addr show dev $TUN | grep inet | awk '{print $2}')
        if [[ -n "$ipv4_addrs" ]]; then
            echo -e "  ${YLW}IPv4 Addresses:${RST}"
            while IFS= read -r addr; do
                echo -e "    ${WHT}→ ${addr}${RST}"
            done <<< "$ipv4_addrs"
        else
            echo -e "  ${RED}No IPv4 Address Configured${RST}"
        fi

        # IPv6
        local ipv6_addrs=$(ip -6 addr show dev $TUN | grep inet6 | awk '{print $2}')
        if [[ -n "$ipv6_addrs" ]]; then
            echo -e "  ${YLW}IPv6 Addresses:${RST}"
            while IFS= read -r addr; do
                echo -e "    ${WHT}→ ${addr}${RST}"
            done <<< "$ipv6_addrs"
        else
            echo -e "  ${RED}No IPv6 Address Configured${RST}"
        fi

    else
        echo -e "  ${BRED}Status: INACTIVE ${RST}(Interface: ${WHT}$TUN${RST})"
    fi
    
    echo # Extra line for spacing
}

# ────────────── حلقه منو اصلی ──────────────
while true; do
    clear
    # وضعیت تونل‌ها
    STATUS_6TO4=$(ip link show 6to4 &>/dev/null && echo -e "${BGRN}ACTIVE${RST}" || echo -e "${BRED}INACTIVE${RST}")
    STATUS_IPIP=$(ip link show ipip6 &>/dev/null && echo -e "${BGRN}ACTIVE${RST}" || echo -e "${BRED}INACTIVE${RST}")
    STATUS_GRE=$(ip link show gre1 &>/dev/null && echo -e "${BGRN}ACTIVE${RST}" || echo -e "${BRED}INACTIVE${RST}")

    # ────────────── Header (Minimalist) ──────────────
    echo -e "${BCYN}======================================================${RST}"
    echo -e "${WHT}TUNNEL MANAGER v8.0 (Minimalist)${RST}"
    echo -e "${CYN}A Project by Cyber Net Plus${RST}"
    echo -e "${CYN}YouTube: https://www.youtube.com/@Cyber_Net_Plus${RST}"
    echo -e "${BCYN}======================================================${RST}"
    echo

    # ────────────── Menu ──────────────
    echo -e "${WHT}Select an option:${RST}"
    echo -e "${BLU}------------------------------------------------------${RST}"
    
    # Options
    echo -e " ${YLW}1)${RST} Create new 6to4 tunnel           [Status: ${STATUS_6TO4}]"
    echo -e " ${YLW}2)${RST} Setup IPIP6 Tunnel               [Status: ${STATUS_IPIP}]"
    echo -e " ${YLW}3)${RST} Setup GRE1 Tunnel                [Status: ${STATUS_GRE}]"
    echo -e "${BLU}------------------------------------------------------${RST}"
    echo -e " ${YLW}4)${RST} Setup Networking & Firewall"
    echo -e " ${YLW}5)${RST} Show all tunnels status"
    echo -e " ${YLW}6)${RST} Delete all existing tunnels"
    echo -e "${BLU}------------------------------------------------------${RST}"
    echo -e " ${BRED}7)${RST} Exit"
    echo -e "${BLU}------------------------------------------------------${RST}"
    echo

    read -rp "→ Enter your choice [1-7]: " choice
    echo

    case $choice in
        1)
            echo -e "${CYN}--- 6to4 Tunnel Configuration ---${RST}"
            read -rp "Enter Remote IPv4 (leave empty to skip): " REMOTE_IP
            read -rp "Enter Local IPv4 (leave empty to skip): " LOCAL_IP
            read -rp "Enter IPv6 Address with Prefix (default: $DEFAULT_6TO4_IPV6): " IPV6_ADDR
            IPV6_ADDR=${IPV6_ADDR:-$DEFAULT_6TO4_IPV6}

            echo -e "${YLW}[*] Creating 6to4 tunnel...${RST}"
            CMD="sudo ip tunnel add 6to4 mode sit"
            [[ -n "$REMOTE_IP" ]] && CMD="$CMD remote $REMOTE_IP"
            [[ -n "$LOCAL_IP" ]] && CMD="$CMD local $LOCAL_IP"
            
            if $CMD 2>/dev/null; then
                echo -e "${BGRN}[✔] Tunnel interface created.${RST}"
            else
                echo -e "${BRED}[✖] Tunnel may already exist! Attempting to continue...${RST}"
            fi

            if sudo ip -6 addr add "$IPV6_ADDR" dev 6to4 2>/dev/null; then
                echo -e "${BGRN}[✔] IPv6 address added: ${WHT}$IPV6_ADDR${RST}"
            else
                echo -e "${BRED}[✖] Failed to add IPv6 address. Check if the interface is up or if the address is already in use.${RST}"
            fi
            
            sudo ip link set 6to4 mtu 1400
            sudo ip link set 6to4 up
            echo -e "${BGRN}------------------------------------------------------${RST}"
            echo -e "${BGRN}[✔] 6to4 Tunnel configuration complete!${RST}"
            echo -e "${BGRN}------------------------------------------------------${RST}"
            read -rp "Press Enter to return to main menu..."
            ;;
        2)
            echo -e "${CYN}--- IPIP6 Tunnel Configuration ---${RST}"
            read -rp "Enter Local IPv6 (default: $DEFAULT_LOCAL): " LOCAL
            LOCAL=${LOCAL:-$DEFAULT_LOCAL}
            read -rp "Enter Remote IPv6 (default: $DEFAULT_REMOTE): " REMOTE
            REMOTE=${REMOTE:-$DEFAULT_REMOTE}
            read -rp "Enter IPv4 address for IPIP6 (default: $DEFAULT_IPIP_IPV4): " IPV4
            IPV4=${IPV4:-$DEFAULT_IPIP_IPV4}

            echo -e "${YLW}[*] Setting up IPIP6 Tunnel...${RST}"
            
            if sudo ip link add name ipip6 type ip6tnl local $LOCAL remote $REMOTE mode any 2>/dev/null; then
                echo -e "${BGRN}[✔] Tunnel interface created.${RST}"
            else
                echo -e "${BRED}[✖] Failed to create IPIP6 tunnel. It may already exist.${RST}"
            fi
            
            sleep 1
            if sudo ip addr add $IPV4 dev ipip6 2>/dev/null; then
                echo -e "${BGRN}[✔] IPv4 address added: ${WHT}$IPV4${RST}"
            else
                echo -e "${BRED}[✖] Failed to add IPv4 address. Check if the interface is up or if the address is already in use.${RST}"
            fi
            
            sudo ip link set ipip6 mtu 1400
            sudo ip link set ipip6 up
            echo -e "${BGRN}------------------------------------------------------${RST}"
            echo -e "${BGRN}[✔] IPIP6 Tunnel configuration complete!${RST}"
            echo -e "${BGRN}------------------------------------------------------${RST}"
            read -rp "Press Enter to return to main menu..."
            ;;
        3)
            echo -e "${CYN}--- GRE1 Tunnel Configuration ---${RST}"
            read -rp "Enter Local IPv6 (default: $DEFAULT_LOCAL): " LOCAL
            LOCAL=${LOCAL:-$DEFAULT_LOCAL}
            read -rp "Enter Remote IPv6 (default: $DEFAULT_REMOTE): " REMOTE
            REMOTE=${REMOTE:-$DEFAULT_REMOTE}
            read -rp "Enter IPv4 address for GRE1 (default: $DEFAULT_GRE_IPV4): " IPV4
            IPV4=${IPV4:-$DEFAULT_GRE_IPV4}

            echo -e "${YLW}[*] Setting up GRE1 Tunnel...${RST}"
            
            if sudo ip link add name gre1 type ip6gre local $LOCAL remote $REMOTE 2>/dev/null; then
                echo -e "${BGRN}[✔] Tunnel interface created.${RST}"
            else
                echo -e "${BRED}[✖] Failed to create GRE1 tunnel. It may already exist.${RST}"
            fi
            
            if sudo ip addr add $IPV4 dev gre1 2>/dev/null; then
                echo -e "${BGRN}[✔] IPv4 address added: ${WHT}$IPV4${RST}"
            else
                echo -e "${BRED}[✖] Failed to add IPv4 address. Check if the interface is up or if the address is already in use.${RST}"
            fi
            
            sudo ip link set gre1 mtu 1400
            sudo ip link set gre1 up
            echo -e "${BGRN}------------------------------------------------------${RST}"
            echo -e "${BGRN}[✔] GRE1 Tunnel configuration complete!${RST}"
            echo -e "${BGRN}------------------------------------------------------${RST}"
            read -rp "Press Enter to return to main menu..."
            ;;
        4)
            echo -e "${CYN}--- Networking & Firewall Setup ---${RST}"
            echo -e "${YLW}[*] Enabling IP forwarding...${RST}"
            
            # IP forwarding
            if ! grep -q "net.ipv4.ip_forward" /etc/sysctl.conf; then
                echo "net.ipv4.ip_forward = 1" | sudo tee -a /etc/sysctl.conf > /dev/null
                echo -e "${BGRN}  → net.ipv4.ip_forward set.${RST}"
            fi
            if ! grep -q "net.ipv6.conf.all.forwarding" /etc/sysctl.conf; then
                echo "net.ipv6.conf.all.forwarding = 1" | sudo tee -a /etc/sysctl.conf > /dev/null
                echo -e "${BGRN}  → net.ipv6.conf.all.forwarding set.${RST}"
            fi
            sudo sysctl -p > /dev/null
            echo -e "${BGRN}[✔] IP forwarding enabled.${RST}"

            echo -e "${YLW}[*] Configuring iptables (NAT/MASQUERADE)...${RST}"
            sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
            sudo iptables -A INPUT -i eth0 -m state --state ESTABLISHED,RELATED -j ACCEPT
            sudo iptables -A FORWARD -j ACCEPT
            echo -e "${BGRN}[✔] Basic firewall rules applied.${RST}"

            echo -e "${YLW}[*] Setting MTU for existing tunnels...${RST}"
            # MTU برای همه تونل‌ها
            for TUN in 6to4 ipip6 gre1; do
                if ip link show $TUN &>/dev/null; then
                    sudo ip link set $TUN mtu 1400
                    echo -e "${BGRN}  → MTU 1400 set for $TUN.${RST}"
                fi
            done
            echo -e "${BGRN}[✔] MTU settings updated.${RST}"
            
            echo -e "\n${WHT}--- Current iptables Rules ---${RST}"
            sudo iptables -L -v -n
            
            echo -e "\n${WHT}--- Current Routes ---${RST}"
            ip route show
            ip -6 route show

            echo -e "${BGRN}------------------------------------------------------${RST}"
            echo -e "${BGRN}[✔] Networking & Firewall setup completed!${RST}"
            echo -e "${BGRN}------------------------------------------------------${RST}"
            read -rp "Press Enter to return to main menu..."
            ;;
        5)
            echo -e "${CYN}--- All Tunnel Status ---${RST}"
            show_tunnel_status 6to4 "6to4 Tunnel"
            show_tunnel_status ipip6 "IPIP6 Tunnel"
            show_tunnel_status gre1 "GRE1 Tunnel"
            read -rp "Press Enter to return to main menu..."
            ;;
        6)
            echo -e "${CYN}--- Tunnel Removal ---${RST}"
            read -rp "WARNING: Are you sure you want to remove ALL tunnels? (y/N): " CONFIRM_DEL
            if [[ "$CONFIRM_DEL" =~ ^[Yy]$ ]]; then
                echo -e "${YLW}[*] Removing all tunnels...${RST}"
                for TUN in 6to4 ipip6 gre1; do
                    if ip link show $TUN &>/dev/null; then
                        sudo ip link set $TUN down 2>/dev/null
                        sudo ip tunnel del $TUN 2>/dev/null
                        sudo ip link del $TUN 2>/dev/null
                        echo -e "${BGRN}[✔] $TUN removed successfully.${RST}"
                    else
                        echo -e "${YLW}[-] $TUN not found, skipping.${RST}"
                    fi
                done
                echo -e "${BGRN}------------------------------------------------------${RST}"
                echo -e "${BGRN}[✔] All tunnels removed.${RST}"
                echo -e "${BGRN}------------------------------------------------------${RST}"
            else
                echo -e "${YLW}[-] Tunnel removal cancelled.${RST}"
            fi
            read -rp "Press Enter to return to main menu..."
            ;;
        7)
            echo -e "${BGRN}Thank you for using Tunnel Manager. Goodbye!${RST}"
            exit 0
            ;;
        *)
            echo -e "${BRED}Invalid option! Please select a number between 1 and 7.${RST}"
            sleep 2
            ;;
    esac
done
