#!/usr/bin/env sh

ip netns exec Router1 ./config_router1.sh
ip netns exec Router2 ./config_router2.sh
ip netns exec DMZ ./config_dmz.sh
ip netns exec Client1 ./config_client1.sh
ip netns exec Backup ./config_backup.sh



./mwg.sh