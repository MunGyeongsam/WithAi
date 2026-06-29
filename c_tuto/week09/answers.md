# Week 09 정답과 해설

---

## 문제 1 정답

```c
#include <stddef.h>

int my_memcmp(const void *s1, const void *s2, size_t n) {
    const unsigned char *p1 = (const unsigned char *)s1;
    const unsigned char *p2 = (const unsigned char *)s2;
    for (size_t i = 0; i < n; i++) {
        if (p1[i] != p2[i]) return p1[i] - p2[i];
    }
    return 0;
}
```

---

## 문제 2 정답

```c
void my_itoa(int n, char *buf) {
    int i = 0, sign = 0;
    if (n < 0) { sign = 1; n = -n; }
    do {
        buf[i++] = '0' + (n % 10);
        n /= 10;
    } while (n > 0);
    if (sign) buf[i++] = '-';
    buf[i] = '\0';
    /* reverse */
    for (int l = 0, r = i - 1; l < r; l++, r--) {
        char t = buf[l]; buf[l] = buf[r]; buf[r] = t;
    }
}
```

---

## 문제 3 정답

```c
void *my_memmove(void *dest, const void *src, size_t n) {
    unsigned char *d = (unsigned char *)dest;
    const unsigned char *s = (const unsigned char *)src;
    if (d < s) {
        for (size_t i = 0; i < n; i++) d[i] = s[i];
    } else if (d > s) {
        for (size_t i = n; i > 0; i--) d[i-1] = s[i-1];
    }
    return dest;
}
```

테스트:
```c
int arr[] = {1, 2, 3, 4, 5};
/* 뒤로 이동: arr+1에서 arr+0으로 3개 */
my_memmove(arr, arr + 1, 3 * sizeof(int));
/* 결과: {2, 3, 4, 4, 5} */
```

---

## 문제 5 정답

버그: "Hello"는 5문자 + '\0' = 6바이트가 필요한데, 5바이트만 할당.
strcpy가 6번째 바이트(배열 밖)에 '\0'을 쓰므로 **heap-buffer-overflow**.

수정: `malloc(6)` 또는 `malloc(strlen("Hello") + 1)`
