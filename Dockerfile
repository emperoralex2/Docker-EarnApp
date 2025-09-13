FROM ubuntu:24.04

ENV container=docker
ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /app

RUN apt update -y && \
    apt install -y wget tar htop net-tools curl && \
	apt autoclean && \
	apt autoremove -y && \
	rm -rf /var/lib/apt/lists/* && \
	rm -rf /tmp/* && \
	rm -rf /var/tmp/*

RUN wget -cq "https://brightdata.com/static/earnapp/install.sh" --output-document=/app/setup.sh && \
    VERSION=$(grep VERSION= /app/setup.sh | cut -d'"' -f2) && \
    mkdir /download && \
    wget -cq "https://cdn-earnapp.b-cdn.net/static/earnapp-aarch64-$VERSION" --output-document=/usr/bin/earnapp && \ 
    echo | md5sum /usr/bin/earnapp && \
    chmod a+x /usr/bin/earnapp

# COPY custom.sh /custom.sh
# RUN bash /custom.sh

RUN printf '#!/bin/bash \n echo "%s"' "$(lsb_release -a)" > /usr/bin/lsb_release && \
    printf '#!/bin/bash \n echo "%s"' "$(hostnamectl)" > /usr/bin/hostnamectl && \
    printf '#!/bin/bash \n echo "%s"' "$(systemctl)" > /usr/bin/systemctl && \
    chmod a+x /usr/bin/install /usr/bin/hostnamectl /usr/bin/lsb_release /usr/bin/systemctl

COPY _start.sh /_start.sh
RUN chmod a+x /_start.sh

VOLUME [ "/etc/earnapp" ]

CMD ["/_start.sh"]
