FROM ubuntu:24.04

ENV container=docker
ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /app

RUN apt update -y && \
    apt install -y wget tar htop net-tools curl && \
    apt autoclean && \
    apt autoremove -y && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Download install script and determine version
RUN wget -cq "https://brightdata.com/static/earnapp/install.sh" -O /app/setup.sh && \
    VERSION=$(grep VERSION= /app/setup.sh | cut -d'"' -f2) && \
    ARCH=$(dpkg --print-architecture) && \
    case "$ARCH" in \
      amd64)  BIN="earnapp-x64-$VERSION" ;; \
      arm64)  BIN="earnapp-arm64-$VERSION" ;; \
      *) echo "Unsupported architecture: $ARCH" && exit 1 ;; \
    esac && \
    mkdir /download && \
    wget -cq "https://cdn-earnapp.b-cdn.net/static/$BIN" -O /usr/bin/earnapp && \
    chmod +x /usr/bin/earnapp

# Fake some system utilities
RUN printf '#!/bin/bash\n echo "%s"' "$(lsb_release -a 2>/dev/null || true)" > /usr/bin/lsb_release && \
    printf '#!/bin/bash\n echo "%s"' "$(hostnamectl 2>/dev/null || true)" > /usr/bin/hostnamectl && \
    printf '#!/bin/bash\n echo "%s"' "$(systemctl 2>/dev/null || true)" > /usr/bin/systemctl && \
    chmod +x /usr/bin/hostnamectl /usr/bin/lsb_release /usr/bin/systemctl

COPY _start.sh /_start.sh
RUN chmod +x /_start.sh

VOLUME [ "/etc/earnapp" ]

CMD ["/_start.sh"]
