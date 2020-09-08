.PHONY: all clean rebuild run

RM := rm -rf

CC=gcc
CFLAGS=-g
BIN=kbin
LIBS=-I./include

ASM_INCLUDE_DIR := ./arch/i386/boot/

BOOT_SRC   := ./arch/i386/boot/bootsect.asm
BOOT_OUT   := ./build/boot.bin

LOADER_SRC := ./arch/i386/boot/loader.asm
LOADER_OUT := ./build/loader.bin

IMG := ./build/data.img
IMG_MNT_PATH := /home/mzygmzyg1996/mnt

all : $(BOOT_OUT) $(LOADER_OUT) $(IMG)
	@echo "build success..."
  
$(BOOT_OUT) : $(BOOT_SRC)
	nasm $^ -o $@
	dd if=$(BOOT_OUT) of=$(IMG) bs=512 count=1 conv=notrunc

$(LOADER_OUT) : $(LOADER_SRC)
	nasm $< -I $(ASM_INCLUDE_DIR) -o $@
	sudo mount -o loop $(IMG) $(IMG_MNT_PATH)
	sudo cp $@ $(IMG_MNT_PATH)/loader.bin
	sudo umount $(IMG_MNT_PATH)

clean :
	$(RM) $(BOOT_OUT) $(LOADER_OUT) *.o

rebuild :
	@$(MAKE) clean
	@$(MAKE) all

run :
	@$(MAKE) clean
	@$(MAKE) all
	bochs
