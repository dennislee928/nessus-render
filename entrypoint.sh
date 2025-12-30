#!/usr/bin/env bash
set -euo pipefail

export PORT="${PORT:-10000}"

# Render sends HTTP to your container; nginx listens on $PORT
envsubst '${PORT}' < /etc/nginx/templates/default.conf.template > /etc/nginx/conf.d/default.conf

# Start Nessus the same way the base image does (supervisord is present in the Tenable image)
# Run it in the background, then keep nginx in the foreground.
if command -v supervisord >/dev/null 2>&1; then
  # Try common supervisor config locations
  for cfg in \
    /etc/supervisor/supervisord.conf \
    /etc/supervisord.conf \
    /etc/supervisor/conf.d/supervisord.conf
  do
    if [ -f "$cfg" ]; then
      supervisord -c "$cfg" &
      break
    fi
  done

  # Fallback if none matched
  if ! pgrep -x supervisord >/dev/null 2>&1; then
    supervisord &
  fi
else
  # Last resort: try to start nessusd directly
  if [ -x /opt/nessus/sbin/nessusd ]; then
    /opt/nessus/sbin/nessusd &
  else
    echo "ERROR: Could not start Nessus (no supervisord and no /opt/nessus/sbin/nessusd)." >&2
    exit 1
  fi
fi

exec nginx -g 'daemon off;'
