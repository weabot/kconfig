#!/bin/bash

echo "zfs-generator: starting" >> /dev/kmsg

GENERATOR_DIR="$1"
[ -n "$GENERATOR_DIR" ] || {
    echo "zfs-generator: no generator directory specified, exiting" >> /dev/kmsg
    exit 1
}

[ -f /lib/dracut-lib.sh ] && dracutlib=/lib/dracut-lib.sh
[ -f /usr/lib/dracut/modules.d/99base/dracut-lib.sh ] && dracutlib=/usr/lib/dracut/modules.d/99base/dracut-lib.sh

type getarg >/dev/null 2>&1 || {
    echo "zfs-generator: loading Dracut library from $dracutlib" >> /dev/kmsg
    . "$dracutlib"
}

[ -z "$root" ]       && root=$(getarg root=)
[ -z "$rootfstype" ] && rootfstype=$(getarg rootfstype=)
[ -z "$rootflags" ]  && rootflags=$(getarg rootflags=)

# If root is not ZFS= or zfs: or rootfstype is not zfs
# then we are not supposed to handle it.
[ "${root##zfs}" = "${root}" -a "${root##ZFS}" = "${root}" -a "$rootfstype" != "zfs" ] && exit 0

rootfstype=zfs
if echo "${rootflags}" | grep -Eq '^zfsutil$|^zfsutil,|,zfsutil$|,zfsutil,' ; then
    true
elif test -n "${rootflags}" ; then
    rootflags="zfsutil,${rootflags}"
else
    rootflags=zfsutil
fi

root="${root##zfs:}"
root="${root##ZFS=}"

echo "zfs-generator: writing extension for sysroot.mount to $GENERATOR_DIR"/sysroot.mount.d/zfs-enhancement.conf >> /dev/kmsg

[ -d "$GENERATOR_DIR" ] || mkdir "$GENERATOR_DIR"
[ -d "$GENERATOR_DIR"/sysroot.mount.d ] || mkdir "$GENERATOR_DIR"/sysroot.mount.d

{
    echo "[Unit]"
    echo "Before=initrd-root-fs.target"
    echo "After=zfs-import-opt.service"
} > "$GENERATOR_DIR"/sysroot.mount.d/zfs-enhancement.conf

[ -d "$GENERATOR_DIR"/initrd-root-fs.target.requires ] || mkdir -p "$GENERATOR_DIR"/initrd-root-fs.target.requires
ln -s ../sysroot.mount "$GENERATOR_DIR"/initrd-root-fs.target.requires/sysroot.mount

echo "zfs-generator: finished" >> /dev/kmsg
