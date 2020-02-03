WORDPRESS_VERSION = "5.3.2"
WORDPRESS_SHA1 = "fded476f112dbab14e3b5acddd2bcfa550e7b01b"
IMAGE_NAME = "arhea/wordpress"
IMAGE_TAG = "latest"

build:
	@echo "Building Wordpress Container From Source...";
	cd ./docker; docker build --tag $(IMAGE_NAME):$(IMAGE_TAG) --build-arg "WORDPRESS_VERSION=$(WORDPRESS_VERSION)" --build-arg "WORDPRESS_SHA1=$(WORDPRESS_SHA1)" .;
	@echo "Wordpress Version: $(WORDPRESS_VERSION)";
	@echo "Wordpress SHA1: $(WORDPRESS_SHA1)";
	@echo "Image: $(IMAGE_NAME):$(IMAGE_TAG)";

compose-up:
	docker-compose -f ./examples/docker-compose.yml -p wordpress up

compose-down:
	docker-compose -f ./examples/docker-compose.yml -p wordpress down

.PHONY: build
