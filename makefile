TARGET = build/main

S_SRC    = ./main.S

MCU_SPEC  = atmega328p
FLASHER = arduino
PORT = "\\.\COM22"
BAUD = 57600
FLASH_TARGET = m328p
# Toolchain definitions (ARM bare metal defaults)
CC = avr-gcc
OC = avr-objcopy
OD = avr-objdump
AD = avrdude
# Assembly directives.
ASFLAGS += -mmcu=$(MCU_SPEC)
ASFLAGS += -nostdlib
ASFLAGS += -Wall
# (Set error messages to appear on a single line.)
ASFLAGS += -fmessage-length=0
# C compilation directives
CFLAGS += -mmcu=$(MCU_SPEC)
CFLAGS += -Wall
CFLAGS += -g
# (Set error messages to appear on a single line.)
CFLAGS += -fmessage-length=0

# -c arduino -P \\.\COM22 -b 57600 -p m328p -D -U flash:w:main.hex:i
ADFLAGS = -c $(FLASHER)
ADFLAGS += -P $(PORT)
ADFLAGS += -b $(BAUD)
ADFLAGS += -p $(FLASH_TARGET)

OBJS =  $(S_SRC:.S=.o)

.PHONY: all
all: build flash

.PHONY: build
build: $(TARGET).hex clean
# %.elf: %.S
# 	$(CC) $(ASFLAGS) $< -o $@

$(TARGET).elf: $(OBJS)
	if not exist build mkdir build
	$(CC) $(ASFLAGS) $< -o $@
$(TARGET).hex: $(TARGET).elf
	$(OC) -O ihex $< $@

.PHONY: clean
clean:
	del main.o

.PHONY: flash
flash: $(TARGET).hex clean
	$(AD) $(ADFLAGS) -D -U flash:w:$(TARGET).hex:i

.PHONY: disasm
disasm: $(TARGET).elf
	$(OD) -D $(TARGET).elf > $(TARGET).txt
	