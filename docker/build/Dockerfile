FROM alpine:edge

RUN apk --update add \
    erlang erlang-crypto erlang-sasl\
    elixir \
    postgresql-client \
    nodejs python make g++ \
    && rm -rf /var/cache/apk/*

RUN yes | mix local.hex
RUN mix hex.info

WORKDIR /code

RUN npm install -g npm

CMD npm install \
    && node_modules/brunch/bin/brunch build --production \
    && mix phoenix.digest \
    && mix deps.get \
    && mix compile \
    && mix release
