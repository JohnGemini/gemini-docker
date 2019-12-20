FROM ubuntu:14.04

ARG TZ=Asia/Taipei

COPY apache_exporter /usr/bin/
COPY post_script.sh requirements.txt apache-supervisord.conf beat-supervisord.conf docker-entrypoint.sh /
COPY installs /installs

RUN export DEBIAN_FRONTEND=noninteractive && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone && \
    rm /bin/sh && ln -s /bin/bash /bin/sh && \
    apt-get update && \
    apt-get upgrade -y && \
    for apt in /installs/*;do bash "$apt";done && \
    apt-get clean && \
    pip install -r /requirements.txt && \
    pip install -U setuptools && \
    pip install ipython ipdb && \
    bash /post_script.sh && \
    rm -rf /root/.cache/* /tmp/* /var/tmp/* /var/lib/apt/lists/*

WORKDIR /usr/share/gocloud

USER www-data

ENTRYPOINT ["/docker-entrypoint.sh"]
