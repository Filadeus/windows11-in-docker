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

# Download and install Windows 11 Evaluation ISO from Microsoft
RUN mkdir /home/windows11-iso
WORKDIR /home/windows11-iso
RUN apt update
RUN apt install -y wget apt-transport-https software-properties-common 

RUN wget -q https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb
RUN dpkg -i packages-microsoft-prod.deb

RUN apt update
RUN apt install -y powershell

RUN wget https://raw.githubusercontent.com/pbatard/Fido/master/Fido.ps1
RUN pwsh Fido.ps1 -Win 11 -Ed Pro -Lang English International

