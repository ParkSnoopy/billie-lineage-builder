#!/bin/env bash


# exit on error
set -e

# preset PATH
echo "export PATH=\"$HOME/go/bin:$PATH\"" >> ~/.zshrc

# setup ccache
export USE_CCACHE=1
export CCACHE_EXEC=/usr/bin/ccache
ccache -M 50G

# clone LineageOS
mkdir -p ~/android/lineage
cd ~/android/lineage
repo init -u https://github.com/LineageOS/android.git -b lineage-21.0 --git-lfs --no-clone-bundle
repo sync -c -j 6
source build/envsetup.sh
croot

# add deprecated `billie` to `local_manifests`
cd ~/android/lineage
mkdir -p .repo/local_manifests
cat << EOF > ~/android/lineage/.repo/local_manifests/billie.xml
<?xml version="1.0" encoding="UTF-8"?>
<manifest>
    <!-- Device Tree -->
    <project name="LineageOS/android_device_oneplus_billie" path="device/oneplus/billie" remote="github" revision="lineage-21" />

    <!-- Kernel -->
    <project name="LineageOS/android_kernel_oneplus_sm6350" path="kernel/oneplus/sm6350" remote="github" revision="lineage-21" />

    <!-- Hardware -->
    <project name="LineageOS/android_hardware_oneplus" path="hardware/oneplus" remote="github" revision="lineage-21" />
</manifest>
EOF
repo sync -c -j 6

# dump proprietary vendor binary (from latest official build)
mkdir -p ~/tmp/vendor_dump
cd ~/tmp
wget https://media.githubusercontent.com/media/ParkSnoopy/billie-lineage-builder/refs/heads/main/lineage-21.0-20251006-nightly-billie-signed.zip?download=true
payload-dumper-go -o $HOME/tmp/vendor_dump $HOME/tmp/lineage-21.0-20251006-nightly-billie-signed.zip
cd ~/android/lineage
cd ./device/oneplus/billie
cp ~/tmp/vendor_dump/*.img .
./extract-files.sh -p .
./setup-makefiles.sh -p .

# start build ( `-j12` for 32G RAM and 16G SWAP, ETA 3h )
cd ~/android/lineage
breakfast billie
mka bacon -j12

# export result
mkdir -p $HOME/dist
cp $OUT/* $HOME/dist/
