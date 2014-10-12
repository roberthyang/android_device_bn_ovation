# Copyright (C) 2007 The Android Open Source Project
# Copyright (C) 2011 The CyanogenMod Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# BoardConfig.mk
#
# Product-specific compile-time definitions.
#

DEVICE_FOLDER := device/bn/ovation
TARGET_BOARD_OMAP_CPU := 4470
TARGET_BOOTLOADER_BOARD_NAME := ovation
TARGET_BOARD_PLATFORM := omap4
TARGET_NO_KERNEL := false
TARGET_NO_RADIOIMAGE := true
OMAP_ENHANCEMENT := true
HARDWARE_OMX := true
INCLUDE_PERF := 0
BOARD_HAVE_BLUETOOTH := true
BOARD_HAVE_NFC := true
TARGET_USERIMAGES_USE_EXT4 := true
#BOARD_USES_HGL := true
#BOARD_USES_OVERLAY := true
BOARD_USE_TI_ENHANCED_DOMX := true
USE_OPENGL_RENDERER := true
OMAP_ENHANCEMENT_MULTIGPU := true
#BOARD_USE_CUSTOM_LIBION := true

# HWComposer
BOARD_USES_HWCOMPOSER := true
BOARD_USE_SYSFS_VSYNC_NOTIFICATION := true
TARGET_RUNNING_WITHOUT_SYNC_FRAMEWORK := true
BOARD_EGL_WORKAROUND_BUG_10194508 := true

ifdef HARDWARE_OMX
OMX_VENDOR := ti
OMX_VENDOR_INCLUDES := \
   hardware/ti/omx/system/src/openmax_il/omx_core/inc \
   hardware/ti/omx/image/src/openmax_il/jpeg_enc/inc
OMX_VENDOR_WRAPPER := TI_OMX_Wrapper
BOARD_OPENCORE_LIBRARIES := libOMX_Core
BOARD_OPENCORE_FLAGS := -DHARDWARE_OMX=1
endif

# TI Enhancement Settings (Part 2)
ifdef BOARD_USE_TI_ENHANCED_DOMX
    BOARD_USE_TI_DUCATI_H264_PROFILE := true
    COMMON_GLOBAL_CFLAGS += -DENHANCED_DOMX
    ENHANCED_DOMX := true
else
    DOMX_PATH := hardware/ti/omap4xxx/domx
endif

ifdef OMAP_ENHANCEMENT
    COMMON_GLOBAL_CFLAGS += -DOMAP_ENHANCEMENT -DTARGET_OMAP4
    COMMON_GLOBAL_CFLAGS += -DFORCE_SCREENSHOT_CPU_PATH
endif

ifdef OMAP_ENHANCEMENT_BURST_CAPTURE
    COMMON_GLOBAL_CFLAGS += -DOMAP_ENHANCEMENT_BURST_CAPTURE
endif

ifdef OMAP_ENHANCEMENT_S3D
    COMMON_GLOBAL_CFLAGS += -DOMAP_ENHANCEMENT_S3D
endif

ifdef OMAP_ENHANCEMENT_CPCAM
    COMMON_GLOBAL_CFLAGS += -DOMAP_ENHANCEMENT_CPCAM
    PRODUCT_MAKEFILES += $(LOCAL_DIR)/sdk_addon/ti_omap_addon.mk
endif

ifdef OMAP_ENHANCEMENT_VTC
    COMMON_GLOBAL_CFLAGS += -DOMAP_ENHANCEMENT_VTC
endif

ifdef USE_ITTIAM_AAC
    COMMON_GLOBAL_CFLAGS += -DUSE_ITTIAM_AAC
endif

ifdef OMAP_ENHANCEMENT_MULTIGPU
    COMMON_GLOBAL_CFLAGS += -DOMAP_ENHANCEMENT_MULTIGPU
endif

# CPU
TARGET_CPU_ABI := armeabi-v7a
TARGET_CPU_ABI2 := armeabi
TARGET_CPU_SMP := true
TARGET_ARCH := arm
TARGET_ARCH_VARIANT := armv7-a-neon
TARGET_ARCH_VARIANT_CPU := cortex-a9
TARGET_CPU_VARIANT := cortex-a9
ARCH_ARM_HAVE_TLS_REGISTER := true
TARGET_GLOBAL_CFLAGS += -mtune=cortex-a9 -mfpu=neon -mfloat-abi=softfp
TARGET_GLOBAL_CPPFLAGS += -mtune=cortex-a9 -mfpu=neon -mfloat-abi=softfp
TARGET_USERIMAGES_SPARSE_EXT_DISABLED := true

# OMAP4 -- Cortex A9
TARGET_EXTRA_CFLAGS += $(call cc-ifversion, -ge, 46, $(call cc-option,-mtune=cortex-a9,$(call cc-option,-mtune=cortex-a8)) $(call cc-option,-mcpu=cortex-a9,$(call cc-option,-mcpu=cortex-a8)))

# ARMs gator (DS-5)
# TARGET_USE_GATOR:= true

# inherit from common
-include device/bn/common/BoardConfigCommon.mk

# inherit from the proprietary version
-include vendor/bn/hd-common/BoardConfigVendor.mk

# use stub camera from device/bn/common.
BN_CAMERA_STUB := true
#USE_CAMERA_STUB := false

# Kernel/Boot
BOARD_USES_UBOOT := false

# boot.img creation
BOARD_CUSTOM_BOOTIMG_MK := $(DEVICE_FOLDER)/boot.mk

TARGET_KERNEL_CONFIG := yellow_ovation_defconfig
#TARGET_KERNEL_CONFIG := cyanogenmod_ovation_green_defconfig
TARGET_KERNEL_SOURCE := kernel/bn/omap
#TARGET_GCC_VERSION_EXP := 4.7
#TARGET_KERNEL_CUSTOM_TOOLCHAIN := arm-linux-androideabi-
#TARGET_USE_O3 := true

SGX_MODULES:
	make clean -C $(COMMON_FOLDER)/pvr-source/eurasiacon/build/linux2/omap4430_android
	cp $(TARGET_KERNEL_SOURCE)/drivers/video/omap2/omapfb/omapfb.h $(KERNEL_OUT)/drivers/video/omap2/omapfb/omapfb.h
	make -j4 -C $(COMMON_FOLDER)/pvr-source/eurasiacon/build/linux2/omap4430_android ARCH=arm KERNEL_CROSS_COMPILE=arm-eabi- CROSS_COMPILE=arm-eabi- KERNELDIR=$(KERNEL_OUT) TARGET_PRODUCT="blaze_tablet" BUILD=release TARGET_SGX=544sc PLATFORM_VERSION=4.2
	mv $(KERNEL_OUT)/../../target/kbuild/pvrsrvkm_sgx544_112.ko $(KERNEL_MODULES_OUT)
	$(ARM_EABI_TOOLCHAIN)/arm-eabi-strip --strip-unneeded $(KERNEL_MODULES_OUT)/pvrsrvkm_sgx544_112.ko

WIFI_MODULES:
	make -C hardware/ti/wlan/mac80211/compat_wl12xx KERNELDIR=$(KERNEL_OUT) KLIB=$(KERNEL_OUT) KLIB_BUILD=$(KERNEL_OUT) ARCH=arm CFLAGS_MODULE=-fno-pic CROSS_COMPILE=arm-eabi-
	mv $(KERNEL_OUT)/lib/crc7.ko $(KERNEL_MODULES_OUT)
	mv hardware/ti/wlan/mac80211/compat_wl12xx/compat/compat.ko $(KERNEL_MODULES_OUT)
	mv hardware/ti/wlan/mac80211/compat_wl12xx/net/mac80211/mac80211.ko $(KERNEL_MODULES_OUT)
	mv hardware/ti/wlan/mac80211/compat_wl12xx/net/wireless/cfg80211.ko $(KERNEL_MODULES_OUT)
	mv hardware/ti/wlan/mac80211/compat_wl12xx/drivers/net/wireless/wl12xx/wl12xx.ko $(KERNEL_MODULES_OUT)
	mv hardware/ti/wlan/mac80211/compat_wl12xx/drivers/net/wireless/wl12xx/wl12xx_sdio.ko $(KERNEL_MODULES_OUT)

TARGET_KERNEL_MODULES := SGX_MODULES WIFI_MODULES

# Recovery
BOARD_CUSTOM_RECOVERY_KEYMAPPING := ../../$(DEVICE_FOLDER)/recovery/recovery_keys.c
TARGET_RECOVERY_INITRC := $(DEVICE_FOLDER)/recovery/init.rc
TARGET_RECOVERY_FSTAB := $(DEVICE_FOLDER)/root/fstab.ovation
RECOVERY_FSTAB_VERSION := 2

#Config for building TWRP
DEVICE_RESOLUTION := 1920x1200
RECOVERY_TOUCHSCREEN_SWAP_XY := true
RECOVERY_TOUCHSCREEN_FLIP_Y := true
