#Assembler and linker
ASM = nasm
LD = ld

#Flags for NASM and LD
ASM_FLAGS = -f bin
LD_FLAGS = -Ttext 0x7C00 --oformat binary


OUTPUT = bootloader.img


SOURCES = boot.asm 


OBJS = boot.o 


EMU = qemu-system-x86_64

# USB target (optional: path to your USB device)
USB_DEV = /dev/sdc  # Change this to the actual USB device (e.g., /dev/sdb)

#Default target: compile and link the bootloader
all: $(OUTPUT)

#Compile each .asm file to a .bin format (for bootable binary)
bootloader.img: $(SOURCES)
	$(ASM) $(ASM_FLAGS) -o boot.bin boot.asm

# Run the bootloader using QEMU for testing
run:
	$(EMU) -drive format=raw,file=$(OUTPUT),index=0,if=floppy

# Clean all generated files
clean:
	rm -f *.bin $(OUTPUT)

# Write the bootloader to a USB device
#write_to_usb:
#	dd if=$(OUTPUT) of=$(USB_DEV) bs=512 count=1

#.PHONY: all clean run write_to_usb
.PHONY: all clean run
