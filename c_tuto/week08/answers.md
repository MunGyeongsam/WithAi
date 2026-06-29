# Week 08 정답과 해설

---

## 문제 1 정답

```c
char *my_strchr(const char *s, int c) {
    while (*s != '\0') {
        if (*s == (char)c) {
            return (char *)s;
        }
        s++;
    }
    /* '\0'도 찾을 수 있어야 한다 (표준 동작) */
    if (c == '\0') return (char *)s;
    return NULL;
}
```

**해설:** 표준 strchr은 c=='\0'일 때 문자열 끝의 '\0' 위치를 반환한다.

---

## 문제 2 정답

```c
char *my_strcat(char *dest, const char *src) {
    char *ret = dest;
    /* dest의 끝('\0')으로 이동 */
    while (*dest != '\0') {
        dest++;
    }
    /* src를 복사 */
    while (*src != '\0') {
        *dest = *src;
        dest++;
        src++;
    }
    *dest = '\0';
    return ret;
}
```

---

## 문제 3 정답

```c
#include <stddef.h>

void *my_memset(void *s, int c, size_t n) {
    unsigned char *p = (unsigned char *)s;
    for (size_t i = 0; i < n; i++) {
        p[i] = (unsigned char)c;
    }
    return s;
}
```

---

## 문제 4 정답

```c
char *my_strstr(const char *haystack, const char *needle) {
    if (*needle == '\0') return (char *)haystack;

    while (*haystack != '\0') {
        const char *h = haystack;
        const char *n = needle;
        while (*h == *n && *n != '\0') {
            h++;
            n++;
        }
        if (*n == '\0') return (char *)haystack;  /* 전부 일치 */
        haystack++;
    }
    return NULL;
}
```

**해설:** 이중 루프: 바깥은 시작점을 옮기고, 안쪽은 해당 위치에서 needle과 비교.

---

## 문제 5 정답

```c
#include <stdio.h>
#include <string.h>

#define TEST(cond, msg) do { \
    if (!(cond)) { printf("FAIL: %s\n", msg); fails++; } \
    else { passes++; } \
} while(0)

int main(void) {
    int passes = 0, fails = 0;

    /* strchr 테스트 */
    TEST(my_strchr("hello", 'e') != NULL, "strchr found");
    TEST(*my_strchr("hello", 'e') == 'e', "strchr value");
    TEST(my_strchr("hello", 'z') == NULL, "strchr not found");
    TEST(my_strchr("", 'a') == NULL, "strchr empty");

    /* strcat 테스트 */
    char buf[50] = "Hello";
    my_strcat(buf, " World");
    TEST(strcmp(buf, "Hello World") == 0, "strcat basic");
    char buf2[10] = "";
    my_strcat(buf2, "Hi");
    TEST(strcmp(buf2, "Hi") == 0, "strcat to empty");

    /* strstr 테스트 */
    TEST(my_strstr("Hello World", "World") != NULL, "strstr found");
    TEST(my_strstr("Hello", "xyz") == NULL, "strstr not found");
    TEST(my_strstr("Hello", "") != NULL, "strstr empty needle");
    TEST(my_strstr("", "abc") == NULL, "strstr empty haystack");

    printf("\n결과: %d passed, %d failed\n", passes, fails);
    return fails > 0 ? 1 : 0;
}
```
