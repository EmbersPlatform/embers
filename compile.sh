#!/usr/bin/env bash

MIX_ENV=prod

mix deps.get --only prod

mix compile

mix embers.static
mix phx.digest
