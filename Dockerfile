FROM alpine:latest
MAINTAINER Lars Kiesow <lkiesow@uos.de>

# Install certbot and cloudflare plugin
RUN apk --update add \
   coreutils \
   gcc \
   musl-dev \
   nginx \
   openssl \
   openssl-dev \
   py3-cffi \
   python3 \
   python3-dev
RUN pip3 install \
   certbot \
   certbot-dns-cloudflare
RUN apk del \
   gcc \
   musl-dev \
   openssl-dev \
   python3-dev

# Prepare cloudflare configuration
RUN mkdir /etc/letsencrypt/
RUN touch /etc/letsencrypt/dnscloudflare.ini
RUN chmod 600 /etc/letsencrypt/dnscloudflare.ini

# Configure certbot
ADD cli.ini /etc/letsencrypt/cli.ini

# Add start script
ADD run.sh /opt/bin/run
RUN chmod 755 /opt/bin/run

# Nginx setup
RUN mkdir -p /run/nginx

EXPOSE 80

CMD ["/opt/bin/run"]
