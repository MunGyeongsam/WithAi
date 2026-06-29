# Week 12 더 알아보기 (Further More)

---

## 1. 전처리 결과 확인

```bash
gcc -E main.c | tail -50  /* 전처리된 소스 끝부분 보기 */
gcc -E -P main.c          /* 줄번호 정보 없이 깔끔하게 */
```

---

## 2. static_assert (C11)

컴파일 시점에 조건을 검사:

```c
#include <assert.h>
static_assert(sizeof(int) == 4, "int must be 4 bytes");
```

---

## 3. 생각해볼 질문

- 매크로는 왜 디버거에서 추적이 어려운가?
- 현대 C에서 매크로 대신 inline 함수를 쓰는 것이 더 나은 경우는?
- #include가 텍스트 삽입이라면, 순환 include는 어떻게 되는가?
