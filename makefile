# $@ = target file
# $< = first dependency
# $^ = all dependencies

# detect all .o files based on their .c source
ASM_SOURCES = $(wildcard kernel/*.asm drivers/*.asm cpu/*.asm)
HEADERS = $(wildcard kernel/*.h  drivers/*.h cpu/*.h)
OBJ_FILES = ${ASM_SOURCES:.asm=.o cpu/interrupt.o}

# First rule is the one executed when no parameters are fed to the Makefile
all: run

# Notice how dependencies are built as needed
kernel.bin: ${OBJ_FILES}
	x86_64-elf-ld -m elf_i386 -o $@ -Ttext 0x1000 $^ --oformat binary

os-image.bin: boot/mbr.bin kernel.bin
	type boot\mbr.bin kernel.bin > $@

run: os-image.bin
	qemu-system-i386 -fda $<

echo: os-image.bin
	xxd $<

%.o: %.c ${HEADERS}
	x86_64-elf-gcc.exe -g -m32 -ffreestanding -c $< -o $@

%.o: %.asm
	nasm $< -f elf -o $@

%.bin: %.asm
	nasm $< -f bin -o $@

%.dis: %.bin
	ndisasm -b 32 $< > $@

clean:
	del *.bin *.o *.dis *.elf
	del kernel\*.o
	del boot\*.o boot\*.bin
	del cpu\*.o
	del drivers\*.o

