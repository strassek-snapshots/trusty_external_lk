ifndef ARCH_x86_64_TOOLCHAIN_INCLUDED
ARCH_x86_64_TOOLCHAIN_INCLUDED := 1

ifndef ARCH_x86_64_TOOLCHAIN_PREFIX
ARCH_x86_TOOLCHAIN_PREFIX := x86_64-elf-
FOUNDTOOL=$(shell which $(ARCH_x86_64_TOOLCHAIN_PREFIX)gcc)
endif

ifeq ($(FOUNDTOOL),)
$(error cannot find toolchain, please set ARCH_x86_64_TOOLCHAIN_PREFIX or add it to your path)
endif

endif