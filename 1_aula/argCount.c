#include <stdio.h>

int main(int argc, char *argv[])
{
    printf("Nome próprio do programa é %s e n de argunmentos %d\n", *argv, argc);

    int i = 0;
    for (i = 0; i< argc; i++)
    {
        printf("%d: %s\n", i, argv[i]);
    }
    return 0;
}
