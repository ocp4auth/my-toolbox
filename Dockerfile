FROM ubi8
USER root

ENV \
    APP_ROOT=/opt/app-root \
    HOME=/opt/app-root/src \
    PATH=/opt/app-root/src/bin:/opt/app-root/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    PLATFORM="el8"

RUN { \
        echo '[mongodb-org-4.2]'; \
        echo 'name = MongoDBRepository'; \
        echo 'baseurl = https://repo.mongodb.org/yum/redhat/$releasever/mongodb-org/4.2/x86_64/'; \
        echo 'gpgcheck = 1'; \
        echo 'enabled = 1'; \
        echo 'gpgkey = https://www.mongodb.org/static/pgp/server-4.2.asc'; \
    } > /etc/yum.repos.d/mongodb-org-4.2.repo

RUN dnf update -y && dnf clean all -y
RUN dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm && dnf clean all -y
RUN dnf install -y procps which hostname sshpass siege jq python3-pip wget git sudo mongodb-org && dnf clean all -y

RUN wget -nv -O - https://mirror.openshift.com/pub/openshift-v4/clients/ocp/stable/openshift-client-linux.tar.gz \
    | tar -C /usr/local/bin -xz

RUN curl -sS -L https://mirror.openshift.com/pub/openshift-v4/clients/odo/latest/odo-linux-amd64 -o /usr/local/bin/odo
RUN chmod +x /usr/local/bin/odo

RUN mkdir -p ${APP_ROOT} && \
    chown -R 1001:1001 ${APP_ROOT} && \
    chgrp -R 0 ${APP_ROOT} && \
    chmod -R g=u ${APP_ROOT}

RUN useradd -u 1001 -r -g 0 -d ${HOME} -s /sbin/nologin \
    -c "Default Application User" default && \
    chown -R 1001:0 ${APP_ROOT}

RUN groupadd -g 1000 developer && \
    useradd  -g      developer -m -s /bin/bash devuser && \
    echo 'devuser:2wsx!cde8' | chpasswd

RUN echo 'Defaults visiblepw'             >> /etc/sudoers
RUN echo 'devuser ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers



RUN pip3 install --upgrade pip
RUN pip3 install ansible

#USER 1001
USER devuser
