# Nome do compilador cruzado para RISC-V
CC = riscv64-unknown-linux-gnu-gcc

# Nome do emulador QEMU para RISC-V
QEMU = qemu-riscv64

# Flags do compilador
# -nostdlib: Não vincula com a biblioteca C padrão.
# -nostartfiles: Não usa os arquivos de inicialização padrão do sistema (temos nosso próprio _start).
# -o: Especifica o nome do arquivo de saída.
CFLAGS = -nostdlib -nostartfiles

# Arquivo de origem assembly
SRC = arquivo.s

# Nome do executável de saída
TARGET = arquivo

# O alvo padrão, que é executado quando você digita 'make'
.PHONY: all
all: $(TARGET)

# Regra para compilar o código-fonte em um executável
$(TARGET): $(SRC)
	$(CC) $(CFLAGS) -o $(TARGET) $(SRC)

# Regra para limpar os arquivos compilados
.PHONY: clean
clean:
	rm -f $(TARGET)