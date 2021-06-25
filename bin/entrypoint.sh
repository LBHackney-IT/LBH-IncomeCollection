#!/usr/bin/env bash

set -e

echo "Starting $RAILS_ENV"

rm -f /app/tmp/pids/server.pid

# Start app
exec "$@"
