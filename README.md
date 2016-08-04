# bundleservice-deb

The debian/ubuntu packaging of bundleservice.

## Installing Packages

 1. sudo add-apt-repository ppa:yellow/ppa
 1. sudo apt-get update ; sudo apt-get install bundleservice

## Build Dependencies

Package building requirements are the same as bundleservice.

Build dependencies are specified in debian/control, but if they change and
the source packages are not yet in a PPA, then `apt-get build-dep` will not
be able to install the build dependencies for you.

    $ sudo apt-get install build-essential bzr debhelper devscripts git golang-go lsb-release mercurial

## Development Packages

To build a development debian package, suitable for a development or daily
PPA, checkout this repository and run make deb.

The deb make target calls `dch` and adds a new version entry to
`debian/changelog` with your name in it. You should have `DEBEMAIL` and
`DEBFULLNAME` set. `dch` tries to figure out who is revising the package and
uses these environment variables to update `debian/changelog`. See `dch(1)` for
details.

### Example environment variables:

    DEBEMAIL=jay.wren@canonical.com
    DEBFULLNAME='Jay R. Wren'

*dch will set the package author in changelog to 'Jay R. Wren
<jay.wren@canonical.com>'*

This full name and email will be used for signing with gpg.

### Uploading

Run `make upload`.

Once you have uploaded to the PPA you should add and commit the changes to
`debian/changelog` and push them to the git repository.

### Notes

This workflow is not
https://wiki.debian.org/Python/GitPackaging. The GitPackaging workflow is still
release tarball centric with an upstream branch being equivalent to a tarball,
the pristine-tar branch being delta and a master branch being upstream with
debian directory. This workflow did not seem to match well with what we needed.

The debian packages are in 3.0 (native) format, not 3.0 (quilt) format as a
result of our needs.

Golang is not compatible with bzr-builder.

    14:30    sinzui| jrwren, no, golang is 100% incompatible with bzr-builder
    and Lp's security policies

This rules out using build recipes on Launchpad.

## Release Packages

The dev-deb make target for building a daily or snapshot development
package. To build a release package, follow steps in `RELEASE_PROCESS.md`.

## Verifying Packaged Binaries

In the course of executing a binary from a debian package, it may be necessary
to verify that the binaries are built the way that you think that they are. Two
methods are possible. One is to download the source debian package from the PPA
and confirm that the source which you expected is used. Another is to inspect
the binaries yourself.

### Verifying Using Source Packages

 1. Include the deb-src line in the PPA configuration.
   - See `Installing Packages` above.
 1. `apt-get source bundleservice`
 1. Inspect the source which was just downloaded.

### Verifying Using Binaries

 1. Find a difference which you expect to be in the binary using git diff.
   - e.g. `git diff 0.0.1..0.0.2`

     https://github.com/CanonicalLtd/bundleservice/compare/0.0.1...0.0.2

   - Look for an easy difference such as a new package level symbol. e.g.
     entityExists endpoint added
 1. Run strings on the binary in question and grep for the symbol.

    ```
    $ strings /usr/bin/bundleserviced | grep somesymbol
    ...
    github.com/juju/bundleservice/internal/v1.(*Handler).somesymbol
    ...
    ```
    The symbol is listed, so this binary must be built from the right tag  (or
    potentially newer) because the symbol does not exist in that older tag.
