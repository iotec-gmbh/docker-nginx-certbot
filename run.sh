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

# Prepare nginx include
echo "ssl_certificate_key $KEY;" > /etc/nginx/certificate.conf
echo "ssl_certificate $CERT;" >> /etc/nginx/certificate.conf
# Use in nginx configuration:
# include /etc/nginx/ssl.conf;

while true; do

  days_to_expire=0
  if [ -f "$CERT" ]; then
    output="$(openssl x509 -enddate -noout -in "$CERT")"
    end_date=$(echo "$output" | grep 'notAfter=' | cut -d= -f2)
    end_epoch=$(date +%s -d "$end_date")
    epoch_now=$(date +%s)
    days_to_expire=$(((end_epoch - epoch_now) / 86400))
  fi

  if [ "$days_to_expire" -lt 7 ]; then
    # Get certificate (allowed to fail)
    certbot certonly -d "${DOMAIN}" -d "*.${DOMAIN}" --dns-cloudflare \
      --non-interactive --agree-tos --email "$EMAIL" || :

    # Launch nginx
    if [ -f "${CERT}" ]; then
      # Start or reload Nginx depending on its status
      if pgrep nginx > /dev/null; then
        nginx -s reload
      else
        nginx
      fi

      # Sleep for a day
      sleep 86400
    else
      # Sleep 5 minutes
      sleep 300
    fi
  fi
done
