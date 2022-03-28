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
    qemu-utils 

# Download Windows 11 Evaluation ISO from Microsoft
RUN mkdir /home/windows11-iso
WORKDIR /home/windows11-iso
RUN apt update
RUN apt install -y wget apt-transport-https software-properties-common 

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

# Make QEMU VM
RUN qemu-img create -f qcow2 windows11.img 120G
RUN qemu-system-x86_64 -hda /home/windows11-iso/windows11.img -boot d -cdrom /home/windows11-iso/windows11.iso -m 4096 -enable-kvm