
# Inception

## Description

Inception is a system administration project from the 42 curriculum whose goal is to set up a small, production-style web infrastructure entirely inside Docker containers, each built from a custom Dockerfile (no pre-built application images from Docker Hub, aside from a minimal base OS image).

The mandatory part deploys a single WordPress website behind NGINX, backed by a MariaDB database, with each service running in its own container, all wired together on a dedicated Docker network and orchestrated through `docker-compose`. On top of the mandatory part, this repository also implements the bonus part, adding:

- **Redis** — object cache for WordPress
- **FTP server** — access to the WordPress volume
- **Static website** — a small standalone HTML/CSS site
- **Adminer** — a lightweight web UI for the MariaDB database
- **Portainer** — a web UI for managing the Docker environment

The project is as much about container orchestration as it is about classic sysadmin concerns: TLS termination, secrets management, service isolation, persistent storage, and reproducible builds.

## Instructions

### Prerequisites

- A Linux VM (or bare-metal machine) with Docker and `docker-compose` installed
- `make`

### Setup

1. Clone the repository.
2. Create the required secret files under `secrets/` (see `docker-compose.yml` for the exact filenames expected: `db_password.txt`, `db_root_password.txt`, `credentials.txt`, `wp_user_password.txt`, `ftp_password.txt`).
3. Fill in the `.env` file at the project root with the required environment variables (domain name, database name/user, WordPress admin/user info, etc.). `DOMAIN_NAME` should match an entry added to `/etc/hosts` pointing to `127.0.0.1`.
4. Run:

   ```bash
   make
   ```

   This builds every image and starts all containers via `docker-compose`.

### Useful targets

- `make` — build and start all services
- `make down` — stop and remove the containers
- `make clean` — stop containers and remove images/volumes
- `make fclean` — full clean, including deleting the persistent data stored at `/home/$(USER)/data` (guarantees a clean state on the next `make`)
- `make re` — `fclean` followed by `make`

### Accessing the services

- WordPress site: `https://<DOMAIN_NAME>`
- Static website (bonus): `http://<host>:8080`
- Adminer (bonus): `http://<host>:8050`
- Portainer (bonus): `https://<host>:9443`
- FTP (bonus): port 21, passive range 21000-21010

## Project Description: Docker Usage & Design Choices

Every mandatory service (`mariadb`, `wordpress`, `nginx`) and every bonus service is built from its own Dockerfile under `requirements/`, based on a minimal Debian/Alpine image, rather than pulled as a ready-made application image. Each container runs a single main process in the foreground (no supervisors like `systemd` or multiple background daemons), which keeps the containers restartable, debuggable, and in line with the "one process per container" philosophy Docker is built around.

Key design choices in this repository:

- **NGINX is the only entry point.** It's the sole container publishing a port to the host (443), terminates TLS with a self-signed certificate, and proxies PHP requests to WordPress over `php-fpm`. No other web-facing container is reachable without going through it (aside from bonus services, which are intentionally exposed for direct access/administration).
- **A single custom bridge network (`inception`)** connects every service, so containers reach each other by container/service name (e.g. `wordpress` resolves to the WordPress container) instead of hardcoded IPs.
- **Named volumes with bind-mount driver options** (`mariadb`, `wordpress`) persist database files and the WordPress codebase/uploads outside the container lifecycle, at `/home/${USER}/data/` on the host.
- **Docker secrets** are used for every password (DB root/user passwords, WordPress admin/user passwords, FTP password), injected as files rather than plaintext environment variables.
- **`restart: on-failure`** on every service gives basic self-healing without masking a genuinely broken build.
- **`depends_on`** encodes the startup order (MariaDB before WordPress, WordPress before NGINX/FTP/Redis), though it only waits for container start, not for the application inside to be ready — entrypoint scripts handle the actual readiness logic (e.g. waiting for MariaDB to accept connections).

### Virtual Machines vs Docker

A VM virtualizes an entire machine: it runs its own full kernel and OS on top of a hypervisor, which makes it heavier to boot, larger on disk, and slower to start (minutes), but gives very strong isolation since the guest OS is completely separate from the host. Docker containers share the host's kernel and only package the application plus its userspace dependencies, so they start in seconds, use a fraction of the disk/RAM, and are trivial to reproduce identically across machines — at the cost of weaker isolation (a kernel-level exploit can affect the host) and being tied to the host's kernel/OS family. For this project, Docker was the natural fit: several small, independent services (web server, PHP app, database) that need to start fast, be rebuilt often during development, and be composed together — a use case Docker is designed for, whereas a VM per service would be needlessly heavy.

### Secrets vs Environment Variables

Environment variables set via `.env`/`environment:` are visible to any process in the container, get inherited by child processes, and — critically — are readable by anyone with access to `docker inspect` on that container, or by dumping `/proc/<pid>/environ`; they can also leak into logs or crash dumps. Docker secrets are instead mounted as read-only, in-memory files under `/run/secrets/<name>` inside the container, visible only to the services that explicitly declare them, and are never exposed to `docker inspect`. That's why in this project, values that identify a real identity or grant access — database passwords, WordPress admin/user passwords, the FTP password — are passed as secrets, while non-sensitive configuration (domain name, DB name, WordPress site title, etc.) stays in `.env`.

### Docker Network vs Host Network

With host networking, a container shares the host's network namespace directly: no isolation, no virtual interface, and it binds directly to host ports — simple, but it removes the point of containerizing network-facing services and creates port-collision risk between containers. This project instead defines a custom bridge network (`inception`), which gives each container its own network namespace and a private IP on that bridge, lets containers resolve each other by service name via Docker's embedded DNS, and only exposes to the host the ports explicitly published in `docker-compose.yml` (443 for NGINX, plus the bonus services' ports). This keeps internal traffic (e.g. NGINX → WordPress → MariaDB) fully isolated from the host network and from anything outside the `inception` network.

### Docker Volumes vs Bind Mounts

A bind mount maps an arbitrary path on the host filesystem directly into the container; it's simple and lets you edit files from the host, but it's tied to the host's exact directory layout, has no Docker-managed lifecycle, and is easy to point at the wrong (or an unintended) path. A Docker volume is managed by Docker itself, has a defined lifecycle independent of any single container, and is more portable across environments. In this repository, the `mariadb` and `wordpress` volumes are declared as named Docker volumes, but configured with the `local` driver and `driver_opts` (`type: none`, `o: bind`, `device: /home/${LOGIN}/data/...`) — a hybrid required by the subject: Docker manages the volume's lifecycle and reference-counting like a normal volume, while the actual data physically lives at a known, predictable path on the host (as the subject requires), rather than buried in Docker's internal storage directory.

## Resources

- [Docker documentation](https://docs.docker.com/)
- [Docker Compose file reference](https://docs.docker.com/compose/compose-file/)
- [Docker secrets documentation](https://docs.docker.com/engine/swarm/secrets/)
- [WordPress documentation](https://wordpress.org/documentation/)
- [WordPress CLI (wp-cli) documentation](https://wp-cli.org/)
- [MariaDB documentation](https://mariadb.com/kb/en/documentation/)
- [NGINX documentation](https://nginx.org/en/docs/)
- [NGINX + php-fpm configuration guides](https://www.nginx.com/resources/wiki/start/topics/examples/phpfcgi/)
- [Redis documentation](https://redis.io/docs/latest/)
- [vsftpd documentation](https://security.appspot.com/vsftpd.html)
- [Adminer](https://www.adminer.org/)
- [Portainer documentation](https://docs.portainer.io/)
- 42 Inception subject PDF (distributed via the school's intranet)