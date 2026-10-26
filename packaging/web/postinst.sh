#!/bin/sh
# malu123-web: enable /malu123/ on Apache when it is installed; harmless elsewhere.
set -e
if [ -x /usr/sbin/a2enconf ] && [ -d /etc/apache2/conf-available ]; then
  a2enmod -q headers >/dev/null 2>&1 || true
  a2enconf -q malu123-web >/dev/null 2>&1 || true
  if command -v systemctl >/dev/null 2>&1 && systemctl is-active -q apache2; then
    systemctl reload apache2 || true
  fi
fi
exit 0
