PLATFORM_IOS = iOS Simulator,name=iPhone 14 Pro,OS=16.2
PLATFORM_MACOS = macOS
PLATFORM_MAC_CATALYST = macOS,variant=Mac Catalyst
CONFIG ?= debug
DOCKER_PLATFORM ?= linux/arm64
DOCKER_IMAGE_NAME ?= swift-manual-s-server
SERVER_PORT ?= 8080
SWIFT_VERSION ?= 5.7

default: test-swift

test-swift:
	swift test
	
test-linux:
	docker run --rm \
		--volume "$(PWD):$(PWD)" \
		--workdir "$(PWD)" \
		--platform "$(DOCKER_PLATFORM)" \
		"swift:$(SWIFT_VERSION)-focal" swift test

test-library:
	for platform in "$(PLATFORM_MACOS)" "$(PLATFORM_MAC_CATALYST)"; do \
		xcodebuild test \
			-configuration $(CONFIG) \
			-workspace .swiftpm/xcode/package.xcworkspace \
			-scheme swift-manual-s-api-Package \
			-destination platform="$$platform" || exit 1; \
	done;
	
test-all: test-linux
	$(MAKE) CONFIG=debug test-library
	$(MAKE) CONFIG=release test-library

format:
	swift format \
		--ignore-unparsable-files \
		--in-place \
		--recursive \
		./Package.swift \
		./Sources
		
build-server:
	docker build -t $(DOCKER_IMAGE_NAME):latest .
	
run-server: build-server
	docker run -it --rm -p "$(SERVER_PORT):8080" $(DOCKER_IMAGE_NAME):latest

.PHONY: format test-swift test-linux test-library
