#!/bin/sh
MIX_ENV=prod mix release
MIX_ENV=prod PORT=4000 _build/prod/rel/embers/bin/embers console
