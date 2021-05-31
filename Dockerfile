FROM ubi8
USER root

ENV \
    APP_ROOT=/opt/app-root \
    HOME=/opt/app-root/src \
    PATH=/opt/app-root/src/bin:/opt/app-root/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    PLATFORM="el8"

RUN dnf update -y && dnf clean all -y
RUN dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm && dnf clean all -y
RUN dnf install -y procps which hostname sshpass siege jq python3-pip  && dnf clean all -y

RUN mkdir -p ${APP_ROOT} && \
    chown -R 1001:1001 ${APP_ROOT} && \
    chgrp -R 0 ${APP_ROOT} && \
    chmod -R g=u ${APP_ROOT}

RUN useradd -u 1001 -r -g 0 -d ${HOME} -s /sbin/nologin \
    -c "Default Application User" default && \
    chown -R 1001:0 ${APP_ROOT}

RUN pip3 install --upgrade pip
RUN pip3 install ansible

RUN apt-get update && apt-get install -y --no-install-recommends \
        g++ \
        ca-certificates \
        wget && \
    rm -rf /var/lib/apt/lists/*

RUN wget -nv -O - https://mirror.openshift.com/pub/openshift-v4/clients/ocp/stable/openshift-client-linux.tar.gz \
    | tar -C /usr/local/bin -xz

USER 1001
