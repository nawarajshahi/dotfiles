#!/bin/bash

source _root_prelude.sh

# A lot of my desktop specific software requires repos outside of the core, the
# RPM fusion repos handle that for me
dnf install \
  https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
  https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm -y

dnf install awscli cheese fswebcam pcsc-lite-ccid pinentry-gtk privoxy tor transmission-gtk vlc wireshark -y

systemctl enable pcscd.service
systemctl start pcscd.service

echo "I haven't yet automated this or know if I should, but if this machine has an"
echo "SSD installed as it's primary hard drive I should review /etc/fstab and add:"
echo
echo "\tdiscard,noatime,nodiratime"
echo
echo "to the appropriate partition mount options"
