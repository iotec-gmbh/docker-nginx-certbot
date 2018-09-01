#!/bin/sh

set -eux

# Checking configuration
# shellcheck disable=SC2153
echo "Set to generate wildcard certificate for: ${DOMAINS}"
echo "Using ${EMAIL} for Let's Encrypt"

# Cloudflare configuration
CF_CONFIG_FILE=/etc/letsencrypt/dnscloudflare.ini
echo "dns_cloudflare_api_key = ${CLOUDFLARE_API_KEY}" > "${CF_CONFIG_FILE}"
echo "dns_cloudflare_email = ${CLOUDFLARE_ACCOUNT}" >> "${CF_CONFIG_FILE}"

# Check that the domain configuration contains no spaces
if echo "$DOMAINS" | grep -q ' '; then
  echo "Error: Domains should be a comma separated list of domain names."
  echo "       No spaces!"
  echo "       E.g. DOMAINS=example.com,example1.com"
  exit 1
fi

# Split domains
domains="$(echo "$DOMAINS" | tr ',' "\\n")"

# Prepare Nginx include
for domain in $domains; do
  cert="/etc/letsencrypt/live/${domain}/fullchain.pem"
  key="/etc/letsencrypt/live/${domain}/privkey.pem"
  echo "ssl_certificate_key $key;" > "/etc/nginx/certificate.${domain}.conf"
  echo "ssl_certificate $cert;" >> "/etc/nginx/certificate.${domain}.conf"

  echo "Prepared Nginx configuration. Use:"
  echo "  include /etc/nginx/certificate.$domain.conf;"
done

while true; do

  need_reload=false

  # Check domains
  for domain in $domains; do
    cert="/etc/letsencrypt/live/${domain}/fullchain.pem"
    key="/etc/letsencrypt/live/${domain}/privkey.pem"

    # Check how long the certificate is valid
    days_to_expire=0
    if [ -f "$cert" ]; then
      output="$(openssl x509 -enddate -noout -in "$cert")"
      end_date=$(echo "$output" | grep 'notAfter=' | cut -d= -f2)
      end_epoch=$(date +%s -d "$end_date")
      now_epoch=$(date +%s)
      days_to_expire=$(((end_epoch - now_epoch) / 86400))
    fi

    if [ "$days_to_expire" -lt 7 ]; then
      # Get certificate (allowed to fail)
      certbot certonly -d "${domain}" -d "*.${domain}" --dns-cloudflare \
        --non-interactive --agree-tos --email "$EMAIL" || :
      need_reload=true
    fi
  done

  # Launch or reload Nginx
  # - We can always safely reload Nginx since that means that all certificate
  #   files exist
  # - We need to check if all certificate files exist before starting Nginx for
  #   the first time since a missing certificate file may cause Nginx to fail
  if pgrep nginx > /dev/null; then
    "$need_reload" && nginx -s reload
  else
    launch=true
    for domain in $domains; do
      if [ ! -f "/etc/letsencrypt/live/${domain}/fullchain.pem" ]; then
        launch=false
      fi
    done
    "$launch" && nginx
  fi

  # Sleep 5 minutes
  sleep 300
done
