TARGET = iphone:clang:latest:14.8
INSTALL_TARGET_PROCESSES = watchwitchcompanion

include $(THEOS)/makefiles/common.mk

APPLICATION_NAME = watchwitchcompanion

watchwitchcompanion_FILES = wwcApp.swift ContentView.swift Preferences.swift
watchwitchcompanion_FRAMEWORKS = SwiftUI CoreGraphics
watchwitchcompanion_EXTRA_FRAMEWORKS += Cephei

include $(THEOS_MAKE_PATH)/application.mk
