# Week 06 연습문제

---

## 문제 1: 선언 해석 (난이도: ★☆☆)

다음 선언을 한글로 해석하시오:

1. `char **argv`
2. `int (*matrix)[4]`
3. `void (*handler)(int)`
4. `int *(*fp)(const char *)`

---

## 문제 2: 함수 포인터 계산기 (난이도: ★★☆)

함수 포인터를 사용해서 사칙연산 계산기를 작성하시오.
switch 없이, 연산자 문자에 따라 적절한 함수를 선택해서 호출할 것.

힌트: 함수 포인터 배열 또는 if 체인으로 함수 포인터를 선택.

---

## 문제 3: 콜백 기반 필터 (난이도: ★★☆)

배열에서 조건을 만족하는 원소만 출력하는 filter 함수를 작성하시오:

```c
void filter(const int arr[], int n, int (*predicate)(int));
```

조건 함수 예:
- `is_even(int n)`: 짝수이면 1
- `is_positive(int n)`: 양수이면 1

---

## 문제 4: qsort 사용 (난이도: ★★★)

표준 라이브러리 qsort를 사용해서 문자열 배열을 사전순 정렬하시오:

```c
const char *words[] = {"banana", "apple", "cherry", "date"};
```

qsort의 비교 함수 시그니처: `int cmp(const void *a, const void *b)`

---

## 문제 5: 선언 해석 퀴즈 (난이도: ★★★)

다음 선언의 의미를 쓰고, 사용 예시 코드를 작성하시오:

```c
int (*table[4])(int, int);
```
