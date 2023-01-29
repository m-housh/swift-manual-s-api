
test-linux:
	@docker run --rm -v "${PWD}:${PWD}" -w "${PWD}" swift:5.7-focal swift test
