A dracut module and a few files that it relies on.

This is based on the module by the ZFS on Linux project.

This is to get ZFS built-in to work with dracut using a systemd module or not.

This assumes that you've set all your ZFS pool's mount points properly.

Fuck dracut and fuck systemd.

To use, copy:

* 90zfs to your dracut module directory

* the contents of systemd/ to /usr/lib/systemd/system or an equivalent that dracut will use. Only necessary if you have the systemd module.

* 90-zfs.rule to /usr/lib/udev/rules.d/ or an equivalent


This module doesn't work like ZFS on Linux's. To use, set your root to zfs like so:

`root=ZFS`

and set your zpool to the pool you want to boot from. It will mount every volume and subvolume in that pool according to their mountpoints.

`zpool=rpool`

An example of a compatible kernel line:

`initrd=/dracut root=ZFS zpool=mypool splash quiet amd.powerplay=1 init=/bin/emacs`
