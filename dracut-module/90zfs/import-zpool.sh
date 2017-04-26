#!/bin/sh
/sbin/zpool import -f -R /sysroot ${zpool}
ROOTFS_MOUNTED=yes
