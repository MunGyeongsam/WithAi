# Week 12 강의: 전처리기(Preprocessor) 심화

---

## 왜 전처리기를 이해해야 하는가

C 컴파일의 첫 단계. 컴파일러가 코드를 보기 전에 **텍스트 치환**이 일어난다:
- `#include` → 파일 내용 삽입
- `#define` → 텍스트 치환
- `#ifdef` → 조건부 포함/제외

비유: 원고를 편집자(전처리기)가 먼저 정리한 뒤, 인쇄소(컴파일러)에 보내는 것.

---

## #include의 진짜 의미

```c
#include <stdio.h>    /* 시스템 헤더 경로에서 검색 */
#include "mylib.h"    /* 현재 디렉토리 우선 검색 */
```

전처리기가 하는 일: 해당 파일의 내용을 **그대로 복사-붙여넣기**.
`gcc -E main.c`로 확인하면, stdio.h 하나에 수천 줄이 삽입된 것을 볼 수 있다.

---

## Include Guard: 중복 포함 방지

```c
/* mylib.h */
#ifndef MYLIB_H
#define MYLIB_H

int add(int a, int b);

#endif /* MYLIB_H */
```

**왜 필요한가?** A.h가 B.h를 포함하고, main.c가 A.h와 B.h를 모두 포함하면
B.h가 두 번 삽입 → 중복 선언 오류!

현대적 대안: `#pragma once` (비표준이지만 대부분 컴파일러 지원)

---

## 오브젝트형 매크로 (Object-like macro)

```c
#define MAX_SIZE 100
#define PI 3.14159

int arr[MAX_SIZE];         /* 전처리 후: int arr[100]; */
double area = PI * r * r;  /* 전처리 후: 3.14159 * r * r */
```

> const vs #define:
> - const: 타입 있음, 디버거에서 보임, 스코프 존재
> - #define: 타입 없음, 단순 텍스트 치환, 전역

---

## 함수형 매크로 (Function-like macro)

```c
#define SQUARE(x) ((x) * (x))
#define MAX(a, b) ((a) > (b) ? (a) : (b))
```

### 괄호가 왜 중요한가?

```c
#define BAD_SQUARE(x) x * x

BAD_SQUARE(3 + 1)  /* 3 + 1 * 3 + 1 = 7 (의도: 16) */
SQUARE(3 + 1)      /* ((3 + 1) * (3 + 1)) = 16 (올바름) */
```

> **규칙: 매크로 인자와 전체를 항상 괄호로 감싼다.**

### 부작용(side effect) 위험

```c
int a = 3;
int result = SQUARE(a++);
/* ((a++) * (a++)) → a가 두 번 증가! undefined behavior */
```

> **규칙: 부작용 있는 표현식(a++, 함수 호출 등)을 매크로에 넘기지 않는다.**

---

## 조건부 컴파일 (Conditional compilation)

```c
#ifdef DEBUG
    printf("디버그: x = %d\n", x);
#endif

#if defined(_WIN32)
    #include <windows.h>
#elif defined(__linux__)
    #include <unistd.h>
#elif defined(__APPLE__)
    #include <mach/mach.h>
#endif
```

컴파일 시 플래그로 제어:
```bash
gcc -DDEBUG main.c      /* DEBUG 정의됨 */
gcc main.c              /* DEBUG 정의 안 됨 */
```

---

## 디버그 로그 매크로

```c
#ifdef DEBUG
#define LOG(fmt, ...) \
    fprintf(stderr, "[%s:%d] " fmt "\n", __FILE__, __LINE__, ##__VA_ARGS__)
#else
#define LOG(fmt, ...) ((void)0)  /* 릴리스에서는 아무 일도 안 함 */
#endif
```

사용:
```c
LOG("값 = %d", x);  /* 디버그 빌드에서만 출력 */
```

---

## 특수 매크로 (Predefined macros)

| 매크로 | 값 |
|--------|-----|
| `__FILE__` | 현재 파일 이름 |
| `__LINE__` | 현재 줄 번호 |
| `__func__` | 현재 함수 이름 (C99) |
| `__DATE__` | 컴파일 날짜 |
| `__TIME__` | 컴파일 시각 |

---

## #과 ## 연산자

### # (문자열화, stringize)

```c
#define STRINGIFY(x) #x

printf("%s\n", STRINGIFY(hello));  /* "hello" */
printf("%s\n", STRINGIFY(3 + 4)); /* "3 + 4" */
```

### ## (토큰 붙이기, concatenation)

```c
#define MAKE_VAR(prefix, num) prefix##num

int MAKE_VAR(score, 1) = 100;  /* int score1 = 100; */
int MAKE_VAR(score, 2) = 200;  /* int score2 = 200; */
```

---

## 다중 줄 매크로

```c
#define SWAP(a, b) do { \
    typeof(a) _tmp = (a); \
    (a) = (b); \
    (b) = _tmp; \
} while(0)
```

> `do { ... } while(0)` 패턴: 매크로를 문장(statement)처럼 안전하게 사용.
> 세미콜론 처리, if-else 매칭 문제를 방지한다.

---

## 자주 틀리는 포인트 3가지

1. **매크로 인자 괄호 누락**
   ```c
   #define DOUBLE(x) x + x
   DOUBLE(3) * 2  /* 3 + 3 * 2 = 9 (의도: 12) */
   ```

2. **include guard 이름 충돌**
   - `UTILS_H`처럼 흔한 이름은 다른 라이브러리와 충돌 가능
   - 프로젝트명 접두사 사용: `MYAPP_UTILS_H`

3. **#define 끝에 세미콜론**
   ```c
   #define MAX 100;    /* 세미콜론 포함됨! */
   int arr[MAX];      /* int arr[100;]; 오류! */
   ```

---

## 이번 주 핵심 요약

| 개념 | 한 줄 요약 |
|------|-----------|
| #include | 파일 내용을 그대로 삽입 (텍스트 복사) |
| include guard | 같은 헤더의 중복 삽입 방지 |
| #define | 텍스트 치환. 괄호 필수! |
| 조건부 컴파일 | 빌드 설정에 따라 코드 포함/제외 |
| # / ## | 토큰을 문자열로 변환 / 토큰 결합 |
