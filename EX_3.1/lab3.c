#define BIN 0
#define DEC 1
#define HEX 2
#define inv 3

int read(int __fd, const void *__buf, int __n)
{
    int ret_val;
    __asm__ __volatile__(
        "mv a0, %1          # file descriptor\n"
        "mv a1, %2          # buffer \n"
        "mv a2, %3          # size \n"
        "li a7, 63          # syscall read code (63) \n"
        "ecall              # invoke syscall \n"
        "mv %0, a0          # move return value to ret_val\n"
        : "=r"(ret_val)              // Output list
        : "r"(__fd), "r"(__buf), "r"(__n) // Input list
        : "a0", "a1", "a2", "a7");
    return ret_val;
}

void write(int __fd, const void *__buf, int __n)
{
    __asm__ __volatile__(
        "mv a0, %0          # file descriptor\n"
        "mv a1, %1          # buffer \n"
        "mv a2, %2          # size \n"
        "li a7, 64          # syscall write (64) \n"
        "ecall"
        :                            // Output list
        : "r"(__fd), "r"(__buf), "r"(__n) // Input list
        : "a0", "a1", "a2", "a7");
}

void exit(int code)
{
    __asm__ __volatile__(
        "mv a0, %0          # return code\n"
        "li a7, 93          # syscall exit (93) \n"
        "ecall"
        :           // Output list
        : "r"(code) // Input list
        : "a0", "a7");
}

void _start()
{
    int ret_code = main();
    exit(ret_code);
}

#define STDIN_FD 0
#define STDOUT_FD 1


unsigned int swap_endian(unsigned int num) {
    unsigned int byte0 = (num & 0x000000FF) << 24;
    unsigned int byte1 = (num & 0x0000FF00) << 8;
    unsigned int byte2 = (num & 0x00FF0000) >> 8;
    unsigned int byte3 = (num & 0xFF000000) >> 24;
    return byte0 | byte1 | byte2 | byte3;
}

// Função que verifica se um número é haxadecimal ou não
int is_hexa(char *input)
{
    char correct_sequence[3] = "0x";
    for (int i = 0; i < 2; i++)
    {
        if (input[i] != correct_sequence[i])
            return 0;
    }
    return 1;
}

// Função que verifica o valor do número, a partir da ordem deles. Por exemplo 0 = 0. A = 10, etc
int find_value_number(char caract)
{
    char val[16] = "0123456789abcdef";
    for (int i = 0; i < 16; i++)
    {
        if (val[i] == caract)
        {
            return i;
        }
    }
    return -1; // caso seja inválido
}

// função que transforma um número que está em qualquer base para a base 10.
int dif_to_dec(char *input, int base)
{
    long long n = 0; 
    int i = 0;
    int is_negative = 0;

    
    if (base == 10 && input[0] == '-') {
        is_negative = 1;
        i = 1; //Para pular o sinal de -
    } 

    else if (base != 10) {
        i = 2; // Para pular 0x ou 0b.
    }

    while (input[i] != '\0' && input[i] != '\n')
    {
        int val = find_value_number(input[i]);
        if (val != -1 && val < base) { 
            n = n * base + val;
        } else {
            break; 
        }
        i++;
    }

    if (is_negative) {
        n = -n;
    }

    return (int)n;
}


int strlen(const char *s)
{
    int i = 0;
    while (s[i] != '\0')
    {
        i++;
    }
    return i;
}


int dec_to_binrecursivo(unsigned int num, char *bin)
{
    int index = 0;
    if (num == 0)
    {
        return 0;
    }
    index = dec_to_binrecursivo(num / 2, bin);
    bin[index] = num % 2 + '0';
    return index + 1;
}

//Função que transforma um número inteiro na base dez para um número binário
void dec_to_bin(int num, char *bin)
{
    unsigned int u_num = (unsigned int)num; 
    bin[0] = '0';
    bin[1] = 'b';
    if (u_num == 0) // Para o caso 0.
    {
        bin[2] = '0';
        bin[3] = '\n';
        bin[4] = '\0'; 
        return;
    }

    int len = dec_to_binrecursivo(u_num, bin + 2);
    bin[2 + len] = '\n';
    bin[2 + len + 1] = '\0';
}

// Função que verifica se um número é binário
int is_bin(char *input)
{
    char correct_sequence[3] = "0b";
    for (int i = 0; i < 2; i++)
    {
        if (input[i] != correct_sequence[i])
        {
            return 0;
        }
    }
    return 1;
}

int unsigned_dec_to_str_recursive(unsigned int dec, char *str)
{
    if (dec == 0)
    {
        return 0;
    }
    int index = unsigned_dec_to_str_recursive(dec / 10, str);
    str[index] = (dec % 10) + '0';
    return index + 1;
}


// Função que transformar um int decimal em uma string
void unsigned_dec_to_dec_str(unsigned int dec, char *str)
{
    int index;
    if (dec == 0)
    {
        str[0] = '0';
        index = 1;
    }
    else
    {
        index = unsigned_dec_to_str_recursive(dec, str);
    }
    str[index] = '\n';
    str[index + 1] = '\0';
}

// Função que transformar um int decimal em uma string. A principal que lida com o problema de negativos
void signed_dec_to_dec_str(int dec, char *str) {
    int i = 0;
    if (dec == 0) {
        str[i] = '0';
        i++;
    } else if (dec < 0) {
        str[i] = '-'; // O caso negativo
        i++;
        unsigned int u_dec = -(unsigned int)dec;
        int len = unsigned_dec_to_str_recursive(u_dec, str + i);
        i += len;
    } else {
        int len = unsigned_dec_to_str_recursive((unsigned int)dec, str + i);
        i += len;
    }
    str[i] = '\n';
    str[i+1] = '\0';
}


// Função que transforma um número decimal em um hexadecimal
int dec_to_hexrecursivo(unsigned int num, char *hex)
{
    int index = 0;
    if (num == 0)
    {
        return 0;
    }
    index = dec_to_hexrecursivo(num / 16, hex);
    int resto = num % 16;
    if (resto < 10)
    {
        hex[index] = resto + '0';
    }
    else
    {
        hex[index] = (resto - 10) + 'a';
    }
    return index + 1;
}
void det_answers(int dec, char *bin, char *inteiro, char *hexa, char *swapped_inteiro, char *swapped_dec){
    dec_to_bin(dec, bin);
    signed_dec_to_dec_str(dec, inteiro); 
    dec_to_hex(dec, hexa);
    unsigned_dec_to_dec_str(swapped_dec, swapped_inteiro); 

}
void print_answers(char *bin, char *inteiro, char *hexa, char *swapped_inteiro){
    write(STDOUT_FD, (void *)bin, strlen(bin));
    write(STDOUT_FD, (void *)inteiro, strlen(inteiro));
    write(STDOUT_FD, (void *)hexa, strlen(hexa));
    write(STDOUT_FD, (void *)swapped_inteiro, strlen(swapped_inteiro));
}

int define_dec(){
    if (is_hexa(str))
    {
        dec = dif_to_dec(str, 16);
    }
    else if (is_bin(str))
    {
        dec = dif_to_dec(str, 2);
    }
    else
    {
        dec = dif_to_dec(str, 10);
    }
    return dec;
}

// Função principal que transforma um número decimal em um hexadecimal, chama a recursiva.
void dec_to_hex(int num, char *hex)
{
    unsigned int u_num = (unsigned int)num; 
    hex[0] = '0';
    hex[1] = 'x';
    if (u_num == 0)
    {
        hex[2] = '0';
        hex[3] = '\n';
        hex[4] = '\0';
        return;
    }
    
    int len = dec_to_hexrecursivo(u_num, hex + 2);
    hex[2 + len] = '\n';
    hex[2 + len + 1] = '\0';
}

int main()
{
    char str[20];
    int n = read(STDIN_FD, str, 20);
    char hexa[65], bin[65], inteiro[65], swapped_inteiro[65];
    int dec = define_dec(); 
    unsigned int swapped_dec = swap_endian((unsigned int)dec);
    det_answers(dec, bin, inteiro, hexa, swapped_inteiro);   
    print_answers(bin, inteiro, hexa, swapped_inteiro);

    
    return 0;
}
    