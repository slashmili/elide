FROM msaraiva/elixir-dev

RUN apk --update add bash erlang-tools grep inotify-tools make nodejs postgresql-client
RUN npm install -g npm && npm install brunch
RUN mix hex.info
RUN apk add python
RUN apk add g++
