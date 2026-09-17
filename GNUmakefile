include $(GNUSTEP_MAKEFILES)/common.make

GNUSTEP_INSTALLATION_DOMAIN = SYSTEM

PACKAGE_NAME = George
BUNDLE_NAME = George
BUNDLE_EXTENSION = .theme
VERSION = 1

George_INSTALL_DIR = $(GNUSTEP_LIBRARY)/Themes
George_PRINCIPAL_CLASS = George

George_OBJC_FILES = \
		George.m\
		George+Frame.m\
		George+Menu.m\
		George+Parts.m\
		George+TabView.m\
		George+TitleBar.m\
		GeorgePlatinum.m\
		GeorgeScrollerCells.m\
		NSFont+George.m

George_RESOURCE_FILES = \
	./Resources/Fonts

ADDITIONAL_OBJCFLAGS += -Wall

include $(GNUSTEP_MAKEFILES)/bundle.make

-include GNUmakefile.postamble
