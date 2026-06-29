# Week 06 강의: 포인터 심화와 함수 포인터

---

## 왜 포인터 심화가 필요한가

5주차에서 "주소를 저장하는 변수"로서의 포인터를 배웠다.
이번 주는 한 단계 더 들어간다:

- **복합 선언**: int *arr[5]와 int (*arr)[5]의 차이
- **함수 포인터**: 함수 자체를 변수에 저장
- **콜백 패턴**: 동작을 매개변수로 넘기기

---

## 복합 선언 해석: right-left 규칙

C의 선언이 복잡해 보이는 이유: **연산자 우선순위**가 선언에도 적용되기 때문.

**읽는 법:**
1. 변수 이름에서 시작
2. 오른쪽으로 → 왼쪽으로 번갈아 읽기
3. 괄호를 만나면 방향 전환

### 예시 1: int *p;
- p → * → int
- "p는 int를 가리키는 포인터"

### 예시 2: int *arr[5];
- arr → [5] (오른쪽: 배열) → * (왼쪽: 포인터) → int
- "arr은 크기 5인 배열, 각 원소가 int 포인터"

### 예시 3: int (*arr)[5];
- arr → (괄호 안에서) * → [5] → int
- "arr은 포인터, 크기 5인 int 배열을 가리킴"

### 예시 4: int (*fp)(int, int);
- fp → (괄호 안에서) * → (int, int) (오른쪽: 함수) → int
- "fp는 포인터, int 두 개를 받아 int를 반환하는 함수를 가리킴"

---

## 함수 포인터(function pointer)

### 개념

함수도 메모리에 저장된 코드이므로, 그 시작 주소를 저장할 수 있다:

```c
#include <stdio.h>

int add(int a, int b) { return a + b; }
int sub(int a, int b) { return a - b; }

int main(void) {
    int (*op)(int, int);  /* 함수 포인터 선언 */

    op = add;
    printf("add: %d\n", op(3, 2));  /* 5 */

    op = sub;
    printf("sub: %d\n", op(3, 2));  /* 1 */
    return 0;
}
```

### 왜 유용한가?

- **콜백(callback)**: "이 함수를 나중에 불러줘" 패턴
- **전략(strategy)**: 동작을 실행 시점에 선택
- **테이블 기반 분기**: switch 대신 함수 포인터 배열

---

## 콜백 패턴 예제: 정렬 비교 함수

```c
#include <stdio.h>

void sort(int arr[], int n, int (*compare)(int, int)) {
    for (int i = 0; i < n - 1; i++) {
        for (int j = i + 1; j < n; j++) {
            if (compare(arr[i], arr[j]) > 0) {
                int temp = arr[i];
                arr[i] = arr[j];
                arr[j] = temp;
            }
        }
    }
}

int ascending(int a, int b)  { return a - b; }
int descending(int a, int b) { return b - a; }

int main(void) {
    int data[] = {5, 2, 8, 1, 9};
    int n = 5;

    sort(data, n, ascending);
    printf("오름차순: ");
    for (int i = 0; i < n; i++) printf("%d ", data[i]);
    printf("\n");

    sort(data, n, descending);
    printf("내림차순: ");
    for (int i = 0; i < n; i++) printf("%d ", data[i]);
    printf("\n");
    return 0;
}
```

실행 결과:
```
오름차순: 1 2 5 8 9
내림차순: 9 8 5 2 1
```

> sort 함수는 비교 방법을 모른다. 외부에서 전략(compare 함수)을 주입한다.
> 이것이 표준 라이브러리 qsort의 설계 원리이다.

---

## 함수 포인터 배열

```c
#include <stdio.h>

int add(int a, int b) { return a + b; }
int sub(int a, int b) { return a - b; }
int mul(int a, int b) { return a * b; }

int main(void) {
    int (*ops[])(int, int) = {add, sub, mul};
    const char *names[] = {"+", "-", "*"};

    int a = 10, b = 3;
    for (int i = 0; i < 3; i++) {
        printf("%d %s %d = %d\n", a, names[i], b, ops[i](a, b));
    }
    return 0;
}
```

실행 결과:
```
10 + 3 = 13
10 - 3 = 7
10 * 3 = 30
```

---

## typedef로 함수 포인터 간소화

```c
typedef int (*BinaryOp)(int, int);

/* 이제 BinaryOp가 타입 이름 */
void apply(BinaryOp op, int a, int b) {
    printf("결과: %d\n", op(a, b));
}
```

> 복잡한 선언을 typedef로 감싸면 가독성이 크게 좋아진다.

---

## 선언 해석 연습

| 선언 | 해석 |
|------|------|
| `int *p` | p는 int 포인터 |
| `int **pp` | pp는 int 포인터의 포인터 |
| `int *arr[3]` | arr은 int 포인터 3개의 배열 |
| `int (*arr)[3]` | arr은 int[3] 배열을 가리키는 포인터 |
| `int (*fp)(int)` | fp는 int→int 함수 포인터 |
| `int *fp(int)` | fp는 int를 받아 int*를 반환하는 **함수** |
| `int (*fp[3])(int)` | fp는 함수 포인터 3개의 배열 |

> 핵심: `(*이름)`이면 이름은 포인터. 괄호 없이 `*이름(...)`이면 이름은 함수.

---

## 자주 틀리는 포인트 3가지

1. **함수 포인터와 함수 선언 혼동**
   ```c
   int *f(int);      /* f는 함수! int*를 반환 */
   int (*f)(int);    /* f는 포인터! int→int 함수를 가리킴 */
   ```

2. **괄호 누락**
   ```c
   int *arr[5];      /* int 포인터의 배열 */
   int (*arr)[5];    /* int 배열의 포인터 ← 괄호가 의미를 바꿈 */
   ```

3. **콜백에서 시그니처 불일치**
   ```c
   void sort(int[], int, int(*)(int,int));
   int cmp(double, double);  /* 시그니처 다름! 위험 */
   ```

---

## 이번 주 핵심 요약

| 개념 | 한 줄 요약 |
|------|-----------|
| right-left 규칙 | 변수 이름에서 시작, 좌우로 읽으면 선언 해석 가능 |
| 함수 포인터 | 함수의 주소를 저장하는 변수. 실행 시점에 동작 선택 |
| 콜백 | 함수 포인터를 인자로 받아 "전략"을 주입하는 패턴 |
| typedef | 복잡한 포인터 타입에 이름을 붙여 가독성 향상 |
