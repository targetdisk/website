# Introduction to QEMU for Hackers

One of the things that I've noticed in the infosec community is the tendency to
stick to the proprietary virtualization tools that are familiar.
People often are quick discount tools that they don't already know, so I have
written this blog post in an attempt to foster an interest in exploring other
virtualization options.  My hope is that, even if you don't come away wanting to
use QEMU in your CTF lab or malware analysis playpen, you will at least be more
open to looking into other forms of emulation and virtualization.

## The Case for QEMU
Many hacking event organizers spend ample time pointing and clicking through
their VirtualBox and VMware configuration wizards to setup their hacking labs.
What if I told you there was a better way that works on Linux, macOS, Windows,
and Xen?

### Enter QEMU
With [QEMU](https://www.qemu.org/) your VMs are defined as the arguments passed
to QEMU on its invocation at the command line.  For example, you might invoke a
VM as such (note that **`>`** is a
[**$PS2** prompt](http://tldp.org/HOWTO/Bash-Prompt-HOWTO/x157.html)):
```
$ qemu-system-x86_64 -machine type=q35 --enable-kvm -cpu host -smp cpus=8 \
> -m 512M -netdev user,id=net0 -device e1000,netdev=net0 -hda dsk/vm-hdd.qcow
```

### Shell Scripts as VM Templates

Obviously this isn't a good long-term way to run your VM, but fear not, as there
is a better way!  All you have to do is save your VM arguments to an executable
shell script like the following:
```
#!/usr/bin/env bash

# image creation command:
# qemu-img create -f qcow2 -o preallocation=metadata dsk/vm-hdd.qcow 20G

qemu-system-x86_64 \
  -machine type=q35 \
  --enable-kvm \
  -cpu host \
  -smp cpus=8 \
  -m 512M
  -netdev user,id=net0 \
  -device e1000,netdev=net0 \
  -hda dsk/vm-hdd.qcow \
;
```

Don't forget to make your script executable!
```
$ chmod +x vm-foo
```

The nice thing about these scripts is that you can freely copy and edit them
with the standard UNIX command-line tools that you are used to, meaning that
you can use one VM script as a template for another virtual machine.  Making a
VM based on a template then becomes as simple as copying a bash script:
```
$ cp vm-foo vm-bar
```

For more information on creating QEMU disk images, see the
[qemu-img(1)](https://linux.die.net/man/1/qemu-img) man page.

### QEMU's Advanced Features
QEMU is a capable of emulating foreign CPU architectures, as well as working in
conjunction with a hypervisor to perform fully-accelerated, near
native-performance virtualization.  Some of the supported architectures for
full-system emulation are:

- Alpha
- Altera Nios II
- ARM
- Axis ETRAX CRIS
- HP PA-RISC
- i386/x86
- IBM System/390
- Microblaze (big and little endian)
- MIPS (big and little)
- MIPS64 (big and little)
- Motorola 68000
- Moxie
- OpenRISC 1k (IP core for FPGAs)
- PowerPC
- PowerPC 64 (big and little)
- RISC V
- RISC V 64
- SuperH SH-4
- SPARC and SPARC32 Plus
- SPARC64
- TILE-Gx
- Xtensa

Some of its other features include:

- Support for the Intel HAXM, Linux KVM, and Xen hypervisors
- PCIe passthrough
- attaching physical disks to VMs
- USB passthrough
- network block devices
- importing and converting disks from other formats
- command-line interactive monitor
- VNC support
- multiple virtual VGA adapters and video modes
- tap/tun support (bridging to actual network interfaces on the host)

*Stay tuned for more!*
