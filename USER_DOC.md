# USER_DOC.md — User Documentation

## Overview

This project runs a fully containerized web infrastructure using Docker. It provides the following services:

| Service | Description | Access |
|---|---|---|
| WordPress | A fully configured WordPress website | `https://yourlogin.42.fr` |
| MariaDB | Database storing all WordPress content | Internal only |
| NGINX | Secure entry point, serves the website over HTTPS | Port 443 |
| Redis | Cache layer that speeds up the website | Internal only |
| FTP Server | File access to the WordPress volume | Port 21 |
| Adminer | Web interface to browse the database | `http://yourlogin.42.fr:8080` |
| Static Site | A standalone static HTML/CSS website | `http://yourlogin.42.fr:8081` |
| cAdvisor | Real-time container resource monitoring | `http://yourlogin.42.fr:8082` |
| Portainer | Visual Docker management dashboard | `https://yourlogin.42.fr:9443` |

> Replace `yourlogin` with your actual 42 school login in all URLs above.

---

## Starting the Project

From the root of the repository:

```bash
make
```

This single command will:
1. Create the required data directories on the host
2. Build all Docker images from their Dockerfiles
3. Start all containers in the background

To verify everything is running:

```bash
docker compose -f srcs/docker-compose.yml ps
```

All services should show status `Up`.

---

## Stopping the Project

To stop all containers without losing any data:

```bash
make down
```

To stop and remove all containers, images, and networks (data in volumes is preserved):

```bash
make clean
```

To perform a full reset — stops everything and deletes all stored data:

```bash
make fclean
```

> ⚠️ `make fclean` permanently deletes all WordPress content and database data. Use with caution.

To rebuild everything from scratch after a full reset:

```bash
make re
```

---

## Accessing the Website

### WordPress Site

Open your browser and visit:

```
https://yourlogin.42.fr
```

You will see a certificate warning because the site uses a self-signed TLS certificate. Click **Advanced** then **Proceed** to continue.

### WordPress Administration Panel

```
https://yourlogin.42.fr/wp-admin
```

Log in with the administrator credentials found in the credentials file (see section below).

---

## Accessing Bonus Services

### Adminer (Database UI)

```
http://yourlogin.42.fr:8080
```

Fill in the login form:
- **System:** MySQL
- **Server:** `mariadb`
- **Username:** value of `MYSQL_USER` in `srcs/.env`
- **Password:** content of `secrets/db_password.txt`
- **Database:** value of `MYSQL_DATABASE` in `srcs/.env`

### Static Website

```
http://yourlogin.42.fr:8081
```

### cAdvisor (Container Monitoring)

```
http://yourlogin.42.fr:8082
```

Click on `/docker` to see all running containers and their resource usage.

### Portainer (Docker Dashboard)

```
https://yourlogin.42.fr:9443
```

Accept the certificate warning. On first access, set an admin password. Then select the local Docker environment.

### FTP Access

Connect using any FTP client (e.g. FileZilla):
- **Host:** `127.0.0.1`
- **Port:** `21`
- **Protocol:** FTP (passive mode)
- **Username:** value of `FTP_USER` in `srcs/.env`
- **Password:** content of `secrets/ftp_password.txt`

---

## Credentials

All credentials are stored in two locations:

### Environment Variables — `srcs/.env`

Contains non-sensitive configuration values:
- `DOMAIN_NAME` — the site domain (e.g. `yourlogin.42.fr`)
- `MYSQL_DATABASE` — the WordPress database name
- `MYSQL_USER` — the WordPress database username
- `WP_ADMIN_USER` — the WordPress administrator username
- `WP_ADMIN_EMAIL` — the WordPress administrator email
- `WP_USER` — the second WordPress user's username
- `WP_USER_EMAIL` — the second WordPress user's email
- `FTP_USER` — the FTP username

### Secret Files — `secrets/`

Contains sensitive passwords, one value per file:
- `secrets/db_password.txt` — WordPress database user password
- `secrets/db_root_password.txt` — MariaDB root password
- `secrets/wp_admin_password.txt` — WordPress administrator password
- `secrets/wp_user_password.txt` — WordPress second user password
- `secrets/ftp_password.txt` — FTP user password

> ⚠️ These files are gitignored and must never be committed to any repository.

---

## Checking That Services Are Running

### Quick status check

```bash
docker compose -f srcs/docker-compose.yml ps
```

All containers should show `Up` in the Status column.

### View logs for a specific service

```bash
docker compose -f srcs/docker-compose.yml logs -f nginx
docker compose -f srcs/docker-compose.yml logs -f wordpress
docker compose -f srcs/docker-compose.yml logs -f mariadb
```

### Test that the website is reachable

```bash
curl -k https://yourlogin.42.fr
```

You should receive an HTML response.

### Test that the database is responding

```bash
docker exec mariadb mysqladmin ping --silent
```

Should output: `mysqld is alive`

### Test that Redis cache is active

```bash
docker exec redis redis-cli ping
```

Should output: `PONG`

### Verify restart policy

Kill a container and confirm it restarts automatically:

```bash
docker kill wordpress
# wait 5 seconds
docker ps | grep wordpress
# should show the container running again
```

---

## Where Data Is Stored

All persistent data lives on the host machine at:

```
/home/yourlogin/data/
├── mariadb/      ← all database files
└── wordpress/    ← all WordPress PHP files, uploads, themes, plugins
```

This data survives container restarts and rebuilds. It is only deleted by `make fclean`.