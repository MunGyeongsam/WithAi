# Week 09 강의: 표준 함수 직접 구현 2 + 테스트 하네스

---

## 이번 주 목표

8주차에서 문자열 함수를 구현했다. 이번 주는:
1. **메모리 함수** (memcmp, memmove 심화)
2. **변환 함수** (itoa, tolower/toupper)
3. **체계적 테스트** 작성법

---

## 구현 1: my_memcmp

```c
#include <stddef.h>

int my_memcmp(const void *s1, const void *s2, size_t n) {
    const unsigned char *p1 = (const unsigned char *)s1;
    const unsigned char *p2 = (const unsigned char *)s2;
    for (size_t i = 0; i < n; i++) {
        if (p1[i] != p2[i]) {
            return p1[i] - p2[i];
        }
    }
    return 0;
}
```

**strcmp와의 차이:**
- memcmp는 '\0'에서 멈추지 않는다. 정확히 n 바이트를 비교.
- 바이너리 데이터(구조체, 이미지 등) 비교에 사용.

---

## 구현 2: my_itoa (정수를 문자열로)

표준에는 없지만 매우 유용한 함수:

```c
#include <stddef.h>

/* buf에 정수를 문자열로 변환. buf 크기는 호출자 책임 */
void my_itoa(int n, char *buf) {
    int i = 0;
    int sign = 0;

    if (n < 0) {
        sign = 1;
        /* 주의: INT_MIN의 경우 -n이 오버플로우 가능 */
        n = -n;
    }

    /* 역순으로 숫자 추출 */
    do {
        buf[i++] = '0' + (n % 10);
        n /= 10;
    } while (n > 0);

    if (sign) buf[i++] = '-';
    buf[i] = '\0';

    /* 뒤집기 */
    for (int left = 0, right = i - 1; left < right; left++, right--) {
        char tmp = buf[left];
        buf[left] = buf[right];
        buf[right] = tmp;
    }
}
```

**핵심:**
- do-while: n==0일 때도 최소 '0' 하나는 출력
- 역순 추출 후 뒤집기: 가장 간단한 전략

---

## 구현 3: my_isdigit, my_tolower

```c
int my_isdigit(int c) {
    return (c >= '0' && c <= '9');
}

int my_tolower(int c) {
    if (c >= 'A' && c <= 'Z') {
        return c + ('a' - 'A');
    }
    return c;
}

int my_toupper(int c) {
    if (c >= 'a' && c <= 'z') {
        return c - ('a' - 'A');
    }
    return c;
}
```

---

## 테스트 하네스 설계 원칙

### 좋은 테스트의 3요소

1. **경계값(boundary)**: 빈 입력, 최대 크기, 0, -1
2. **일반값(typical)**: 정상적인 사용 사례
3. **오류값(error)**: NULL, 잘못된 입력

### 매크로 기반 미니 프레임워크

```c
#include <stdio.h>

static int g_pass = 0, g_fail = 0;

#define ASSERT_EQ(actual, expected, msg) do { \
    if ((actual) == (expected)) { g_pass++; } \
    else { \
        printf("FAIL [%s]: got %d, want %d\n", msg, (int)(actual), (int)(expected)); \
        g_fail++; \
    } \
} while(0)

#define ASSERT_STR_EQ(a, b, msg) do { \
    if (strcmp((a), (b)) == 0) { g_pass++; } \
    else { \
        printf("FAIL [%s]: got \"%s\", want \"%s\"\n", msg, (a), (b)); \
        g_fail++; \
    } \
} while(0)

#define REPORT() printf("\n=== %d passed, %d failed ===\n", g_pass, g_fail)
```

---

## 테스트 예시: my_itoa 검증

```c
void test_itoa(void) {
    char buf[20];

    my_itoa(0, buf);
    ASSERT_STR_EQ(buf, "0", "itoa zero");

    my_itoa(42, buf);
    ASSERT_STR_EQ(buf, "42", "itoa positive");

    my_itoa(-7, buf);
    ASSERT_STR_EQ(buf, "-7", "itoa negative");

    my_itoa(2147483647, buf);
    ASSERT_STR_EQ(buf, "2147483647", "itoa INT_MAX");
}
```

---

## AddressSanitizer 소개

컴파일 옵션 하나로 메모리 버그를 자동 감지:

```bash
gcc -std=c11 -Wall -Wextra -fsanitize=address -g mycode.c -o mycode
./mycode
```

감지 가능한 버그:
- 버퍼 오버플로우
- use-after-free
- double free
- 메모리 누수 (-fsanitize=leak)

---

## 자주 틀리는 포인트 3가지

1. **itoa에서 0을 빈 문자열로 변환**
   - while(n > 0) 사용 시 n==0이면 아무 것도 안 씀 → do-while 필수

2. **memcmp에서 signed char 비교**
   - unsigned char로 캐스트하지 않으면 128 이상 값에서 비교 오류

3. **테스트에서 하드코딩된 기대값 오류**
   - strcmp 반환값을 정확한 숫자로 비교하지 말 것. < 0 또는 > 0으로 비교

---

## 이번 주 핵심 요약

| 개념 | 한 줄 요약 |
|------|-----------|
| memcmp | 바이트 단위 비교, '\0' 무시 |
| itoa | 숫자→문자열, do-while + 뒤집기 |
| 테스트 하네스 | 매크로로 자동 검증, 경계값 필수 포함 |
| ASan | 컴파일 옵션으로 메모리 버그 자동 탐지 |
