# swift-manual-s-api

[![CI](https://github.com/m-housh/swift-manual-s-api/actions/workflows/ci.yml/badge.svg)](https://github.com/m-housh/swift-manual-s-api/actions/workflows/ci.yml)

A server written in swift that serves an api and html site for Manual-S calculations.

This project is under active development, so documentation is currently lacking and the api's are subject to
change.

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

### Run in docker

Docker can be downloaded for your machine [here](https://www.docker.com).

This will build the docker image and then run it on your machine.

```bash
make run-server-in-docker
```

By default it runs on your local machine on port `8080`, you can change the
local port by adding the `SERVER_PORT` variable to the environment of the `make`
command.

```bash
make SERVER_PORT=8000 run-server-in-docker
```

## Dependencies

This project relys on several other open-source packages, including (but not limited to):

- [apple/swift-log](https://github.com/apple/swift-log)
- [pointfreeco/swift-dependencies](https://github.com/pointfreeco/swift-dependencies)
- [pointfreeco/swift-url-routing](https://github.com/pointfreeco/swift-url-routing)
- [pointfreeco/swift-html](https://github.com/pointfreeco/swift-url-routing)
- [vapor/vapor](https://github.com/vapor/vapor)
