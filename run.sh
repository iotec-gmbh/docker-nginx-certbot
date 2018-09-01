#!/bin/sh

set -eux

# Checking configuration
echo "Set to generate certificate for *.${DOMAIN}"
echo "Using ${EMAIL} for Let's Encrypt"

# Cloudflare configuration
CF_CONFIG_FILE=/etc/letsencrypt/dnscloudflare.ini
echo "dns_cloudflare_api_key = ${CLOUDFLARE_API_KEY}" > "${CF_CONFIG_FILE}"
echo "dns_cloudflare_email = ${CLOUDFLARE_ACCOUNT}" >> "${CF_CONFIG_FILE}"

CERT="/etc/letsencrypt/live/${DOMAIN}/fullchain.pem"
KEY="/etc/letsencrypt/live/${DOMAIN}/privkey.pem"

# Prepare Nginx include
echo "ssl_certificate_key $KEY;" > /etc/nginx/certificate.conf
echo "ssl_certificate $CERT;" >> /etc/nginx/certificate.conf
# Use in Nginx configuration:
# include /etc/nginx/ssl.conf;

while true; do

  # Check how long the certificate is valid
  days_to_expire=0
  if [ -f "$CERT" ]; then
    output="$(openssl x509 -enddate -noout -in "$CERT")"
    end_date=$(echo "$output" | grep 'notAfter=' | cut -d= -f2)
    end_epoch=$(date +%s -d "$end_date")
    now_epoch=$(date +%s)
    days_to_expire=$(((end_epoch - now_epoch) / 86400))
  fi

  if [ "$days_to_expire" -lt 7 ]; then
    # Get certificate (allowed to fail)
    certbot certonly -d "${DOMAIN}" -d "*.${DOMAIN}" --dns-cloudflare \
      --non-interactive --agree-tos --email "$EMAIL" || :
    # Reload Nginx if it's already running. This also ensures the existence of
    # the certificate.
    if pgrep nginx > /dev/null; then
      nginx -s reload
    fi
  fi

  # Launch Nginx if a certificate exists and if it's not already running
  if [ -f "${CERT}" ] && ! pgrep nginx > /dev/null; then
    nginx
  fi

  # Sleep 5 minutes
  sleep 300
done
