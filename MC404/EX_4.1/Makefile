# --- Variáveis de Cross-Compilação para RISC-V ---
# Define o compilador (clang ou riscv64-unknown-elf-gcc)
CC      = clang
# Define as flags do compilador para o alvo RISC-V
CFLAGS  = --target=riscv32 -march=rv32g -mabi=ilp32d -mno-relax
# Define as flags do linker (ligador)
LDFLAGS = -nostdlib

# --- Nomes dos Arquivos ---
# Nome do arquivo executável final
TARGET = bitwise.x
# Lista de arquivos-objeto. O make irá procurar por um .c correspondente.
OBJS   = bitwise.o

# --- Regras ---

# Regra padrão: executada ao digitar "make"
all: $(TARGET)

# Regra para ligar os arquivos-objeto e criar o executável final
# Depende dos arquivos-objeto (.o)
$(TARGET): $(OBJS)
	# Comando de ligação
	$(CC) $(LDFLAGS) -o $@ $^

# Regra para compilar os arquivos-fonte (.c) em arquivos-objeto (.o)
# Esta é uma regra de sufixo implícita do Make, mas as CFLAGS são aplicadas aqui.
# O Make sabe que para criar um .o, ele precisa de um .c com o mesmo nome.

# Regra para limpar os arquivos gerados
clean:
	# Remove o executável e todos os arquivos-objeto
	rm -f $(TARGET) $(OBJS)

# Declara que "all" e "clean" não são nomes de arquivos
.PHONY: all clean
