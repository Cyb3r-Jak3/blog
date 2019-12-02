---
layout: post
title: "Creating an Onion Website"
date: 2019-02-13 15:00:00 -5000
image: torguide/tor_help.png
tags: [Tor, Tutorial]
categories: [Tutorial]
---
Creating a hidden service is a good way to get introduced to tor and onion routing. For this walk through, I will be installing tor on Ubuntu 18.04 LTS and be using nginx as my web server. This is for educational purposes only. What you do on your hidden service is your responsibility.  
&nbsp;

#### Installing Nginx  

1. ```sudo apt install nginx```  

&nbsp;  

#### Installing Tor

---
To get the tor binaries you can either install from the tor repositories or you can download and build it from source. In this, I will be installing it via the repositories because it is quicker and easier.  

1. ```echo deb https://deb.torproject.org/torproject.org bionic main | sudo tee /etc/apt/sources.list.d/tor.list```
2. ```echo deb-src https://deb.torproject.org/torproject.org bionic main | sudo tee -a /etc/apt/sources.list.d/tor.list```
   1. - The -a in the second tee command means that it will append rather than overwrite.
3. ```gpg2 --recv A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD8```
4. ```gpg2 --export A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89 | sudo apt-key add -```
5. ```sudo apt-get update && sudo apt-get install tor deb.torproject.org-keyring```  
Now tor and nginx are installed and we just have to configure them.  
&nbsp;  

#### Configuring Nginx

---

1. Make web root. This is where your web files will go.
   1. ```sudo mkdir -p /var/www/onionsite/```
2. Nginx config server file.
   1. You want to make a simple nginx config file in the /etc/nginx/sites-available/tor.
   2. My file is ![Nginx config file](/img/torguide/nginxconfig.png)
3. Link Nginx config.
   1. ```sudo ln -s /etc/nginx/sites-available/tor /etc/nginx/sites-enabled/```
   2. Use the full path when linking otherwise it can break.  

&nbsp;  

#### Configuring Tor

The default tor config is located at /etc/tor/torrc. I would recommend backing up the current one you have and starting fresh. You want a config that contains:

- `SOCKSPort 0`
- `DataDirectory /var/lib/tor`  
- `HiddenServiceDir /var/lib/tor/onion/`  
- `HiddenServiceVersion 3`
  - You can omit this line if you want to run an onion v2 hidden service.  
- `HiddenServicePort 80 127.0.0.1:445`  
Mine looks like ![Tor Config File](/img/torguide/torconfig.png)

And you now have a hidden service configure. Just restart all services with ```sudo systemctl restart nginx``` and ```sudo systemctl restart tor```. Your hidden service address will be generated in /var/lib/tor/onion/hostname/.  
Enjoy your hidden service web site.
