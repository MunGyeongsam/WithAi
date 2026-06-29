/*
 * Week 10 예제: 구조체, 유니온, 비트필드 종합
 *
 * 빌드: gcc -std=c11 -Wall -Wextra example01.c -o example01
 */
#include <stdio.h>

/* 구조체 */
typedef struct {
    char name[20];
    int age;
} Person;

/* 유니온: 바이트 뷰 */
union IntView {
    int value;
    unsigned char bytes[sizeof(int)];
};

/* 비트 플래그 */
#define FLAG_A (1u << 0)
#define FLAG_B (1u << 1)
#define FLAG_C (1u << 2)

void print_flags(unsigned int f) {
    printf("flags: %c%c%c\n",
        (f & FLAG_A) ? 'A' : '-',
        (f & FLAG_B) ? 'B' : '-',
        (f & FLAG_C) ? 'C' : '-');
}

int main(void) {
    /* 구조체 */
    Person p = {"Kim", 22};
    printf("%s, %d세\n\n", p.name, p.age);

    /* 유니온 */
    union IntView v;
    v.value = 0xDEADBEEF;
    printf("int: 0x%X\nbytes: ", v.value);
    for (int i = 0; i < (int)sizeof(int); i++) {
        printf("%02X ", v.bytes[i]);
    }
    printf("\n\n");

    /* 플래그 */
    unsigned int flags = FLAG_A | FLAG_C;
    print_flags(flags);
    flags |= FLAG_B;
    print_flags(flags);

    return 0;
}
