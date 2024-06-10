.PHONY: all clean test run build static upgrade help

all: 			# default action

clean:			# clean-up environment
	flutter clean

test:			# run test
	dart fix --apply && git checkout pubspec.*
	flutter analyze

run:			# run in the local environment
	flutter run -d chrome --web-browser-flag "--disable-web-security"

build:			# build the binary/library
	cp ../assets/logo.svg web/favicon.svg
	flutter build web

static:			# run the static artifact
	python3 -m http.server -d build/web

upgrade:		# upgrade all the necessary packages

help:			# show this message
	@printf "Usage: make [OPTION]\n"
	@printf "\n"
	@perl -nle 'print $$& if m{^[\w-]+:.*?#.*$$}' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?#"} {printf "    %-18s %s\n", $$1, $$2}'
