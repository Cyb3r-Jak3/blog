---
title: "Cloudflared DoH proxy"
date: "2023-02-17"
description: "Tutorial on setting up cloudflared to proxy dns via DoH"
featured: true
tags: [ Cloudflare, Tutorial ]
categories: [ Tutorial ]
---

This is a short tutorial on setting up [cloudflared](https://github.com/cloudflare/cloudflared) to proxy DoH for use with service like [Pi.Hole](https://pi-hole.net/). Old guides use `sudo cloudflared service install --legacy` and the `--legacy` flag was [removed](https://github.com/cloudflare/cloudflared/commit/706523389c83ad3bc9b950bd6cb712864e23f586#diff-b10aaca38c8d89afa4c14ffbc373252118ed207da5216b611e1df2405643af08).

## Download

The first thing that is needed is to install cloudflared, [install instructions](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/install-and-setup/tunnel-guide/local/#set-up-a-tunnel-locally-cli-setup). For linux based OSs, I use the [cloudflared package repo](https://pkg.cloudflare.com/index.html) as it makes it easier to update.

If you want to manually install it then you can use the following commands. Please make a note on the architecture you are installed on and make adjustments as needed. See the [releases](https://github.com/cloudflare/cloudflared/releases/latest/) for a full list of supported architectures.

```bash
wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
sudo apt-get install ./cloudflared-linux-amd64.deb
cloudflared -v
```

## Setup

Copy the below text and save it to `/etc/systemd/system/cloudflared-doh.service`

```systemd

[Unit]
Description=cloudflared DNS over HTTPS proxy
After=network-online.target

[Service]
TimeoutStartSec=0
Type=notify
ExecStart=/usr/local/bin/cloudflared --no-autoupdate proxy-dns --port 5053 --upstream https://1.1.1.1/dns-query --upstream https://1.0.0.1/dns-query
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
```

{{% notice note "Note" %}}
You can change the upstream servers to others such as Google's `https://8.8.8.8/dns-query` or Cloudflare's Zero Trust Gateway DNS servers.
{{% /notice %}}

{{% notice tip "Config file" %}}
If you want to add your cloudflared options as a config file then run the following commands

```bash
sudo mkdir /etc/cloudflared/
sudo nano /etc/cloudflared/config.yml
```

and paste

```yaml
proxy-dns: true
proxy-dns-port: 5053
proxy-dns-upstream:
  - https://1.1.1.1/dns-query
  - https://1.0.0.1/dns-query
```

you will need to change the `ExecStart` to  
`ExecStart=/usr/local/bin/cloudflared --no-autoupdate --config /etc/cloudflared/config.yml`.
{{% /notice %}}

After the service file has been added run the following to enable it and start on reboot:

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now cloudflared-doh.service
```

Make sure that the service is healthly:

`sudo systemctl status cloudflared`

Test that DNS is resolving:

`dig @127.0.0.1 -p 5053 google.com`

## Running with Docker

If you want to use docker to run the proxy then you can use [Cloudflare's Image](https://hub.docker.com/r/cloudflare/cloudflared) or a [Community Maintained Image](https://hub.docker.com/r/erisamoe/cloudflared).

To run:

`docker run -d -p 53:53/udp --name cloudflared-doh <cloudflared/image> proxy-dns`

If you want to add upstream servers, defaults to cloudflare, then append `--upstream <upstream>` to the end of the command.
