int main();
void exit(int code) __attribute__((noreturn));

int read(int __fd, const void *__buf, int __n)
{
    int ret_val;
    __asm__ __volatile__(
        "mv a0, %1           # file descriptor\n"
        "mv a1, %2           # buffer \n"
        "mv a2, %3           # size \n"
        "li a7, 63           # syscall read code (63) \n"
        "ecall               # invoke syscall \n"
        "mv %0, a0           # move return value to ret_val\n"
        : "=r"(ret_val)      // Output list
        : "r"(__fd), "r"(__buf), "r"(__n) // Input list
        : "a0", "a1", "a2", "a7");
    return ret_val;
}

void write(int __fd, const void *__buf, int __n)
{
    __asm__ __volatile__(
        "mv a0, %0           # file descriptor\n"
        "mv a1, %1           # buffer \n"
        "mv a2, %2           # size \n"
        "li a7, 64           # syscall write (64) \n"
        "ecall"
        :                    // Output list
        : "r"(__fd), "r"(__buf), "r"(__n) // Input list
        : "a0", "a1", "a2", "a7");
}

void exit(int code)
{
    __asm__ __volatile__(
        "mv a0, %0           # return code\n"
        "li a7, 93           # syscall exit (93) \n"
        "ecall"
        :             // Output list
        : "r"(code)   // Input list
        : "a0", "a7");

}

void _start()
{
    int ret_code = main();
    exit(ret_code);
}



#define STDIN_FD 0
#define STDOUT_FD 1


int find_value_number(char c) {
    if (c >= '0' && c <= '9') return c - '0';
    if (c >= 'a' && c <= 'f') return c - 'a' + 10;
    if (c >= 'A' && c <= 'F') return c - 'A' + 10;
    return -1;
}

int dif_to_dec(char *input, int base)
{
    int n = 0;
    int i = 0;
    int is_negative = 0;

    if (base == 10 && input[0] == '-') {
        is_negative = 1;
        i = 1;
    } else if (base == 10 && input[0] == '+') {
        i = 1;
    } else if (base != 10 && input[0] == '0' && (input[1] == 'b' || input[1] == 'x')) {
        i = 2;
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

    if (is_negative) n = -n;
    return (int)n;
}

void set_numbers(char *input, char *str_out, int *start_index){
    int j = 0;
    while(input[*start_index] == ' ' || input[*start_index] == '\t') (*start_index)++;
    while(input[*start_index] != ' ' && input[*start_index] != '\0'){
        str_out[j++] = input[(*start_index)++];
    }
    str_out[j] = '\0';
}

void set_all_numbers_input(char *input, char *str1, char *str2, char *str3, char *str4, char *str5){
    int start = 0;
    set_numbers(input, str1, &start);
    set_numbers(input, str2, &start);
    set_numbers(input, str3, &start);
    set_numbers(input, str4, &start);
    set_numbers(input, str5, &start);
}

void set_all_numbers_int_dec(char *str1, char *str2, char *str3, char *str4, char *str5, int *dec1, int *dec2, int *dec3, int *dec4, int *dec5){
    *dec1 = dif_to_dec(str1, 10);
    *dec2 = dif_to_dec(str2, 10);
    *dec3 = dif_to_dec(str3, 10);
    *dec4 = dif_to_dec(str4, 10);
    *dec5 = dif_to_dec(str5, 10);
}

// São as operações de colocar os bits nas posições corretas, dado o começo e quantos bits teremos
void bit_operations(int input_val, int num_bits, int start_pos, int *packed_val) {
    int selection = (1 << num_bits) - 1; // São os bits 1 do LSD até uma certa posição
    
    int extracted_bits = input_val & selection; //Operador and
    
    // Desloca os bits para a pos correta.
    int shifted_bits = extracted_bits << start_pos;
    
    // Operador or
    *packed_val = *packed_val | shifted_bits;
}


void hex_code(int val){
    char hex[11];
    unsigned int uval = (unsigned int) val, aux;

    hex[0] = '0';
    hex[1] = 'x';
    hex[10] = '\n';

    for (int i = 9; i > 1; i--){
        aux = uval % 16;
        if (aux >= 10)
            hex[i] = aux - 10 + 'A';
        else
            hex[i] = aux + '0';
        uval = uval / 16;
    }
    write(STDOUT_FD, hex, 11);
}

int main()
{
    char input[32];
    read(STDIN_FD, input, 32);

    char str1[32], str2[32], str3[32], str4[32], str5[32];
    int dec1, dec2, dec3, dec4, dec5;

  
    set_all_numbers_input(input, str1, str2, str3, str4, str5);

    
    set_all_numbers_int_dec(str1, str2, str3, str4, str5, &dec1, &dec2, &dec3, &dec4, &dec5);


    int packed_value = 0;
    bit_operations(dec1, 3,  0,  &packed_value);  
    bit_operations(dec2, 8,  3,  &packed_value);  
    bit_operations(dec3, 5,  11, &packed_value);  
    bit_operations(dec4, 5,  16, &packed_value);  
    bit_operations(dec5, 11, 21, &packed_value); 
    
    
    
    hex_code(packed_value);

    return 0;
}

