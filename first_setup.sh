#!/usr/bin/env bash

mix deps.get
cp -R assets/static priv
mix compile
mix ecto.setup

npm install
npm run build