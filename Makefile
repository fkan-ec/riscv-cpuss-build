# To build for XILINX FPGA (default)
# make all
# To build for AWS FPGA
# make BUILD_TARGET=AWS_FPGA all

ifndef RISCV 
$(error RISCV not defined)
endif

export PATH := $(RISCV)/bin:$(PATH)
export LD_LIBRARY_PATH := $(RISCV)/lib:$(LD_LIBRARY_PATH)
export CROSS_COMPILE := riscv64-unknown-linux-gnu-
BUILD_TARGET ?= XILINX_FPGA

.PHONY: all apply_patch opensbi u-boot linux fit_image

all: u-boot opensbi linux fit_image

apply_patch:
	@echo "Applying u-boot patches ..."
	@cd u-boot; git am --reject --whitespace=fix ../patches/u-boot/*
	@echo "Applying opensbi patches ..."
	@cd opensbi; git am --reject --whitespace=fix ../patches/opensbi/*
	@echo "Applying linux patches ..."
	@cd linux; git am --reject --whitespace=fix ../patches/linux/*

linux:
	@echo "Building linux ..."
	make -C linux ARCH=riscv CROSS_COMPILE=riscv64-unknown-linux-gnu- ec_raptor_defconfig
	make -C linux ARCH=riscv CROSS_COMPILE=riscv64-unknown-linux-gnu- Image -j $(nproc)

ifeq ($(BUILD_TARGET),XILINX_FPGA)
include xilinx_fpga.mk
else
ifeq ($(BUILD_TARGET),AWS_FPGA)
include aws_fpga.mk
else
$(error incorrect BUILD_TARGET '$(BUILD_TARGET)')
endif
endif

clean: clean_u-boot clean_opensbi clean_linux
	@rm -f ./fit_image/fw_payload.bin
	@rm -f ./fit_image/image_*.itb

clean_u-boot:
	make -C u-boot clean

clean_opensbi:
	make -C opensbi clean

clean_linux:
	make -C linux clean
