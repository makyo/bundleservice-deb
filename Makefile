export GOPATH = ${CURDIR}
PROJECT := github.com/juju/bundleservice
BRANCH ?= master

SOURCE_CHANGES := ../bundleservice_$(shell dpkg-parsechangelog -SVersion)_source.changes

$(GOPATH)/bin/godeps:
	go get -v github.com/rogpeppe/godeps

.PHONY: fetch
fetch: $(GOPATH)/bin/godeps
	git clone git@github.com:juju/bundleservice.git src/$(PROJECT) || git -C src/$(PROJECT) fetch origin
	git -C src/$(PROJECT) checkout origin/$(BRANCH)
	make -C src/$(PROJECT) deps
	# consider make -C src/$(PROJECT) version/init.go if bundleservice gets versioning

.PHONY: dev-deb
dev-deb: SHORTHASH=$(shell git -C src/$(PROJECT) log -1 --pretty=format:%h)
dev-deb: fetch
	dch -v $(shell dpkg-parsechangelog -SVersion)+$(shell date -u +%Y%m%d%H%M)-${SHORTHASH} 'autobuild: new commit' -D trusty
	make deb

.PHONY: deb
deb: fetch
	GOPATH=${CURDIR} fakeroot debian/rules clean build binary

$(SOURCE_CHANGES): fetch
	dpkg-buildpackage -S

.PHONY: source-deb
source-deb: $(SOURCE_CHANGES)

.PHONY: upload
upload: $(SOURCE_CHANGES)
	dput ppa:yellow/ppa $(SOURCE_CHANGES)

.PHONY: check-copyright
check-copyright:
	@echo the following packages are missing copyright information in debian/copyright
	awk '{print $$1}' src/$(PROJECT)/dependencies.tsv  | grep -o -F -f - debian/copyright | sort | uniq | grep -v -F -f - src//$(PROJECT)/dependencies.tsv | awk '{print $$1}'

.PHONY: deb-clean
deb-clean:
	rm -rf bin pkg src
