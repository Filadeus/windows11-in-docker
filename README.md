# Windows 11 in Docker using QEMU  

## What's happening inside the container

## TODO

- [x] Get ubuntu image
- [x] Install necessary dependencies
- [x] Download Windows 11 Evaluation ISO from Microsoft
- [ ] Enable KVM support for better perfomance
- [x] Emulate TPM 2.0 (separate container)
- [ ] Install Windows 11 ISO (make it persistent)
- [ ] Write a script to start up the VM every time the container starts
  - [ ] Sata Disk 1 bus must be `VirtIO` type, storage format: `qcow2`
  - [x] NIC's device model: `VirtIO`
  - [x] Add a CDROM storage device with Windows 11 ISO
  - [ ] Add a CDROM storage device with VirtIO Windows Drivers
  - [ ] Minimum CPU allocation: 4. Socket: 1; Cores: 2; Threads: 2
  - [ ] Enable UEFI boot. Requirements: Chipset: i440FX; Firmware: UEFI x86_64:/usr/share/OVMF/OVMF_CODE.fd
- [ ] **Replace CMD in Dockerfile with a proper start.sh file.**
- [ ] **Cleanup Dockerfile**
