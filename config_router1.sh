#!/usr/bin/env sh

#VARIABLES
ip_webserver=10.20.30.10
ip_dns=10.20.30.10
ip_vpn_endpoint=10.20.32.1

# Routing
# Enable
sysctl -w net.ipv4.ip_forward=1
## IPv6 ??


# NAT
# Enable
iptables -t nat -A POSTROUTING -o r1-wan -j MASQUERADE
## SNAT --to-source our.ip.add.res ??
# Forward Webserver
iptables -t nat -A PREROUTING -i r1-wan -p tcp     --dport 80 -j DNAT --to-destination $ip_webserver:80
# Forward DNS -- Actually dont
#iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 53 -j DNAT --to-destination $ip_dns:53
#iptables -t nat -A PREROUTING -i eth0 -p udp --dport 53 -j DNAT --to-destination $ip_dns:53
# Forward to VPN endpoint
iptables -t nat -A PREROUTING -i r1-wan -p tcp     --dport 51820 -j DNAT --to-destination $ip_vpn_endpoint:51820
iptables -t nat -A PREROUTING -i r1-wan -p udp     --dport 51820 -j DNAT --to-destination $ip_vpn_endpoint:51820

# Add routes to the subnets
ip route add 10.20.31.0/24  via 10.20.30.2
ip route add 10.20.32.0/24  via 10.20.30.2
ip route add default        via 203.0.113.1



# Firewall
iptables -P FORWARD ACCEPT # REMOVE BEFORE FIGHT