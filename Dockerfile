# FROM stevemcgrath/nessus_scanner

# # https://github.com/p42/s6-centos-docker/
# ARG S6_OVERLAY_VERSION=1.22.1.0
# ARG S6_OVERLAY_MD5HASH=3060e2fdd92741ce38928150c0c0346a

# RUN yum -y install wget vixie-cron crontabs && \
#     yum -y clean all && \
#     cd /tmp && \
#     wget https://github.com/just-containers/s6-overlay/releases/download/v$S6_OVERLAY_VERSION/s6-overlay-amd64.tar.gz && \
#     echo "$S6_OVERLAY_MD5HASH *s6-overlay-amd64.tar.gz" | md5sum -c - && \
#     tar xzf s6-overlay-amd64.tar.gz -C / && \
#     rm -f s6-overlay-amd64.tar.gz

ARG NESSUS_VERSION=10.4.2

FROM --platform=linux/arm64 lsiobase/ubuntu:focal as stage-arm64
ARG NESSUS_VERSION
ARG FILENAME=Nessus-$NESSUS_VERSION-ubuntu1804_aarch64.deb


FROM --platform=linux/amd64 lsiobase/ubuntu:focal as stage-amd64
ARG NESSUS_VERSION
ARG FILENAME=Nessus-$NESSUS_VERSION-ubuntu1404_amd64.deb


FROM stage-${TARGETARCH} as final
ARG FILENAME

RUN apt-get update && \
    apt-get dist-upgrade -y && \
    apt-get install -y --no-install-recommends cron expect && \
    curl -v --request GET \
        --url https://www.tenable.com/downloads/api/v2/pages/nessus/files/$FILENAME \
        --output $FILENAME && \
    dpkg -i ${FILENAME} && \
    rm ${FILENAME} && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# add local files
COPY root/ /

ENTRYPOINT ["/init"]

EXPOSE 8834