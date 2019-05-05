#!/usr/bin/env bash

ISO_FILE=$1

create_virtual_usb()
{
    USB_IMG_PATH=$1
    USB_SIZE=$2

    fallocate -l ${USB_SIZE}G ${USB_IMG_PATH}
    losetup -Pf --show ${USB_IMG_PATH}
}

detach_loop_device()
{
    DEVICE=$1
    losetup -d ${DEVICE}
}

init_usb_device()
{
    USB_DEVICE=$1
    PART_SZ=$2
    parted --script ${USB_DEVICE} \
        mktable gpt \
        mkpart primary 1049kB ${PART_SZ}% \
        toggle 1 esp
}

add_partition()
{
    USB_DEVICE=$1
    INIT_PART=$2
    PART_SZ=$3

    parted --script ${USB_DEVICE} \
        mkpart primary ${INIT_PART}% ${PART_SZ}%

}

get_partition_device()
{
    USB_DEVICE=$1
    PART_NO=$2
    echo ${USB_DEVICE}p${PART_NO}
}

format_partition()
{
    USB_DEVICE=$1
    PART_NO=$2
    mkfs.vfat $(get_partition_device ${USB_DEVICE} ${PART_NO})
}

do_mount()
{
    DEVICE=$1
    OPTS=$2

    TMP_PATH=$(mktemp -d)
    mount ${OPTS} ${DEVICE} ${TMP_PATH}
    echo ${TMP_PATH}
}

mount_iso()
{
    ISO_IMG=$1
    do_mount ${ISO_IMG} "-o loop"
}

mount_virtual_usb_part()
{
    USB_DEVICE=$1
    PART_NO=$2
    do_mount ${USB_DEVICE}p${PART_NO}
}

umount_and_delete()
{
    MOUNT_POINT=$1
    umount ${MOUNT_POINT}
    rm -rf ${MOUNT_POINT}
}

usb_device=$(create_virtual_usb /tmp/usb.img 3)

init_usb_device ${usb_device} 50

add_partition ${usb_device} 50 75
add_partition ${usb_device} 75 100

format_partition ${usb_device} 1
format_partition ${usb_device} 2
format_partition ${usb_device} 3

ISO_MNT_POINT=$(mount_iso ${ISO_FILE})
USB_MNT_POINT=$(mount_virtual_usb_part ${usb_device} 1)

cp -rf ${ISO_MNT_POINT}/* ${USB_MNT_POINT}

umount_and_delete ${ISO_MNT_POINT}
umount_and_delete ${USB_MNT_POINT}

detach_loop_device ${usb_device}
