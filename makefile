# $@ = target file
# $< = first dependency
# $^ = all dependencies

ASM_SOURCES = $(wildcard kernel/*.asm cpu/*.asm)
OBJ_FILES = ${ASM_SOURCES:.asm=.o}

# First rule is the one executed when no parameters are fed to the Makefile
all: run

# Notice how dependencies are built as needed
kernel.bin: ${OBJ_FILES}
	x86_64-elf-ld -m elf_i386 -o $@ -Ttext 0x1000 $^ --oformat binary

os-image.bin: boot/mbr.bin kernel.bin
	type boot\mbr.bin kernel.bin > $@

run: os-image.bin
	qemu-system-i386 -fda $<

%.o: %.asm
	nasm $< -f elf -o $@

%.bin: %.asm
	nasm $< -f bin -o $@

clean:
	del *.bin *.o *.dis *.elf
	del kernel\*.o
	del boot\*.o boot\*.bin
	del cpu\*.o
	del drivers\*.o

