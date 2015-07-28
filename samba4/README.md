
### Install Samba4 on OpenSUSE Server

**Install Samba4 4.2.3 on OpenSUSE 13.2 64Bits**

```bash
smb_rpm=http://download.opensuse.org/repositories/home:/jniltinho/openSUSE_13.2/x86_64/samba4-4.2.3-1.1.x86_64.rpm
smb_tgz=https://github.com/jniltinho/hangouts/raw/master/samba4/config_samba4_new.tar.gz

mkdir -p /srv/v

cd /srv/v
wget $smb_rpm
wget $smb_tgz
zypper in *.rpm

tar -xvf config_samba4_new.tar.gz

mv config_samba4_new config_samba4
cd config_samba4
chmod +x dcpromo.sh
./dcpromo.sh



```
