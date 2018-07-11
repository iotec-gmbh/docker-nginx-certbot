Nginx/Certbot based HTTP proxy container
========================================

```bash
$ docker run --name http-proxy \
  -e EMAIL=admin@example.com \
  -e DOMAIN=example.com \
  -e CLOUDFLARE_ACCOUNT=cloudflare@example.com \
  -e CLOUDFLARE_API_KEY=123 \
  lkiesow/docker-nginx-certbot
```