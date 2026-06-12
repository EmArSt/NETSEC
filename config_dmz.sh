#!/usr/bin/env sh

# Routing
ip route add default via 10.20.30.1
ip route add 10.20.31.0/24 via 10.20.30.2
ip route add 10.20.32.0/24 via 10.20.30.2
ip route add 10.20.33.0/24 via 10.20.30.2


# DNS
tee /etc/dnsmasq.conf 1>/dev/null << 'EOF'
interface=dmz
bind-interfaces

domain=srv.local
local=/srv.local/

address=/srv.local/10.20.30.10

server=8.8.8.8
server=1.1.1.1
EOF

dnsmasq --conf-file=/etc/dnsmasq.conf --no-daemon &


# Nginx
nginx &