include ../includes.mk

NAME=logspout
IMAGE=$(REGISTRY_BUCKET)/$(NAME)

dev:
	docker build -f Dockerfile.dev -t $(NAME):dev .
	docker run \
		-v /var/run/docker.sock:/tmp/docker.sock \
		-p 8000:8000 \
		$(NAME):dev

build: check-docker
	mkdir -p build
	docker build -t $(IMAGE) .
	docker save $(NAME):$(VERSION) | gzip -9 > build/$(NAME)_$(VERSION).tgz

push: check-registry
	@docker tag -f $(IMAGE) $(REGISTRY)$(IMAGE)
	@docker push $(REGISTRY)$(IMAGE)

start:
	@echo "Start Logspout"
	@curl -X POST http://192.168.50.5:8080/v2/apps?force=true -d "`sed -e "s#{{DEV_REGISTRY}}#$(REGISTRY)#" logspout.json`" -H "Content-type: application/json"

stop:
	@echo "Stop Logspout"
	@curl -X DELETE http://192.168.50.5:8080/v2/apps/logspout?force=true &>/dev/null

restart: stop start

deploy: build push restart
