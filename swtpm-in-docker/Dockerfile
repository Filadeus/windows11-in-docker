FROM ubuntu:20.04 AS build

RUN mkdir /tmp/emulated_tpm
WORKDIR /home

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