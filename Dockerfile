FROM library/debian:stretch-slim
LABEL maintainer "Omar Parkes"

ARG NETEXTENDER_ARCH="x86_64"
ENV NETEXTENDER_URL "https://sslvpn.demo.sonicwall.com/NetExtender.${NETEXTENDER_ARCH}.tgz"

ENV DEBIAN_FRONTEND "noninteractive"

ARG UID="1100"
ENV UID ${UID}
ARG USERNAME="netextender"
ENV USERNAME ${USERNAME}

USER root

WORKDIR /tmp

RUN apt-get update && \
	apt-get install -y -q --no-install-recommends \
		ca-certificates file curl sudo \
		ppp ipppd iptables iproute2 net-tools kmod

RUN curl ${NETEXTENDER_URL} | tar xz && \
	cd netExtenderClient && \
		sed -i -e "s@read -p '  Set pppd to run as root.*@REPLY='Y'@g" install && \
		chmod +x ./install && \
		./install > /dev/null

RUN apt-get remove --purge -y file curl && apt-get autoremove -y && \
	rm -rf /var/lib/apt/lists/* /tmp/*

RUN useradd -u ${UID} -m -U ${USERNAME} && \
	echo "${USERNAME} ALL=(ALL) NOPASSWD: /sbin/iptables, /bin/mknod" >> /etc/sudoers

COPY scripts/docker-entrypoint.sh /
RUN chown ${USERNAME}:${USERNAME} /docker-entrypoint.sh && \
	chmod +x /docker-entrypoint.sh

USER ${USERNAME}

ENTRYPOINT "/docker-entrypoint.sh"
