all:
	docker buildx build -t mtelvers/ocurrent-configurator:latest --progress plain .
