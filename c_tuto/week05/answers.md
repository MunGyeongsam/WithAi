# Week 05 정답과 해설

---

## 문제 1 정답

```c
#include <stdio.h>

int main(void) {
    int    x = 42;
    double d = 3.14;
    char   c = 'A';

    printf("int    x = %d,  주소 = %p\n", x, (void*)&x);
    printf("double d = %.2f, 주소 = %p\n", d, (void*)&d);
    printf("char   c = '%c',  주소 = %p\n", c, (void*)&c);
    return 0;
}
```

**해설:**
- `%p`는 포인터(주소)를 16진수로 출력하는 서식이다.
- `(void*)`로 캐스트하는 이유: %p는 void* 타입을 기대하기 때문.
- 주소값은 실행할 때마다 달라질 수 있다 (ASLR 때문).

---

## 문제 2 정답

```c
#include <stdio.h>

void swap(int *a, int *b) {
    int temp = *a;
    *a = *b;
    *b = temp;
}

int main(void) {
    int x = 10, y = 20;
    printf("교환 전: x=%d, y=%d\n", x, y);
    swap(&x, &y);
    printf("교환 후: x=%d, y=%d\n", x, y);
    return 0;
}
```

**해설:**
- &x, &y로 주소를 전달한다.
- 함수 안에서 *a, *b로 원본에 접근해 값을 교환한다.
- temp 없이 XOR로도 가능하지만, 가독성이 떨어지므로 temp를 권장.

---

## 문제 3 정답

```c
#include <stdio.h>

int array_sum(const int *arr, int n) {
    int sum = 0;
    const int *end = arr + n;
    while (arr < end) {
        sum += *arr;
        arr++;
    }
    return sum;
}

int main(void) {
    int nums[] = {1, 2, 3, 4, 5};
    printf("합계: %d\n", array_sum(nums, 5));  /* 15 */
    return 0;
}
```

**해설:**
- `arr + n`은 배열 끝 바로 다음 주소 (past-the-end).
- `arr < end` 동안 순회하며, `arr++`로 다음 원소로 이동.
- `const int *arr`은 "이 포인터로 값을 수정하지 않겠다"는 약속.

---

## 문제 4 정답

```c
#include <stdio.h>

void find_min_max(const int arr[], int n, int *out_min, int *out_max) {
    *out_min = arr[0];
    *out_max = arr[0];
    for (int i = 1; i < n; i++) {
        if (arr[i] < *out_min) *out_min = arr[i];
        if (arr[i] > *out_max) *out_max = arr[i];
    }
}

int main(void) {
    int data[] = {3, 7, 1, 9, 4};
    int mn, mx;
    find_min_max(data, 5, &mn, &mx);
    printf("min=%d, max=%d\n", mn, mx);  /* min=1, max=9 */
    return 0;
}
```

**해설:**
- C 함수는 return으로 값 하나만 돌려줄 수 있다.
- 여러 결과를 돌려주고 싶으면 포인터 매개변수를 사용한다.
- 호출할 때 &mn, &mx로 결과를 받을 변수의 주소를 전달한다.

---

## 문제 5 정답

| 줄 | 출력 | 이유 |
|----|------|------|
| A | 10 | *p = a[0] = 10 |
| B | 30 | *(p+2) = a[2] = 30 |
| C | 40 | *q = *(a+3) = a[3] = 40 |
| D | 3 | q - p = (a+3) - a = 3 (원소 개수 차이) |
| E | 50 | p[4] = *(p+4) = a[4] = 50 |
| F | 20 | p++후 p = a+1, *p = a[1] = 20 |

**해설:**
- 포인터 뺄셈(q - p)은 두 포인터 사이의 **원소 개수**를 반환한다 (바이트 수가 아님).
- p[i]와 *(p+i)는 완전히 동일한 표현이다.
- p++는 p가 가리키는 타입의 크기만큼 주소를 증가시킨다.
