# Week 14 더 알아보기 (Further More)

---

## 1. 동적 라이브러리 (.so / .dylib / .dll)

정적 라이브러리는 실행 파일에 코드가 포함된다.
동적 라이브러리는 실행 시점에 로드:

```bash
gcc -shared -o libutil.so util.c      # Linux
gcc -dynamiclib -o libutil.dylib util.c  # macOS
```

장점: 여러 프로그램이 하나의 라이브러리를 공유 (메모리 절약)

---

## 2. 헤더 의존성 최소화

```c
/* 나쁜 예: 불필요한 include */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>    /* 안 쓰는데 포함 */

/* 좋은 예: forward declaration */
struct Node;  /* 전방 선언 — 포인터만 쓸 때 헤더 include 불필요 */
void process(struct Node *node);
```

---

## 3. 생각해볼 질문

- 헤더에 inline 함수를 넣어도 되는가? (힌트: static inline)
- 순환 의존(A.h ↔ B.h)은 어떻게 해결하는가?
- C의 모듈 시스템이 없는 것은 장점인가 단점인가?
