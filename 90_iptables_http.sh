#!/bin/sh

iptables -I INPUT -p tcp --dport 80 -j ACCEPT
service iptables save
