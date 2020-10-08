#!/bin/sh

# Usage:
#
# ./create-knocking-rules.sh 1111 3333 2222
#
# Three ports should NOT be duplicated or ordered.

EXPIRATION=$((3600 * 24 * 3))
BANNED_TIMEOUT=60
KNOCKING_TIMEOUT=10

LOG_PREFIX="[OPEN-PORT]"

PORT1=$1
PORT2=$2
PORT3=$3

ipset -exist create banned hash:ip timeout $BANNED_TIMEOUT
ipset -exist create gate1 hash:ip timeout $KNOCKING_TIMEOUT
ipset -exist create gate2 hash:ip timeout $KNOCKING_TIMEOUT
ipset -exist create passed hash:ip timeout $EXPIRATION

# Knocking rules

iptables -t nat -N knocking
# Append chain to `zone_wan_prerouting`: match ports and not in `passed` set
iptables -t nat -A zone_wan_prerouting -p tcp --syn -m multiport --dports $PORT1,$PORT2,$PORT3 -m set ! --match-set passed src -j knocking

# Append rules

# Extend ban duration if retried
iptables -t nat -A knocking -p tcp -m set --match-set banned src -j SET --add-set banned src --exist
iptables -t nat -A knocking -p tcp -m set --match-set banned src -j LOG --log-prefix "[banned]"
iptables -t nat -A knocking -p tcp -m set --match-set banned src -j RETURN

# Add retried ip to `banned` set
iptables -t nat -A knocking -p tcp --dport $PORT1 -m set --match-set gate1 src -j SET --add-set banned src --exist
iptables -t nat -A knocking -p tcp --dport $PORT1 -m set --match-set gate1 src -j LOG --log-prefix "[retry]"
iptables -t nat -A knocking -p tcp --dport $PORT1 -m set --match-set gate1 src -j RETURN

iptables -t nat -A knocking -p tcp -j LOG --log-prefix "[knocking]"

iptables -t nat -A knocking -p tcp --dport $PORT1 -j SET --add-set gate1 src

iptables -t nat -A knocking -p tcp --dport $PORT2 -m set --match-set gate1 src -j SET --add-set gate2 src

iptables -t nat -A knocking -p tcp --dport $PORT3 -m set --match-set gate2 src -j LOG --log-prefix $LOG_PREFIX
iptables -t nat -A knocking -p tcp --dport $PORT3 -m set --match-set gate2 src -j SET --add-set passed src
