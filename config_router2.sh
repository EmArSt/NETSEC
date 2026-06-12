#!/usr/bin/env sh

# Routing
sysctl -w net.ipv4.ip_forward=1
ip route add default        via 10.20.30.1

# Web-Proxy
tee /etc/squid/squid.conf 1>/dev/null << 'EOF'
http_port 3128 intercept
http_port 3129

acl localnet src 10.20.31.0/24

http_access allow localnet
http_access deny all

cache_mem 256 MB
dns_nameservers 10.20.30.10
EOF

iptables -t nat -A PREROUTING -i r2-lan1 -p tcp --dport 80 -j REDIRECT --to-port 3128
squid

# Wireguard
# Gen Keys for router
wg genkey | tee ./wg_keys/router.key | wg pubkey > ./wg_keys/router.pub
wg genkey | tee ./wg_keys/client1.key | wg pubkey > ./wg_keys/client1.pub

tee /etc/wireguard/wg0.conf 1>/dev/null << EOF
[Interface]
Address = 10.20.32.1/24
ListenPort = 51820
PrivateKey = $(cat ./wg_keys/router.key)

[Peer]
PublicKey = $(cat ./wg_keys/client1.pub)
AllowedIPs = 10.20.32.50/32
EOF

wg-quick up wg0

# Firewall
iptables -P FORWARD ACCEPT # REMOVE BEFORE FLIGHT