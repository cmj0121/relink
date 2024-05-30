#! /usr/bin/env sh
set -e

BASE_URL=${BASE_URL:-"https://example.com"}
DATABASE=${DATABASE:-"sqlite3:///app/relink.db"}
SECRET_KEY=${SECRET_KEY:-"$(openssl rand -hex 32)"}

relink migrate -vv "$DATABASE"
relink server -vv --storage "$DATABASE" --bind ":8080" --base-url "$BASE_URL" --auth-token "$SECRET_KEY"
