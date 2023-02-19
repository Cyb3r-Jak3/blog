---
title: "Minecraft Server using Cloudflared"
date: "2022-03-26"
description: "Tutorial on setting up a minecraft server via cloudflared"
tags: [ Cloudflare, Tutorial, Minecraft ]
categories: [ Tutorial ]
featured: true
---

Something that I have started using a lot more is [Cloudflare's Tunnel](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/). I have been using them mainly for securing SSH access to my servers as it means that I don't need to have any external ports open. Plus, Tunnels also offer a browse rendered SSH, which is convenient. In this guide I will walking through how to deploy a Minecraft Server that is securely accessed by a Tunnel.

#### Requirements

- [X] Domain on Cloudflare
- [X] [Cloudflared](https://github.com/cloudflare/cloudflared) installed both on server and client machine. (I am using [Docker](https://docs.docker.com/engine/install/) in this tutorial).

### Creating Server Config

The first thing to do is to create the cloudflared tunnel file and configuration file. To create the tunnel run `cloudflared tunnel create minecraft`. Once the command completes then it will tell you the path to the tunnel JSON file. Copy that file as well as the `cert.pem` into your current directory for convenience. For the cloudflared configuration file, you need something simple like:

```yaml
tunnel: <tunnel-id>
credentials-file: <path/to/your/tunnel/file.json>
ingress:
  - hostname: mc.cyberjake.xyz
    service: tcp://mc:25565
  - service: http_status:404
```

[Download Here](../../other-files/minecraft-cloudflared/cloudflared-config.yml). For those who are not using docker you likely going to want to replace `tcp://mc:25565` with `tcp://localhost:25565` or whatever the address that your Minecraft server is running on. For those who are using docker then there is a [compose file available](../../other-files/minecraft-cloudflared/docker-compose.yml). Can confirm that your tunnel is working by running `cloudflared tunnel run --config </path/to/tunnel/config>`.

### Connecting

To be able to connect to your server you need the client to proxy the connection. This can be done by running `cloudflared access tcp --hostname <url of your server> --url localhost:9210`. Then open your minecraft client and go to multiplayer and add a new server then for the address use `localhost:9210`. Then boom your server will be there to access.

![Final Result](../../images/minecraft-cloudflared/tada.webp)
