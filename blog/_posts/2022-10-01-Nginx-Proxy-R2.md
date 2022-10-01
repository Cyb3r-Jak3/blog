---
layout: post
title: "Nginx + R2"
date: 2022-10-01 10:00:00 -5000
image: ""
tags: [Tutorial, Cloudflare]
categories: [Tutorial]
---

This is a quick tutorial on setting up Nginx to proxy files from [Cloudflare R2](https://developers.cloudflare.com/r2/). All the files are available on [GitHub](https://github.com/Cyb3r-Jak3/cloudflare-example/tree/main/nginx-r2).
This tutorial was done with docker for easy setup but the config file is simple and easy to adapt to a full running nginx server.

## Create Bucket

First thing that is needed is an R2 bucket with public access enabled ([Enable Public Access Docs](https://developers.cloudflare.com/r2/data-access/public-buckets/#enable-public-access-for-your-bucket)). I would recommend configuring a custom domain so that you can get additional benefits like WAF and Cache. [Docs](https://developers.cloudflare.com/r2/data-access/public-buckets/#connect-your-bucket-to-a-custom-domain).

## Upload images

After the bucket is created, you'll need to upload your images. This is how mine looks:
![R2 Bucket Layout](/assets/img/nginx-r2/r2-bucket.webp)

## Create nginx config

Here is a simple server config for nginx.

```
    server {
        listen 80;
        set $bucket <public bucket URL>;
        server_name <nginx server name>;

        location / {
            root /usr/share/nginx/html/;
        }

        location ~ ^/image/(.*)$ {
            resolver 1.1.1.1;
            add_header             Cache-Control max-age=31536000;
            proxy_ssl_server_name on;
            proxy_set_header       Host $bucket;
            proxy_pass https://$bucket/$1;
        }
    }
```

The gotcha setting here for me was `proxy_ssl_server_name on;` which is needed to pass the server name with SNI. This configuration removes the `/image/` path when making the request to Cloudflare. It means that all our images can be stored in the root level of the bucket. I am also using the following filesfor this demo:

### docker-compose.yml

```yaml
version: '3.9'

services:
  web:
    image: nginx:mainline-alpine
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      - ./index.html:/usr/share/nginx/html/index.html:ro
    ports:
      - 80:80
```

If you don't want to use docker compose then you can run it all with `docker run --rm -p 80:80 -v $(pwd)/nginx.conf:/etc/nginx/nginx.conf:ro -v $(pwd)/index.html:/usr/share/nginx/html/index.html:ro nginx:mainline-alpine`.

### index.html

```html
<!DOCTYPE html>
<head>
    <title> Nginx + R2</title>
</head>
<body>
    <p>This page is served from nginx. The image below is served from R2</p>
    <img src="/image/example.png" alt="example image from R2">
</body>
```

After starting docker, browse to `localhost` on your local machine to see the image be loaded from R2.