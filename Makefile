IMAGE = kei2100/ridgepole
DOCKER_USERNAME = kei2100
DOCKER_BUILDX = docker buildx
DOCKER_BUILDX_INSTANCE = ridgepole
DOCKER_BUILDX_PLATFORM = linux/arm64,linux/amd64

.PHONY: docker.build
docker.build: docker.init-tag
	docker build -t $(IMAGE) .
	docker tag $(IMAGE):latest $(IMAGE):$(TAG)

.PHONY: docker.push
docker.push: docker.build
	docker push $(IMAGE):$(TAG)

.PHONY: docker.push.buildx
docker.push.buildx: docker.init-tag
	@$(DOCKER_BUILDX) inspect $(DOCKER_BUILDX_INSTANCE) > /dev/null 2>&1 || $(DOCKER_BUILDX) create --name=$(DOCKER_BUILDX_INSTANCE) --driver docker-container
	@$(DOCKER_BUILDX) build \
	  --platform=$(DOCKER_BUILDX_PLATFORM) \
	  --builder=$(DOCKER_BUILDX_INSTANCE) \
	  -t $(IMAGE):$(TAG) \
	  --push .

.PHONY: docker.init-tag
docker.init-tag:
ifndef TAG
	$(eval TAG = $(shell \
	  read -p $$'\e[33mPlease enter the TAG name for $(IMAGE)\e[0m: ' val; \
	  echo $${val} \
	))
endif

ACT_PLATFORM = ubuntu-latest=catthehacker/ubuntu:act-22.04
ACT_JOB = docker-push

.PHONY: gha.docker-push
gha.docker-push: gha.init-docker_password
	@which act > /dev/null 2>&1 || brew install act
	@act \
		--platform=$(ACT_PLATFORM) \
		--job=$(ACT_JOB) \
		--bind \
		-s DOCKER_PASSWORD=$(DOCKER_PASSWORD)

.PHONY: gha.init-docker_password
gha.init-docker_password:
ifndef DOCKER_PASSWORD
	$(eval DOCKER_PASSWORD = $(shell \
	  read -p $$'\e[33mPlease enter the password for `docker login`\e[0m: ' val; \
	  echo $${val} \
	))
endif
