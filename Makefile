.ONESHELL:
SHELL = /bin/bash
.SHELLFLAGS += -e

KVERSION_SHORT = 5.10.65
KVERSION_SUB = orin
KVERSION = $(KVERSION_SHORT)-$(KVERSION_SUB)
KERNEL_VERSION = 5.10.65
KERNEL_SUBVERSION = orin-1

BUILD_DIR=linux-$(KVERSION)
TAR_FILE = linux-$(KVERSION).tar.xz

LINUX_HEADER_AMD64 = linux-headers-$(KVERSION)_$(KERNEL_VERSION)-$(KERNEL_SUBVERSION)_$(CONFIGURED_ARCH).deb
LINUX_IMAGE = linux-image-$(KVERSION)_$(KERNEL_VERSION)-$(KERNEL_SUBVERSION)_$(CONFIGURED_ARCH).deb
DTB_FILE = $(BUILD_DIR)/arch/arm64/boot/dts/nvidia/$(LINUX_DTB)

MAIN_TARGET = $(LINUX_HEADER_AMD64)
DERIVED_TARGETS = $(LINUX_IMAGE) $(DTB_FILE)

# Building kernel
$(addprefix $(DEST)/, $(MAIN_TARGET)): $(DEST)/% :
	# Obtaining the Debian kernel source
	rm -rf $(BUILD_DIR) *.deb *.dsc *.buildinfo *.changes *.gz

	wget -O $(TAR_FILE) http://fit69/auto/mtrsysgwork/fradensky/$(TAR_FILE)
	tar xf $(TAR_FILE)

	pushd $(BUILD_DIR)
	
	export ARCH=arm64

	git init
	git add -f *
	git commit -qm "check in all loose files and diffs"
	stg init
	stg import -s ../patch/orin/series

	make tegra_defconfig
	../manage-config $(CONFIGURED_ARCH) $(CONFIGURED_PLATFORM)

	make -j $(shell nproc) deb-pkg LOCALVERSION=-$(KVERSION_SUB)

	popd

ifneq ($(DEST),)
	mv $(DERIVED_TARGETS) $* $(DEST)/
endif

$(addprefix $(DEST)/, $(DERIVED_TARGETS)): $(DEST)/% : $(DEST)/$(MAIN_TARGET)

