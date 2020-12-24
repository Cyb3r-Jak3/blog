FROM nginx:mainline-alpine

ADD public/ /usr/share/nginx/html/
COPY nginx.conf /etc/nginx/nginx.conf
RUN nginx -c /etc/nginx/nginx.conf -t 