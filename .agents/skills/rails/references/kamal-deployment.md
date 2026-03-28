# Kamal 2 Deployment

## Overview

Kamal 2 deploys Rails applications with zero downtime using Docker and Traefik.

## Basic deploy.yml Structure

```yaml
# config/deploy.yml
service: klop

image: myregistry/klop

servers:
  web:
    hosts:
      - 192.168.1.1
    labels:
      traefik.http.routers.klop.rule: Host(`klop.app`)
      traefik.http.routers.klop.tls.certresolver: letsencrypt

proxy:
  ssl: true
  host: klop.app

registry:
  server: ghcr.io
  username: myuser
  password:
    - KAMAL_REGISTRY_PASSWORD

builder:
  arch: amd64

env:
  clear:
    RAILS_ENV: production
    RAILS_LOG_TO_STDOUT: "true"
    RAILS_SERVE_STATIC_FILES: "true"
  secret:
    - RAILS_MASTER_KEY
    - DATABASE_URL
```

## Secrets Management

Create `.kamal/secrets` (DO NOT commit):

```bash
# .kamal/secrets
KAMAL_REGISTRY_PASSWORD=$GITHUB_TOKEN
RAILS_MASTER_KEY=$(cat config/master.key)
DATABASE_URL=sqlite3:/app/storage/production.sqlite3
```

## Health Checks

```yaml
# config/deploy.yml
healthcheck:
  path: /up
  port: 3000
  interval: 5s
  max_attempts: 10
```

Add health check endpoint to Rails:
```ruby
# config/routes.rb
get "up" => "rails/health#show", as: :rails_health_check
```

## Accessories (SQLite with Litestream)

```yaml
# config/deploy.yml
accessories:
  litestream:
    image: litestream/litestream:latest
    host: 192.168.1.1
    env:
      clear:
        LITESTREAM_ACCESS_KEY_ID: $AWS_ACCESS_KEY_ID
        LITESTREAM_SECRET_ACCESS_KEY: $AWS_SECRET_ACCESS_KEY
      secret:
        - LITESTREAM_ACCESS_KEY_ID
        - LITESTREAM_SECRET_ACCESS_KEY
    volumes:
      - klop_storage:/data
    files:
      - config/litestream.yml:/etc/litestream.yml
```

## Deploy Commands

```bash
# Setup server (first time)
kamal setup

# Deploy
kamal deploy

# Check status
kamal details

# View logs
kamal logs

# Run Rails console
kamal app exec "bin/rails console"

# Run migrations
kamal app exec "bin/rails db:migrate"

# Restart
kamal app restart

# Stop
kamal app stop

# Remove everything
kamal remove
```

## Zero-Downtime Deploys

Kamal 2 uses rolling deploys by default:
1. Starts new container
2. Runs health checks
3. Switches Traefik to new container
4. Stops old container

## Traefik Configuration

Traefik is automatically configured by Kamal. Key labels:

```yaml
servers:
  web:
    hosts:
      - 192.168.1.1
    labels:
      # Basic routing
      traefik.http.routers.klop.rule: Host(`klop.app`)
      
      # HTTPS with Let's Encrypt
      traefik.http.routers.klop.tls: true
      traefik.http.routers.klop.tls.certresolver: letsencrypt
      
      # Sticky sessions (if needed)
      traefik.http.services.klop.loadbalancer.sticky.cookie: true
```

## Debugging

```bash
# View Kamal config
kamal config

# SSH into server
kamal server exec -i

# View Traefik logs
kamal traefik logs

# View app container details
kamal app details

# Check health
kamal app exec "curl -s http://localhost:3000/up"
```

## Common Issues

### Registry Authentication
```bash
# Test registry access
echo $GITHUB_TOKEN | docker login ghcr.io -u USERNAME --password-stdin
```

### Health Check Failing
- Verify `/up` endpoint returns 200
- Check `config/puma.rb` has correct port
- Ensure `config.hosts` includes your domain

### Assets Not Loading
- Verify `RAILS_SERVE_STATIC_FILES=true`
- Check asset compilation in Dockerfile
- Ensure `config.public_file_server.enabled = true`

## Multi-Server Setup

```yaml
servers:
  web:
    hosts:
      - 192.168.1.1
      - 192.168.1.2
    labels:
      traefik.http.routers.klop.rule: Host(`klop.app`)

  worker:
    hosts:
      - 192.168.1.3
    cmd: bundle exec solid_queue
```

## Rollback

```bash
# List previous releases
kamal app containers

# Rollback to previous version
kamal app rollback

# Rollback to specific version
kamal app rollback VERSION
```

## Maintenance Mode

```bash
# Enable
kamal app maintenance on

# Disable
kamal app maintenance off
```
