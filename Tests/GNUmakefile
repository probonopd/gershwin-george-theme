# Copyright (c) 2026 Simon Peter
#
# SPDX-License-Identifier: BSD-2-Clause

include $(GNUSTEP_MAKEFILES)/common.make

TEST_TOOL_NAME = t_GeorgeFonts t_GeorgeIcons t_GeorgePlatinum t_GeorgeTitleBar

ADDITIONAL_CPPFLAGS += -I$(GNUSTEP_MAKEFILES)/TestFramework

t_GeorgeFonts_OBJC_FILES = t_GeorgeFonts.m
t_GeorgeIcons_OBJC_FILES = t_GeorgeIcons.m
t_GeorgePlatinum_OBJC_FILES = t_GeorgePlatinum.m
t_GeorgeTitleBar_OBJC_FILES = t_GeorgeTitleBar.m

-include GNUmakefile.preamble
include $(GNUSTEP_MAKEFILES)/test-tool.make
