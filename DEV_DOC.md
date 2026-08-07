# Dev Documentation — Inception

## Architecture

- **nginx** — TLS termination (self-signed cert), to `wordpress:9000`. Only mandatory-part container exposed to host (443).
- **wordpress** — php-fpm + WordPress core, provisioned via entrypoint script (wp-cli: DB wait, config, admin/user creation).
- **mariadb** — DB server, entrypoint initializes DB/users on first run, secured (no anonymous/test users, root only from localhost).
- All services on one custom bridge network (`inception`); resolve each other by service name via Docker DNS.

### Bonus

- **redis** — object cache for WordPress (plugin-based).
- **ftp** (vsftpd) — access to the `wordpress` volume; passive range 21000-21010.
- **website** — static HTML/CSS, standalone container, own port (8080).
- **adminer** — DB admin UI, talks to `mariadb`.
- **portainer** — manages Docker via `/var/run/docker.sock` mount.

## Build/config notes

- Every image built from a minimal base (no off-the-shelf app images) — one main foreground process per container.
- Secrets injected as files under `/run/secrets/<name>`, read by entrypoint scripts (never baked into images or passed as plain env vars).
- `.env` holds non-sensitive config (domain, DB name, WP site title, etc.) and `${USER}` for host data path.
- Volumes: named (`mariadb`, `wordpress`), `local` driver with `driver_opts: {type: none, o: bind, device: /home/${USER}/data/...}` — Docker-managed lifecycle, data at a known host path.
- `restart: on-failure` on all services; `depends_on` sets start order only (entrypoints handle actual readiness, e.g. polling MariaDB before WP setup).

## Makefile

- Uses `$(USER)` (never hardcoded) for the data path.
- `fclean` deletes `/home/$(USER)/data` — intentional full wipe for guaranteed reproducibility.

## Known gotchas

- `depends_on` ≠ readiness — race conditions if entrypoint doesn't wait for MariaDB to actually accept connections.
- MariaDB config must not be world-writable and must not run as root inside the container (caused early failures).
- `DOMAIN_NAME` must match both `.env` and `/etc/hosts`, or NGINX/TLS setup won't resolve correctly for local testing.


















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



cat srcs/.env << EOF
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

