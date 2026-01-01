#!/bin/env bash

# exit on error
set -e
set -x

# install dependencies
apt update
apt install -y bc bison build-essential ccache curl flex g++-multilib gcc-multilib git git-lfs gnupg gperf imagemagick protobuf-compiler python3-protobuf lib32readline-dev lib32z1-dev libdw-dev libelf-dev libgnutls28-dev lz4 libsdl1.2-dev libssl-dev libxml2 libxml2-utils lzop pngcrush rsync schedtool squashfs-tools xsltproc zip zlib1g-dev android-platform-tools-base lib32ncurses-dev libncurses6 libncurses-dev libwxgtk3.2-dev repo python-is-python3

# setup git
git config --global user.name "ubuntu"
git config --global user.email "ubuntu@android-builder.local"
git config --global trailer.changeid.key "Change-Id"
git config --global color.ui true
git lfs install

# setup ccache
export USE_CCACHE=1
export CCACHE_EXEC=/usr/bin/ccache
ccache -M 50G

# LineageOS init
mkdir -p ~/android/lineage
cd ~/android/lineage
repo init -u https://github.com/LineageOS/android.git -b lineage-21.0 --git-lfs

# LineageOS local_manifests billie
mkdir -p .repo/local_manifests
cat <<EOF >.repo/local_manifests/billie.xml
<?xml version="1.0" encoding="UTF-8"?>
<manifest>
  <project name="LineageOS/android_device_oneplus_billie" path="device/oneplus/billie" remote="github" revision="lineage-21" />
  <project name="LineageOS/android_kernel_oneplus_sm6350" path="kernel/oneplus/sm6350" remote="github" revision="lineage-21" />
  <project name="LineageOS/android_hardware_oneplus" path="hardware/oneplus" remote="github" revision="lineage-21" />
</manifest>
EOF

# LineageOS sync and setup
repo sync -c -j 8
source build/envsetup.sh
croot

# dump proprietary vendor binary (from latest official build)
cd ~/android/lineage
cd device/oneplus/billie
cp $HOME/src/lineage-21.0-20251006-nightly-billie-signed.zip .
./extract-files.sh lineage-21.0-20251006-nightly-billie-signed.zip
./setup-makefiles.sh

# start build ( `-j12` for 32G RAM and 16G SWAP, ETA 3h )
cd ~/android/lineage
breakfast billie
mka bacon -j12
