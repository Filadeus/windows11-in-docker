FROM ubuntu:20.04 AS build

RUN mkdir /tmp/emulated_tpm
WORKDIR /home

RUN export DEBIAN_FRONTEND=noninteractive \
    && apt update \
    && apt install -y --no-install-recommends \
    binutils-mingw-w64-i686 \
    ca-certificates \
    curl \
    gcc-mingw-w64-i686 \
    genisoimage \
    make \
    p7zip-full \
    qemu-system-x86 \
    qemu-utils \
    qemu-kvm \
    git \
    wget \
    apt-transport-https \
    software-properties-common

RUN apt install -y dpkg-dev debhelper libssl-dev libtool net-tools \
libfuse-dev libglib2.0-dev libgmp-dev expect libtasn1-dev socat \
python3-twisted gnutls-dev gnutls-bin  libjson-glib-dev gawk git \
python3-setuptools softhsm2 libseccomp-dev automake autoconf libtool \
gcc build-essential libssl-dev dh-exec pkg-config dh-autoreconf

RUN git clone https://github.com/stefanberger/libtpms.git
WORKDIR /home/libtpms
RUN ./autogen.sh --with-openssl
RUN make dist
RUN dpkg-buildpackage -us -uc -j4
RUN apt install ../libtpms*.deb

WORKDIR /home

RUN git clone https://github.com/stefanberger/swtpm.git
WORKDIR /home/swtpm
RUN dpkg-buildpackage -us -uc -j4
RUN apt install ../swtpm*.deb

VOLUME [/tmp/emulated_tpm]

CMD swtpm socket --tpmstate dir=/tmp/emulated_tpm --ctrl type=unixio,path=/tmp/emulated_tpm/swtpm-sock --log level=20 --tpm2 && qemu-system-x86_64 -hda /home/windows11-iso/windows11.img -boot d -m 4096 \
    -chardev socket,id=chrtpm,path=/tmp/emulated_tpm/swtpm-sock \
    -tpmdev emulator,id=tpm0,chardev=chrtpm \
    -device tpm-tis,tpmdev=tpm0