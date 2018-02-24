ARG FROM_BASE=base_container:20180217
FROM $FROM_BASE

ARG DBUSER="${CFG_MYSQL_USER}"
ARG DBPASS="${CFG_MYSQL_PASSWORD}"
ARG DBHOST='mysql'

# version of this docker image
ARG CONTAINER_VERSION=1.0.2
LABEL version=$CONTAINER_VERSION  

# Add configuration and customizations
COPY build /tmp/

# build content
RUN set -o verbose \
    && chmod u+rwx /tmp/build.sh \
    && /tmp/build.sh 'ZENPHOTO'
RUN rm -rf /tmp/*  


#USER $zen_user
#WORKDIR $ZEN_HOME\

ENTRYPOINT [ "docker-entrypoint.sh" ]
CMD ["zen"]
