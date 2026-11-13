#!/bin/sh

exec qemu-system-x86_64 \
    -enable-kvm \
    -machine accel=kvm,type=q35 \
    -m 2048 \
    -smp 2 \
    -drive file="$1",if=virtio,format=qcow2 \
    -netdev "user,id=net0,hostfwd=tcp::2222-:22" \
    -device virtio-net-pci,netdev=net0 \
    -virtfs local,path="$(pwd)",mount_tag=hostshare,security_model=none,id=hostshare 
    # -nographic
