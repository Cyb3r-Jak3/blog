---
layout: post
title: "BitBucket Pipelines"
date: 2019-03-06 17:00:00 -5000
image: pipelines/bitbucket-pipelines.png
tags: [Tutorial, Announcements]
catergories: [Announcements]
---
Something that I recently completed over the weekend was using bitbucket pipelines to automate the building and deployment of my blog. Previously I was building the site on my computer and sftping the files to my hosting server. This worked reasonably well. I had links set up so that I could upload the files to a folder in the home directory and then it would link those files to the /var/www/ folder. It wasn't the best setup because I would have to link the files every time that I added new files. Also, it wasn't really that secure, I felt. Nginx was loading files from a folder in a home directory so it was not that clean. I always wanted to automate the process because it just makes everything easier. I tried using git deploy hooks but it did not really work for me.  
  
Pipelines are something I have wanted to look at because they seem like a cool concept and can be extremely useful. I have used [Travis Ci](https://travis-ci.org/) before, but I was never really that good with it. Plus I did not understand it that much. I got the concepts of it before, but I have never really needed something like it offered. I might look at adding it to this project for the experience.  
  
With pipelines, it was easy and there were examples offered by BitBucket to use. I selected the ruby template and make a couple edits and boom, my builds were passing. Adding the deployment feature of it was even easier. They have templates for deploying with multiple Azure, AWS and Google services. I choose to go with SCP copy because is quicker to set up and I don't need to worry about transfer two ways like with SFTP.  
To set it up, all you need to add is file called bitbucket-pipelines.yml to your working folder in the repository. My completed config is
![Pipeline Config File](/img/pipelines/configfile.png)  
  
Breaking it down:  
There are two steps to it. The first step builds and tests my site while the seconds one deploys it if I manually trigger it. This means that I can run as many builds as I want and it only deploys if it looks good to me. With that all it takes is for me to push to the master branch on bitbucket and it will deploy.
