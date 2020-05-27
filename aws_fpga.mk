u-boot:
	@echo "Building u-boot for AWS FPGA ..."
	@cd u-boot/arch/riscv/dts; cp ec_raptorawsfpga.dts ec_raptorfpga.dts
	make -C u-boot ec_raptorfpga_defconfig
	make -C u-boot all -j$(nproc)
	@cd u-boot; git checkout arch/riscv/dts/ec_raptorfpga.dts

opensbi:
	@echo "Building opensbi for AWS FPGA ..."
	make -C opensbi PLATFORM=ec/raptor FW_PAYLOAD_PATH=../u-boot/u-boot.bin FW_PAYLOAD_FDT_PATH=../u-boot/u-boot.dtb FW_UART_CONFIG=RAPTOR_AWS_FPGA

fit_image:
	@echo "Building FIT image for AWS FPGA ..."
	@cp ./u-boot/arch/riscv/dts/ec_raptorawsfpga.dts fit_image
	@cp ./opensbi/build/platform/ec/raptor/firmware/fw_payload.bin fit_image
	@cp ./linux/arch/riscv/boot/Image fit_image
	@cd fit_image; dtc -O dtb -o ec_raptorawsfpga.dtb ec_raptorawsfpga.dts
	@cd fit_image; ../u-boot/tools/mkimage -f image_aws.its image_aws.itb
	@rm -f ./fit_image/Image
	@rm -f ./fit_image/ec_raptorawsfpga.dt*
