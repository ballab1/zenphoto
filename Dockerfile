FROM alpine:3.4

ARG TZ=UTC

ENV VERSION 0.4

ADD https://github.com/zenphoto/zenphoto/archive/zenphoto-1.4.14.tar.gz /tmp/

RUN apk add tzdata && cp /usr/share/zoneinfo/$TZ /etc/timezone && apk del tzdata
#RUN mkdir -p /var/www/html \
# && tar -C /var/www/html -xvzf /tmp/zenphoto-1.4.14.tar.gz \
# && mv /tmp/zenphoto-zenphoto-1.4.14  /var/www/zenphoto \
# && rm /tmp/zenphoto-1.4.14.tar.gz

