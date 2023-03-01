PLATFORM_IOS = iOS Simulator,name=iPhone 14 Pro,OS=16.2
PLATFORM_MACOS = macOS
PLATFORM_MAC_CATALYST = macOS,variant=Mac Catalyst
CONFIG ?= debug
DOCKER_PLATFORM ?= linux/arm64
DOCKER_IMAGE_NAME ?= ghcr.io/m-housh/swift-manual-s-api
DOCKER_TAG ?= latest
DOCKERFILE ?= Bootstrap/Dockerfile.prod
SERVER_PORT ?= 8080
SWIFT_VERSION ?= 5.7
LOG_LEVEL ?= info
DOCC_TARGET ?= SiteMiddlewareLive
TEST_SERVER ?= 1
PREFIX ?= $(HOME)/.local
BINDIR = $(PREFIX)/bin
LIBDIR = $(PREFIX)/lib
COMPLETIONDIR = $(PREFIX)/completions

default: test-swift

test-swift:
	swift test

test-linux:
	docker run --rm \
		--volume "$(PWD):$(PWD)" \
		--workdir "$(PWD)" \
		--platform "$(DOCKER_PLATFORM)" \
		--env "TEST_SERVER=$(TEST_SERVER)" \
		"swift:$(SWIFT_VERSION)-focal" swift test

test-dev-image: build-docker-dev-image
	docker run -it --rm \
		$(DOCKER_IMAGE_NAME):dev \
		swift test

test-library:
	for platform in "$(PLATFORM_MACOS)" "$(PLATFORM_MAC_CATALYST)"; do \
		xcodebuild test \
			-configuration $(CONFIG) \
			-workspace .swiftpm/xcode/package.xcworkspace \
			-scheme server \
			-destination platform="$$platform" || exit 1; \
	done;

# Runs a server in docker, then test's the
# live api client.
test-client: remove-client-test-container
	docker run \
		--name "api-client-test" \
		--detach \
		-p "$(SERVER_PORT):8080" \
		-e "LOG_LEVEL=$(LOG_LEVEL)" \
		-e "BASE_URL=$(BASE_URL)" \
		$(DOCKER_IMAGE_NAME):$(DOCKER_TAG)

	for platform in "$(PLATFORM_IOS)" "$(PLATFORM_MACOS)" "$(PLATFORM_MAC_CATALYST)"; do \
		xcodebuild test \
			-configuration $(CONFIG) \
			-workspace .swiftpm/xcode/package.xcworkspace \
			-scheme ApiClient \
			-destination platform="$$platform" || exit 1; \
	done;

	$(MAKE) remove-client-test-container

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

build-docker-image:
	docker build \
		--file $(DOCKERFILE) \
		--tag $(DOCKER_IMAGE_NAME):$(DOCKER_TAG) \
		--platform $(DOCKER_PLATFORM) \
		.

build-docker-dev-image:
	$(MAKE) DOCKERFILE="Bootstrap/Dockerfile.dev" \
		DOCKER_TAG="dev" \
		build-docker-image

push-docker-image:
	docker push $(DOCKER_IMAGE_NAME):$(DOCKER_TAG)

push-docker-dev-image:
	$(MAKE) DOCKER_TAG="dev" push-docker-image

remove-client-test-container:
	docker container kill $(shell docker container ls --all --quiet --filter name=^/api-client-test$) || true
	docker container rm $(shell docker container ls --all --quiet --filter name=^/api-client-test$)	|| true

run-server:
	LOG_LEVEL=$(LOG_LEVEL) swift run server

run-server-in-docker:
	docker run \
		-it \
		--rm \
		-p "$(SERVER_PORT):8080" \
		-e "LOG_LEVEL=$(LOG_LEVEL)" \
		-e "BASE_URL=$(BASE_URL)" \
		$(DOCKER_IMAGE_NAME):$(DOCKER_TAG)

build-documentation:
	swift package \
		--allow-writing-to-directory ./docs \
		generate-documentation \
		--target $(DOCC_TARGET) \
		--disable-indexing \
		--transform-for-static-hosting \
		--hosting-base-path swift-manual-s-api \
		--output-path ./docs

preview-documentation:
	swift package \
		--disable-sandbox \
		preview-documentation \
		--target $(DOCC_TARGET)

clean:
	rm -rf .build || true

build:
	swift build -c release --disable-sandbox

install: build
	install -d "$(BINDIR)" "$(LIBDIR)"
	install .build/release/equipment-selection "$(BINDIR)"

install-completions:
	install -d "$(COMPLETIONDIR)"
	"$(BINDIR)/equipment-selection" --generate-completion-script zsh > "$(COMPLETIONDIR)/_equipment-selection"

uninstall:
	rm "$(BINDIR)/equipment-selection" || true
	rm "$(COMPLETIONDIR)/_equipment-selection" || true

.PHONY: format test-swift test-linux test-library
