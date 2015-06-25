#/bin/bash

########################################
# Start By Flushing Any Current Tables
########################################
iptables -F
iptables -X
iptables -Z
iptables -t nat -F
iptables -t nat -X
iptables -t nat -Z
iptables -t mangle -F
iptables -t mangle -X
iptables -t mangle -Z


########################################
# Set Default Policies
########################################
iptables -P INPUT DROP
iptables -P FORWARD ACCEPT
iptables -P OUTPUT DROP


########################################
# Get Rid Of IPV6 If You're Not Using It
########################################
ip6tables -P INPUT DROP
ip6tables -P FORWARD DROP
ip6tables -P OUTPUT DROP


########################################
# Declare Chains
########################################
iptables -N SSH
iptables -N HTTP


########################################
# Allow Unlimited Access From Local Interface
########################################
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT


########################################
# Input Chain
########################################
# Accept established traffic and sort the rest
iptables -A INPUT -i eth+ -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -p tcp --dport 22 --match state --state NEW -j SSH
iptables -A INPUT -p tcp --dport 80 --match state --state NEW -j HTTP
iptables -A INPUT -p tcp --dport 443 --match state --state NEW -j HTTP


# SSH chain
iptables -A SSH -j ACCEPT


# HTTP chain
iptables -A HTTP -j ACCEPT

# Log anything that gets dropped
# iptables -A INPUT -j LOG --log-prefix "Input Chain Reject"


########################################
# Output chain
########################################
iptables -A OUTPUT -o eth+ -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -p icmp -m icmp --icmp-type echo-request -j ACCEPT

# List of ports that are allowed to go out
# See http://en.wikipedia.org/wiki/List_of_TCP_and_UDP_port_numbers
# Port 80, HTTP
# Port 465 SMTP Over SSL
# Port 995 POP3 Over SSL
# Port 25 SMTP
# Port 110 POP3
# Port 53 DNS
# Port 443 HTTPS
# Port 6667 IRC
# Port 67 DHCP (client)
# Port 5353 Multicast DNS
# Port 111 portmap
# Port 2049 nfs
# Port 4002 custom nfs port
# Port 123 network time
# Port 587 msmtp/gmail
# Port 9418 git://
iptables -A OUTPUT -p tcp --dport 80 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 8080 -j ACCEPT
#iptables -A OUTPUT -p tcp --dport 465 -j ACCEPT
#iptables -A OUTPUT -p tcp --dport 995 -j ACCEPT
#iptables -A OUTPUT -p tcp --dport 25 -j ACCEPT
#iptables -A OUTPUT -p tcp --dport 110 -j ACCEPT
iptables -A OUTPUT -p udp --dport 53 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 53 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 443 -j ACCEPT
#iptables -A OUTPUT -p tcp --dport 6667 -j ACCEPT
iptables -A OUTPUT -p udp --dport 67 -j ACCEPT
iptables -A OUTPUT -p udp --dport 5353 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 22 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 9418 -j ACCEPT
#iptables -A OUTPUT -p tcp --dport 587 -j ACCEPT
#iptables -A OUTPUT -p tcp --dport 111 -j ACCEPT
#iptables -A OUTPUT -p udp --dport 111 -j ACCEPT
#iptables -A OUTPUT -p tcp --dport 2049 -j ACCEPT
#iptables -A OUTPUT -p udp --dport 2049 -j ACCEPT
#iptables -A OUTPUT -p tcp --dport 4002 -j ACCEPT
#iptables -A OUTPUT -p udp --dport 4002 -j ACCEPT
iptables -A OUTPUT -p udp --dport 123 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 587 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 11371 -j ACCEPT

exit 0
