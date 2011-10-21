@rem auto create by AVRUBD at 28.04.2011 13:54:04
avr-gcc.exe  -mmcu=atmega8515 -Wall -gdwarf-2  -Os -fsigned-char -MD -MP  -c  bootldr.c
avr-gcc.exe -mmcu=atmega8515  -Wl,-section-start=.text=0x1800 bootldr.o     -o Bootldr.elf
avr-objcopy -O ihex -R .eeprom  Bootldr.elf Bootldr.hex
@pause
