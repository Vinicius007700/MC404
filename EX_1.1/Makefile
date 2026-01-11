# --- Variáveis Essenciais ---
# Define o compilador e as flags de cross-compilação para RISC-V.
CC      = clang
CFLAGS  = --target=riscv32 -march=rv32g -mabi=ilp32d -mno-relax
LDFLAGS = -nostdlib



TARGET = prog.x

OBJS   = file1.o file2.o

all: $(TARGET)

$(TARGET): $(OBJS)
	$(CC) $(LDFLAGS) -o $@ $^


clean:
	rm -f $(TARGET) $(OBJS)


.PHONY: all clean