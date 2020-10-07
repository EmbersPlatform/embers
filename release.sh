#!/usr/bin/env bash

rm -rf priv/static

cp -R assets/static priv/static

cd assets && yarn install && yarn build
cd ../

mix phx.digest

MIX_ENV=prod mix release tar
