# Week 09 연습문제

---

## 문제 1: my_memcmp 구현 (난이도: ★☆☆)

두 메모리 블록을 n 바이트만큼 비교하는 함수를 구현하시오.

```c
int my_memcmp(const void *s1, const void *s2, size_t n);
```

---

## 문제 2: my_itoa 구현 (난이도: ★★☆)

정수를 문자열로 변환하는 함수를 구현하시오. 음수도 지원.

```c
void my_itoa(int n, char *buf);
```

테스트: 0, 42, -7, 2147483647

---

## 문제 3: my_memmove 구현 (난이도: ★★☆)

겹치는 메모리 영역에서도 안전하게 복사하는 함수를 구현하시오.
배열 {1,2,3,4,5}에서 앞으로/뒤로 이동하는 테스트를 작성하시오.

---

## 문제 4: 종합 테스트 하네스 (난이도: ★★★)

8~9주차에서 구현한 함수들(strlen, strcpy, strcmp, memcpy, memmove, atoi)에 대해
경계값 포함 최소 20개의 테스트 케이스로 구성된 하네스를 작성하시오.

---

## 문제 5: ASan으로 버그 찾기 (난이도: ★★★)

다음 코드를 ASan(-fsanitize=address)으로 빌드하여 실행하고,
보고된 오류 메시지를 해석하시오:

```c
#include <stdlib.h>
#include <string.h>

int main(void) {
    char *s = (char *)malloc(5);
    strcpy(s, "Hello");  /* 버그! */
    free(s);
    return 0;
}
```
