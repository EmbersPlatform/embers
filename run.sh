#!/usr/bin/env bash

echo "\n preparing static assets..."
cp -R assets/static priv/static

echo "\n Setting up and seeding database..."
mix ecto.setup

# echo "\n Starting server..."
# mix phx.server

sleep 99999
