# ucore-kmods

[![build-ucore](https://github.com/bsherman/ucore-kmods/actions/workflows/build.yml/badge.svg)](https://github.com/bsherman/ucore-kmods/actions/workflows/build.yml)

# ucore-kmods

A layer to provide kernel modules for use in other [Fedora CoreOS](https://getfedora.org/coreos/) images.

### The maintainers of the ucore project are not liable for any damage that may occur during use of the operating system.

## Features

This image currently contains:

- ZFS (including debug packages)

A list of all RPMs is generated with each build, a snapshot of this list looks like this:

```
kmod-zfs-6.1.11-200.fc37.x86_64-2.1.9-1.fc37.x86_64.rpm
kmod-zfs-6.1.11-200.fc37.x86_64-debuginfo-2.1.9-1.fc37.x86_64.rpm
kmod-zfs-devel-2.1.9-1.fc37.x86_64.rpm
kmod-zfs-devel-6.1.11-200.fc37.x86_64-2.1.9-1.fc37.x86_64.rpm
libnvpair3-2.1.9-1.fc37.x86_64.rpm
libnvpair3-debuginfo-2.1.9-1.fc37.x86_64.rpm
libuutil3-2.1.9-1.fc37.x86_64.rpm
libuutil3-debuginfo-2.1.9-1.fc37.x86_64.rpm
libzfs5-2.1.9-1.fc37.x86_64.rpm
libzfs5-debuginfo-2.1.9-1.fc37.x86_64.rpm
libzfs5-devel-2.1.9-1.fc37.x86_64.rpm
libzpool5-2.1.9-1.fc37.x86_64.rpm
libzpool5-debuginfo-2.1.9-1.fc37.x86_64.rpm
python3-pyzfs-2.1.9-1.fc37.noarch.rpm
zfs-2.1.9-1.fc37.src.rpm
zfs-2.1.9-1.fc37.x86_64.rpm
zfs-debuginfo-2.1.9-1.fc37.x86_64.rpm
zfs-debugsource-2.1.9-1.fc37.x86_64.rpm
zfs-dracut-2.1.9-1.fc37.noarch.rpm
zfs-kmod-2.1.9-1.fc37.src.rpm
zfs-kmod-debugsource-2.1.9-1.fc37.x86_64.rpm
zfs-test-2.1.9-1.fc37.x86_64.rpm
zfs-test-debuginfo-2.1.9-1.fc37.x86_64.rpm
```

## Usage


Add this to your Containerfile to install all the typically intalled RPMs:

    COPY --from=ghcr.io/bsherman/ucore-kmods:latest /rpms/*.rpm /
    RUN rpm-ostree install `ls | grep -v -E "debug|devel|test|src|dracut" | xargs`

Note: the above install command filters out packages likely not needed unless doing development or debugging.

  
## Verification

These images are signed with sisgstore's [cosign](https://docs.sigstore.dev/cosign/overview/). You can verify the signature by downloading the `cosign.pub` key from this repo and running the following command:

    cosign verify --key cosign.pub ghcr.io/bsherman/ucore-kmods