# Week 03 강의: 제어문과 함수 기초

---

## 왜 제어문(control flow)이 필요한가

지금까지의 프로그램은 위에서 아래로 한 줄씩 실행됐다.
하지만 현실 문제는 **조건**과 **반복**이 필요하다:

- "비가 오면 우산을 가져간다" → **조건문(if)**
- "시험 점수에 따라 A/B/C 학점" → **분기(switch)**
- "100명의 출석을 확인한다" → **반복문(for/while)**

비유: 요리 레시피에서 "소금을 넣는다"는 순차(sequential)이고,
"맛을 보고 싱거우면 소금 추가"는 조건, "3분간 젓는다"는 반복이다.

---

## 조건문: if / else if / else

### 기본 구조

```c
if (조건) {
    /* 조건이 참(true, 0이 아닌 값)일 때 실행 */
} else if (다른_조건) {
    /* 첫 조건이 거짓이고 이 조건이 참일 때 */
} else {
    /* 모두 거짓일 때 */
}
```

### 예제: 합격 판정

```c
#include <stdio.h>

int main(void) {
    int score = 72;

    if (score >= 90) {
        printf("A학점\n");
    } else if (score >= 80) {
        printf("B학점\n");
    } else if (score >= 70) {
        printf("C학점\n");
    } else {
        printf("재수강\n");
    }
    return 0;
}
```

실행 결과: `C학점`

### C에서 "참"과 "거짓"

| 값 | 의미 |
|----|------|
| `0` | 거짓(false) |
| 0이 아닌 모든 값 | 참(true) |

```c
if (1)  { /* 항상 실행 */ }
if (0)  { /* 절대 실행 안 됨 */ }
if (-5) { /* 실행됨! -5도 "참" */ }
```

---

## 조건문: switch

같은 변수를 여러 값과 비교할 때 `if-else if` 체인보다 깔끔:

```c
#include <stdio.h>

int main(void) {
    int day = 3;

    switch (day) {
    case 1: printf("월요일\n"); break;
    case 2: printf("화요일\n"); break;
    case 3: printf("수요일\n"); break;
    case 4: printf("목요일\n"); break;
    case 5: printf("금요일\n"); break;
    default: printf("주말\n");  break;
    }
    return 0;
}
```

> ⚠️ **break를 빠뜨리면?** → 아래 case로 계속 실행된다(fall-through).
> 이것은 C의 가장 흔한 버그 중 하나이다.

---

## 반복문: for

**"정해진 횟수"** 반복할 때 가장 적합:

```c
for (초기화; 조건; 증감) {
    /* 조건이 참인 동안 반복 */
}
```

```c
#include <stdio.h>

int main(void) {
    for (int i = 1; i <= 5; i++) {
        printf("%d ", i);
    }
    printf("\n");
    return 0;
}
```

실행 결과: `1 2 3 4 5`

실행 순서:
1. `int i = 1` (초기화, 1번만)
2. `i <= 5` 검사 → 참이면 본문 실행
3. 본문 실행 후 `i++`
4. 2번으로 돌아감

---

## 반복문: while

**"조건이 참인 동안"** 반복. 횟수를 모를 때 적합:

```c
#include <stdio.h>

int main(void) {
    int n = 1;
    while (n <= 100) {
        n = n * 2;  /* 2배씩 증가 */
    }
    printf("100을 처음 넘는 2의 거듭제곱: %d\n", n);
    return 0;
}
```

실행 결과: `100을 처음 넘는 2의 거듭제곱: 128`

---

## 반복문: do-while

**최소 1번은 실행**한 뒤 조건 검사:

```c
int input;
do {
    printf("1~10 사이의 수를 입력: ");
    scanf("%d", &input);
} while (input < 1 || input > 10);
```

> for vs while vs do-while 선택 기준:
> - 횟수가 정해짐 → `for`
> - 조건만 있고 횟수 불명 → `while`
> - 최소 1회 실행 보장 → `do-while`

---

## break와 continue

| 키워드 | 효과 |
|--------|------|
| `break` | 반복문을 즉시 종료 |
| `continue` | 현재 반복의 나머지를 건너뛰고 다음 반복으로 |

```c
for (int i = 1; i <= 10; i++) {
    if (i == 5) continue;  /* 5는 건너뛴다 */
    if (i == 8) break;     /* 8에서 멈춘다 */
    printf("%d ", i);
}
/* 출력: 1 2 3 4 6 7 */
```

---

## 함수(function): 코드를 나누는 기술

### 왜 함수가 필요한가

같은 코드를 여러 번 복사-붙여넣기하면:
1. 버그 수정할 때 모든 복사본을 찾아야 한다
2. 코드가 길어지면 읽기 어렵다

**함수 = 이름을 붙인 작업 단위**

비유: "저녁 준비"라는 큰 일을 "쌀 씻기", "반찬 만들기", "상 차리기"로 나누는 것.

### 함수의 구조

```c
반환타입 함수이름(매개변수목록) {
    /* 본문 */
    return 값;
}
```

### 예제: 절댓값 함수

```c
#include <stdio.h>

int abs_val(int x) {
    if (x < 0) {
        return -x;
    }
    return x;
}

int main(void) {
    printf("|  5| = %d\n", abs_val(5));
    printf("| -3| = %d\n", abs_val(-3));
    printf("|  0| = %d\n", abs_val(0));
    return 0;
}
```

실행 결과:
```
|  5| = 5
| -3| = 3
|  0| = 0
```

### 함수 선언(declaration)과 정의(definition)

```c
/* 선언(prototype) - 컴파일러에게 "이런 함수가 있을 것"을 알림 */
int max(int a, int b);

int main(void) {
    printf("%d\n", max(3, 7));  /* 사용 가능 */
    return 0;
}

/* 정의 - 실제 동작 구현 */
int max(int a, int b) {
    return (a > b) ? a : b;
}
```

> 선언 없이 함수를 사용하면 컴파일러가 경고를 내거나 오류를 발생시킨다.

---

## 스코프(scope)와 수명(lifetime)

### 스코프 = 이름이 보이는 범위

```c
int main(void) {
    int x = 10;       /* main 전체에서 보인다 */
    
    if (x > 5) {
        int y = 20;   /* 이 블록 {} 안에서만 보인다 */
        printf("y = %d\n", y);
    }
    /* printf("y = %d\n", y); */  /* 오류! y는 여기서 안 보인다 */
    return 0;
}
```

### 수명 = 변수가 메모리에 존재하는 기간

| 종류 | 수명 | 예시 |
|------|------|------|
| 지역 변수(local) | 함수/블록 실행 동안 | `int x = 5;` |
| 전역 변수(global) | 프로그램 전체 | 함수 밖에 선언 |
| 정적 변수(static) | 프로그램 전체 (하지만 스코프는 지역) | `static int count = 0;` |

```c
void counter(void) {
    static int count = 0;  /* 첫 호출 때만 초기화, 값 유지 */
    count++;
    printf("호출 횟수: %d\n", count);
}
```

---

## 자주 틀리는 포인트 3가지

1. **if 조건에 = 대신 == 써야 함**
   ```c
   if (x = 5) { }   /* 대입! 항상 참! 버그! */
   if (x == 5) { }  /* 비교. 올바름 */
   ```

2. **switch에서 break 누락**
   ```c
   case 1: printf("one\n");   /* break 없으면 아래로 계속! */
   case 2: printf("two\n");
   ```

3. **for 루프에서 세미콜론 실수**
   ```c
   for (int i = 0; i < 10; i++);  /* 세미콜론! 빈 본문! */
   {
       printf("%d\n", i);  /* 1번만 실행됨 (i 스코프 문제) */
   }
   ```

---

## 이번 주 핵심 요약

| 개념 | 한 줄 요약 |
|------|-----------|
| if/else | 조건에 따라 다른 코드를 실행 |
| switch | 하나의 값을 여러 상수와 비교 (break 필수!) |
| for | 횟수가 정해진 반복 |
| while | 조건 기반 반복 |
| 함수 | 이름 붙인 재사용 가능한 코드 블록 |
| 스코프 | {} 블록이 이름의 가시 범위를 결정 |
