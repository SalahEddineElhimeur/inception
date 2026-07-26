all:
	mkdir -p /home/sel-hime/data/mariadb
	mkdir -p /home/sel-hime/data/wordpress
	docker compose -f ./srcs/docker-compose.yml up -d --build

clean:
	docker compose -f ./srcs/docker-compose.yml down
	# Do not delete the data folders here unless you run 'fclean'
