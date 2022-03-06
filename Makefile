ARCHS = arm64e arm64

export SDKVERSION = 10.3
export TARGET = iphone:clang:14.4:14.4

export iP = localhost
export Port = 2001
export Pass = alpine
export Bundle = com.crazymind90.YTDownload

DEBUG = 0

INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = RotateAV

RotateAV_FILES = Tweak.xm
RotateAV_CFLAGS = -fobjc-arc
RotateAV_LIBRARIES = rocketbootstrap
RotateAV_PRIVATE_FRAMEWORKS = AppSupport SpringBoardServices

include $(THEOS_MAKE_PATH)/tweak.mk


install5::
		install5.exec
