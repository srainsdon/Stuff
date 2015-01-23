#!/bin/sh -
LIST=allowed-domains.txt

iptables-restore <<'END'
*filter
:INPUT DROP
:FORWARD DROP
:OUTPUT ACCEPT
-A INPUT -i lo -j ACCEPT
-A OUTPUT -o lo -j ACCEPT
-A INPUT -m conntrack --ctstate ESTABLISHED -j ACCEPT
COMMIT
END
while read entry; do
    case $entry in
        *[0-9])
        iptables -A OUTPUT -d $entry -j ACCEPT
        ;;

        *)
        dig $entry ANY | awk '/\tA\t/ {print $5}' \
            | xargs -iADDR iptables -A OUTPUT -d ADDR -j ACCEPT
        ;;
    esac
done < $LIST
iptables -A OUTPUT -j REJECT
