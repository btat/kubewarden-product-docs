
.PHONY: local
  local: tmpdir environment
	npx antora --version | tee -a tmp/local-build.log
	npx antora --stacktrace --log-format=pretty --log-level=info \
		kw-local-playbook.yml 2>&1 | tee -a tmp/local-build.log

.PHONY: rancher-dsc
rancher-dsc: tmpdir environment
	npx antora --version | tee -a tmp/rancher-dsc-build.log
	npx antora --stacktrace --log-format=pretty --log-level=info \
		kw-rancher-dsc.yml 2>&1 | tee -a tmp/rancher-dsc-build.log

.PHONY: rancher-dsc-local
rancher-dsc-local: tmpdir environment
	npx antora --version | tee -a tmp/rancher-dsc-local-build.log
	npx antora --stacktrace --log-format=pretty --log-level=info \
		kw-rancher-dsc-local.yml  2>&1 | tee -a tmp/rancher-dsc-local-build.log
	cp build-rancher-dsc-local/site/search-index.js tmp/.
	node product-docs-common/jscript/split-search-index.js build-rancher-dsc-local/site/search-index.js build-rancher-dsc-local/site/lang-indexes
	mkdir -p build-rancher-dsc-local/site/sitemaps.not-used
	find build-rancher-dsc-local/site -type f -name "sitemap*.xml" -exec sh -c 'mv "$$0" "$${0%.xml}.xml-not-used"' {} \;
	mv build-rancher-dsc-local/site/*.xml-not-used build-rancher-dsc-local/site/sitemaps.not-used/. > /dev/null 2>&1 || true
	gzip build-rancher-dsc-local/site/sitemaps.not-used/*.xml-not-used > /dev/null 2>&1 || true

.PHONY: remote
remote: tmpdir environment
	npx antora --version | tee -a tmp/remote-build.log
	npx antora --stacktrace --log-format=pretty --log-level=info \
		kw-remote-playbook.yml 2>&1 | tee -a tmp/remote-build.log

.PHONY: first-local
first-local: tmpdir environment
	npx antora --version | tee -a tmp/first-local-build.log
	npx antora --stacktrace --log-format=pretty --log-level=info \
		kw-rancher-first-local.yml \
		2>&1 | tee -a tmp/first-local-build.log

.PHONY: original-local
original-local: tmpdir environment
	npx antora --version | tee -a tmp/original-local-build.log
	npx antora --stacktrace --log-format=pretty --log-level=info \
		kw-rancher-original-local.yml \
		2>&1 | tee -a tmp/original-local-build.log

.PHONY: clean
clean:
	rm -rf build*
	rm -rf tmp/*.log

NPM_FLAGS = --no-color --no-progress
.PHONY: environment
environment:
	npm $(NPM_FLAGS) ci || npm $(NPM_FLAGS) install

.PHONY: tmpdir
tmpdir:
	mkdir -p tmp

.PHONY: checkmake
checkmake:
	@if [ $$(which checkmake 2>/dev/null) ]; then \
		checkmake --config=tmp/checkmake.ini Makefile; \
		if [ $$? -ne 0 ]; then echo "checkmake failed"; exit 1; \
		else echo "checkmake passed"; \
		fi; \
	else echo "checkmake not available"; fi

.PHONY: preview
preview:
	npx http-server build-rancher-dsc-local/site -c-1

.PHONY: all
all:

.PHONY: test
test:
