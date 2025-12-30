FROM --platform=linux/amd64 tenable/nessus:latest-ubuntu

USER root

RUN apt-get update \
  && apt-get install -y --no-install-recommends nginx gettext-base ca-certificates \
  && rm -rf /var/lib/apt/lists/*

COPY nginx.conf.template /etc/nginx/templates/default.conf.template
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Nginx will listen on $PORT (Render default 10000)
EXPOSE 10000

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
