# DEV_DOC.md — Developer Documentation

## Prerequisites

The following must be available on the host machine before building:

| Requirement | Minimum Version | Check |
|---|---|---|
| Docker Engine | 24.0+ | `docker --version` |
| Docker Compose plugin | 2.20+ | `docker compose version` |
| GNU Make | 4.0+ | `make --version` |
| A Linux VM | Debian-based recommended | — |

Docker must be runnable without `sudo`. If not:

```bash
sudo usermod -aG docker $USER
newgrp docker
```

---

## Repository Structure

```
inception/
├── Makefile                        ← project entry point
├── USER_DOC.md                     ← user documentation
├── DEV_DOC.md                      ← this file
├── secrets/                        ← gitignored password files
│   ├── db_password.txt
│   ├── db_root_password.txt
│   ├── wp_admin_password.txt
│   ├── wp_user_password.txt
│   └── ftp_password.txt
└── srcs/
    ├── .env                        ← gitignored environment variables
    ├── docker-compose.yml
    └── requirements/
        ├── nginx/
        │   ├── Dockerfile
        │   ├── conf/nginx.conf
        │   └── tools/nginx-start.sh
        ├── wordpress/
        │   ├── Dockerfile
        │   ├── conf/www.conf
        │   └── tools/wp-setup.sh
        ├── mariadb/
        │   ├── Dockerfile
        │   ├── conf/my.cnf
        │   └── tools/db-init.sh
        └── bonus/
            ├── redis/
            ├── ftp/
            ├── static_site/
            ├── adminer/
            ├── cadvisor/
            └── portainer/
```

---

## Environment Setup from Scratch

### Step 1 — Clone the repository

```bash
git clone https://github.com/yourlogin/inception.git
cd inception
```

### Step 2 — Create the secrets directory and files

```bash
mkdir -p secrets
echo "your_db_password"       > secrets/db_password.txt
echo "your_root_password"     > secrets/db_root_password.txt
echo "your_admin_password"    > secrets/wp_admin_password.txt
echo "your_user_password"     > secrets/wp_user_password.txt
echo "your_ftp_password"      > secrets/ftp_password.txt
```

> Each file must contain only the password value — no extra spaces, no newlines beyond the value itself.

### Step 3 — Create the `.env` file

```bash
cat > srcs/.env << EOF
DOMAIN_NAME=yourlogin.42.fr
DATA_PATH=/home/yourlogin/data

MYSQL_DATABASE=wordpress
MYSQL_USER=wpuser
MYSQL_ROOT_PASSWORD_FILE=/run/secrets/db_root_password
MYSQL_PASSWORD_FILE=/run/secrets/db_password

WP_TITLE=Inception
WP_ADMIN_USER=boss
WP_ADMIN_EMAIL=boss@example.com
WP_USER=editor
WP_USER_EMAIL=editor@example.com

FTP_USER=ftpuser
EOF
```

> Replace all values with your actual configuration. The admin username must NOT contain `admin` or `administrator` in any form.

### Step 4 — Add domain to `/etc/hosts`

```bash
echo "127.0.0.1   yourlogin.42.fr" | sudo tee -a /etc/hosts
```

Verify:

```bash
ping -c 1 yourlogin.42.fr
# should resolve to 127.0.0.1
```

### Step 5 — Verify gitignore

Confirm secrets and `.env` are never committed:

```bash
cat .gitignore
# must contain:
# secrets/
# srcs/.env
```

---

## Building and Launching

### Full build and start

```bash
make
```

Internally this runs:
1. `mkdir -p /home/yourlogin/data/wordpress /home/yourlogin/data/mariadb` — creates host data directories
2. `docker compose -f srcs/docker-compose.yml up -d --build` — builds all images and starts all containers

### Build without starting

```bash
docker compose -f srcs/docker-compose.yml build
```

### Rebuild a single service (without touching others)

```bash
docker compose -f srcs/docker-compose.yml up -d --build nginx
docker compose -f srcs/docker-compose.yml up -d --build wordpress
docker compose -f srcs/docker-compose.yml up -d --build mariadb
```

### Force full rebuild ignoring cache

```bash
docker compose -f srcs/docker-compose.yml build --no-cache
```

---

## Makefile Targets Reference

| Target | Description |
|---|---|
| `make` / `make all` | Create data directories + build + start all services |
| `make up` | Start all services (assumes images already built) |
| `make down` | Stop and remove containers and networks (data preserved) |
| `make clean` | `make down` + remove all unused Docker images |
| `make fclean` | `make clean` + delete all host data at `/home/yourlogin/data` |
| `make re` | `make fclean` + `make all` — full clean rebuild |

---

## Container Management Commands

### Status

```bash
# All containers
docker compose -f srcs/docker-compose.yml ps

# Or using docker directly
docker ps -a
```

### Logs

```bash
# Follow all services
docker compose -f srcs/docker-compose.yml logs -f

# Follow a specific service
docker compose -f srcs/docker-compose.yml logs -f mariadb
docker compose -f srcs/docker-compose.yml logs -f wordpress
docker compose -f srcs/docker-compose.yml logs -f nginx

# Last 100 lines
docker logs --tail 100 mariadb
```

### Shell access

```bash
# Open a bash shell inside a container
docker exec -it nginx bash
docker exec -it wordpress bash
docker exec -it mariadb bash
docker exec -it redis bash
```

### Inspect a container

```bash
# Full JSON details (mounts, network, env vars, etc.)
docker inspect mariadb

# Just the IP address
docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' mariadb

# Just the mounts
docker inspect -f '{{.Mounts}}' wordpress
```

### Network inspection

```bash
# Verify all containers are on the inception network
docker network inspect inception

# List all networks
docker network ls
```

### Restart a single service

```bash
docker compose -f srcs/docker-compose.yml restart nginx
```

---

## Volume and Data Management

### Where data lives

| Volume | Host path | Container path | Used by |
|---|---|---|---|
| `mariadb_data` | `/home/yourlogin/data/mariadb` | `/var/lib/mysql` | mariadb |
| `wordpress_data` | `/home/yourlogin/data/wordpress` | `/var/www/html` | wordpress, nginx, ftp |

### Verify data is persisted on the host

```bash
ls /home/yourlogin/data/mariadb/
# should show: mysql/  wordpress/  ibdata1  ib_logfile0 ...

ls /home/yourlogin/data/wordpress/
# should show: wp-config.php  wp-admin/  wp-content/  wp-includes/  index.php ...
```

### Inspect a volume

```bash
docker volume ls
docker volume inspect inception_mariadb_data
```

### Delete all data (full reset)

```bash
make fclean
# then rebuild:
make
```

> This deletes everything in `/home/yourlogin/data/`. All WordPress posts, users, and database contents are permanently lost.

---

## Debugging Common Issues

### Container exits immediately

```bash
docker logs <container_name>
# Read the last lines — they explain why the container crashed
```

### WordPress can't connect to MariaDB

```bash
# Check MariaDB is actually running and accepting connections
docker exec mariadb mysqladmin ping --silent

# Check the inception network — all services should be listed
docker network inspect inception

# Verify the DB user exists
docker exec -it mariadb mysql -u root -p
# enter root password, then:
SELECT User, Host FROM mysql.user;
```

### NGINX returns 502 Bad Gateway

```bash
# php-fpm isn't ready or crashed
docker logs wordpress
# look for errors near the end
```

### TLS certificate warning

This is expected — the certificate is self-signed. Accept it in the browser by clicking **Advanced → Proceed**.

### Port already in use

```bash
# find what is using port 443
sudo lsof -i :443
# stop any conflicting process, then restart:
make down && make up
```

### Full environment check

```bash
# Run all services health checks at once
docker exec mariadb mysqladmin ping --silent && echo "MariaDB OK"
docker exec redis redis-cli ping && echo "Redis OK"
curl -sk https://yourlogin.42.fr | grep -q "WordPress" && echo "WordPress OK"
```

---

## How Data Persists

Each service that needs persistent storage uses a named Docker volume backed by a bind mount to `/home/yourlogin/data/`:

```yaml
volumes:
  mariadb_data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /home/yourlogin/data/mariadb
```

This means:
- `docker compose down` → containers removed, data intact
- `docker compose up --build` → containers recreated, data intact, MariaDB skips re-initialization
- `make fclean` → data deleted, next `make` starts from a blank state

The entrypoint scripts check for existing data before initializing:
- **MariaDB:** checks `if [ ! -d "/var/lib/mysql/mysql" ]`
- **WordPress:** checks `if [ ! -f "/var/www/html/wp-config.php" ]`

If the check passes (data exists), the service starts directly without re-running setup.

---

## Security Notes

- All passwords are stored as Docker secrets (files under `secrets/`) and mounted at `/run/secrets/<name>` inside containers — never as plain environment variables visible in `docker inspect`
- No credentials appear in any Dockerfile or `docker-compose.yml`
- The `secrets/` directory and `srcs/.env` are listed in `.gitignore` and must never be pushed to any remote repository
- NGINX only accepts connections on port 443 using TLSv1.2 or TLSv1.3 — no plain HTTP
- MariaDB is not exposed outside the Docker network — only accessible from containers on the `inception` network
- The FTP user is chrooted to `/var/www/html` — cannot browse outside the WordPress directory