DOCKER_PLATFORM ?= linux/arm64

test-swift:
	@swift test
	
test-linux:
	docker run --rm \
		-v "$(PWD):$(PWD)" \
		-w "$(PWD)" \
		--platform "$(DOCKER_PLATFORM)" \
		swift:5.7-focal swift test
