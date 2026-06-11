# Static-file server for the demo SPA.
FROM nginx:1.27-alpine
RUN apk add --no-cache curl tini && \
    adduser -D -u 10001 web && \
    sed -i 's/user  nginx;/user  web;/' /etc/nginx/nginx.conf && \
    mkdir -p /var/cache/nginx/client_temp /var/cache/nginx/proxy_temp \
             /var/cache/nginx/fastcgi_temp /var/cache/nginx/uwsgi_temp \
             /var/cache/nginx/scgi_temp /var/run/nginx /run && \
    chown -R web:web /var/cache/nginx /var/run/nginx /var/log/nginx /run
COPY src/frontend/ /usr/share/nginx/html/
COPY docker/nginx.conf /etc/nginx/conf.d/default.conf
USER 10001
HEALTHCHECK CMD curl -fsS http://127.0.0.1:8080/ -o /dev/null || exit 1
EXPOSE 8080
