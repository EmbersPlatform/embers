#!/usr/bin/env bash
source .env
MIX_ENV=prod mix release unix --overwrite
