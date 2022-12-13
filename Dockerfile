FROM ubuntu:22.04

ARG S3
ARG ZFS
ARG KERNEL

RUN apt update && apt install -y build-essential cmake zlib1g-dev libcppunit-dev git wget curl

# Install OpenSSL 1.1.1
RUN wget https://www.openssl.org/source/openssl-1.1.1s.tar.gz -O - | tar -xz
WORKDIR /openssl-1.1.1s
RUN ./config
RUN make && make install
RUN ldconfig /usr/local/lib64/ && echo "/usr/local/lib64" > /etc/ld.so.conf.d/openssl.conf

# Install kernel headers
RUN apt install -y linux-headers-$KERNEL

# Install ZFS Reqs
RUN apt install -y xz-utils  autoconf automake libtool gawk alien fakeroot dkms \
    libblkid-dev uuid-dev libudev-dev libssl-dev zlib1g-dev libaio-dev          \
    libattr1-dev libelf-dev python3 python3-dev python3-setuptools              \
    python3-cffi libffi-dev python3-packaging

COPY build_docker.sh /
COPY publish /

WORKDIR /
RUN ./build_docker.sh -b $S3 -k -z $ZFS -d /src -r $KERNEL