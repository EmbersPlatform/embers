#!/usr/bin/env bash
mix deps.get --only prod

MIX_ENV=prod mix compile

MIX_ENV=prod mix ecto.migrate

MIX_ENV=prod PORT=4000 mix phx.server
