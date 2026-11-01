.PHONY: setup check lint test mutants

check: lint test mutants

setup:
	git config core.hooksPath .githooks

lint:
	shellcheck clacc install.sh tests/*.sh tests/stub/* .githooks/*
	tests/requirements.sh

test:
	tests/run.sh
	tests/gates.sh

mutants:
	tests/mutants.sh
