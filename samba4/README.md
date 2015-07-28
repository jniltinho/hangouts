
### Install Samba4 on OpenSUSE

**Install Samba4 4.2.3 on OpenSUSE 13.2 64Bits**

```bash
SUSE_VERSION=$(cat /etc/issue | awk '{ print $4 }' | head -n1)
smb_tgz=https://github.com/jniltinho/hangouts/raw/master/samba4/config_samba4_new.tar.gz
smb_repo=http://download.opensuse.org/repositories/home:/jniltinho/openSUSE_${SUSE_VERSION}/

zypper ar $smb_repo samba4_linuxpro
zypper --no-gpg-checks refresh
zypper in samba4-4.2.3

mkdir -p /srv/v

cd /srv/v
wget $smb_tgz

tar -xvf config_samba4_new.tar.gz

mv config_samba4_new config_samba4
cd config_samba4
chmod +x dcpromo.sh
./dcpromo.sh

```

