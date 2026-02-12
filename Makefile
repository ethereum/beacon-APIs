.PHONY: default build serve lint clean

default: build serve

build:
	npx swagger-cli bundle ./beacon-node-oapi.yaml -r -t yaml -o ./deploy/beacon-node-oapi.yaml

serve:
	npx http-server -c-1 deploy -o "/?urls.primaryName=dev"

lint:
	npx @redocly/cli lint beacon-node-oapi.yaml

clean:
	rm -f ./deploy/beacon-node-oapi.yaml
