include $(THEOS)/makefiles/common.mk

TWEAK_NAME = FckZck

FckZck_FILES = Tweak.xm
FckZck_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
