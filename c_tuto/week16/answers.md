# Week 16 정답과 해설

---

## 문제 2 정답 (리팩터링 후)

```c
#include <stdio.h>

#define DATA_SIZE 10

int sum_array(const int arr[], int n) {
    int sum = 0;
    for (int i = 0; i < n; i++) sum += arr[i];
    return sum;
}

int find_max(const int arr[], int n) {
    int max = arr[0];
    for (int i = 1; i < n; i++) {
        if (arr[i] > max) max = arr[i];
    }
    return max;
}

int find_min(const int arr[], int n) {
    int min = arr[0];
    for (int i = 1; i < n; i++) {
        if (arr[i] < min) min = arr[i];
    }
    return min;
}

int main(void) {
    int scores[DATA_SIZE] = {3, 7, 1, 9, 2, 8, 4, 6, 5, 10};

    int total = sum_array(scores, DATA_SIZE);
    printf("sum=%d avg=%.1f\n", total, (double)total / DATA_SIZE);
    printf("max=%d\n", find_max(scores, DATA_SIZE));
    printf("min=%d\n", find_min(scores, DATA_SIZE));
    return 0;
}
```

개선 사항:
1. 매직 넘버 10 → #define DATA_SIZE
2. 변수 이름: a → scores, s → total, m → max, mn → min
3. 중복 루프 → find_max / find_min 함수 분리
4. const 매개변수로 의도 명확화

---

## 문제 5 정답

| 번호 | 출력 | 이유 |
|------|------|------|
| Q1 | 4 | C에서 'a'는 int 타입 (C++에서는 1) |
| Q2 | 2 | 정수 나눗셈, 소수점 버림 |
| Q3 | (불확실) | 초기화 안 된 변수, 쓰레기 값 (UB) |
| Q4 | 101 | "hello"[1] = 'e', ASCII 101 |
| Q5 | 3 | 12바이트 / 4바이트 = 3개 |
