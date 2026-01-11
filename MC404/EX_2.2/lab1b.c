int read(int __fd, const void *__buf, int __n)
{
    int ret_val;
    __asm__ __volatile__(
        "mv a0, %1           # file descriptor\n"
        "mv a1, %2           # buffer \n"
        "mv a2, %3           # size \n"
        "li a7, 63           # syscall write code (63) \n"
        "ecall               # invoke syscall \n"
        "mv %0, a0           # move return value to ret_val\n"
        : "=r"(ret_val)                   // Output list
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
        :                                 // Output list
        : "r"(__fd), "r"(__buf), "r"(__n) // Input list
        : "a0", "a1", "a2", "a7");
}

void exit(int code)
{
    __asm__ __volatile__(
        "mv a0, %0           # return code\n"
        "li a7, 93           # syscall exit (64) \n"
        "ecall"
        :           // Output list
        : "r"(code) // Input list
        : "a0", "a7");

        while(1);
}
#define ERROR -1
int main();
void _start()
{
    int ret_code = main();
    exit(ret_code);
}

int addition(int n1, int n2)
{
    return n1 + n2;
}
int substraction(int n1, int n2)
{
    return n1 - n2;
}

int multiplication(int n1, int n2)
{
    return n1 * n2;
}

int calculator(char *input)
{
    char op = input[2];
    int n1, n2;
    n1 = input[0] - '0';
    n2 = input[4] - '0';
    if (op == '+')
        return addition(n1, n2);
    else if (op == '-')
        return substraction(n1, n2);
    else if (op == '*')
        return multiplication(n1, n2);

    return ERROR;
}

char input_buffer[10];

int main()
{

    int n = read(0, (void *)input_buffer, 10), answer;
    answer = calculator(input_buffer);
    char output_buffer[2];
    output_buffer[0] = answer + '0';
    output_buffer[1] = '\n';

    write(1, (void *)output_buffer, 2);

    return 0;
}
