ARG FROM_BASE=php5:20180314
FROM $FROM_BASE

# name and version of this docker image
ARG CONTAINER_NAME=zen
ARG CONTAINER_VERSION=1.0.0

LABEL org_name=$CONTAINER_NAME \
      version=$CONTAINER_VERSION 

# Specify CBF version to use with our configuration and customizations
ARG CBF_VERSION=${CBF_VERSION:-v3.0}
# include our project files
COPY build /tmp/
# set to non zero for the framework to show verbose action scripts
#    (0:default, 1:trace & do not cleanup; 2:continue after errors)
ENV DEBUG_TRACE=0


ARG ZEN_HOST=mysql
ARG ZEN_PASS=${CFG_PASS}
ARG ZEN_USER=${CFG_USER}


# build content
RUN set -o verbose \
    && chmod u+rwx /tmp/build.sh \
    && /tmp/build.sh "$CONTAINER_NAME" "$DEBUG_TRACE"
RUN [ $DEBUG_TRACE != 0 ] || rm -rf /tmp/* 


#USER $zen_user
#WORKDIR $ZEN_HOME\


ENTRYPOINT [ "docker-entrypoint.sh" ]
#CMD ["$CONTAINER_NAME"]
CMD ["zen"]
