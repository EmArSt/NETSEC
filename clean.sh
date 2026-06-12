#!/usr/bin/env sh
# Setup DNS for some Network NS'
for i in Router1 Router2 DMZ Client1;
do
    ip netns pids $i | xargs kill 2> /dev/null
    ip netns del $i 2>/dev/null
done

ip link del br0      2>/dev/null
ip link del br1      2>/dev/null
ip link del inet     2>/dev/null
ip link del wg1      2>/dev/null

#!!!!!!!! Very dangorous !!!!!!!
rm -r /etc/netns #             !
#!!!!!!!! Comment out !!!!!!!!!!

echo "Cleaned up."