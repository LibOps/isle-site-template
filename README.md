# LibOps ISLE Site Template

[![LICENSE](https://img.shields.io/badge/license-MIT-blue.svg?style=flat-square)](./LICENSE)

- [Introduction](#introduction)
- [Requirements](#requirements)
- [Deployment](#deployment)
- [Attribution](#attribution)

## Introduction

This is the development and production infrastructure for Islandora sites running on the LibOps platform. LibOps customers should not have to worry about anything in this repo, and will make any necessary changes to their Islandora instance from their Drupal repository.

## Requirements

- [Docker 24.0+](https://docs.docker.com/get-docker/)
- [Docker Compose](https://docs.docker.com/compose/install/linux/)

## Deployment

This repository will run your Islandora site on the LibOps Platform. It is not intended to be ran locally, but theoretically could with

```
export LIBOPS_ENVIRONMENT=development
export LIBOPS_GCLOUD_PROJECT_ID=your-libops-project-id
export SITE_DOCKER_REGISTRY=us-docker.pkg.dev/${LIBOPS_GCLOUD_PROJECT_ID}/private
export LIBOPS_DOCKER_REGISTRY=us-docker.pkg.dev/libops-images/shared
docker compose up -d
```

> TODO: would need to mock the google metadata server in the locally running instance to allow gcp IAM to work

## Attribution

This codebase was initially forked from [Islandora-Devops/isle-site-template](https://github.com/islandora-devops/isle-site-template/). It was then customized to allow running on the LibOps platform:

- Removed the dev/prod profiles and codeserver
- Removed traefik and TLS. TLS will be handled by a load balancer in front of this deployment
- Moved the drupal container build step into the drupal codebase which will be a separate repo
- Added an SSH service to allow IDE integrations
- Replaced activemq and alpaca with a lightweight service to forward islandora events to Google Cloud Pub/Sub
- replaced local microservices with [fully managed microservices](https://github.com/libops/islandora-microservices)
- added cadvisor metrics and auto-ingest into Google Cloud Monitoring
