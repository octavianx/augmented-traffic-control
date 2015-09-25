# You must have a working go environment in order to build atc.
# See https://golang.org/doc/code.html

PROJECT = github.com/facebook/augmented-traffic-control
SRC = ${PROJECT}/src

TEST = go test -v
BUILD = go build
VET = @go vet
FMT = @go fmt
GET = go get
LIST = @go list
BINGEN = go-bindata # https://github.com/jteeuwen/go-bindata
THRIFT = thrift

STATIC_FILES = $(shell find static/ -print)

.PHONY: all
all: get bin bin/atcd bin/atc_api

bin/atcd: src/atc_thrift src/daemon/*.go src/atcd/*.go
	$(FMT) ${SRC}/daemon ${SRC}/atcd
	$(VET) ${SRC}/daemon ${SRC}/atcd
	$(TEST) ${SRC}/daemon ${SRC}/atcd
	$(BUILD) -o $@ ${SRC}/atcd

bin/atc_api: src/atc_thrift src/api/*.go src/atc_api/*.go
	$(FMT) ${SRC}/api ${SRC}/atc_api
	$(VET) ${SRC}/api ${SRC}/atc_api
	$(TEST) ${SRC}/api ${SRC}/atc_api
	$(BUILD) -o $@ ${SRC}/atc_api

src/api/bindata.go: $(STATIC_FILES)
	$(BINGEN) -pkg api -o $@ static/...

src/atc_thrift: if/atc_thrift.thrift
	$(THRIFT) --out src/ --gen go if/atc_thrift.thrift

bin:
	mkdir -p bin/

.PHONY: clean
clean:
	rm -rf bin/

.PHONY: fullclean
fullclean: clean
	rm -rf src/atc_thrift/
	rm -f src/api/bindata.go

.PHONY: get
get:
	$(LIST) -f '{{range .Imports}}{{.}}{{"\n"}}{{end}}' ${SRC}/daemon ${SRC}/atcd ${SRC}/api ${SRC}/atc_api ${SRC}/atc_thrift | sort -u | fgrep '.' | grep -v 'augmented-traffic-control' | xargs $(GET)
