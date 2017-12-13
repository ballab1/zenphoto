FROM alpine:3.6

ARG TZ=America/New_York
ARG www_user=www-data
ARG www_group=www-data
ARG www_uid=82
ARG www_gid=82


ENV VERSION=1.0.0

ENV CORE_PKGS="bash curl findutils libgd libxml2 mysql-client nginx openssh-client shadow sudo supervisor ttf-dejavu tzdata unzip util-linux zlib" \
    PHP_PKGS="php5-fpm php5-ctype php5-cgi php5-common php5-dom php5-iconv php5-gd php5-imap php5-json php5-ldap php5-mysql php5-pgsql php5-pdo php5-pdo_dblib php5-pdo_mysql php5-pdo_pgsql php5-pdo_sqlite php5-posix php5-sockets php5-sqlite3 php5-xml php5-xmlreader php5-xmlrpc php5-zip" \
    ZEN_PKGS="fcgiwrap freetype gd jpeg libjpeg libpng openssl rsync" 
    
LABEL version=$VERSION

# Add configuration and customizations
COPY docker-entrypoint.sh /usr/local/bin/
COPY build /tmp/


# Download tarball, verify it using gpg and extract
# Install dependencies
# If you bind mount a volume from the host or a data container, 
# ensure you use the same uid
RUN set -o xtrace \
    \
    && chmod u+rwx /usr/local/bin/docker-entrypoint.sh \
    && ln -s /usr/local/bin/docker-entrypoint.sh /docker-entrypoint.sh \
    \
    && apk update \
    && apk add --no-cache $CORE_PKGS $PHP_PKGS $ZEN_PKGS \
    \
    && echo "$TZ" > /etc/TZ \
    && cp /usr/share/zoneinfo/$TZ /etc/timezone \
    && cp /usr/share/zoneinfo/$TZ /etc/localtime \
    \
    && chmod u+rwx /tmp/build_zen.sh \
    && /tmp/build_zen.sh \
    && rm -rf /tmp/* 



#USER $zen_user
#WORKDIR $ZEN_HOME\

ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD ["zen"]
