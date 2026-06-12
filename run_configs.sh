#!/usr/bin/env sh

ip netns exec Router1 ./config_router1.sh
ip netns exec Router2 ./config_router2.sh
ip netns exec DMZ ./config_dmz.sh



./mwg.sh