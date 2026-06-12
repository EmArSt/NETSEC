#!/usr/bin/env sh

ip link delete dev wg1 2>/dev/null

tee /etc/wireguard/wg1.conf 1>/dev/null << EOF
[Interface]
Address = 10.20.32.50/24
PrivateKey = $(cat ./wg_keys/client1.key)
DNS = 10.20.30.10


[Peer]
PublicKey = $(cat ./wg_keys/router.pub)
Endpoint = 203.0.113.2:51820
AllowedIPs = 10.20.0.0/16

PersistentKeepalive = 25
EOF

wg-quick up wg1
wg show
ip netns exec Router2 wg show