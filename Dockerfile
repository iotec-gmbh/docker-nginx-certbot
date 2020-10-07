FROM alpine:latest
MAINTAINER Lars Kiesow <lkiesow@uos.de>

# Install certbot and cloudflare plugin
RUN apk --no-cache add \
   coreutils \
   gcc \
   libffi \
   libffi-dev \
   musl-dev \
   nginx \
   openssl \
   openssl-dev \
   python3 \
   python3-dev \
   py3-pip
RUN pip3 install --no-cache-dir --upgrade pip \
   && pip3 install --no-cache-dir \
      certbot \
      certbot-dns-cloudflare
RUN apk --no-cache del \
   gcc \
   libffi-dev \
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
