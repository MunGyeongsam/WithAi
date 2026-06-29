# Week 07 연습문제

---

## 문제 1: 동적 배열 생성 (난이도: ★☆☆)

사용자에게 정수 n을 입력받아, n개의 정수를 저장하는 배열을 동적 할당하시오.
배열에 1~n까지 저장한 뒤 출력하고, 메모리를 해제하시오.

---

## 문제 2: 동적 문자열 복사 (난이도: ★★☆)

문자열을 받아 힙에 복사본을 만들어 반환하는 함수를 작성하시오:

```c
char *my_strdup(const char *s);
/* 호출자가 free 책임 */
```

---

## 문제 3: 동적 배열 확장 (난이도: ★★☆)

초기 용량 4인 동적 int 배열에 20개의 값을 삽입하시오.
용량이 부족하면 2배로 확장(realloc)한다. 매 확장 시 현재 용량을 출력할 것.

---

## 문제 4: 2차원 동적 배열 (난이도: ★★★)

행(row)과 열(col)을 입력받아 동적으로 2차원 배열을 할당하고,
각 칸에 row*10 + col 값을 채운 뒤 출력하시오.
사용 후 모든 메모리를 올바르게 해제할 것.

---

## 문제 5: 메모리 누수 찾기 (난이도: ★★★)

다음 코드에서 메모리 관련 버그를 모두 찾아 수정하시오:

```c
#include <stdlib.h>
#include <string.h>

char *make_greeting(const char *name) {
    char *buf = malloc(50);
    sprintf(buf, "Hello, %s!", name);
    return buf;
}

int main(void) {
    char *g1 = make_greeting("Alice");
    char *g2 = make_greeting("Bob");
    g1 = g2;  /* 버그! */
    free(g1);
    free(g2);  /* 버그! */
    return 0;
}
```
