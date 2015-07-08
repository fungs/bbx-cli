path    := PATH=./vendor/python/bin:$(shell echo "${PATH}")
version := $(shell $(path) python setup.py --version)
build   := dist/biobox_cli-$(version).tar.gz

publish: $(build)
	@$(path) twine upload \
		--username ${PYPI_USERNAME} \
		--password ${PYPI_PASSWORD} \
		$^

feature:
	@$(path) behave features

build: $(build) test-build

test-build: $(build)
	docker run \
		--volume=$(abspath $(dir $^)):/dist:ro \
		python:2.7 \
		/bin/bash -c "pip install --user /$^ && /root/.local/bin/biobox -h"

$(build): $(shell find biobox_cli) requirements.txt setup.py MANIFEST.in
	$(path) python setup.py sdist
	touch $@

bootstrap: vendor/python

vendor/python: requirements.txt
	mkdir -p log
	virtualenv $@ 2>&1 > log/virtualenv.txt
	$(path) pip install -r $< 2>&1 > log/pip.txt
	touch $@

.PHONY: bootstrap build feature test-build publish