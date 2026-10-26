#!/bin/sh
set -e
if [ -x /usr/sbin/a2disconf ] && [ -e /etc/apache2/conf-enabled/malu123-web.conf ]; then
  a2disconf -q malu123-web >/dev/null 2>&1 || true
  if command -v systemctl >/dev/null 2>&1 && systemctl is-active -q apache2; then
    systemctl reload apache2 || true
  fi
fi
exit 0
