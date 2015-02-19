DOCKER_IMAGE=zvelo/zvelo-gerrit

all: image

image:
	docker build -t $(DOCKER_IMAGE) .
