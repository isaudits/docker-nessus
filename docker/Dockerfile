FROM stevemcgrath/nessus_scanner

ENV UPDATE_ON_START=true

# https://github.com/p42/s6-centos-docker/
ARG S6_OVERLAY_VERSION=1.22.1.0
ARG S6_OVERLAY_MD5HASH=3060e2fdd92741ce38928150c0c0346a

# add local files
COPY ./root/ /

RUN yum -y install wget vixie-cron crontabs && \
    yum -y clean all && \
    cd /tmp && \
    wget https://github.com/just-containers/s6-overlay/releases/download/v$S6_OVERLAY_VERSION/s6-overlay-amd64.tar.gz && \
    echo "$S6_OVERLAY_MD5HASH *s6-overlay-amd64.tar.gz" | md5sum -c - && \
    tar xzf s6-overlay-amd64.tar.gz -C / && \
    rm -f s6-overlay-amd64.tar.gz && \
    sh /usr/local/sbin/fix-bins.sh

ENTRYPOINT ["/init"]

EXPOSE 8834