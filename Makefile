TOP = ..
include $(TOP)/mk/boilerplate.mk

SSUBDIRS = Dph Hackage Repa Shootout

SUBDIRS = $(filter-out $(NOT_THESE), $(SSUBDIRS))

include $(TOP)/mk/target.mk


