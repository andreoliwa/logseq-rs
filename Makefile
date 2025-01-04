GO_TEST = go test -v ./... -race -covermode=atomic

help: # Display this help
	@cat Makefile | egrep '^[a-z0-9 ./-]*:.*#' | sed -E -e 's/:.+# */@ /g' -e 's/ .+@/@/g' | sort | awk -F@ '{printf "\033[1;34m%-15s\033[0m %s\n", $$1, $$2}'
.PHONY: help

build: # Build the crate
	cargo build
.PHONY: build

clean: # Clean the build artifacts
	cargo clean
.PHONY: clean

test: # Run tests
	cargo test
.PHONY: test

release: # Bump the version, create a tag, commit and push. This will trigger the PyPI release on GitHub Actions
	# https://commitizen-tools.github.io/commitizen/bump/#configuration
	# See also: cz bump --help
	@echo "THIS IS ONLY A DRY-RUN. Remove --dry-run to actually bump the version when some bug fix or new feature is ready to publish"
	# TODO: remove --dry-run and uncomment "cargo publish" when there is some bug fix or new feature ready to publish
	cz bump --dry-run --check-consistency
	# TODO: publish the Rust crate on GitHub Actions instead of locally
	#cargo publish -p logseq --locked
.PHONY: release

.release-post-bump: # This is called in .cz.toml in post_bump_hooks
	git push --atomic origin master ${CZ_POST_CURRENT_TAG_VERSION}
	gh release create ${CZ_POST_CURRENT_TAG_VERSION} --notes-from-tag
	gh repo view --web
.PHONY: .release-post-bump

clippy: # Run clippy on the Rust code
	cargo clippy
.PHONY: clippy
