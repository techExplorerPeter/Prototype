#------------------------------------------------------------------------------
#	Generic Makefile for M7 project
#------------------------------------------------------------------------------
# default output directory
BUILD 		  := ../Build
OBJS_DIR      := $(BUILD)/objs
IMAGE_OUT_DIR := $(BUILD)/image
SHELL_DIR     := ../Tools/shell
DIRS		  := $(BUILD) $(OBJS_DIR) $(IMAGE_OUT_DIR)
LINKER_DIR    := Linkers
Kconfig_Out_log := kconfig_log.txt
Kconfig_PROJ_CFG := project_config.h
LINKER_FILE := $(OBJS_DIR)/project.ld
LDFLAGS 	:= -pie -Bstatic  --no-dynamic-linker -T $(LINKER_FILE) #-L$(DIR_LD)# -lc

# The C program compiler choice
CROSS_COMPILE := arm-none-eabi-
CC := $(CROSS_COMPILE)gcc
LD := $(CROSS_COMPILE)ld
OBJCOPY:= $(CROSS_COMPILE)objcopy
OBJDUMP:= $(CROSS_COMPILE)objdump

# a53 target sdcard file
A53_BOOTLOADER := ../Docs/release/fip.s32-sdcard

#generic bsw files directory
BSW_STATIC := BSW/S32DS

CFLAGS = -g -mcpu=cortex-m7 -mthumb -mlittle-endian -fomit-frame-pointer -Wall 

BSW_STATIC_INCS :=	-I$(BSW_STATIC)/board 				\
					-I$(BSW_STATIC)/generate/include 	\
					-I$(BSW_STATIC)/RTD/include

SRC_INCS +=	$(BSW_STATIC_INCS)

CFLAGS += $(SRC_INCS)
CFLAGS += -mfloat-abi=hard  -mfpu=fpv5-sp-d16 -DENABLE_FPU -DMPU_ENABLE -DS32R45 -DCPU_CORTEX_M7 -DUSE_SW_VECTOR_MODE
CFLAGS += -DD_CACHE_ENABLE -DVV_RESULT_ADDRESS=0x34500000 -DI_CACHE_ENABLE -DCPU_S32R45 -std=c99 #-DM7_BIN_SIZE=0x10000

include ./.config

# add BSW source files
SRC := 

ASM_SRC 		 := $(wildcard $(LINKER_DIR)/*.S)
# add cobblestone sources and includes
include Cobblestone/Cobblestone.mk

STRIPPED_SRC 	 := $(notdir $(SRC))
STRIPPED_ASM_SRC := $(notdir $(ASM_SRC))
STRIPPED_OBJ 	 := $(STRIPPED_SRC:%.c=%.o)
STRIPPED_ASM_OBJ := $(STRIPPED_ASM_SRC:%.S=%.o)
STRIPPED_BSW_OBJ :=
ASM_OBJ 		 := $(addprefix $(OBJS_DIR)/,$(STRIPPED_ASM_OBJ))
OBJ 		 	 := $(addprefix $(OBJS_DIR)/,$(STRIPPED_OBJ))
BSW_SRC			 :=
BSW_OBJ 		 :=
obj-y            :=
# add your sub-makefile into this
include BSW/Makefile

# enum the bsw obj and sources
ifneq ($(strip $(obj-y) $(obj-m) $(obj-)),)
BSW_SRC += $(foreach dir,$(addprefix $(BSW_STATIC)/,$(filter-out %.o,$(obj-y))),$(wildcard $(dir)/*.c))
STRIPPED_BSW_OBJ += $(patsubst %.c,%.o,$(BSW_SRC))   
STRIPPED_BSW_OBJ += $(filter %.o,$(obj-y))
BSW_OBJ 		 += $(addprefix $(OBJS_DIR)/,$(notdir $(STRIPPED_BSW_OBJ)))
endif

SRC += $(BSW_SRC)

vpath %.S $(sort $(dir $(ASM_SRC)))
vpath %.c $(sort $(dir $(SRC)))

OBJ += $(ASM_OBJ) $(BSW_OBJ)

ELF := $(OBJS_DIR)/m7.elf
ELF_MAP := $(patsubst %.elf,%.map, $(ELF))
ELF_BIN := $(patsubst %.elf,%.bin, $(ELF))
ELF_DUMP := $(patsubst %.elf,%.dump, $(ELF))

ifeq (,$(findstring clean,$(MAKECMDGOALS))$(findstring compile,$(MAKECMDGOALS)))
ifeq ("$(wildcard $(A53_BOOTLOADER))","")
$(error "Please specify the bootloader binary using A53_BOOTLOADER argument.\
	E.g.: make A53_BOOTLOADER=u-boot.s32")
endif

CFLAGS += -DCUSTOM_START_ADDR=$(shell $(SHELL_DIR)/append_m7.sh -e -i $(A53_BOOTLOADER))
A53_BOOTLOADER_OUT := $(A53_BOOTLOADER).m7      #target merge files
endif

ifdef DISABLE_A53_LOCKSTEP
CFLAGS += -DDISABLE_A53_LOCKSTEP
endif

ASFLAGS := $(CFLAGS)

.PHONY: all compile $(A53_BOOTLOADER_OUT)

all: autoconfig $(DIRS) $(A53_BOOTLOADER_OUT)

compile: $(DIRS) $(ELF)

$(A53_BOOTLOADER_OUT): $(A53_BOOTLOADER) cleanlinker $(ELF)
	@printf "  [APP]\t$@ <- $<\n"
	@$(SHELL_DIR)/append_m7.sh -i $< -b $(ELF_BIN) -m $(ELF_MAP)
	@cp $(A53_BOOTLOADER_OUT) $(IMAGE_OUT_DIR)

$(OBJS_DIR)/%.ld: %.ld.S
	@printf "  [CC]\t$@ <- $<\n"
	@$(CC) -E -P $(CFLAGS) -o $@ $<

$(OBJS_DIR)/%.o: %.S
	@printf "  [CC]\t$@ <- $<\n"
	@$(CC) $(ASFLAGS) -c -o $@ $<

$(OBJS_DIR)/%.o: %.c
	@printf "  [CC]\t$@ <- $<\n"
	@$(CC) $(CFLAGS) -c -o $@ $<

$(ELF): $(OBJ) $(LINKER_FILE)
	@printf "  [LD]\t$@ <- $<\n"
	@echo 11111111111obj-y =  $(obj-y)
	@echo -----------BSW_SRC =  $(BSW_SRC)
	@echo ===========BSW_OBJ = $(BSW_OBJ)
	@$(LD) $(LDFLAGS) -Map=$(ELF_MAP) -o $@ $(OBJ)
#	@$(OBJCOPY) -j .vtable -j .data -j .text -O binary $@ $(ELF_BIN) # for reduce the bin size
	@$(OBJCOPY) -O binary $@ $(ELF_BIN)
	@$(OBJDUMP) -D $@ > $(ELF_DUMP)

$(DIRS):
	@printf "  [MK]\t$(DIRS)\n"
	@mkdir -p $(DIRS)

cleanlinker:
	@printf "  [RM]\t$(LINKER_FILE)\n"
	@rm -f $(LINKER_FILE)

clean:
	@printf "  [RM]\t$(BUILD)\n"
	@rm -rf $(BUILD)
	@rm -rf $(Kconfig_PROJ_CFG) $(Kconfig_Out_log)

config:
	menuconfig
menuconfig:
	menuconfig

autoconfig:
	python ../Tools/kconfig/kconfig.py Kconfig .config $(Kconfig_PROJ_CFG) $(Kconfig_Out_log) .config
