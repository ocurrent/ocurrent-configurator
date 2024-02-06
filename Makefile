all:
	docker buildx build -t mtelvers/ocurrent-configurator:latest --progress plain .

up:
	docker compose -p ocurrent-configurator up -d

down:
	docker compose -p ocurrent-configurator down
