ARG FROM_BASE=${DOCKER_REGISTRY:-ubuntu-s2:5000/}${CONTAINER_OS:-alpine}/php/${PHP7_VERSION:-7.2.22-r0}:${BASE_TAG:-latest}
FROM $FROM_BASE

# name and version of this docker image
ARG CONTAINER_NAME=zen
# Specify CBF version to use with our configuration and customizations
ARG CBF_VERSION

# include our project files
COPY build Dockerfile /tmp/

# set to non zero for the framework to show verbose action scripts
#    (0:default, 1:trace & do not cleanup; 2:continue after errors)
ENV DEBUG_TRACE=0


ARG ZEN_HOST=mysql
ARG ZEN_PASS=${CFG_PASS}
ARG ZEN_USER=${CFG_USER}

# postgres version being bundled in this docker image
ARG ZEN_VERSION=1.5.6
LABEL version.zenphoto=$ZEN_VERSION  


# build content
RUN set -o verbose \
    && chmod u+rwx /tmp/build.sh \
    && /tmp/build.sh "$CONTAINER_NAME" "$DEBUG_TRACE" \
    && ([ "$DEBUG_TRACE" != 0 ] || rm -rf /tmp/*) 


#USER $zen_user
#WORKDIR $ZEN_HOME\


ENTRYPOINT [ "docker-entrypoint.sh" ]
#CMD ["$CONTAINER_NAME"]
CMD ["zen"]
