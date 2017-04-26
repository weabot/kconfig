#!/bin/sh

# export_all OPTS
#   exports all imported zfs pools.
export_all() {
        local opts="${@}"
        local ret=0

        IFS="${NEWLINE}"
        for pool in `zpool list -H -o name` ; do
                if zpool list -H "${pool}" 2>&1 > /dev/null ; then
                        zpool export "${pool}" ${opts} || ret=$?
                fi
        done
        IFS="${OLDIFS}"

        return ${ret}
}

_do_zpool_export() {
	local ret=0
	local errs=""
	local final="${1}"

	info "ZFS: Exporting ZFS storage pools..."
	errs=$(export_all -F 2>&1)
	ret=$?
	[ -z "${errs}" ] || echo "${errs}" | vwarn
	if [ "x${ret}" != "x0" ]; then
		info "ZFS: There was a problem exporting pools."
	fi

	if [ "x${final}" != "x" ]; then
		info "ZFS: pool list"
		zpool list 2>&1 | vinfo
	fi

	return ${ret}
}

if command -v zpool >/dev/null; then
	_do_zpool_export "${1}"
else
	:
fi
