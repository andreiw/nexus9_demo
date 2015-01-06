CC = $(CROSS_COMPILE)gcc
LD = $(CROSS_COMPILE)ld
OBJCOPY = $(CROSS_COMPILE)objcopy

TARGET = nexus9_demo
TEXT_BASE = 0x80080000

CFLAGS = \
	-march=armv8-a \
	-mlittle-endian \
	-fno-stack-protector \
	-mgeneral-regs-only \
	-mstrict-align \
	-fno-common \
	-fno-builtin \
	-ffreestanding \
	-std=gnu99 \
	-Werror \
	-Wall

LDFLAGS =

%.o: %.S
	$(CC) $(CFLAGS) $< -c -o $@

%.o: %.c
	$(CC) $(CFLAGS) $< -c -o $@

$(TARGET): $(TARGET).with_dtb
	mkbootimg --base 0 --pagesize 2048 --kernel_offset 0x0 --ramdisk_offset 0x0 --second_offset 0x0 --tags_offset 0x0 --kernel $< --ramdisk /dev/null -o $@

$(TARGET).with_dtb: $(TARGET).gz nexus9_dtb
	cat $^ > $@

$(TARGET).gz: $(TARGET).bin
	gzip -f -c $< > $@

$(TARGET).bin: $(TARGET).elf
	$(OBJCOPY) -v -O binary $< $@

$(TARGET).elf: start.o demo.o
	$(LD) -T boot.lds -Ttext=$(TEXT_BASE) $(LDFLAGS) $^ -o $@

clean:
	rm -f *.o $(TARGET) $(TARGET).*

.PHONY: all clean
