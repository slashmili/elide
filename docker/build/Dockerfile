FROM alpine:edge

RUN apk --update add \
    erlang erlang-crypto erlang-sasl \
    erlang-syntax-tools erlang-tools erlang-parsetools \
    erlang-inets erlang-asn1 erlang-sasl erlang-erl-interface \
    erlang-dev erlang-eunit \
    elixir \
    postgresql-client \
    coreutils \
    nodejs python make g++ \
    && rm -rf /var/cache/apk/*


WORKDIR /code

RUN npm install -g npm


RUN mix local.hex --force
RUN mix local.rebar --force

RUN mix hex.info

CMD mix deps.get \
    && npm install \
    && node_modules/brunch/bin/brunch build --production \
    && mix phoenix.digest \
    && mix compile \
    && mix release
