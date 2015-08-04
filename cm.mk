# Inherit some common CM stuff.
$(call inherit-product, vendor/cm/config/common_full_phone.mk)

# Boot animation
TARGET_SCREEN_WIDTH := 854
TARGET_SCREEN_HEIGHT := 480

# Release name
PRODUCT_RELEASE_NAME := msm8x25q_d5c
PRODUCT_NAME := cm_msm8x25q_d5c

$(call inherit-product, device/smartfren/msm8x25q_d5c/full_d5c.mk)

PRODUCT_BUILD_PROP_OVERRIDES += \
    PRODUCT_BRAND=smartfren \
    PRODUCT_NAME=msm8x25q_d5c \
    BUILD_PRODUCT=msm8x25q_d5c

