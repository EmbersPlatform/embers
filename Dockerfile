FROM elixir:1.10-slim as builder

ENV MIX_ENV=prod \
    LANG=C.UTF-8d

RUN mix local.rebar --force \
    && mix local.hex --force

RUN mkdir /app
WORKDIR /app

COPY mix.exs .
COPY mix.lock .

RUN mix deps.get
RUN mix deps.compile

COPY config ./config
COPY lib ./lib
COPY priv ./priv

RUN mix phx.digest
RUN mix release embers

FROM debian:buster as app

ENV LANG=C.UTF-8

RUN apt-get update && apt-get install -y openssl imagemagick ffmpeg

RUN useradd --create-home app
WORKDIR /home/app

COPY --from=builder /app/_build .

RUN chown -R app: ./prod
USER app

EXPOSE 4000

CMD ["./prod/rel/embers/bin/embers", "start"]
