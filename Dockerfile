FROM ubuntu:20.04
LABEL maintainer="xrsec"
LABEL mail="Jalapeno1868@outlook.com"
LABEL Github="https://github.com/XRSec/AWVS-Update"
LABEL org.opencontainers.image.source="https://github.com/XRSec/AWVS-Update"
LABEL org.opencontainers.image.title="AWVS-Update"
ENV TZ Asia/Shanghai

COPY . /awvs

# init
#RUN cp /etc/apt/sources.list /etc/apt/sources.list.bak \
#    && sed -i "s/archive.ubuntu/mirrors.aliyun/g" /etc/apt/sources.list \
#    && sed -i "s/ports.ubuntu/mirrors.aliyun/g" /etc/apt/sources.list \
#    && sed -i "s/security.ubuntu/mirrors.aliyun/g" /etc/apt/sources.list \
#    && apt update -y

# INIT
RUN apt-get -qq update \
    && apt-get -qq upgrade \
    && ln -sf "/usr/share/zoneinfo/${TZ}" /etc/localtime \
    && echo "${TZ}" > /etc/timezone \
    && ln -sf "$(which bash)" "$(which sh)" \
    && apt-get -qq install \
        libxdamage1 \
        libgtk-3-0 \
        libasound2 \
        libnss3 \
        libxss1 \
        libgbm-dev \
        sudo \
        bzip2 \
        fonts-droid-fallback \
        ttf-wqy-zenhei \
        ttf-wqy-microhei \
        fonts-arphic-ukai \
        fonts-arphic-uming \
        language-pack-zh-hans \
        libx11-xcb-dev \
        libxshmfence1 \
        net-tools \
        curl \
        unzip

# init_install
# split -b 50m x64.sh
RUN cat /awvs/acunetix/AWVS_INSTALLATION_PACKAGE/xa* > /awvs/acunetix/AWVS_INSTALLATION_PACKAGE/awvs_x86.sh \
    && chmod +x /awvs/acunetix/AWVS_INSTALLATION_PACKAGE/awvs_x86.sh \
    && sed -i "s/read -r dummy/#read -r dummy/g" /awvs/acunetix/AWVS_INSTALLATION_PACKAGE/awvs_x86.sh \
    && sed -i "s/pager=\"more\"/pager=\"cat\"/g" /awvs/acunetix/AWVS_INSTALLATION_PACKAGE/awvs_x86.sh \
    && sed -i "s/read -r ans/ans=yes/g" /awvs/acunetix/AWVS_INSTALLATION_PACKAGE/awvs_x86.sh \
    && sed -i "s/read -p \"    Hostname \[\$host_name\]:\" hn/hn=awvs.lan/g" /awvs/acunetix/AWVS_INSTALLATION_PACKAGE/awvs_x86.sh \
    && sed -i "s/host_name=\$(hostname)/host_name=awvs.lan/g" /awvs/acunetix/AWVS_INSTALLATION_PACKAGE/awvs_x86.sh \
    && sed -i "s/read -p '    Email: ' master_user/master_user='awvs@awvs.lan'/g" /awvs/acunetix/AWVS_INSTALLATION_PACKAGE/awvs_x86.sh \
    && sed -i "s/read -sp '    Password: ' master_password/master_password='Awvs@awvs.lan'/g" /awvs/acunetix/AWVS_INSTALLATION_PACKAGE/awvs_x86.sh \
    && sed -i "s/read -sp '    Password again: ' master_password2/master_password2='Awvs@awvs.lan'/g" /awvs/acunetix/AWVS_INSTALLATION_PACKAGE/awvs_x86.sh \
    && sed -i "s/systemctl/echo/g"  /awvs/acunetix/AWVS_INSTALLATION_PACKAGE/awvs_x86.sh \
    # && sed -i "s/uname -a | grep --quiet x86_64/uname -a | grep --quiet aarch64/g"  /awvs/acunetix/AWVS_INSTALLATION_PACKAGE/awvs_x86.sh \ # TODO ARM64
    && /bin/bash /awvs/acunetix/AWVS_INSTALLATION_PACKAGE/awvs_x86.sh \
    && mv /awvs/acunetix/CERTS/ca.key /home/acunetix/.acunetix/data/certs/ \
    && mv /awvs/acunetix/CERTS/ca.cer /home/acunetix/.acunetix/data/certs/ \
    && mv /awvs/acunetix/CERTS/server.key /home/acunetix/.acunetix/data/certs/ \
    && mv /awvs/acunetix/CERTS/server.cer /home/acunetix/.acunetix/data/certs/ \
    && cp /awvs/awvs.sh /awvs.sh \
    && cp /awvs/acunetix/README/LAST_VERSION /LAST_VERSION \
    && rm -rf /awvs \
    && mkdir /awvs \
    && echo "" > /awvs/.hosts \
    && mv /awvs.sh /awvs/awvs.sh \
    && mv /LAST_VERSION /awvs/LAST_VERSION \
    && chmod 777 /awvs/awvs.sh \
    && apt-get -qq autoremove \
    && apt-get -qq clean \
    && rm -rf /var/lib/apt/lists/*

EXPOSE 3443
ENV TZ='Asia/Shanghai'
ENV LANG 'zh_CN.UTF-8'
STOPSIGNAL SIGQUIT

CMD ["/awvs/awvs.sh"]
