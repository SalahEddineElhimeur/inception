all:
	mkdir -p /home/$USER/data/mariadb
	mkdir -p /home/sel-hime/data/wordpress
	docker compose -f ./srcs/docker-compose.yml up -d --build

down:
	docker compose -f srcs/docker-compose.yml down


clean:
	docker compose -f srcs/docker-compose.yml down -v

fclean: clean
	docker system prune -af
	rm -rf /home/$USER/data/*
re: fclean all