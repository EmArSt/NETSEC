#!/usr/bin/env sh

#####################################################
#               Network Layout                      #
#####################################################
#                    DMZ                            #     
#                     |                             #
# INET----Router1----br0----Router2---br1           #
#                                      |            #
#                                      -----Client1 #
#___________________________________________________#
# wan        |       lan0      |        lan1        #
#####################################################

# VARIABLES
public_interface_name=enp1s0

cleanup() {
    ./clean.sh
}
trap cleanup EXIT INT TERM

ip netns add Router1
ip netns add Router2
ip netns add DMZ
ip netns add Client1

ip link add name br0 type bridge
ip link add name br1 type bridge
ip link set br0 up
ip link set br1 up

ip link add inet    type veth peer name r1-wan
ip link add r1-lan  type veth peer name br0-r1
ip link add dmz     type veth peer name br0-dmz
ip link add r2-lan0 type veth peer name br0-r2
ip link add r2-lan1 type veth peer name br1-r2
ip link add client  type veth peer name br1-client

# Move ends into namespaces
ip link set r1-wan  netns Router1
ip link set r1-lan  netns Router1
ip link set dmz     netns DMZ
ip link set r2-lan0 netns Router2
ip link set r2-lan1 netns Router2
ip link set client  netns Client1

# Plug bridge-side ends into bridges
ip link set br0-r1     master br0
ip link set br0-dmz    master br0
ip link set br0-r2     master br0
ip link set br1-r2     master br1
ip link set br1-client master br1

# Bring up host-side interfaces
ip link set inet       up
ip link set br0-r1     up
ip link set br0-dmz    up
ip link set br0-r2     up
ip link set br1-r2     up
ip link set br1-client up

# Bring up interfaces inside namespaces
ip netns exec Router1 ip link set lo      up
ip netns exec Router1 ip link set r1-wan  up
ip netns exec Router1 ip link set r1-lan  up

ip netns exec DMZ     ip link set lo      up
ip netns exec DMZ     ip link set dmz     up

ip netns exec Router2 ip link set lo      up
ip netns exec Router2 ip link set r2-lan0 up
ip netns exec Router2 ip link set r2-lan1 up

ip netns exec Client1 ip link set lo      up
ip netns exec Client1 ip link set client  up

#Assign addresses
ip addr add 203.0.113.1/30  dev inet

ip netns exec Router1 ip addr  add 203.0.113.2/30 dev r1-wan
ip netns exec Router1 ip addr  add 10.20.30.1/24  dev r1-lan


ip netns exec DMZ     ip addr  add 10.20.30.10/24 dev dmz


ip netns exec Router2 ip addr  add 10.20.30.2/24  dev r2-lan0
ip netns exec Router2 ip addr  add 10.20.31.1/24  dev r2-lan1

ip netns exec Client1 ip addr  add 10.20.31.10/24 dev client
ip netns exec Client1 ip route add default via 10.20.31.1

# Setup DNS for some Network NS'
for i in Client1 DMZ;
do
    mkdir -p /etc/netns/$i
    cat > /etc/netns/$i/resolv.conf << 'EOF'
nameserver 10.20.30.10
EOF
done


# Enable IP forwarding in the host
sysctl -w net.ipv4.ip_forward=1
iptables -t nat -A POSTROUTING -o $public_interface_name -j MASQUERADE
# Allow forwarding between inet and $public_interface_name
iptables -A FORWARD -i inet -o $public_interface_name -j ACCEPT
iptables -A FORWARD -i $public_interface_name -o inet -m state --state RELATED,ESTABLISHED -j ACCEPT

#configure individual components
./run_configs.sh

echo "Done."
# Prevent trap from firing on clean exit
trap - EXIT