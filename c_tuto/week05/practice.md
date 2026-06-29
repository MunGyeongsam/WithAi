# Week 05 연습문제

---

## 문제 1: 주소와 값 출력 (난이도: ★☆☆)

int, double, char 변수를 각각 선언하고, 각 변수의 값과 주소를 출력하시오.

출력 형식:
```
int    x = 42,  주소 = 0x7fff...
double d = 3.14, 주소 = 0x7fff...
char   c = 'A',  주소 = 0x7fff...
```

---

## 문제 2: swap 함수 (난이도: ★☆☆)

두 int 변수의 값을 교환하는 swap 함수를 포인터로 구현하시오.

```c
void swap(int *a, int *b);
```

main에서 x=10, y=20으로 테스트.

---

## 문제 3: 배열 합계 (포인터 버전) (난이도: ★★☆)

배열과 크기를 받아 합계를 반환하는 함수를 포인터 산술로 구현하시오:

```c
int array_sum(const int *arr, int n);
```

내부에서 인덱스([])를 사용하지 말고, 포인터 이동(ptr++)으로만 순회할 것.

---

## 문제 4: 최솟값과 최댓값 동시 반환 (난이도: ★★☆)

배열에서 최솟값과 최댓값을 동시에 찾는 함수를 작성하시오.
C는 값을 하나만 return할 수 있으므로, 포인터 매개변수로 결과를 돌려준다:

```c
void find_min_max(const int arr[], int n, int *out_min, int *out_max);
```

테스트: {3, 7, 1, 9, 4} → min=1, max=9

---

## 문제 5: 포인터 퀴즈 (난이도: ★★★)

다음 코드의 출력을 **먼저 종이에 예측**한 뒤 실행하시오:

```c
#include <stdio.h>

int main(void) {
    int a[] = {10, 20, 30, 40, 50};
    int *p = a;
    int *q = a + 3;

    printf("A: %d\n", *p);
    printf("B: %d\n", *(p + 2));
    printf("C: %d\n", *q);
    printf("D: %d\n", q - p);
    printf("E: %d\n", p[4]);

    p++;
    printf("F: %d\n", *p);
    return 0;
}
```

각 줄의 출력값과 그 이유를 설명하시오.
