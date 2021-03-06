#!/bin/csh

set zfsversion=0.6.5.9

set kconfigpath=/usr/src/kconfig
set kernelpath=/usr/src/linux

set configfile=${kconfigpath}/kConfig
set zfsbase=${kconfigpath}

#create zfssrc
if(!(-e "${zfsbase}/zfssrc")) then
	echo "zfssrc directory not found in ${zfsbase}, creating it."
	mkdir ${zfsbase}/zfssrc
endif

#fetch and extract sources if they don't exist
foreach pkg(spl zfs)
	if(!(-e "${zfsbase}/zfssrc/${pkg}-${zfsversion}")) then
		echo "Fetching ${pkg} sources."
		cd ${zfsbase}/zfssrc
		curl -L -O https://github.com/zfsonlinux/zfs/releases/download/zfs-${zfsversion}/${pkg}-${zfsversion}.tar.gz
		echo "Extracting ${pkg} sources."
		tar -xf ${pkg}-${zfsversion}.tar.gz
		rm ${pkg}-${zfsversion}.tar.gz
	endif
end


#prepare kernel
cd ${kernelpath}
cp ${configfile} ${kernelpath}/.config
make prepare

#patch zfs and spl
foreach file(spl zfs)
	echo "Patching for ${file}"
	cd ${zfsbase}/zfssrc/${file}-${zfsversion}
	make clean
	./configure --with-linux=${kernelpath} --enable-linux-builtin
	./copy-builtin ${kernelpath}
end

# setup kernel modules for dracut
cp ${configfile} ${kernelpath}/.config
