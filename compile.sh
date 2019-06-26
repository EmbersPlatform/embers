#!/bin/sh

MIX_ENV=prod

mix deps.get --only prod

mix compile

cd assets
npm install
npm run production
cd ../

mix embers.static
mix phx.digest
