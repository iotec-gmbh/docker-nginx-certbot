Nginx/Certbot based HTTP proxy container
========================================

[![Quay build status](https://quay.io/repository/iotec-gmbh/nginx-certbot/status)
](https://quay.io/repository/iotec-gmbh/nginx-certbot?tab=builds)

Docker container to automatically obtain wildcard certificates for a set of
domains which can be used in Nginx.

```bash
$ docker run --name http-proxy \
  -e EMAIL=admin@example.com \
  -e DOMAINS=example.com \
  -e CLOUDFLARE_ACCOUNT=cloudflare@example.com \
  -e CLOUDFLARE_API_KEY=123 \
  ghcr.io/iotec-gmbh/docker-nginx-certbot:master
```


Parameters description:

- `EMAIL`: Email address used for Let's Encrypt registration. This is used to
  send certificate expiration warnings in case something went wrong.
- `DOMAINS`: Comma separated list of domains to get a (wildcard) certificate
  for.
- `CLOUDFLARE_ACCOUNT`: Email address to identify the Cloudflare account to use.
- `CLOUDFLARE_API_KEY`: Cloudflare API key to get access to the DNS management.
