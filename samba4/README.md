
### Install Samba4 on OpenSUSE Server

**OpenSUSE New 42.1 64Bits**

```bash
samba4_url=http://download.opensuse.org/repositories/home:/jniltinho/openSUSE_13.2/x86_64/samba4-4.2.3-1.1.x86_64.rpmß
samba4_config_url=https://github.com/jniltinho/hangouts/raw/master/samba4/config_samba4_new.tar.gz

mkdir -p /srv/v

cd /srv/v
wget $samba4_config_url
wget $samba4_url
zypper in *.rpm

tar -xvf config_samba4_new.tar.gz

mv config_samba4_new config_samba4
cd config_samba4
chmod +x dcpromo.sh
./dcpromo.sh



```
