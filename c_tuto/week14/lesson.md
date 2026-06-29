# Week 14 강의: 모듈화와 라이브러리화

---

## 왜 모듈화가 필요한가

프로그램이 1000줄을 넘으면 한 파일로 관리가 어렵다:
- 수정할 때 관련 없는 코드를 건드릴 위험
- 여러 프로그램에서 같은 코드를 재사용할 수 없음
- 팀 작업 시 파일 충돌

**모듈화 = 코드를 기능 단위로 분리하는 기술**

비유: 모든 요리를 한 냄비에 만드는 대신, 밥솥/프라이팬/냄비를 분리하는 것.

---

## 헤더(.h)와 소스(.c) 분리 원칙

```
[math_util.h]  → 선언(declaration): "이런 함수가 있다"
[math_util.c]  → 정의(definition): "이 함수는 이렇게 동작한다"
[main.c]       → 사용: #include "math_util.h"
```

### math_util.h

```c
#ifndef MATH_UTIL_H
#define MATH_UTIL_H

/* 공개 인터페이스(public interface) */
int sum_array(const int *arr, int n);
int max_array(const int *arr, int n);
double average(const int *arr, int n);

#endif /* MATH_UTIL_H */
```

### math_util.c

```c
#include "math_util.h"

int sum_array(const int *arr, int n) {
    int s = 0;
    for (int i = 0; i < n; i++) s += arr[i];
    return s;
}

int max_array(const int *arr, int n) {
    int m = arr[0];
    for (int i = 1; i < n; i++) {
        if (arr[i] > m) m = arr[i];
    }
    return m;
}

double average(const int *arr, int n) {
    return (double)sum_array(arr, n) / n;
}
```

### main.c

```c
#include <stdio.h>
#include "math_util.h"

int main(void) {
    int data[] = {3, 7, 1, 9, 4};
    printf("합계: %d\n", sum_array(data, 5));
    printf("최대: %d\n", max_array(data, 5));
    printf("평균: %.1f\n", average(data, 5));
    return 0;
}
```

### 빌드

```bash
gcc -std=c11 -Wall -Wextra main.c math_util.c -o program
```

---

## 헤더 파일 규칙

### 헤더에 넣는 것
- 함수 선언 (prototype)
- 타입 정의 (typedef, struct, enum)
- 매크로 (#define)
- extern 변수 선언

### 헤더에 넣지 않는 것
- 함수 정의 (본문)
- 전역 변수 정의
- static 함수

> **원칙: 헤더는 "계약서", 소스는 "실행"**

---

## static의 두 가지 의미

### 1. 파일 내부 전용 (내부 연결, internal linkage)

```c
/* helper.c */
static int internal_helper(int x) {  /* 이 파일에서만 보임 */
    return x * 2;
}

int public_func(int x) {  /* 다른 파일에서도 사용 가능 */
    return internal_helper(x) + 1;
}
```

### 2. 함수 내 영속 변수 (static local)

```c
void counter(void) {
    static int count = 0;
    count++;
    printf("%d번째 호출\n", count);
}
```

---

## extern: 다른 파일의 변수 사용

```c
/* config.c */
int g_verbose = 0;  /* 정의 (메모리 할당) */

/* config.h */
extern int g_verbose;  /* 선언만 (메모리 없음) */

/* main.c */
#include "config.h"
g_verbose = 1;  /* config.c의 변수에 접근 */
```

> ⚠️ 전역 변수는 최소한으로. 대부분 함수 매개변수나 구조체로 대체 가능.

---

## 분할 컴파일 (Separate compilation)

```bash
# 1. 각 소스를 개별 컴파일 → 오브젝트 파일(.o)
gcc -c main.c -o main.o
gcc -c math_util.c -o math_util.o

# 2. 오브젝트 파일들을 링크
gcc main.o math_util.o -o program
```

장점: math_util.c만 수정하면 math_util.o만 다시 빌드. 대규모 프로젝트에서 빌드 시간 절약.

---

## Makefile 기초

```makefile
CC = gcc
CFLAGS = -std=c11 -Wall -Wextra

program: main.o math_util.o
	$(CC) $^ -o $@

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f *.o program
```

```bash
make          # 빌드
make clean    # 정리
```

---

## 정적 라이브러리 (.a)

여러 오브젝트를 하나의 아카이브로 묶기:

```bash
# 오브젝트 파일들 생성
gcc -c math_util.c -o math_util.o
gcc -c str_util.c -o str_util.o

# 아카이브 생성
ar rcs libmyutil.a math_util.o str_util.o

# 사용
gcc main.c -L. -lmyutil -o program
```

---

## 자주 틀리는 포인트 3가지

1. **헤더에 함수 본문 작성**
   - 여러 .c에서 include하면 "중복 정의(multiple definition)" 링크 오류

2. **include guard 없이 헤더 작성**
   - A.h가 B.h를 포함, main.c가 둘 다 포함 → 중복 선언 오류

3. **.c 파일을 #include**
   ```c
   #include "math_util.c"  /* 절대 하지 말 것! */
   ```

---

## 이번 주 핵심 요약

| 개념 | 한 줄 요약 |
|------|-----------|
| .h / .c 분리 | 선언(계약)과 정의(구현)을 분리 |
| include guard | 헤더 중복 삽입 방지 |
| static (파일) | 파일 내부에서만 보이는 함수/변수 |
| extern | 다른 파일의 변수를 참조하는 선언 |
| 분할 컴파일 | 변경된 파일만 다시 빌드 (효율) |
| Makefile | 빌드 과정 자동화 |
