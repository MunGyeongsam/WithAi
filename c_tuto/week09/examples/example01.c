/*
 * Week 09 예제: 테스트 하네스 종합
 *
 * 빌드: gcc -std=c11 -Wall -Wextra example01.c -o example01
 * 실행: ./example01
 */
#include <stdio.h>
#include <string.h>
#include <stddef.h>

static int g_pass = 0, g_fail = 0;

#define ASSERT_EQ(actual, expected, msg) do { \
    if ((actual) == (expected)) { g_pass++; } \
    else { printf("FAIL [%s]: got %d, want %d\n", msg, (int)(actual), (int)(expected)); g_fail++; } \
} while(0)

/* ---- 구현 ---- */
size_t my_strlen(const char *s) {
    size_t n = 0;
    while (s[n]) n++;
    return n;
}

int my_memcmp(const void *a, const void *b, size_t n) {
    const unsigned char *pa = a, *pb = b;
    for (size_t i = 0; i < n; i++) {
        if (pa[i] != pb[i]) return pa[i] - pb[i];
    }
    return 0;
}

/* ---- 테스트 ---- */
int main(void) {
    ASSERT_EQ(my_strlen(""), 0, "strlen empty");
    ASSERT_EQ(my_strlen("abc"), 3, "strlen abc");
    ASSERT_EQ(my_strlen("a"), 1, "strlen single");

    ASSERT_EQ(my_memcmp("abc", "abc", 3), 0, "memcmp equal");
    ASSERT_EQ(my_memcmp("abc", "abd", 3) < 0, 1, "memcmp less");
    ASSERT_EQ(my_memcmp("abd", "abc", 3) > 0, 1, "memcmp greater");
    ASSERT_EQ(my_memcmp("abc", "abx", 2), 0, "memcmp partial");

    printf("\n=== %d passed, %d failed ===\n", g_pass, g_fail);
    return g_fail > 0 ? 1 : 0;
}
