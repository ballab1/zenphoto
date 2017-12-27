FROM alpine:3.6

<<<<<<< HEAD
=======
<<<<<<< HEAD
ARG TZ=America/New_York
ARG www_user=www-data
ARG www_group=www-data
ARG www_uid=82
ARG www_gid=82


ENV VERSION=1.0.0

ENV CORE_PKGS="bash curl findutils libgd libxml2 mysql-client nginx openssh-client shadow sudo supervisor ttf-dejavu tzdata unzip util-linux zlib" \
    PHP_PKGS="php5-fpm php5-ctype php5-cgi php5-common php5-dom php5-gettext php5-iconv php5-gd php5-imap php5-json php5-ldap php5-mysql php5-pgsql php5-pdo php5-pdo_dblib php5-pdo_mysql php5-pdo_pgsql php5-pdo_sqlite php5-posix php5-sockets php5-sqlite3 php5-xml php5-xmlreader php5-xmlrpc php5-zip" \
    ZEN_PKGS="fcgiwrap freetype gd jpeg libjpeg libpng openssl rsync" 
=======
>>>>>>> master
ARG TZ="America/New_York"
ARG DBUSER="${CFG_MYSQL_USER}"
ARG DBPASS="${CFG_MYSQL_PASSWORD}"
ARG DBHOST='mysql'
<<<<<<< HEAD
=======
>>>>>>> 2bef2227afc1be002e7f366a4b41f77843b1d05c
>>>>>>> master
    
ENV VERSION=1.0.0 \
    TZ="America/New_York" \
    DBUSER="${CFG_MYSQL_USER}" \
    DBPASS="${CFG_MYSQL_PASSWORD}" \
    DBHOST='mysql'

LABEL version=$VERSION

# Add configuration and customizations
COPY build /tmp/

# build content
RUN set -o verbose \
    && apk update \
    && apk add --no-cache bash \
    && chmod u+rwx /tmp/build_container.sh \
    && /tmp/build_container.sh \
    && rm -rf /tmp/*


#USER $zen_user
#WORKDIR $ZEN_HOME\

ENTRYPOINT [ "docker-entrypoint.sh" ]
CMD ["zen"]
