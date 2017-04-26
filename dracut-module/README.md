A dracut module and a few files that it relies on.

This is based on the module by the ZFS on Linux project.

This is to get ZFS built-in to work with dracut using a systemd module or not.

This assumes that you've set all your ZFS pool's mount points properly.

Fuck dracut and fuck systemd.

To use, copy:

* 90zfs to your dracut module directory

* the contents of systemd/ to /usr/lib/systemd/system or an equivalent that dracut will use. Only necessary if you have the systemd module.

* 90-zfs.rule to /usr/lib/udev/rules.d/ or an equivalent
