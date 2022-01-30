SRC=$(wildcard *.asm)
OBJ=$(SRC:.asm=.o)
EXE=ebp
ASFLAGS := -f elf64 -F dwarf
LDFLAGS :=

ifdef VERBOSE
	Q :=
else
	Q := @
endif

.PHONY: all clean

all: $(EXE)

%.o: %.asm
	@echo "===> NASM $<"
	$(Q)nasm $(ASFLAGS) -o $@ $<

$(EXE): $(OBJ)
	@echo "===> LD $@"
	$(Q)cc $(LDFLAGS) -o $@ $^

clean:
	@echo "===> RM -f $(EXE)"
	$(Q)rm -f $(EXE)
	@echo "===> RM -f $(OBJ)"
	$(Q)rm -f $(OBJ)
