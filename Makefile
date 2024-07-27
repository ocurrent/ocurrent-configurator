all:
	docker buildx build -t mtelvers/ocurrent-configurator:latest --progress plain .

run:
	dune exec -- bin/main.exe mtelvers/ansible --github-webhook-secret-file secrets/webhook-secret --github-oauth secrets/oauth.json --github-token-file secrets/github-activity-token --confirm average --port 8001

up:
	docker compose -p ocurrent-configurator up -d

down:
	docker compose -p ocurrent-configurator down
