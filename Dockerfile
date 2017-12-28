FROM alpine:3.6

ARG TZ="America/New_York"
ARG DBUSER="${CFG_MYSQL_USER}"
ARG DBPASS="${CFG_MYSQL_PASSWORD}"
ARG DBHOST='mysql'
    
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