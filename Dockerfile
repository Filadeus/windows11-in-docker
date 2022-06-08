FROM ubuntu:20.04 AS build
SHELL ["/bin/bash", "-c"]

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

# Download Windows 11 Evaluation ISO from Microsoft
RUN mkdir /home/windows11-iso
WORKDIR /home/windows11-iso

# Install Powershell Core
RUN wget -q https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb
RUN dpkg -i packages-microsoft-prod.deb

RUN apt update 
RUN apt install -y powershell

# Enable KVM 
RUN chown $(id -u):$(id -g) /dev/kvm 2>/dev/null || true

# Download Windows 11 Pro with English International and Virtio
# RUN wget https://raw.githubusercontent.com/pbatard/Fido/master/Fido.ps1
# RUN pwsh Fido.ps1 -Win 11 -Ed Pro -Lang English International
RUN wget http://192.168.0.113:8000/Win11_EnglishInternational_x64v1.iso
RUN wget https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso

# Rename ISO file and virtio ISO file
RUN find . -type f -name 'Win11*.iso' -exec sh -c 'x="{}"; mv "$x" "windows11.iso"' \;
RUN find . -type f -name 'virtio-win*.iso' -exec sh -c 'x="{}"; mv "$x" "virtio-win.iso"' \;

# Prepare system .img file and ISO for VM
RUN qemu-img create -f qcow2 windows11.img 120G
# RUN apt install kmod
# RUN modprobe kvm
# RUN qemu-system-x86_64 -hda /home/windows11-iso/windows11.img -boot d -cdrom /home/windows11-iso/windows11.iso -m 4096 -enable-kvm
# DELETE ORIGINAL INSTALLATION ISO AFTER

# TPM Emulation
## build swtpm
RUN mkdir /tmp/emulated_tpm
# RUN apt install -y dpkg-dev debhelper libssl-dev libtool net-tools \
# libfuse-dev libglib2.0-dev libgmp-dev expect libtasn1-dev socat \
# python3-twisted gnutls-dev gnutls-bin  libjson-glib-dev gawk git \
# python3-setuptools softhsm2 libseccomp-dev automake autoconf libtool \
# gcc build-essential libssl-dev dh-exec pkg-config dh-autoreconf
# RUN git clone https://github.com/stefanberger/libtpms.git
# RUN cd libtpms
# WORKDIR /home/windows11-iso/libtpms
# RUN ./autogen.sh --with-openssl
# RUN make dist
# RUN dpkg-buildpackage -us -uc -j4
# RUN apt install ../libtpms*.deb

# WORKDIR /home/windows11-iso

# RUN git clone https://github.com/stefanberger/swtpm.git
# RUN cd swtpm
# WORKDIR /home/windows11-iso/swtpm
# RUN dpkg-buildpackage -us -uc -j4
# RUN apt install ../swtpm*.deb

WORKDIR /home/windows11-iso
# VOLUME ["/tmp/.X11-unix"]
# ENV DISPLAY=:0.0

# Install Windows to VM disk
RUN apt install -y qemu-system-gui x11-apps
# RUN ln -s /mnt/wslg/.X11-unix /tmp/.X11-unix
# RUN export DISPLAY=${DISPLAY:-:0}
# RUN ls /tmp/.X11-unix
# RUN qemu-system-x86_64 -hda ./windows11.img -boot d -cdrom ./windows11.iso -m 4096 -display gtk
# CMD qemu-system-x86_64 -hda ./windows11.img -boot d -cdrom ./windows11.iso -m 4096 -display gtk \
#     -chardev socket,id=chrtpm,path=/tmp/emulated_tpm/swtpm-sock \
#     -tpmdev emulator,id=tpm0,chardev=chrtpm \
#     -device tpm-tis,tpmdev=tpm0 --verbose

# Enable Secure Boot
RUN apt install ovmf

RUN touch start.sh \
    && chmod +x ./start.sh \
    && tee -a start.sh <<< '#!/bin/sh' \
    && tee -a start.sh <<< 'ls /tmp/emulated_tpm' \
    && tee -a start.sh <<< 'exec qemu-system-x86_64 \' \ 
    && tee -a start.sh <<< '-hda /home/windows11-iso/windows11.img \' \
    && tee -a start.sh <<< '-device -drive file=/home/windows11-iso/windows11.img,if=virtio \' \
    && tee -a start.sh <<< '-boot d -cdrom /home/windows11-iso/windows11.iso \' \
    && tee -a start.sh <<< '-boot g -cdrom /home/windows11-iso/virtio-win.iso' \
    && tee -a start.sh <<< '-chardev socket,id=chrtpm,path=/tmp/emulated_tpm/swtpm-sock \' \
    && tee -a start.sh <<< '-tpmdev emulator,id=tpm0,chardev=chrtpm \' \
    && tee -a start.sh <<< '-device tpm-tis,tpmdev=tpm0 \' \
    && tee -a start.sh <<< '-net nic,model=virtio \' \
    && tee -a start.sh <<< '-cpu host -smp 4,cores=2 -m 8192 \' \

CMD ./start.sh

# Create vTPM emulated device
# RUN swtpm socket --tpmstate dir=/tmp/emulated_tpm --ctrl type=unixio,path=/tmp/emulated_tpm/swtpm-sock --log level=20 --tpm2 && qemu-system-x86_64 -hda /home/windows11-iso/windows11.img -boot d -m 4096 \
#    -chardev socket,id=chrtpm,path=/tmp/emulated_tpm/swtpm-sock \
#    -tpmdev emulator,id=tpm0,chardev=chrtpm \
#    -device tpm-tis,tpmdev=tpm0

# Mount vTPM from another container

# Starting VM (-enable-kvm currently disabled)
# RUN qemu-system-x86_64 -hda /home/windows11-iso/windows11.img -boot d -m 4096 \
#    -chardev socket,id=chrtpm,path=/tmp/emulated_tpm/swtpm-sock \
#    -tpmdev emulator,id=tpm0,chardev=chrtpm \
#    -device tpm-tis,tpmdev=tpm0
