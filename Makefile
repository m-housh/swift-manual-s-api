DOCKER_PLATFORM ?= linux/arm64
SWIFT_VERSION ?= 5.7

test-swift:
	@swift test
	
test-linux:
	docker run --rm \
		--volume "$(PWD):$(PWD)" \
		--workdir "$(PWD)" \
		--platform "$(DOCKER_PLATFORM)" \
		"swift:$(SWIFT_VERSION)-focal" swift test
