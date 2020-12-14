FROM bretfisher/jekyll:latest as builder

COPY blog ./blog
COPY Gemfile Gemfile

RUN bundle install --jobs 4 --retry 3

RUN jekyll build --source blog  --destination ./site

FROM nginx:mainline-alpine

COPY --from=builder ./site/* /usr/share/nginx/html/
COPY nginx.conf /etc/nginx/nginx.conf
RUN nginx -c /etc/nginx/nginx.conf -t