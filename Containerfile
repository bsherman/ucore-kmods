ARG COREOS_VERSION="${COREOS_VERSION:-stable}"
ARG ZFS_VERSION="${ZFS_VERSION}"

FROM quay.io/fedora/fedora-coreos:${COREOS_VERSION} as kernel-query

#We can't use the `uname -r` as it will pick up the host kernel version
RUN rpm -qa kernel --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}' > /kernel-version.txt

# Using https://openzfs.github.io/openzfs-docs/Developer%20Resources/Custom%20Packages.html
FROM registry.fedoraproject.org/fedora:latest as builder
ARG ZFS_VERSION

COPY --from=kernel-query /kernel-version.txt /kernel-version.txt

WORKDIR /etc/yum.repos.d
RUN BUILDER_VERSION=$(grep VERSION_ID /etc/os-release | cut -f2 -d=) \
    && curl -L -O https://src.fedoraproject.org/rpms/fedora-repos/raw/f${BUILDER_VERSION}/f/fedora-updates-archive.repo \
    && sed -i 's/enabled=AUTO_VALUE/enabled=true/' fedora-updates-archive.repo
RUN dnf install -y jq dkms gcc make autoconf automake libtool rpm-build libtirpc-devel libblkid-devel \
    libuuid-devel libudev-devel openssl-devel zlib-devel libaio-devel libattr-devel elfutils-libelf-devel \
    kernel-$(cat /kernel-version.txt) kernel-modules-$(cat /kernel-version.txt) kernel-devel-$(cat /kernel-version.txt) \
    python3 python3-devel python3-setuptools python3-cffi libffi-devel git ncompress libcurl-devel

WORKDIR /
RUN curl -L -O https://github.com/openzfs/zfs/releases/download/zfs-${ZFS_VERSION}/zfs-${ZFS_VERSION}.tar.gz \
    && tar xzf zfs-${ZFS_VERSION}.tar.gz \
    && mv zfs-${ZFS_VERSION} /tmp/zfs

WORKDIR /tmp/zfs
RUN ./configure \
        -with-linux=/usr/src/kernels/$(cat /kernel-version.txt)/ \
        -with-linux-obj=/usr/src/kernels/$(cat /kernel-version.txt)/ \
    && make -j 1 rpm-utils rpm-kmod
RUN ls *.rpm | sort


FROM scratch

# Copy build RPMs
COPY --from=builder /tmp/zfs/*.rpm /
