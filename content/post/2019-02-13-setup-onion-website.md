---
title: "Creating an Onion Website"
date: "2019-02-13"
tags: [ Tor, Tutorial ]
categories: [ Tutorial ]
thumbnail: "images/torguide/tor_help.webp"
---
Creating a hidden service is a good way to get introduced to tor and onion routing. For this walk through, I will be installing tor on Ubuntu 18.04 LTS and be using nginx as my web server. This is for educational purposes only. What you do on your hidden service is your responsibility.  

#### Installing Nginx  

1. ```sudo apt install nginx```  

&nbsp;  

#### Installing Tor

---
To get the tor binaries you can either install from the tor repositories or you can download and build it from source. In this, I will be installing it via the repositories because it is quicker and easier.  

```bash
sudo apt install apt-transport-https lsb-release
echo "deb [signed-by=/usr/share/keyrings/tor-archive-keyring.gpg] https://deb.torproject.org/torproject.org $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/tor.list
echo "deb-src [signed-by=/usr/share/keyrings/tor-archive-keyring.gpg] https://deb.torproject.org/torproject.org $(lsb_release -cs) main" | sudo tee -a /etc/apt/sources.list.d/tor.list
sudo apt-get update && sudo apt-get install tor deb.torproject.org-keyring
```

Now tor and nginx are installed and we just have to configure them.  

#### Configuring Nginx

---

1. Make web root. This is where your web files will go:

   `sudo mkdir -p /var/www/onionsite/`
2. Nginx config server file.
   - You want to make a simple nginx config file in the /etc/nginx/sites-available/tor.
   - My file is ![Nginx config file](../../images/torguide/nginxconfig.webp)
3. Link Nginx config:

   `sudo ln -s /etc/nginx/sites-available/tor /etc/nginx/sites-enabled/`

{{% notice warning "Warning" %}}
   Use the full path when linking otherwise it can break.
{{% /notice %}}  

#### Configuring Tor

The default tor config is located at /etc/tor/torrc. I would recommend backing up the current one you have and starting fresh. You want a config that contains:

```ini
SOCKSPort 0
DataDirectory /var/lib/tor
HiddenServiceDir /var/lib/tor/onion/
HiddenServiceVersion 3
HiddenServicePort 80 127.0.0.1:445
```

{{% notice note "Note" %}}
 You can omit `HiddenServiceVersion 3` if you want to run an onion v2 hidden service.  
{{% /notice %}}

You can omit this line if you want to run an onion v2 hidden service.  

Mine looks like ![Tor Config File](../../images/torguide/torconfig.webp)

And you now have a hidden service configure. Just restart all service:

`sudo systemctl restart nginx tor`

Your hidden service address will be generated in `/var/lib/tor/onion/<hostname>/`.  
Enjoy your hidden service web site.
