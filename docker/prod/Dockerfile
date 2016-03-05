FROM alpine:edge

RUN apk --update add \
    erlang erlang-crypto erlang-sasl \
    coreutils \
    && rm -rf /var/cache/apk/*

ENV MIX_ENV prod
ENV PORT 4000

ADD rel /opt

RUN wget -q http://geolite.maxmind.com/download/geoip/database/GeoLiteCountry/GeoIP.dat.gz -O /tmp/GeoIP.dat.gz \
    && gunzip /tmp/GeoIP.dat.gz \
    && mkdir -p /usr/share/GeoIP \
    && mv /tmp/GeoIP.dat /usr/share/GeoIP

EXPOSE $PORT

CMD trap exit TERM; /opt/elide/bin/elide foreground & wait
