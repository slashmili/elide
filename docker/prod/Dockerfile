FROM alpine:edge

RUN apk --update add \
    erlang erlang-crypto erlang-sasl \
    && rm -rf /var/cache/apk/*

ENV MIX_ENV prod
ENV PORT 4000

ADD rel /opt

EXPOSE $PORT

CMD trap exit TERM; /opt/elide/bin/elide foreground & wait
