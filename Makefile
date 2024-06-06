SRC := $(shell find . -name '*.go')
BIN := relink

SUBDIR := web

.PHONY: all clean test run build upgrade help $(SUBDIR)

all: $(SUBDIR) 		# default action
	@[ -f .git/hooks/pre-commit ] || pre-commit install --install-hooks
	@git config commit.template .git-commit-template

clean: $(SUBDIR)	# clean-up environment
	@find . -name '*.sw[po]' -delete

test: $(SUBDIR)		# run test
	$(MAKE) -C $(SUBDIR) build
	go test ./...

run:				# run in the local environment
	./relink server -vv -u http://localhost:8080 --auth-token=example

build: $(SUBDIR)	# build the binary/library
	go build -ldflags "-w -s" -o $(BIN) cmd/$(BIN)/main.go

upgrade:			# upgrade all the necessary packages
	pre-commit autoupdate

help:				# show this message
	@printf "Usage: make [OPTION]\n"
	@printf "\n"
	@perl -nle 'print $$& if m{^[\w-]+:.*?#.*$$}' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?#"} {printf "    %-18s %s\n", $$1, $$2}'

$(SUBDIR):
	$(MAKE) -C $@ $(MAKECMDGOALS)

test run build: linter
linter:
	@go mod tidy
	@gofmt -s -w $(SRC)
