#!/bin/bash

###################################################
###################################################
##    Copyright (c) 2016, Adesh15                ##
##             All rights reserved.              ##
##                                               ##
##   Kernel Build Script beta - v0.2             ##
##                                               ##
###################################################
###################################################

#For Time Calculation
BUILD_START=$(date +"%s")

# Housekeeping
blue='\033[0;34m'
cyan='\033[0;36m'
green='\033[1;32m'
red='\033[0;31m'
nocol='\033[0m'

# 
# Configure following according to your system
# 

# Directories
KERNEL_DIR=$PWD
KERN_IMG=$KERNEL_DIR/arch/arm/boot/zImage-dtb
OUT_DIR=$KERNEL_DIR/zipping/onyx
WING_VERSION="Upstream"
PRODUCT_INFO=$KERNEL_DIR/product_info
COMPILE_LOG=$KERNEL_DIR/compile.log
SIGNAPK=$KERNEL_DIR/zipping/common/sign/signapk.jar
CERT=$KERNEL_DIR/zipping/common/sign/certificate.pem
KEY=$KERNEL_DIR/zipping/common/sign/key.pk8
# Device Spceifics
export ARCH=arm
export CROSS_COMPILE="/home/adesh/kernel/arm-linux-androideabi-4.9/bin/arm-linux-androideabi-"
export KBUILD_BUILD_USER="adesh15"
export KBUILD_BUILD_HOST="serveroflegends"


########################
## Start Build Script ##
########################

# Remove Last builds
rm -rf $OUT_DIR/*.zip
rm -rf $OUT_DIR/zImage
rm -rf $OUT_DIR/dtb.img

compile_kernel ()
{
echo -e "$green ********************************************************************************************** $nocol"
echo "                    "
echo "                                   Compiling Kernel                    "
echo "                    "
echo -e "$green ********************************************************************************************** $nocol"
# make clean && make mrproper
make cardinal_onyx_defconfig
make -j16
if ! [ -a $KERN_IMG ];
then
echo -e "$red Kernel Compilation failed! Fix the errors! $nocol"
exit 1
fi
zipping
}

zipping() {

# make new zip
cp $KERN_IMG $OUT_DIR/zImage
cd $OUT_DIR
zip -r -9 Feather.zip *
java -jar $SIGNAPK $CERT $KEY Feather.zip Feather-UNOFFICIAL-onyx-$WING_VERSION-$(date +"%Y%m%d")-$(date +"%H%M%S").zip
rm -f Feather_UNSIGNED.zip
}

compile_kernel | tee $COMPILE_LOG
BUILD_END=$(date +"%s")
DIFF=$(($BUILD_END - $BUILD_START))
echo -e "$blue Build completed in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds.$nocol"
cat $PRODUCT_INFO
echo -e "$red zImage size (bytes): $(stat -c%s $KERN_IMG) $nocol"
