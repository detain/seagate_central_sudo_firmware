#!/bin/bash
img=Seagate-HS-update-201506110006F.img;
if [ ! -e ${img} ]; then
	wget 'https://apps1.seagate.com/downloads/certificate.html?action=performDownload&key=941311271907' -O ${img}
fi;
orig_year="$(echo "$img" | cut -d- -f4 | cut -c1-4)"
orig_month="$(echo "$img" | cut -d- -f4 | cut -c5-6)"
orig_day="$(echo "$img" | cut -d- -f4 | cut -c7-8)"
release="$(echo "$img" | cut -d- -f4 | cut -c9- | cut -d\. -f1)"
year=$(date +%Y)
month=$(date +%m)
day=$(date +%d)
newimg="Seagate-HS-update-${year}${month}${day}${release}.img";
#mkdir -p seagate;
#cd seagate;
tar xvzf ${img};
unsquashfs rfs.squashfs;
if [ "$(grep "^PermitRootLogin yes" squashfs-root/etc/ssh/sshd_config)" = "" ]; then
	sed s#"^PermitRootLogin without-password"#"PermitRootLogin yes"#g -i squashfs-root/etc/ssh/sshd_config
fi;
if [ "$(grep "\"users,nogroup,wheel" squashfs-root/usr/sbin/ba-upgrade-finish)" = "" ]; then
	sed s#"\"users,nogroup"#"\"users,nogroup,wheel"#g -i squashfs-root/usr/bin/usergroupmgr.sh;
fi;
if [ "$(grep "usermod -a -G users,wheel" squashfs-root/usr/sbin/ba-upgrade-finish)" = "" ]; then
	sed s#"usermod -a -G nogroup"#"usermod -a -G users,wheel,nogroup"#g -i squashfs-root/usr/sbin/ba-upgrade-finish;
fi;
if [ "$(grep "^%wheel.*NOPASS" squashfs-root/etc/sudoers)" = "" ]; then
	echo '%wheel ALL=(ALL)       NOPASSWD: ALL' >> squashfs-root/etc/sudoers;
fi;
if [ "$(grep "^%users.*NOPASS" squashfs-root/etc/sudoers)" = "" ]; then
	echo '%users ALL=(ALL)       NOPASSWD: ALL' >> squashfs-root/etc/sudoers;
fi;
if [ "$(grep "^passwd -d root" squashfs-root/usr/sbin/ba-upgrade-finish)" = "" ]; then
	echo 'passwd -d root' >> squashfs-root/usr/sbin/ba-upgrade-finish;
fi;
/bin/rm -f rfs.squashfs;
mksquashfs squashfs-root rfs.squashfs;
md5="$(md5sum rfs.squashfs  | cut -d" " -f1)"
sed \
	-e s#"=${orig_day}-${orig_month}-${orig_year}"#"=${day}-${month}-${year}"#g \
	-e s#"=${orig_year}\.${orig_month}${orig_day}"#"=${year}.${month}${day}"#g \
	-e s#"^rfs=.*$"#"rfs=$md5"#g \
	-i config.ser;
tar cfzv ${newimg} rfs.squashfs uImage config.ser
echo "Created ${newimg} from ${img}"
