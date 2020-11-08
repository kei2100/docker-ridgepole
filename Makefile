IMAGE = kei2100/ridgepole
DOCKER_USERNAME = kei2100

.PHONY: docker.build
docker.build: docker.init-tag
	docker build -t $(IMAGE) .
	docker tag $(IMAGE):latest $(IMAGE):$(TAG)

.PHONY: docker.push
docker.push: docker.build
	docker push $(IMAGE):$(TAG)

.PHONY: docker.init-tag
docker.init-tag:
ifndef TAG
	$(eval TAG = $(shell \
	  read -p $$'\e[33mPlease enter the TAG name for $(IMAGE)\e[0m: ' val; \
	  echo $${val} \
	))
endif

ACT_PLATFORM = ubuntu-latest=nektos/act-environments-ubuntu:18.04
ACT_JOB = docker-push

.PHONY: gha.docker-push
gha.docker-push: gha.init-docker_password
	@which act > /dev/null 2>&1 || brew install nektos/tap/act
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
