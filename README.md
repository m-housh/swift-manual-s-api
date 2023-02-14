# swift-manual-s-api

[![CI](https://github.com/m-housh/swift-manual-s-api/actions/workflows/ci.yml/badge.svg)](https://github.com/m-housh/swift-manual-s-api/actions/workflows/ci.yml)

A server written in swift that serves an api and html site for Manual-S calculations.

This project is under active development, so hosted documentation is currently lacking 
and the api's are subject to change.

- [Run locally](#run-locally)
- [Run in docker](#run-in-docker)
- [Build from source](#building-the-image-from-source)
- [View documents locally](#viewing-the-documents)
- [Project Dependencies](#dependencies)

## Run locally

Clone the repository.

```bash
git clone https://github.com/m-housh/swift-manual-s-api.git
```

### Run on macOS

Xcode is required to run on macOS, which can be download from the app store.

[Download Xcode](https://apps.apple.com/us/app/xcode/id497799835?mt=12)

Once Xcode is installed you can run the following command in the root of the package
directory.

```bash
make run-server
```

This will build and run the server, or you can open the project in Xcode by clicking on the
`Package.swift` file or using the following command in the terminal from the root project
directory.

```bash
xed .
```

### Run in docker

Docker can be downloaded for your machine [here](https://www.docker.com).

#### Pull a pre-built image.

The following command will pull a pre-built image that can run the server locally.
This will be the latest release version, which will be a `slim` version of the build.
It will only be able to run the server, no other commands will easily work inside the
container, which will be fine for most development use cases.

> Note: By default the `linux/amd64` versions get built in the `ci/cd` pipeline, the
> `linux/arm64` variants may not always be available as they have to be built and pushed
> seperately.

```bash
docker pull ghcr.io/m-housh/swift-manual-s-api:latest
```

Then run the server image.

```bash
docker run -it --rm ghcr.io/m-housh/swift-manual-s-api:latest
```

If you would like to pull a pre-built image of the main branch that can be used more
broadly for tests or other commands, you can use the following command to pull a 
development container image, only `linux/amd64` images will be built for the main branch.

```bash
docker pull ghcr.io/m-housh/swift-manual-s-api:dev
```

You could then run tests in the development container.

```bash
docker run -it --rm ghcr.io/m-housh/swift-manual-s-api:dev swift test
```

### Building the image from source

First build the docker image.

```bash
make build-docker-image
```

Then run the image.

```bash
make run-server-in-docker
```

By default it runs on your local machine on port `8080`, you can change the
local port by adding the `SERVER_PORT` variable to the environment of the `make`
command.

```bash
make SERVER_PORT=8000 run-server-in-docker
```

## Viewing the documents

Once you have the container running locally, if you open your browser to:

```bash
http://localhost:8080/
```

Then you can browse the documents and api routes.

If you specified a different port when starting the container, then use whichever server 
port you specified.


## Dependencies

This project relys on several other open-source packages, including (but not limited to):

- [apple/swift-log](https://github.com/apple/swift-log)
- [m-housh/swift-validations](https://github.com/m-housh/swift-validations)
- [pointfreeco/swift-dependencies](https://github.com/pointfreeco/swift-dependencies)
- [pointfreeco/swift-url-routing](https://github.com/pointfreeco/swift-url-routing)
- [pointfreeco/swift-html](https://github.com/pointfreeco/swift-url-routing)
- [vapor/vapor](https://github.com/vapor/vapor)
