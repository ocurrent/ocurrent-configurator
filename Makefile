all:
	docker buildx build -t mtelvers/ocurrent-configurator:latest --progress plain .

run:
	dune exec -- ocurrent-configurator --github-webhook-secret-file secrets/webhook-secret --github-oauth secrets/oauth.json --github-app-id 812230 --github-private-key-file secrets/private-key.pem --github-account-allowlist mtelvers --confirm average

up:
	docker compose -p ocurrent-configurator up -d

down:
	docker compose -p ocurrent-configurator down
