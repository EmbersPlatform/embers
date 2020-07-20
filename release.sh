#!/usr/bin/env bash

rm -rf priv/static
mkdir priv/static

mix embers.static

cd assets && yarn production
cd admin && yarn production
cd ../../

mix phx.digest

MIX_ENV=prod mix release tar
