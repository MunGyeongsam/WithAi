/*
 * Week 08 예제: 표준 함수 직접 구현 + 테스트
 *
 * 빌드: gcc -std=c11 -Wall -Wextra example01.c -o example01
 * 실행: ./example01
 */
#include <stdio.h>
#include <stddef.h>

size_t my_strlen(const char *s) {
    size_t n = 0;
    while (s[n] != '\0') n++;
    return n;
}

char *my_strcpy(char *dest, const char *src) {
    char *ret = dest;
    while (*src != '\0') { *dest++ = *src++; }
    *dest = '\0';
    return ret;
}

int my_strcmp(const char *s1, const char *s2) {
    while (*s1 && *s1 == *s2) { s1++; s2++; }
    return (unsigned char)*s1 - (unsigned char)*s2;
}

int my_atoi(const char *s) {
    int result = 0, sign = 1;
    while (*s == ' ') s++;
    if (*s == '-') { sign = -1; s++; }
    else if (*s == '+') { s++; }
    while (*s >= '0' && *s <= '9') {
        result = result * 10 + (*s - '0');
        s++;
    }
    return sign * result;
}

int main(void) {
    printf("strlen(\"Hello\") = %zu\n", my_strlen("Hello"));

    char buf[32];
    my_strcpy(buf, "Philosophy");
    printf("strcpy: %s\n", buf);

    printf("strcmp(\"abc\",\"abc\") = %d\n", my_strcmp("abc", "abc"));
    printf("strcmp(\"abc\",\"abd\") = %d\n", my_strcmp("abc", "abd"));

    printf("atoi(\"  -42\") = %d\n", my_atoi("  -42"));
    printf("atoi(\"123abc\") = %d\n", my_atoi("123abc"));

    return 0;
}
