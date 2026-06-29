# Week 02 강의: 타입, 연산자, 형변환

---

## 왜 타입(type)이 필요한가

컴퓨터 메모리(memory)에는 0과 1만 저장된다. 같은 비트 패턴 `01000001`도:
- 정수로 읽으면: 65
- 문자로 읽으면: 'A'

**타입은 비트에 의미를 부여하는 라벨이다.**

비유: 똑같은 투명한 병에 담긴 액체라도, 라벨이 "물"이면 마시고, "세제"면 마시지 않는다.
컴퓨터도 메모리 속 비트를 어떻게 해석할지 **타입**이 알려준다.

---

## 기본 타입(primitive types)

| 타입 | 크기(일반적) | 용도 | 예시 |
|------|-------------|------|------|
| `char` | 1바이트 | 문자 하나 | `'A'`, `'7'`, `'\n'` |
| `int` | 4바이트 | 정수 | `42`, `-1`, `0` |
| `float` | 4바이트 | 소수점 (낮은 정밀도) | `3.14f` |
| `double` | 8바이트 | 소수점 (높은 정밀도) | `3.141592653589` |

> **주의**: 크기는 플랫폼마다 다를 수 있다. 확실한 크기가 필요하면 `<stdint.h>`의 `int32_t` 등을 사용한다.

---

## sizeof로 크기 확인하기

```c
#include <stdio.h>

int main(void) {
    printf("char:   %zu bytes\n", sizeof(char));
    printf("int:    %zu bytes\n", sizeof(int));
    printf("float:  %zu bytes\n", sizeof(float));
    printf("double: %zu bytes\n", sizeof(double));
    return 0;
}
```

실행 결과 (일반적인 64비트 시스템):
```
char:   1 bytes
int:    4 bytes
float:  4 bytes
double: 8 bytes
```

`sizeof`는 **연산자(operator)**이다. 함수가 아니다.
괄호 없이 `sizeof x`도 가능하지만, 가독성을 위해 `sizeof(x)`를 쓴다.

---

## 정수의 범위와 오버플로우(overflow)

4바이트 `int`는 약 ±21억까지 표현할 수 있다:

| 타입 | 최솟값 | 최댓값 |
|------|--------|--------|
| `int` (32비트) | -2,147,483,648 | 2,147,483,647 |
| `unsigned int` | 0 | 4,294,967,295 |

**오버플로우** = 범위를 넘기면 값이 되돌아간다:

```c
#include <stdio.h>
#include <limits.h>

int main(void) {
    int big = INT_MAX;
    printf("INT_MAX = %d\n", big);
    printf("INT_MAX + 1 = %d\n", big + 1);  /* undefined behavior! */
    return 0;
}
```

실행 결과:
```
INT_MAX = 2147483647
INT_MAX + 1 = -2147483648
```

> ⚠️ **위험**: signed int 오버플로우는 **미정의 동작(undefined behavior)**이다.
> 컴파일러가 어떤 결과를 내놓을지 보장되지 않는다.

---

## 연산자(operator) 정리

### 산술 연산자

| 연산자 | 의미 | 예시 | 결과 |
|--------|------|------|------|
| `+` | 덧셈 | `7 + 3` | `10` |
| `-` | 뺄셈 | `7 - 3` | `4` |
| `*` | 곱셈 | `7 * 3` | `21` |
| `/` | 나눗셈 | `7 / 3` | `2` (정수끼리!) |
| `%` | 나머지 | `7 % 3` | `1` |

### 정수 나눗셈의 함정

```c
int a = 7, b = 2;
int result = a / b;    /* result = 3, 소수점 버림! */
```

비유: 피자 7조각을 2명이 나누면, 각자 3조각, **남은 1조각은 사라진다(버려진다)**.

---

## 형변환(type conversion)

### 암시적 형변환 (implicit conversion)

컴파일러가 자동으로 수행. 작은 타입 → 큰 타입으로 승격(promotion):

```c
int i = 5;
double d = i;  /* int → double 자동 변환. d = 5.0 */
```

### 명시적 형변환 (explicit cast)

프로그래머가 직접 지시:

```c
int a = 7, b = 2;
double result = (double)a / b;  /* 7.0 / 2 = 3.5 */
```

**(double)a**에서:
1. `a`의 값 7을 `double` 7.0으로 복사한다.
2. 7.0 / 2 → 2도 자동으로 double로 승격 → 7.0 / 2.0 = 3.5

> **왜 `(double)(a / b)`는 안 되는가?**
> `a / b`가 먼저 계산되어 `7 / 2 = 3` (정수). 그 후 3을 double로 바꿔봐야 `3.0`이다.

---

## signed vs unsigned 혼합의 함정

```c
#include <stdio.h>

int main(void) {
    int s = -1;
    unsigned int u = 1;

    if (s < u) {
        printf("예상대로 -1 < 1\n");
    } else {
        printf("예상과 다르게 -1 >= 1 ?!\n");
    }
    return 0;
}
```

실행 결과:
```
예상과 다르게 -1 >= 1 ?!
```

**이유**: 비교 시 `s`가 unsigned로 변환된다.
-1의 비트 패턴을 unsigned로 읽으면 4,294,967,295 (매우 큰 수!)

> ⚠️ **교훈**: signed와 unsigned를 섞어서 비교하지 않는다.
> 컴파일러 경고(`-Wsign-compare`)를 켜두면 이 실수를 잡을 수 있다.

---

## 상수(constant)

### 정수 상수
```c
int dec = 42;        /* 10진수(decimal) */
int oct = 052;       /* 8진수(octal) - 0으로 시작 */
int hex = 0x2A;      /* 16진수(hexadecimal) - 0x로 시작 */
```

> 주의: `052`는 42가 아니라 8진수이므로 10진수 42이다.
> 실수로 0을 붙이면 값이 바뀐다!

### 문자 상수
```c
char c = 'A';        /* ASCII 65 */
char newline = '\n'; /* 특수 문자(escape sequence) */
```

### const 한정자(qualifier)
```c
const int MAX_STUDENTS = 40;
/* MAX_STUDENTS = 50; */  /* 컴파일 오류! 변경 불가 */
```

---

## 자주 틀리는 포인트 3가지

1. **정수 나눗셈 결과가 0이 되는 실수**
   ```c
   double ratio = 1 / 3;  /* 0.0! 정수끼리 나눠서 0 */
   double ratio = 1.0 / 3; /* 0.333... 올바름 */
   ```

2. **8진수 리터럴 모르고 사용**
   ```c
   int x = 010;  /* 8이다, 10이 아니다! */
   ```

3. **unsigned 변수에 음수 대입**
   ```c
   unsigned int x = -1;  /* x = 4294967295 (UINT_MAX) */
   ```

---

## 이번 주 핵심 요약

| 개념 | 한 줄 요약 |
|------|-----------|
| 타입 | 비트에 의미를 부여하는 라벨 |
| sizeof | 타입/변수의 바이트 크기를 알려주는 연산자 |
| 정수 나눗셈 | 소수점 이하를 버린다 |
| 형변환 | 연산 전에 타입을 맞춰야 원하는 결과를 얻는다 |
| signed/unsigned 혼합 | 절대 섞어서 비교하지 않는다 |
| 오버플로우 | 범위를 넘기면 미정의 동작 (signed) |
