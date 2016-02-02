#!/bin/bash

export VENDOR=smartfren
export DEVICE=msm8x25q_d5c

if [ $# -eq 1 ]; then
    COPY_FROM=$1
    test ! -d "$COPY_FROM" && echo error reading dir "$COPY_FROM" && exit 1
fi

test -z "$DEVICE" && echo device not set && exit 2
test -z "$VENDOR" && echo vendor not set && exit 2
test -z "$VENDORDEVICEDIR" && VENDORDEVICEDIR=$DEVICE
export VENDORDEVICEDIR

BASE=../../../vendor/$VENDOR/$VENDORDEVICEDIR/proprietary
rm -rf $BASE/*

for FILE in `egrep -v '(^#|^$)' ../$DEVICE/proprietary-files.txt`; do
    echo "Extracting /system/$FILE ..."
    OLDIFS=$IFS IFS=":" PARSING_ARRAY=($FILE) IFS=$OLDIFS
    FILE=`echo ${PARSING_ARRAY[0]} | sed -e "s/^-//g"`
    DEST=${PARSING_ARRAY[1]}
    if [ -z $DEST ]
    then
        DEST=$FILE
    fi
    DIR=`dirname $FILE`
    if [ ! -d $BASE/$DIR ]; then
        mkdir -p $BASE/$DIR
    fi
    if [ "$COPY_FROM" = "" ]; then
        adb pull /system/$FILE $BASE/$DEST
        # if file dot not exist try destination
        if [ "$?" != "0" ]
          then
          adb pull /system/$DEST $BASE/$DEST
        fi
    else
        cp $COPY_FROM/$FILE $BASE/$DEST
        # if file does not exist try destination
        if [ "$?" != "0" ]
            then
            cp $COPY_FROM/$DEST $BASE/$DEST
        fi
    fi
done

echo "Applying proprietary blobs patches..."
printf "patching libgsl.so... "
echo "BinaryPatch log" > binary_patch.log
# Hack
# [00003B20] BNE.W loc_3C58 ----->  B loc_3C58
# Be quiet about ioctl warnings
dd if=binary_patches/libgsl.bin count=4 bs=1 seek=15136 of=$BASE/lib/libgsl.so conv=notrunc &>> binary_patch.log
if [ "$?" = "0" ]; then
    echo "success"
else
    echo "failed $?"
fi

echo "This is designed to extract files from an official stock build"
./setup-makefiles.sh
