# User Documentation — Inception

## What you get

A WordPress site served over HTTPS, backed by MariaDB, plus (bonus) Redis caching, FTP access, a static site, Adminer, and Portainer.

## Setup

1. Add password files in `secrets/`: `db_password.txt`, `db_root_password.txt`, `credentials.txt` (WP admin), `wp_user_password.txt`, `ftp_password.txt`.
2. Edit `.env` with your domain, DB name/user, WordPress site info.
3. Add `127.0.0.1  <DOMAIN_NAME>` to `/etc/hosts`.
4. `make`

## Everyday commands

| Command       | Effect                              |
|---------------|-------------------------------------|
| `make`        | build + start everything            |
| `make down`   | stop containers                     |
| `make clean`  | stop + remove images/volumes        |
| `make fclean` | full reset, deletes persistent data |
| `make re`     | fclean + make                       |

## Where things live

| Service     | URL/Port |
|-------------|---|
| WordPress   | `https://<DOMAIN_NAME>`     |
| Static site | `:8080`                     |
| Adminer     | `:8050`                     |
| Portainer   | `:9443`                     |
| FTP         | `:21` (passive 21000-21010) |

## Troubleshooting

- **Site not loading:** check `/etc/hosts` and that `nginx` container is up (`docker ps`).
- **DB errors:** check `mariadb` logs, confirm secrets files exist and aren't empty.
- **Clean slate needed:** `make fclean && make`.