# segate_central_sudo_firmware
Seagate Central NAS script to download and patch the Firmware 
re-adding sudo, ssh to root, and other removed things in the last patch.

## What the script does:
- Downloads patch
- uncompresses patch binary into normal files.
- adds PermitRootLogin yes  to sshd_config
- enable people in the 'wheel' and 'users' group to sudo without password
- add setting everyone to wheel group on firmware update, reboot, and other places

## Related (to seagate central) sidenote:
- They also released thier source trees for everything and ive managed to recompile/update a few programs but nothing ready for release yet.  If interested in somethign like this drop me a line.
