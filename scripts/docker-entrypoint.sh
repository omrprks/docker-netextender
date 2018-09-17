#! /usr/bin/env bash

[[ ! -f /.dockerenv ]] && echo "Not running in a docker container." && exit 1

[[ ! -e /dev/ppp ]] && sudo mknod /dev/ppp c 108 0

if [ ! -z "${VPN_PC}" ]; then
	echo "Forwarding 0.0.0.0:3389 to ${VPN_PC}:3389"
	sudo iptables -F
	sudo iptables -t nat -A PREROUTING -p tcp --dport 3389 -j DNAT --to-destination ${VPN_PC}:3389
	sudo iptables -t nat -A POSTROUTING -j MASQUERADE

	for iface in $(ip a | grep eth | grep inet | awk '{print $2}'); do
		sudo iptables -t nat -A POSTROUTING -s "$iface" -j MASQUERADE
	done
fi

# TODO(oparkes): Allow selectively inserting Username/Domain/Server.
# TODO(oparkes): Find a way to securely add password automagically? (Docker Secrets?)
if [ ! -z "${VPN_USERNAME}" ] && [ ! -z "${VPN_DOMAIN}" ] && [ ! -z "${VPN_SERVER}" ]; then
	exec netExtender -u ${VPN_USERNAME} -d ${VPN_DOMAIN} -s ${VPN_SERVER}
else
	exec netExtender
fi
