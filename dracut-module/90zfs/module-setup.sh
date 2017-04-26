#!/bin/sh

check() {
	# We depend on udev-rules being loaded
	[ "${1}" = "-d" ] && return 0

	# Verify the zfs tool chain
	for tool in "/sbin/zpool" "/sbin/zfs" "/sbin/mount.zfs" ; do
		test -x "$tool" || return 1
	done
	# Verify grep exists
	which grep >/dev/null 2>&1 || return 1

	return 0
}

depends() {
	echo udev-rules
	return 0
}

install() {
	inst_rules /lib/udev/rules.d/90-zfs.rules
	inst_rules /lib/udev/rules.d/69-vdev.rules
	inst_rules /lib/udev/rules.d/60-zvol.rules
	dracut_install hostid
	dracut_install grep
	dracut_install sed
	dracut_install /sbin/zfs
	dracut_install /sbin/zpool
	dracut_install /sbin/mount.zfs
	dracut_install /lib/udev/vdev_id
	dracut_install /lib/udev/zvol_id
	if [ -n "$systemdutildir" ] ; then
		inst_script "${moddir}/zfs-generator.sh" "$systemdutildir"/system-generators/dracut-zfs-generator
	fi
	inst_hook cmdline 95 "${moddir}/parse-zfs.sh"
	inst_hook cleanup 99 "${moddir}/zfs-needshutdown.sh"
	inst_hook shutdown 20 "${moddir}/export-zfs.sh"
	inst_hook mount 98 "${moddir}/import-zpool.sh"

	if [ -e /etc/zfs/zpool.cache ]; then
		inst /etc/zfs/zpool.cache
		type mark_hostonly >/dev/null 2>&1 && mark_hostonly /etc/zfs/zpool.cache
	fi

	if [ -e /etc/zfs/vdev_id.conf ]; then
		inst /etc/zfs/vdev_id.conf
		type mark_hostonly >/dev/null 2>&1 && mark_hostonly /etc/zfs/vdev_id.conf
	fi

	# Synchronize initramfs and system hostid
	AA=`hostid | cut -b 1,2`
	BB=`hostid | cut -b 3,4`
	CC=`hostid | cut -b 5,6`
	DD=`hostid | cut -b 7,8`
	printf "\x${DD}\x${CC}\x${BB}\x${AA}" > "${initdir}/etc/hostid"

	if dracut_module_included "systemd"; then
		mkdir -p "${initdir}/$systemdsystemunitdir/initrd.target.wants"
		dracut_install /usr/lib/systemd/system/zfs-import-opt.service
		if ! [ -L "${initdir}/$systemdsystemunitdir/initrd.target.wants"/zfs-import-opt.service ]; then
			ln -s ../zfs-import-opt.service "${initdir}/$systemdsystemunitdir/initrd.target.wants"/zfs-import-opt.service
			type mark_hostonly >/dev/null 2>&1 && mark_hostonly /usr/lib/systemd/system/zfs-import-opt.service
		fi
	fi
}
