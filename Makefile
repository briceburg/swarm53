DOCKERFILES := $(wildcard Dockerfile*)
PUBLISH := no
PROJECT := $(shell git remote -v | head -n1 | awk '{print $$2};' | sed 's/.*\///' | sed 's/\.git//')

all: $(DOCKERFILES)
.PHONY: $(DOCKERFILES)

Dockerfile-xx.xx: PUBLISH = yes
$(DOCKERFILES):
	$(eval TAG = $(subst Dockerfile-,,$@))
	$(eval TAG = $(subst Dockerfile,latest,$(TAG)))
	docker build -t briceburg/$(PROJECT) -t briceburg/$(PROJECT):$(TAG) -f $@ .
	if [ "$(PUBLISH)" = "yes" ]; then docker push briceburg/$(PROJECT):$(TAG) ; fi
