.PHONY: all clean rebuild run

RM := rm -rf

CC=gcc
CFLAGS=-g
BIN=kbin
LIBS=-I./include

SRC := ./arch/i386/boot/bootsect.asm
OUT := ./build/boot.bin
IMG := ./build/data.img

all : $(OUT) $(IMG)
	dd if=$(OUT) of=$(IMG) bs=512 count=1 conv=notrunc
	@echo "build success..."
  
$(OUT) : $(SRC)
	nasm $^ -o $@

clean :
	$(RM) $(OUT) *.o

rebuild :
	@$(MAKE) clean
	@$(MAKE) all

run :
	@$(MAKE) clean
	@$(MAKE) all
	bochs
