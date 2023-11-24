# HELP
# This will output the help for each task
# thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help

help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

APP_NAME = stable-diffusion-sdxl

STAGING_TAG_NAME = asia.gcr.io/piccollage-ml-dev/uwu-webui

docker-run-staging:
	docker run -it --rm --gpus all -p 3011:3011 -p 3021:3021 -p 6066:6066 -p 3001:3001 $(STAGING_TAG_NAME)

docker-build-staging:
	DOCKER_BUILDKIT=1 docker build -t $(STAGING_TAG_NAME) .

docker-push-staging:
	docker push $(STAGING_TAG_NAME)
