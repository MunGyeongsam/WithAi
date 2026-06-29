# Week 08 강의: 표준 함수 직접 구현

---

## 왜 표준 함수를 직접 구현하는가

표준 라이브러리(string.h, stdlib.h)의 함수들은 이미 있다.
왜 다시 만들어야 하는가?

1. **원리 이해**: 블랙박스로 쓰지 않고, 내부 동작을 파악
2. **경계값 감각**: 빈 문자열, NULL, 길이 0 등 예외 상황 대응력
3. **면접 필수**: 시스템 프로그래머 면접의 단골 문제
4. **임베디드**: 표준 라이브러리가 없는 환경에서 직접 구현

---

## 구현 1: my_strlen

```c
#include <stddef.h>  /* size_t */

size_t my_strlen(const char *s) {
    size_t n = 0;
    while (s[n] != '\0') {
        n++;
    }
    return n;
}
```

**설계 결정:**
- 반환 타입 `size_t`: 음수 길이는 없으므로 unsigned 사용
- `const char *`: 문자열을 수정하지 않겠다는 약속
- NULL 검사?: 표준 strlen도 NULL을 넘기면 undefined behavior

---

## 구현 2: my_strcpy

```c
char *my_strcpy(char *dest, const char *src) {
    char *ret = dest;
    while (*src != '\0') {
        *dest = *src;
        dest++;
        src++;
    }
    *dest = '\0';
    return ret;
}
```

**핵심 포인트:**
- 반환값이 dest의 시작 주소: 체이닝 가능 `printf("%s", my_strcpy(buf, "hi"))`
- '\0'을 반드시 마지막에 복사
- dest 크기가 충분한지는 호출자 책임 (위험한 설계!)

---

## 구현 3: my_strcmp

```c
int my_strcmp(const char *s1, const char *s2) {
    while (*s1 != '\0' && *s1 == *s2) {
        s1++;
        s2++;
    }
    return (unsigned char)*s1 - (unsigned char)*s2;
}
```

**반환값 규약:**
- 0: 같음
- 양수: s1 > s2 (사전순)
- 음수: s1 < s2

**왜 unsigned char?** — char가 signed일 때, 128 이상의 값에서 음수로 잘못 비교될 수 있음.

---

## 구현 4: my_strncpy

```c
char *my_strncpy(char *dest, const char *src, size_t n) {
    size_t i;
    for (i = 0; i < n && src[i] != '\0'; i++) {
        dest[i] = src[i];
    }
    for (; i < n; i++) {
        dest[i] = '\0';  /* 나머지를 '\0'으로 채움 */
    }
    return dest;
}
```

> ⚠️ 주의: src 길이 >= n이면 dest에 '\0'이 붙지 않는다!
> 안전하게 사용하려면: `dest[n-1] = '\0';`을 추가.

---

## 구현 5: my_memcpy

```c
#include <stddef.h>

void *my_memcpy(void *dest, const void *src, size_t n) {
    unsigned char *d = (unsigned char *)dest;
    const unsigned char *s = (const unsigned char *)src;
    for (size_t i = 0; i < n; i++) {
        d[i] = s[i];
    }
    return dest;
}
```

**strcpy와의 차이:**
- memcpy는 '\0'에서 멈추지 않는다. 정확히 n 바이트를 복사.
- 어떤 타입이든 복사 가능 (int 배열, 구조체 등).
- src와 dest가 겹치면 **undefined behavior** → memmove 사용.

---

## 구현 6: my_memmove (겹침 안전)

```c
void *my_memmove(void *dest, const void *src, size_t n) {
    unsigned char *d = (unsigned char *)dest;
    const unsigned char *s = (const unsigned char *)src;

    if (d < s) {
        /* 앞에서 뒤로 복사 (겹침 시 안전) */
        for (size_t i = 0; i < n; i++) {
            d[i] = s[i];
        }
    } else if (d > s) {
        /* 뒤에서 앞으로 복사 (겹침 시 안전) */
        for (size_t i = n; i > 0; i--) {
            d[i-1] = s[i-1];
        }
    }
    return dest;
}
```

**핵심**: 복사 방향을 src/dest 위치 관계에 따라 결정.
겹치는 영역이 있을 때 방향이 잘못되면 데이터가 덮어써진다.

---

## 구현 7: my_atoi

```c
int my_atoi(const char *s) {
    int result = 0;
    int sign = 1;

    /* 앞쪽 공백 건너뛰기 */
    while (*s == ' ' || *s == '\t') s++;

    /* 부호 처리 */
    if (*s == '-') { sign = -1; s++; }
    else if (*s == '+') { s++; }

    /* 숫자 변환 */
    while (*s >= '0' && *s <= '9') {
        result = result * 10 + (*s - '0');
        s++;
    }

    return sign * result;
}
```

> 실전에서는 오버플로우 검사, 유효하지 않은 입력 처리도 필요하다.

---

## 테스트 하네스 작성법

```c
#include <stdio.h>
#include <string.h>

/* 간단한 assert 매크로 */
#define TEST(cond, msg) do { \
    if (!(cond)) { printf("FAIL: %s\n", msg); fails++; } \
    else { printf("PASS: %s\n", msg); passes++; } \
} while(0)

int main(void) {
    int passes = 0, fails = 0;

    /* my_strlen 테스트 */
    TEST(my_strlen("") == 0, "strlen empty");
    TEST(my_strlen("abc") == 3, "strlen abc");
    TEST(my_strlen("a") == 1, "strlen single");

    /* my_strcmp 테스트 */
    TEST(my_strcmp("abc", "abc") == 0, "strcmp equal");
    TEST(my_strcmp("abc", "abd") < 0, "strcmp less");
    TEST(my_strcmp("abd", "abc") > 0, "strcmp greater");

    printf("\n결과: %d passed, %d failed\n", passes, fails);
    return fails > 0 ? 1 : 0;
}
```

---

## 자주 틀리는 포인트 3가지

1. **'\0' 복사를 잊음**
   - strcpy 구현에서 루프 후 `*dest = '\0'` 필수

2. **memcpy에서 겹침 가정 안 함**
   - "같은 배열 내에서 복사"할 때 memcpy는 위험. memmove 사용.

3. **atoi에서 오버플로우 무시**
   - "99999999999"를 atoi하면 int 범위 초과 → 안전한 대안: strtol

---

## 이번 주 핵심 요약

| 함수 | 핵심 로직 |
|------|----------|
| strlen | '\0'까지 세기 |
| strcpy | '\0'까지 복사 + 마지막 '\0' 추가 |
| strcmp | 문자 하나씩 비교, 다르면 차이 반환 |
| memcpy | 바이트 단위 n개 복사 (겹침 불가) |
| memmove | 방향 선택 후 바이트 복사 (겹침 안전) |
| atoi | 공백 건너뛰기 → 부호 → 숫자 누적 |
