# Визначення префіксу для крос-компіляції під ARM (наприклад, arm-none-eabi-)
SDK_PREFIX?=arm-none-eabi-

# Визначення змінних для інструментів компіляції та збирання
CC = $(SDK_PREFIX)gcc       # Компілятор GCC для ARM
LD = $(SDK_PREFIX)ld         # Лінкер
SIZE = $(SDK_PREFIX)size     # Інструмент для перевірки розміру вихідного файлу
OBJCOPY = $(SDK_PREFIX)objcopy # Утиліта для конвертації бінарних файлів
QEMU = qemu-system-gnuarmeclipse # Емулятор QEMU для STM32

# Параметри плати та мікроконтролера
BOARD ?= STM32F4-Discovery   # За замовчуванням використовується плата STM32F4-Discovery
MCU=STM32F407VG             # Вказуємо модель мікроконтролера

# Назва цільового файлу (фірмварі)
TARGET=firmware

# Архітектура процесора
CPU_CC=cortex-m4

# Адреса для підключення через GDB у QEMU
TCP_ADDR=1234

# Додаткові залежності, які використовуються у процесі компіляції
deps = start.S lscript.ld

# Основна ціль
all: target

# Компіляція та лінкування
target:
	# Асемблюємо стартовий файл (start.S) у об'єктний файл
	$(CC) -x assembler-with-cpp -c -O0 -g3 -mcpu=$(CPU_CC) -Wall start.S -o start.o
	
	# Лінкуємо об'єктний файл у виконуваний ELF-файл
	$(CC) start.o -mcpu=$(CPU_CC) -Wall --specs=nosys.specs -nostdlib -lgcc -T./lscript.ld -o $(TARGET).elf
	
	# Конвертуємо ELF-файл у бінарний формат
	$(OBJCOPY) -O binary -F elf32-littlearm $(TARGET).elf $(TARGET).bin

# Запуск емулятора QEMU з відповідними параметрами
qemu:
	$(QEMU) --verbose --verbose --board $(BOARD) --mcu $(MCU) -d unimp,guest_errors \
	--image $(TARGET).bin --semihosting-config enable=on,target=native \
	-gdb tcp::$(TCP_ADDR) -S

# Очищення згенерованих файлів
clean:
	-rm *.o
	-rm *.elf
	-rm *.bin
