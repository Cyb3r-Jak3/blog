---
title: "Github Actions Docker Pipeline"
date: "2021-06-16"
tags: [ "GitHub Actions", CI, Docker ]
categories: [ Docker, CI ]
---

Something that I have been using more and more is [Github Actions](https://github.com/actions). It is an easy to use tool to run tests and build in CI. One of the nice things about it is that is is more module than [GitLab Pipeline]({{< relref "2019-10-28-continuous-integration.md" >}}). There is also a marketplace of company and user created actions so there are many options to choose when you are looking to build something out.

I have used them to build docker pipelines for container building and deployment. I found that actions workflow were great to keep a simple and clean workflow for my [pypy-flask](https://github.com/Cyb3r-Jak3/pypy-flask) docker image. The full workflow file is available [in the repo](https://github.com/Cyb3r-Jak3/pypy-flask/blob/3317792e053a84db3738f35f6e9268ce9dc52cdd/.github/workflows/docker.yml) but I will be breaking it down below.

Full file:

```yaml
name: Docker

on:
  push:


jobs:
  Slim:
    runs-on: ubuntu-latest
    steps:

    - name: Checkout
      uses: actions/checkout@v2

    - name: Login to Docker
      uses: docker/login-action@v1
      if: ${{ startsWith(github.ref, 'refs/tags/v') }}
      with:
        username: ${{ secrets.DOCKER_USERNAME }}
        password: ${{ secrets.DOCKER_PASSWORD }}

    - name: Login To GitHub
      uses: docker/login-action@v1
      if: ${{ startsWith(github.ref, 'refs/tags/v') }}
      with:
        registry: ghcr.io
        username: ${{ github.repository_owner }}
        password: ${{ secrets.CR_PAT }}

    - name: Login To GitLab
      uses: docker/login-action@v1
      if: ${{ startsWith(github.ref, 'refs/tags/v') }}
      with:
        registry: registry.gitlab.com
        username: ${{ secrets.GITLAB_USER }}
        password: ${{ secrets.GITLAB_TOKEN }}

    - name: Docker Meta
      id: meta
      uses: docker/metadata-action@v3
      with:
        images: cyb3rjak3/pypy-flask,ghcr.io/cyb3r-jak3/pypy-flask,registry.gitlab.com/cyb3r-jak3/pypy-flask
        tags: |
          type=ref,event=pr
          type=semver,pattern={{version}}
          type=semver,pattern={{major}}.{{minor}}
          type=sha
        labels: |
          org.label-schema.vcs-url=https://github.com/Cyb3r-Jak3/pypy-flask.git
          org.label-schema.schema-version=1.0.0-rc1

    - name: Set up QEMU
      uses: docker/setup-qemu-action@v1.2.0

    - name: Set up Docker Buildx
      uses: docker/setup-buildx-action@v1.3.0

    - name: Cache Docker layers
      uses: actions/cache@v2.1.6
      with:
        path: /tmp/.buildx-cache
        key: buildx-slim-${{ github.sha }}
        restore-keys: buildx-slim

    - name: Slim Build and Push
      uses: docker/build-push-action@v2.5.0
      with:
        platforms: linux/amd64,linux/arm64
        cache-from: type=local,src=/tmp/.buildx-cache
        cache-to: type=local,dest=/tmp/.buildx-cache
        push: ${{ startsWith(github.ref, 'refs/tags/v') }}
        file: Dockerfile
        tags: ${{ steps.meta.outputs.tags }}
        labels: ${{ steps.meta.outputs.labels }}

  Alpine:
    runs-on: ubuntu-latest
    steps:

    - name: Checkout
      uses: actions/checkout@v2

    - name: Login to Docker
      uses: docker/login-action@v1
      if: ${{ startsWith(github.ref, 'refs/tags/v') }}
      with:
        username: ${{ secrets.DOCKER_USERNAME }}
        password: ${{ secrets.DOCKER_PASSWORD }}

    - name: Login To GitHub
      uses: docker/login-action@v1 
      if: ${{ startsWith(github.ref, 'refs/tags/v') }}
      with:
        registry: ghcr.io
        username: ${{ github.repository_owner }}
        password: ${{ secrets.CR_PAT }}

    - name: Login To GitLab
      uses: docker/login-action@v1
      if: ${{ startsWith(github.ref, 'refs/tags/v') }}
      with:
        registry: registry.gitlab.com
        username: ${{ secrets.GITLAB_USER }}
        password: ${{ secrets.GITLAB_TOKEN }}

    - name: Docker Meta
      id: meta
      uses: docker/metadata-action@v3
      with:
        images: cyb3rjak3/pypy-flask,ghcr.io/cyb3r-jak3/pypy-flask,registry.gitlab.com/cyb3r-jak3/pypy-flask
        flavor: |
          suffix=-alpine
        tags: |
          type=ref,event=pr
          type=semver,pattern={{version}}
          type=semver,pattern={{major}}.{{minor}}
          type=sha
        labels: |
          org.label-schema.vcs-url=https://github.com/Cyb3r-Jak3/pypy-flask.git
          org.label-schema.schema-version=1.0.0-rc1

    - name: Set up QEMU
      uses: docker/setup-qemu-action@v1.2.0

    - name: Set up Docker Buildx
      uses: docker/setup-buildx-action@v1.3.0

    - name: Cache Docker layers
      uses: actions/cache@v2.1.6
      with:
        path: /tmp/.buildx-cache
        key: buildx-alpine-${{ github.sha }}
        restore-keys: buildx-alpine

    - name: Alpine Build and Push
      uses: docker/build-push-action@v2.5.0
      with:
        platforms: linux/amd64,linux/arm64
        cache-from: type=local,src=/tmp/.buildx-cache
        cache-to: type=local,dest=/tmp/.buildx-cache
        push: ${{ startsWith(github.ref, 'refs/tags/v') }}
        file: alpine.Dockerfile
        tags: ${{ steps.meta.outputs.tags }}
        labels: ${{ steps.meta.outputs.labels }}

```

It looks like a lot but the same job is close to being repeated twice to have better caching and means they run in parallel.

### Breaking it down

Main Step

```yaml

# Name of the Workflow
name: Docker

# When to run the workflow
on:
  # Run on all push
  push:

# List of the jobs
jobs:
  # Name of the job
  Slim:
    # Operating system to run. Can be ubuntu, windows or mac
    runs-on: ubuntu-latest
    # List of steps for the job
    steps:

```

After setting up the workflow there are some starter steps for checking out the repo and logging in.

Where there is `uses` in a step it means that the step is using a custom workflow.

```yaml
    # Checkout the repo
    - name: Checkout
      uses: actions/checkout@v2

    # Log into DockerHub
    - name: Login to Docker
      uses: docker/login-action@v1
      # The IF statement means that only tags that start with v will run this step
      if: ${{ startsWith(github.ref, 'refs/tags/v') }}
      # With passes action specific input. Used here with the login creds for DockerHub
      with:
        username: ${{ secrets.DOCKER_USERNAME }}
        password: ${{ secrets.DOCKER_PASSWORD }}

    # Login into GitHub's container registry
    - name: Login To GitHub
      uses: docker/login-action@v1
      # The IF statement means that only tags that start with v will run this step
      if: ${{ startsWith(github.ref, 'refs/tags/v') }}
      # With passes action specific input. Used here with the login creds for GitHub
      with:
        registry: ghcr.io
        username: ${{ github.repository_owner }}
        password: ${{ secrets.CR_PAT }}

    # Login in GitLab's Container registry
    - name: Login To GitLab
      uses: docker/login-action@v1
      # The IF statement means that only tags that start with v will run this step
      if: ${{ startsWith(github.ref, 'refs/tags/v') }}
      # With passes action specific input. Used here with the login creds for GitLab
      with:
        registry: registry.gitlab.com
        username: ${{ secrets.GITLAB_USER }}
        password: ${{ secrets.GITLAB_TOKEN }}
```

Next the metadata is setup for building the container

```yaml

    - name: Docker Meta
      # ID allows us to use the output of the step in later steps
      id: meta
      uses: docker/metadata-action@v3
      # With passes action specific input. Used here to pass the baseline images, tags to generate and labels to add
      with:
        images: cyb3rjak3/pypy-flask,ghcr.io/cyb3r-jak3/pypy-flask,registry.gitlab.com/cyb3r-jak3/pypy-flask
        # The '|' allows for multi line entries.
        tags: |
          type=ref,event=pr
          type=semver,pattern={{version}}
          type=semver,pattern={{major}}.{{minor}}
          type=sha
        labels: |
          org.label-schema.vcs-url=https://github.com/Cyb3r-Jak3/pypy-flask.git
          org.label-schema.schema-version=1.0.0-rc1

```

Once all the metadata has been generated then the build environment is setup

```yaml

    - name: Set up QEMU
      # Using docker action
      uses: docker/setup-qemu-action@v1.2.0

    - name: Set up Docker Buildx
      uses: docker/setup-buildx-action@v1.3.0

    # Using the caching action means we can pass items between workflow runs to speed up runs where not much has changed
    - name: Cache Docker layers
      # Using docker action
      uses: actions/cache@v2.1.6
      with:
        # Path of the files to cache / restore to
        path: /tmp/.buildx-cache
        # The cache key to save the files as
        key: buildx-slim-${{ github.sha }}
        # The cache key to restore with. It will restore from any key that starts with buildx-slim
        restore-keys: buildx-slim
```

Finally the build step

```yaml
    - name: Slim Build and Push
      uses: docker/build-push-action@v2.5.0
      with:
        # Using buildx to build on multiple platforms
        platforms: linux/amd64,linux/arm64
        # Using the cached layers
        cache-from: type=local,src=/tmp/.buildx-cache
        # Saving layers to cache
        cache-to: type=local,dest=/tmp/.buildx-cache
        # Only push to the registries if the git ref is a tag that starts with v
        push: ${{ startsWith(github.ref, 'refs/tags/v') }}
        # The Dockerfile to use when building
        file: Dockerfile
        # The tags for the container. Used from the meta step
        tags: ${{ steps.meta.outputs.tags }}
        # The labels for the container. Used from the meta step
        labels: ${{ steps.meta.outputs.labels }}
```

There is a repeat job that runs for the alpine Dockerfile in the repo only adding the suffix of alpine.

## Wrap up

Using custom actions means that it is much simpler to build out workflows. I don't have to worry about generating all the tags or labels for each image. It also means that it is easier to copy and paste between repos as only a few lines need to be changed. I highly recommend Github actions for people who are just starting with CI/CD solutions

### Further Reading

- [Learn Github Actions](https://docs.github.com/en/actions/learn-github-actions)
- [Workflow Syntax for Actions](https://docs.github.com/en/actions/reference/workflow-syntax-for-github-actions)

#### Actions used

In order of use

- [actions/checkout](https://github.com/actions/checkout)
- [docker/login-action](https://github.com/docker/login-action)
- [docker/metadata-action](https://github.com/docker/metadata-action)
- [docker/setup-qemu-action](https://github.com/docker/setup-qemu-action)
- [docker/setup-buildx-action](https://github.com/docker/setup-buildx-action)
- [actions/cache](https://github.com/actions/cache)
- [docker/build-push-action](https://github.com/docker/build-push-action)
