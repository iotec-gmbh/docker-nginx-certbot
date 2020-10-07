Nginx/Certbot based HTTP proxy container
========================================

[![Quay build status](https://quay.io/repository/iotec-gmbh/nginx-certbot/status)
](https://quay.io/repository/iotec-gmbh/nginx-certbot?tab=builds)

[![Travis build status](https://travis-ci.com/iotec-gmbh/docker-nginx-certbot.svg?branch=master)
](https://travis-ci.com/iotec-gmbh/docker-nginx-certbot)

Docker container to automatically obtain wildcard certificates for a set of
domains which can be used in Nginx. [Iotec](https://iotec-gmbh.de) uses this as
primary HTTP proxy for several web-services.

```bash
$ docker run --name http-proxy \
  -e EMAIL=admin@example.com \
  -e DOMAINS=example.com \
  -e CLOUDFLARE_ACCOUNT=cloudflare@example.com \
  -e CLOUDFLARE_API_KEY=123 \
  quay.io/iotec-gmbh/nginx-certbot
```


Parameters description:

- `EMAIL`: Email address used for Let's Encrypt registration. This is used to
  send certificate expiration warnings in case something went wrong.
- `DOMAINS`: Comma separated list of domains to get a (wildcard) certificate
  for.
- `CLOUDFLARE_ACCOUNT`: Email address to identify the Cloudflare account to use.
- `CLOUDFLARE_API_KEY`: Cloudflare API key to get access to the DNS management.
