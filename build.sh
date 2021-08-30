#!/usr/bin/env bash
#Set time zone to Singapore
sudo ln -sf /usr/share/zoneinfo/Asia/India /etc/localtime
echo "Cloning dependencies"
git clone --depth=1 https://github.com/sohamxda7/llvm-stable clang
git clone https://github.com/sohamxda7/llvm-stable -b gcc64 --depth=1 gcc
git clone https://github.com/sohamxda7/llvm-stable -b gcc32  --depth=1 gcc32
git clone https://github.com/fabianonline/telegram.sh.git  -b master
echo "Done"
IMAGE=$(pwd)/out/arch/arm64/boot/Image
START=$(date +"%s")
KERNEL_DIR=$(pwd)
REPACK_DIR="${KERNEL_DIR}/AnyKernel3"
SEND_DIR="${KERNEL_DIR}/telegram.sh"
PATH="${KERNEL_DIR}/clang/bin:${KERNEL_DIR}/gcc/bin:${KERNEL_DIR}/gcc32/bin:${PATH}"
VERSION="$(cat arch/arm64/configs/vendor/citrus-perf_defconfig | grep "CONFIG_LOCALVERSION\=" | sed -r 's/.*"(.+)".*/\1/' | sed 's/^.//')"
export KBUILD_BUILD_HOST=ubuntu
export KBUILD_BUILD_USER=Sanvin

# Compile plox
function compile() {
    make O=out ARCH=arm64 vendor/citrus-perf_defconfig
    make -j$(nproc --all) O=out \
                    ARCH=arm64 \
                    CC=clang \
                    CLANG_TRIPLE=aarch64-linux-gnu- \
                    CROSS_COMPILE=aarch64-linux-android- \
                    CROSS_COMPILE_ARM32=arm-linux-androideabi-

    if ! [ -a "$IMAGE" ]; then
        exit 1
    fi
    cp out/arch/arm64/boot/Image AnyKernel3
}
# Zipping
function zipping() {
    cd $REPACK_DIR || exit 1
    zip -r9 $VERSION-JUICE-$(date +%Y%m%d-%H%M).zip *
    cd $SEND_DIR   || exit 1
    echo "Changing Dir to Send FIle"
    ./telegram -t 1952191372:AAFhP6XC_hFZeMOY2Ce302NUg4cGjXYH3mE -c -1001574498260 -f $REPACK_DIR/$VERSION-JUICE-$(date +%Y%m%d-%H%M).zip "Zip Sent through GithubActions"
}

compile
zipping
END=$(date +"%s")
DIFF=$(($END - $START))
echo "Build took $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) second(s)."
