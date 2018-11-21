nasm -f macho64 source64.asm
ld -macosx_version_min 10.7.0 -lSystem -o source64 source64.o

nasm -f macho32 source32.asm
ld -macosx_version_min 10.7.0 -lSystem -o source32 source32.o