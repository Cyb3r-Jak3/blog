---
author: "Cyb3r Jak3"
title: "Python Library Template"
date: "2020-12-06"
tags: [ Python, CI, "GitHub Actions"]
categories: [ Python, CI ]
thumbnail: "images/python-template/title.webp"
---

One of the things that I discovered when working on python libraries, is that a good amount still uses a lot of manual work when deploying. There are a good number of blog posts about getting automated deploys set up using various services. I decided to go a step further and make it even easier. I have created a template repo that will lint and test code, draft a release, and when the release is published, upload to PyPi. I believe that this will benefit people who are looking to get started but don't know how to have an automated process for everything.
[Template Repo](https://github.com/Cyb3r-Jak3/python_template_repo)

Some of the key features are:

* GitHub Action Templates
* Auto deploy to PyPi
* Issue and Pull Request Templates
* Auto Configured install and test requires

Please go check it out and any feedback is appreciated!
