#!/bin/sh

. /lib/dracut-lib.sh

# Let the command line override our host id.
spl_hostid=`getarg spl_hostid=`
if [ -n "${spl_hostid}" ] ; then
	info "ZFS: Using hostid from command line: ${spl_hostid}"
	AA=`echo ${spl_hostid} | cut -b 1,2`
	BB=`echo ${spl_hostid} | cut -b 3,4`
	CC=`echo ${spl_hostid} | cut -b 5,6`
	DD=`echo ${spl_hostid} | cut -b 7,8`
	printf "\x${DD}\x${CC}\x${BB}\x${AA}" >/etc/hostid
elif [ -f "/etc/hostid" ] ; then
	info "ZFS: Using hostid from /etc/hostid: `hostid`"
else
	warn "ZFS: No hostid found on kernel command line or /etc/hostid."
	warn "ZFS: Pools may not import correctly."
fi

zpool=`getarg zpool=`
export zpool

if [ -e /sbin/systemctl ] || [ -e /bin/systemctl ] || [ -e /usr/bin/systemctl ] || [ -e /usr/sbin/systemctl ]; then
	systemctl set-environment ZPOOL=${zpool}
fi

echo ${zpool} > /zpool
wait_for_zfs=0
case "${root}" in
	ZFS*|zfs*)
		info "ZFS found"
		rootok=1
	;;
esac
