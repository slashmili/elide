FROM alpine:edge

ENV MIX_ENV prod

RUN apk --update add \
    erlang erlang-crypto erlang-sasl\
    elixir \
    postgresql-client \
    && rm -rf /var/cache/apk/*

RUN yes | mix local.hex

RUN mix hex.info

WORKDIR /code

CMD mix phoenix.digest \
    && mix deps.get \
    && mix compile \
    && mix release
