init: build up

build:
	docker compose build --parallel

up:
	docker compose up -d

down:
	docker compose down --remove-orphans

reload: down init
