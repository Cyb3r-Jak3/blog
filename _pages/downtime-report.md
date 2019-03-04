---
layout: comment-policy
title: Downtime Report
permalink: /downtime-report/
---
This is a page where I will discuss any downtime of services that I provide. A report will have the time, affected services, reason/cause, actions taken and remedial actions. I will do my best to make sure that any reports come out as soon as possible after a downtime event takes place. Currently all times will have a ish factor of 5 minutes because I use [Uptime Robot](https://uptimerobot.com/) and it checks every 5 minutes.  

---

#### Downtime on March 3rd, 2019
- **Time**:  
	- Down: 15:21 UTC (~ 5 minutes)  
	- Up: 15:38 UTC (Manual Check). Reported back up at 15:40 UTC by Uptime Robot.  
	- Total Time: 17 minutes down
- **Affected Services**: blog, failover webserver, hidden services web site, tor exit.
- **Reason/Cause**: I believe the cause to be that I was running a program to generate a custom onion v3 address and it is CPU heavy. This caused nginx to not have the resources needed to serve web content. When I tried to connect with VNC and SSH to take a look it would not connect with SSH and with VNC it would not allow me to type anything in so I could not login. This let me to believe that the server was overloaded.
- **Actions Taken**: I first tried to preform a graceful shutdown of the server. However after a few minutes the server never shutdown. I then forced a power off. This brought the server offline. Once it booted back up I was able to login and the services came back online.
- **Remedial Actions**: I am going to limit the amount of threads that the generatoring program is allowed to use. If it causes downtime again, then I will abandon it and find another way to generate an address.  

-----

#### Downtime on March 4th, 2019
- **Time**:  
	- Down: 10:32 UTC (~ 5 minutes)
	- Up: 13:28 UTC (Manual Check). Reported back at 13:29 UTC by Uptime Robot.  
	- Total Time: 2 hours and 55 minutes. (I was asleep when it went down)
- **Affected Services**: blog, failover webserver, hidden service web site, tor exit.
- **Reason/Cause**: I suspect that the program running to generate a custom v3 address caused CPU overload. It had the same symptoms as the previous downtime on March 3rd.
- **Actions Taken**: I forced a restart because it would not respond otherwise.
- **Remedial Actions**: I am abandoning the attempt to generate an address as it is only causing issues. I will see if I can find another to generate an address on less critical infrastructure.

----

