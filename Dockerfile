FROM ubuntu:20.04 AS build

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
    git \
    wget \
    apt-transport-https \
    software-properties-common

# Download Windows 11 Evaluation ISO from Microsoft
RUN mkdir /home/windows11-iso
WORKDIR /home/windows11-iso

# Install Powershell Core
RUN wget -q https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb
RUN dpkg -i packages-microsoft-prod.deb

RUN apt update 
RUN apt install -y powershell

# Download Windows 11 Pro with English International
RUN wget https://raw.githubusercontent.com/pbatard/Fido/master/Fido.ps1
RUN pwsh Fido.ps1 -Win 11 -Ed Pro -Lang English International

# Rename ISO file
RUN find . -type f -name 'Win11*.iso' -exec sh -c 'x="{}"; mv "$x" "windows11.iso"' \;

# Prepare system .img file and ISO for VM
RUN qemu-img create -f qcow2 windows11.img 120G
RUN qemu-system-x86_64 -hda /home/windows11-iso/windows11.img -boot d -cdrom /home/windows11-iso/windows11.iso -m 4096 -enable-kvm

# TPM Emulation
## build swtpm
RUN mkdir /tmp/emulated_tpm
RUN apt install -y dpkg-dev debhelper libssl-dev libtool net-tools \
libfuse-dev libglib2.0-dev libgmp-dev expect libtasn1-dev socat \
python3-twisted gnutls-dev gnutls-bin  libjson-glib-dev gawk git \
python3-setuptools softhsm2 libseccomp-dev automake autoconf libtool \
gcc build-essential libssl-dev dh-exec pkg-config dh-autoreconf
RUN git clone https://github.com/stefanberger/libtpms.git
RUN cd libtpms
RUN ./autogeb.sh --with-openssl
RUN make dist
RUN dpkg-buildpackage -us -uc -j4
RUN apt install ../libtpms*.deb

RUN git clone https://github.com/stefanberger/swtpm.git
RUN cd swtpm
RUN dpkg-buildpackage -us -uc -j4
RUN apt install ../swtpm*.deb

RUN swtpm socket --tpmstate dir=/tmp/emulated_tpm --ctrl type=unixio,path=/tmp/emulated_tpm/swtpm-sock --log level=20 --tpm2

# Starting VM
RUN qemu-system-x86_64 -hda /home.windows11-iso/windows11.img -boot d -m 4096 -enable-kvm \
    -chardev socket,id=chrtpm,path=/tmp/emulated_tpm/swtpm-sock \
    -tpmdev emulator,id=tpm0,chardev=chrtpm \
    -device tpm-tis,tpmdev=tpm0