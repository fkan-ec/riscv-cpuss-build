u-boot:
	@echo "Building u-boot for XILINX FPGA ..."
	make -C u-boot ec_raptorfpga_defconfig
	make -C u-boot all -j$(nproc)

opensbi:
	@echo "Building opensbi for XILINX FPGA ..."
	make -C opensbi PLATFORM=ec/raptor FW_PAYLOAD_PATH=../u-boot/u-boot.bin FW_PAYLOAD_FDT_PATH=../u-boot/u-boot.dtb FW_UART_CONFIG=RAPTOR_XILINX_FPGA

fit_image:
	@echo "Building FIT image for XILINX FPGA ..."
	@cp ./u-boot/arch/riscv/dts/ec_raptorfpga.dts fit_image
	@cp ./opensbi/build/platform/ec/raptor/firmware/fw_payload.bin fit_image
	@cp ./linux/arch/riscv/boot/Image fit_image
	@cd fit_image; dtc -O dtb -o ec_raptorfpga.dtb ec_raptorfpga.dts
	@cd fit_image; ../u-boot/tools/mkimage -f image_xilinx.its image_xilinx.itb
	@rm -f ./fit_image/Image
	@rm -f ./fit_image/ec_raptorfpga.dt*
