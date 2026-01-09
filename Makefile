ARDUINO_CLI := $(shell which arduino-cli)
SRCDIR := ESP32_PrusaConnectCam
BUILD_DIR := build
OUT_DIR := $(BUILD_DIR)/output
MCU_CFG := $(SRCDIR)/mcu_cfg.h

.PHONY: all prereqs clean esp32-cam esp32-wrover-dev esp32-s3-eye-22 xiao-esp32-s3 esp32-s3-cam esp32-s3-wroom-freenove

all: esp32-cam esp32-wrover-dev esp32-s3-eye-22 xiao-esp32-s3 esp32-s3-cam esp32-s3-wroom-freenove

prereqs:
	@if [ -z "$(ARDUINO_CLI)" ]; then echo "arduino-cli not found. Please install arduino-cli and ensure it's on PATH."; exit 1; fi

	$(ARDUINO_CLI) lib update-index
	$(ARDUINO_CLI) lib install ArduinoJson
	$(ARDUINO_CLI) lib install ArduinoUniqueID
	$(ARDUINO_CLI) lib install DHTNEW
	$(ARDUINO_CLI) lib install "Async TCP"@3.1.4
	$(ARDUINO_CLI) lib install "ESP Async WebServer"@2.10.8
	$(ARDUINO_CLI) lib upgrade
	$(ARDUINO_CLI) lib list

	$(ARDUINO_CLI) core update-index
	$(ARDUINO_CLI) core install esp32:esp32
	$(ARDUINO_CLI) core upgrade
	$(ARDUINO_CLI) core list

clean:
	rm -rf $(BUILD_DIR)

# Per-board variables (display name, mcu define, compile flags, output filename)
BOARD_DISPLAY_esp32-cam := Ai Thinker ESP32-CAM
BOARD_DEFINE_esp32-cam := AI_THINKER_ESP32_CAM
BOARD_FLAGS_esp32-cam := esp32:esp32:esp32cam:CPUFreq=240,FlashFreq=80,FlashMode=dio,PartitionScheme=min_spiffs,DebugLevel=none,EraseFlash=none
BOARD_OUT_esp32-cam := ESP32_PrusaConnectCam.ino.bin

BOARD_DISPLAY_esp32-wrover-dev := ESP32 Wrover Dev board
BOARD_DEFINE_esp32-wrover-dev := ESP32_WROVER_DEV
BOARD_FLAGS_esp32-wrover-dev := esp32:esp32:esp32wrover:FlashFreq=80,FlashMode=dio,PartitionScheme=min_spiffs,DebugLevel=none,EraseFlash=none
BOARD_OUT_esp32-wrover-dev := ESP32_WROVERDEV.bin

BOARD_DISPLAY_esp32-s3-eye-22 := ESP32-S3-EYE 2.2 board
BOARD_DEFINE_esp32-s3-eye-22 := CAMERA_MODEL_ESP32_S3_EYE_2_2
BOARD_FLAGS_esp32-s3-eye-22 := esp32:esp32:esp32s3:USBMode=hwcdc,CDCOnBoot=cdc,MSCOnBoot=default,DFUOnBoot=default,UploadMode=cdc,CPUFreq=240,FlashMode=dio,FlashSize=8M,PartitionScheme=min_spiffs,DebugLevel=none,PSRAM=opi,LoopCore=0,EventsCore=0,EraseFlash=none,JTAGAdapter=default,ZigbeeMode=default
BOARD_OUT_esp32-s3-eye-22 := ESP32S3_EYE22.bin

BOARD_DISPLAY_xiao-esp32-s3 := XIAO ESP32-S3 Sense
BOARD_DEFINE_xiao-esp32-s3 := CAMERA_MODEL_XIAO_ESP32_S3_CAM
BOARD_FLAGS_xiao-esp32-s3 := esp32:esp32:XIAO_ESP32S3:USBMode=hwcdc,CDCOnBoot=default,MSCOnBoot=default,DFUOnBoot=default,UploadMode=default,CPUFreq=160,FlashMode=qio,FlashSize=8M,PartitionScheme=default_8MB,DebugLevel=none,PSRAM=opi,LoopCore=1,EventsCore=1,EraseFlash=none,JTAGAdapter=default
BOARD_OUT_xiao-esp32-s3 := XIAO_ESP32S3.bin

BOARD_DISPLAY_esp32-s3-cam := ESP32-S3-CAM
BOARD_DEFINE_esp32-s3-cam := CAMERA_MODEL_ESP32_S3_CAM
BOARD_FLAGS_esp32-s3-cam := esp32:esp32:esp32s3:USBMode=hwcdc,CDCOnBoot=default,MSCOnBoot=default,DFUOnBoot=default,UploadMode=default,CPUFreq=240,FlashMode=dio,FlashSize=16M,PartitionScheme=min_spiffs,DebugLevel=none,PSRAM=opi,LoopCore=0,EventsCore=0,EraseFlash=none,JTAGAdapter=default,ZigbeeMode=default
BOARD_OUT_esp32-s3-cam := esp32-s3-cam.bin

BOARD_DISPLAY_esp32-s3-wroom-freenove := ESP32-S3 WROOM FREENOVE
BOARD_DEFINE_esp32-s3-wroom-freenove := ESP32_S3_WROOM_FREENOVE
BOARD_FLAGS_esp32-s3-wroom-freenove := esp32:esp32:esp32s3:USBMode=hwcdc,CDCOnBoot=default,MSCOnBoot=default,DFUOnBoot=default,UploadMode=default,CPUFreq=240,FlashMode=qio,FlashSize=8M,PartitionScheme=min_spiffs,DebugLevel=none,PSRAM=opi,LoopCore=0,EventsCore=0,EraseFlash=none,JTAGAdapter=default,ZigbeeMode=default
BOARD_OUT_esp32-s3-wroom-freenove := ESP32-S3-WROOM_FREENOVE.bin


# Shared board build template using per-board variables
# Reset all known board defines to false
define RESET_DEFINES
	sed -E -i.bak "s/^#define (AI_THINKER_ESP32_CAM|ESP32_WROVER_DEV|CAMERA_MODEL_ESP32_S3_DEV_CAM|CAMERA_MODEL_ESP32_S3_EYE_2_2|CAMERA_MODEL_XIAO_ESP32_S3_CAM|CAMERA_MODEL_ESP32_S3_CAM|ESP32_S3_WROOM_FREENOVE)([[:space:]]+).*/#define \1\2false/" $(abspath $(MCU_CFG)) && rm -f $(abspath $(MCU_CFG)).bak
endef

define BUILD_BOARD
$1:
	@echo "Building $$(BOARD_DISPLAY_$1)"
	@mkdir -p $(BUILD_DIR)/$1 $(OUT_DIR)
	@cd $(SRCDIR) && \
		$(RESET_DEFINES) && \
		sed -E -i.bak "s/^#define ($$(BOARD_DEFINE_$1))([[:space:]]+).*/#define \1\2true/" $(abspath $(MCU_CFG)) && rm -f $(abspath $(MCU_CFG)).bak && \
		$(ARDUINO_CLI) compile -v -b $$(BOARD_FLAGS_$1) --output-dir ../$(BUILD_DIR)/$1
	@cp $(BUILD_DIR)/$1/ESP32_PrusaConnectCam.ino.bin $(OUT_DIR)/$$(BOARD_OUT_$1) || true
	@cd $(BUILD_DIR)/$1 && zip -r ../$1.zip . && cd -
	@mv $(BUILD_DIR)/$1.zip $(OUT_DIR)/
	@cd $(SRCDIR) &&  $(RESET_DEFINES)

	@echo ""
	@echo "Build for $$(BOARD_DISPLAY_$1) completed:"
	@echo "  $(OUT_DIR)/$1.zip"
	@echo "  $(OUT_DIR)/$$(BOARD_OUT_$1)"
endef

$(eval $(call BUILD_BOARD,esp32-cam))
$(eval $(call BUILD_BOARD,esp32-wrover-dev))
$(eval $(call BUILD_BOARD,esp32-s3-eye-22))
$(eval $(call BUILD_BOARD,xiao-esp32-s3))
$(eval $(call BUILD_BOARD,esp32-s3-cam))
$(eval $(call BUILD_BOARD,esp32-s3-wroom-freenove))
