#!/bin/sh

set -eux

# Checking configuration
echo "Set to generate certificate for *.${DOMAIN}"
echo "Using ${EMAIL} for Let's Encrypt"

# Cloudflare configuration
CF_CONFIG_FILE=/etc/letsencrypt/dnscloudflare.ini
echo "dns_cloudflare_api_key = ${CLOUDFLARE_API_KEY}" > "${CF_CONFIG_FILE}"
echo "dns_cloudflare_email = ${CLOUDFLARE_ACCOUNT}" > "${CF_CONFIG_FILE}"

# Get certificate
# TODO: In background. Daily, one week before expiration
certbot certonly -d "*.${DOMAIN}" --dns-cloudflare

# Launch nginx
CERT="/etc/letsencrypt/live/${DOMAIN}/fullchain.pem"
KEY="/etc/letsencrypt/live/${DOMAIN}/privkey.pem"
while [ ! -f "${CERT}" ]; do sleep 1; done
nginx -g "daemon off;"
