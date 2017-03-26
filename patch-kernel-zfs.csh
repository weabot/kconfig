#!/bin/csh

set zfsversion=0.6.5.9

set kernelpath=/usr/src/linux
set configpath=/usr/src/kconfig
set zfsbase=/usr/src

#create zfssrc
if(!(-e "${zfsbase}/zfssrc")) then
	mkdir ${zfsbase}/zfssrc
endif

#fetch and extract sources if they don't exist
foreach pkg(spl zfs)
	if(!(-e "${zfsbase}/zfssrc/spl-${version}")) then
		echo "Fetching ${pkg} sources."
		cd ${zfsbase}/zfssrc
		wget https://github.com/zfsonlinux/zfs/releases/download/zfs-${zfsversion}/${pkg}-${zfsversion}.tar.gz
		tar -xf ${pkg}-${zfsversion}.tar.gz
		rm ${pkg}-${zfsversion}.tar.gz
	endif
end


#prepare kernel
cd ${kernelpath}
cp ${configpath}/kConfig .config
make prepare

#patch zfs and spl
foreach file(spl zfs)
	echo "Patching for ${file}"
	cd ${zfsbase}/zfssrc/${file}-${zfsversion}
	make clean
	./configure --with-linux=${kernelpath} --enable-linux-builtin
	./copy-builtin ${kernelpath}
end

cp ${configpath}/kConfig ${kernelpath}/.config
