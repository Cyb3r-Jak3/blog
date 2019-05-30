---
layout: post
title: "Fail2Ban + CloudFlare"
date: 2019-05-30 15:00:00 -5000
image: fail2ban/nginx-fail2ban-security.png
tags: [Tutorial]
categories: [Tutorial]
---
When protecting a server [fail2ban](https://www.fail2ban.org/wiki/index.php/Main_Page) is a great tool for the job. It reads log files and bans IPs that show signs of malicious activity. There is a lot of support for and it can intergrate well with other applications.

##### How I Use it
I use CloudFlare on all my sites. This means that when you connect to any of my sites, you connect to cloudflare then CloudFlare connects to my site. Because of this, I have an rule in nginx (which I added a the bottom) that blocks any connections that attempt to connect directly to my server. I decicded to increase the protection that I had on my server by creating a filter in fail2ban. I made it so connections are blocked for 5 minutes if the connection is made from an IP that is not from CloudFlare.  

#### [Fail2ban filter configuration and instructions here](https://github.com/jwhite1st/Scripts/tree/master/Linux/fail2ban)

##### Nginx Rule  


#Allow Cloudflare IPs  
#Retrived from https://www.cloudflare.com/ips/  
allow 173.245.48.0/20;  
allow 103.21.244.0/22;  
allow 103.22.200.0/22;  
allow 103.31.4.0/22;  
allow 141.101.64.0/18;  
allow 108.162.192.0/18;  
allow 190.93.240.0/20;  
allow 188.114.96.0/20;  
allow 197.234.240.0/22;  
allow 198.41.128.0/17;  
allow 162.158.0.0/15;  
allow 104.16.0.0/12;  
allow 172.64.0.0/13;  
allow 131.0.72.0/22;  
allow 2400:cb00::/32;  
allow 2606:4700::/32;  
allow 2803:f800::/32;  
allow 2405:b500::/32;  
allow 2405:8100::/32;  
allow 2a06:98c0::/29;  
allow 2c0f:f248::/32;  
  
#Block all other IPs from connecting  
deny all;  
