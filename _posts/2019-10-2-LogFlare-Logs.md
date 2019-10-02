---
layout: post
title: "Cloudflare Log Analysis"
date: 2019-10-02 15:00:00 -5000
image: logflare/title.png
tags: [Tutorial, Cloudflare, Logflare, BigQuery]
categories: [Tutorial, Cloudflare]
---

My website uses Cloudflare as a CDN and as a security measure. Cloudflare basically operates like a man in the middle, which has its pros and cons. It provides analytics on your traffic based on the connections for your domain. One issue with the analytics is that you can not see the raw logs and can only see the overview, so you do not know who or what is hitting your site. Recently, I discovered a service called [Logflare](https://logflare.app) which allows for export of the logs from Cloudflare to its service so you can view the raw logs, plus other metadata.  
![Example Log](/img/logflare/example-request.png)  
[raw json](/other-files/logflare/example.json)  
This gives me plenty of information about who is connecting what and what I sent back. By default, Logflare only saves logs for 7 days. However, you can export logs to BigQuery or explore the logs in Data Studio which gives you better options for visualization. I recently started exporting my logs to BigQuery and then attaching that as a data source for Data Studio. My logs will stay in BigQuery for 30 days because I have not enabled billing. I have created a quick report for download [here](/other-files/logflare/Website_Data_from_9_30.pdf) or you can view it online [here](https://datastudio.google.com/reporting/a7161381-2294-49fa-8439-8eac508999ef). One piece of information that I found interesting was with this chart.
![Interesting Chart](/img/logflare/interesting-chart.png)
That chart is showing that the IP 192.162.240.106 is requesting the file ```t.txt``` from my blog. This file does not exist and this is the only IP that is trying to request this file. If I look at the IP origin it is from Russia. I was curious so I went and found the actual log and this is it
![Russia Google Log](/img/logflare/russia-google.png)
[interesting json](/other-files/logflare/example.json)  
What is interesting is that the request is using the user agent of Google's web crawler bot, however, if we try and verify that it is a legitimate IP of Google's bot using [Google's Recommended Method](https://support.google.com/webmasters/answer/80553), it fails to get a record. This means that it is a fake bot impersonating Google.

This shows the power of being able to view the raw logs and visualizations the logs can have. I plan on keep using the services and will have an update when I have a greater amount of logs.
