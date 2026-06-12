#!/usr/bin/env sh

# Routing
ip route add default via 10.20.30.1

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