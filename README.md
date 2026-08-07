*This project has been created as part of the 42 curriculum by sel-hime.*

# Inception

## Description

Inception sets up a small web infrastructure entirely in Docker: NGINX, WordPress/php-fpm, and MariaDB, each in its own container built from a custom Dockerfile, orchestrated with `docker-compose`. Bonus part adds Redis, an FTP server, a static site, Adminer, and Portainer.

## Instructions

1. Add secret files under `secrets/` (see `docker-compose.yml` for filenames).
2. Fill in `.env` (domain, DB, WordPress credentials, etc.) and add `DOMAIN_NAME` to `/etc/hosts`.
3. Run `make`.

Other targets: `make down`, `make clean`, `make fclean` , `make re`.

Access: WordPress at `https://<DOMAIN_NAME>`, static site `:8080`, Adminer `:8050`,  Portainer `:9443`, FTP `:21`.

See `DEV_DOC.md` for architecture/design details and `USER_DOC.md` for day-to-day usage.

## Project Description: Docker Usage & Design Choices

Each service is built from its own minimal-base Dockerfile (no ready-made app images), runs one main process, and communicates over a single custom bridge network (`inception`) using Docker's internal DNS. NGINX is the only mandatory-part container exposed to the host (443, TLS-terminated). Data persists via named volumes bound to `/home/${LOGIN}/data` on the host. All passwords are handled via Docker secrets, never plain env vars.

**VMs vs Docker** — VMs virtualize a full OS on a hypervisor: strong isolation, slow boot, heavy footprint. Containers share the host kernel: fast, light, easy to reproduce, weaker isolation. Docker fits this project's need for several small services to build/rebuild and compose quickly.

**Secrets vs env vars** — Env vars are readable via `docker inspect`/`/proc/<pid>/environ` and can leak into logs. Docker secrets mount as read-only files under `/run/secrets/`, visible only to services that declare them. Passwords use secrets; non-sensitive config stays in `.env`.

**Docker network vs host network** — Host networking shares the host's namespace directly (no isolation, port collisions). This project uses a custom bridge network so containers get their own namespace, resolve each other by name, and only publish the ports explicitly declared.

**Volumes vs bind mounts** — Plain bind mounts tie you to a host path with no Docker-managed lifecycle. This project uses named volumes with `driver_opts` (`type: none, o: bind`) — Docker manages the volume, but data lives at a known host path, satisfying the subject's requirement.

## Resources

- [Docker docs](https://docs.docker.com/)
- [Compose file reference](https://docs.docker.com/compose/compose-file/)
- [Docker secrets](https://docs.docker.com/engine/swarm/secrets/)
- [WordPress docs](https://wordpress.org/documentation/)
- [wp-cli](https://wp-cli.org/)
- [MariaDB docs](https://mariadb.com/kb/en/documentation/)
- [NGINX docs](https://nginx.org/en/docs/)
- [Redis docs](https://redis.io/docs/latest/)
- [vsftpd](https://security.appspot.com/vsftpd.html)
- [Adminer](https://www.adminer.org/), 
- [Portainer docs](https://docs.portainer.io/)
- 42 Inception subject PDF
