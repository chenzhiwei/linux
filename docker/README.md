# 怎样交叉构建Docker镜像

> 今天早上一个 Travis CI 的员工找到我，问我怎么 Cross Build Docker images，我给他回复了一下，也在这里记录一下吧。

This demos how to build a ppc64le image on amd64 build machine.

The commands:

```
[root@mixhub ~]# uname -a
Linux mixhub 5.2.7-1.el7.elrepo.x86_64 #1 SMP Tue Aug 6 14:33:51 EDT 2019 x86_64 x86_64 x86_64 GNU/Linux

[root@mixhub ~]# docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
Setting /usr/bin/qemu-alpha-static as binfmt interpreter for alpha
Setting /usr/bin/qemu-arm-static as binfmt interpreter for arm
Setting /usr/bin/qemu-armeb-static as binfmt interpreter for armeb
Setting /usr/bin/qemu-sparc-static as binfmt interpreter for sparc
Setting /usr/bin/qemu-sparc32plus-static as binfmt interpreter for sparc32plus
Setting /usr/bin/qemu-sparc64-static as binfmt interpreter for sparc64
Setting /usr/bin/qemu-ppc-static as binfmt interpreter for ppc
Setting /usr/bin/qemu-ppc64-static as binfmt interpreter for ppc64
Setting /usr/bin/qemu-ppc64le-static as binfmt interpreter for ppc64le
Setting /usr/bin/qemu-m68k-static as binfmt interpreter for m68k
Setting /usr/bin/qemu-mips-static as binfmt interpreter for mips
Setting /usr/bin/qemu-mipsel-static as binfmt interpreter for mipsel
Setting /usr/bin/qemu-mipsn32-static as binfmt interpreter for mipsn32
Setting /usr/bin/qemu-mipsn32el-static as binfmt interpreter for mipsn32el
Setting /usr/bin/qemu-mips64-static as binfmt interpreter for mips64
Setting /usr/bin/qemu-mips64el-static as binfmt interpreter for mips64el
Setting /usr/bin/qemu-sh4-static as binfmt interpreter for sh4
Setting /usr/bin/qemu-sh4eb-static as binfmt interpreter for sh4eb
Setting /usr/bin/qemu-s390x-static as binfmt interpreter for s390x
Setting /usr/bin/qemu-aarch64-static as binfmt interpreter for aarch64
Setting /usr/bin/qemu-aarch64_be-static as binfmt interpreter for aarch64_be
Setting /usr/bin/qemu-hppa-static as binfmt interpreter for hppa
Setting /usr/bin/qemu-riscv32-static as binfmt interpreter for riscv32
Setting /usr/bin/qemu-riscv64-static as binfmt interpreter for riscv64
Setting /usr/bin/qemu-xtensa-static as binfmt interpreter for xtensa
Setting /usr/bin/qemu-xtensaeb-static as binfmt interpreter for xtensaeb
Setting /usr/bin/qemu-microblaze-static as binfmt interpreter for microblaze
Setting /usr/bin/qemu-microblazeel-static as binfmt interpreter for microblazeel
Setting /usr/bin/qemu-or1k-static as binfmt interpreter for or1k

[root@mixhub ~]# docker build -t ppc -f Dockerfile.ppc64le .
STEP 1: FROM amd64/alpine AS builder
STEP 2: RUN wget -O /qemu-ppc64le-static https://github.com/multiarch/qemu-user-static/releases/latest/download/qemu-ppc64le-static
--> Using cache 2dc8d555e80bcb78e721dd707ad3bcf485c785dc9385a11598fe34fb2e2ab4e8
--> 2dc8d555e80
STEP 3: RUN chmod +x /qemu-ppc64le-static
--> Using cache a2bcbc6e4a31ac4415e50a0c6a4422a7f2d05f45462b09241999eff8f52a4ec7
--> a2bcbc6e4a3
STEP 4: FROM ppc64le/alpine
STEP 5: COPY --from=builder /qemu-ppc64le-static /usr/bin/
--> Using cache 48a0e2645b666bc848dec0244e980d435c20433b358074d962967c6d2bf39129
--> 48a0e2645b6
STEP 6: RUN apk --no-cache add bash
fetch https://dl-cdn.alpinelinux.org/alpine/v3.13/main/ppc64le/APKINDEX.tar.gz
fetch https://dl-cdn.alpinelinux.org/alpine/v3.13/community/ppc64le/APKINDEX.tar.gz
(1/4) Installing ncurses-terminfo-base (6.2_p20210109-r0)
(2/4) Installing ncurses-libs (6.2_p20210109-r0)
(3/4) Installing readline (8.1.0-r0)
(4/4) Installing bash (5.1.0-r0)
Executing bash-5.1.0-r0.post-install
Executing busybox-1.32.1-r0.trigger
OK: 9 MiB in 18 packages
STEP 7: COMMIT ppc
--> 12650ee65c8
12650ee65c841b25253fb14402b4b0a3d378f2de0f5d2b62adf10a1e4ecefac9

[root@mixhub ppc]# docker run --rm ppc uname -a
Linux a28f83e3fca5 5.2.7-1.el7.elrepo.x86_64 #1 SMP Tue Aug 6 14:33:51 EDT 2019 ppc64le Linux
```


The Dockerfile.ppc64le content:

```
[root@mixhub ~]# cat Dockerfile.ppc64le
# This Dockerfile demos how to build ppc64le image on amd64 machine

# The architecture is same as build machine
FROM amd64/alpine AS builder

# Change the qume-static binary to the target image architecture
RUN wget -O /qemu-ppc64le-static https://github.com/multiarch/qemu-user-static/releases/latest/download/qemu-ppc64le-static

RUN chmod +x /qemu-ppc64le-static

# The target base image
FROM ppc64le/alpine

# this enables you can run ppc64le binaries, such as `apk`
COPY --from=builder /qemu-ppc64le-static /usr/bin/

# this installs bash package inside the ppc64le based image
RUN apk --no-cache add bash

# RUN commands that in the ppc64le/alpine image
```
