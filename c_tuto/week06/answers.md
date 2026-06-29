# Week 06 정답과 해설

---

## 문제 1 정답

1. `char **argv` — "argv는 char 포인터를 가리키는 포인터" (문자열 배열에 사용)
2. `int (*matrix)[4]` — "matrix는 int[4] 배열을 가리키는 포인터"
3. `void (*handler)(int)` — "handler는 int를 받고 반환없는 함수를 가리키는 포인터"
4. `int *(*fp)(const char *)` — "fp는 const char*를 받아 int*를 반환하는 함수를 가리키는 포인터"

---

## 문제 2 정답

```c
#include <stdio.h>

int add(int a, int b) { return a + b; }
int sub(int a, int b) { return a - b; }
int mul(int a, int b) { return a * b; }
int divide(int a, int b) { return (b != 0) ? a / b : 0; }

int main(void) {
    int (*ops[128])(int, int) = {0};
    ops['+'] = add;
    ops['-'] = sub;
    ops['*'] = mul;
    ops['/'] = divide;

    char op = '+';
    int a = 10, b = 3;

    if (ops[(int)op] != NULL) {
        printf("%d %c %d = %d\n", a, op, b, ops[(int)op](a, b));
    } else {
        printf("지원하지 않는 연산자\n");
    }
    return 0;
}
```

**해설:** 문자의 ASCII 값을 인덱스로 사용해서 switch 없이 분기한다.

---

## 문제 3 정답

```c
#include <stdio.h>

int is_even(int n)     { return n % 2 == 0; }
int is_positive(int n) { return n > 0; }

void filter(const int arr[], int n, int (*predicate)(int)) {
    for (int i = 0; i < n; i++) {
        if (predicate(arr[i])) {
            printf("%d ", arr[i]);
        }
    }
    printf("\n");
}

int main(void) {
    int data[] = {-3, 4, 7, -2, 0, 8, -1, 6};
    int n = sizeof(data) / sizeof(data[0]);

    printf("짝수: ");
    filter(data, n, is_even);

    printf("양수: ");
    filter(data, n, is_positive);
    return 0;
}
```

실행 결과:
```
짝수: 4 -2 0 8 6
양수: 4 7 8 6
```

---

## 문제 4 정답

```c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int cmp_str(const void *a, const void *b) {
    const char *sa = *(const char **)a;
    const char *sb = *(const char **)b;
    return strcmp(sa, sb);
}

int main(void) {
    const char *words[] = {"banana", "apple", "cherry", "date"};
    int n = sizeof(words) / sizeof(words[0]);

    qsort(words, n, sizeof(words[0]), cmp_str);

    for (int i = 0; i < n; i++) {
        printf("%s\n", words[i]);
    }
    return 0;
}
```

실행 결과:
```
apple
banana
cherry
date
```

**해설:** qsort는 void*로 원소의 주소를 넘긴다. 문자열 배열의 원소는 `const char*`이므로, void*를 `const char**`로 캐스트해서 역참조한다.

---

## 문제 5 정답

`int (*table[4])(int, int)` — "table은 크기 4인 배열, 각 원소가 (int,int)->int 함수 포인터"

```c
#include <stdio.h>

int add(int a, int b) { return a + b; }
int sub(int a, int b) { return a - b; }
int mul(int a, int b) { return a * b; }
int divide(int a, int b) { return a / b; }

int main(void) {
    int (*table[4])(int, int) = {add, sub, mul, divide};
    const char *names[] = {"+", "-", "*", "/"};

    for (int i = 0; i < 4; i++) {
        printf("10 %s 3 = %d\n", names[i], table[i](10, 3));
    }
    return 0;
}
```
