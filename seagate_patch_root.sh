#!/bin/bash
year=$(date +%Y)
month=$(date +%m)
day=$(date +%d)
if [ ! -e Seagate-HS-update-201506110006F.img ]; then
	wget 'https://apps1.seagate.com/downloads/certificate.html?action=performDownload&key=941311271907' -O Seagate-HS-update-201506110006F.img
fi;
mkdir -p seagate;
cd seagate;
tar xvzf ../Seagate-HS-update-201506110006F.img;
unsquashfs rfs.squashfs;
/bin/mv -f rfs.squashfs rfs.squashfs.orig;
sed s#"^PermitRootLogin without-password"#"PermitRootLogin yes"#g -i squashfs-root/etc/ssh/sshd_config
sed s#"\"users,nogroup"#"\"users,nogroup,wheel"#g -i squashfs-root/usr/bin/usergroupmgr.sh;
sed s#"usermod -a -G nogroup"#"usermod -a -G users,wheel,nogroup"#g -i squashfs-root/usr/sbin/ba-upgrade-finish;
echo '%wheel ALL=(ALL)       NOPASSWD: ALL' >> squashfs-root/etc/sudoers;
echo '%users ALL=(ALL)       NOPASSWD: ALL' >> squashfs-root/etc/sudoers;
#patch -p1 < seagate_patch_root.patch;
mksquashfs squashfs-root rfs.squashfs;
md5="$(md5sum rfs.squashfs  | cut -d" " -f1)"
sed -e s#"=11-06-2015"#"=${day}-${month}-${year}"#g -e s#"=2015\.0611"#"=${year}.${month}${day}"#g -e s#"^rfs=.*$"#"rfs=$md5"#g -i config.ser
tar cfzv ../Seagate-HS-update-${year}${month}${day}0006F.img rfs.squashfs uImage config.ser
