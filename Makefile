NO_COLOR = \033[0m
O1_COLOR = \033[0;01m
O2_COLOR = \033[32;01m

PREFIX = "$(O2_COLOR)==>$(O1_COLOR)"
SUFFIX = "$(NO_COLOR)"

CURRENT_DIR = $(shell pwd)

ZONEMINDER_VERSION := 1.36.31-r2

IMAGE_REPO	:= registry.fuwafuwatime.moe/concord/zoneminder
IMAGE_TAG 	:= $(ZONEMINDER_VERSION)

default: build

.PHONY: help
help: ## This message.
	@echo -e "USAGE: make [COMMAND]\n"
	@echo "Available commands:"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\t\033[36m%-20s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.PHONY: clean
clean: ## Remove existing container images.
	@echo -e $(PREFIX) $@ $(SUFFIX)
	cd $(CURRENT_DIR); \
		(podman rmi $(IMAGE_REPO):$(IMAGE_TAG) || true)

.PHONY: build
build: clean ## Build the container image.
	@echo -e $(PREFIX) $@ $(SUFFIX)
	cd $(CURRENT_DIR); \
		buildah build \
			--build-arg ZONEMINDER_VERSION=$(ZONEMINDER_VERSION) \
			--tag $(IMAGE_REPO):$(IMAGE_TAG) \
			Containerfile
