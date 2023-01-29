FROM swift:5.7-focal

RUN apt-get --fix-missing update
RUN apt-get -q install \
  libcurl4

CMD ["swift", "test"]
