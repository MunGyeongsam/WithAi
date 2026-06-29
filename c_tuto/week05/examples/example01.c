/*
 * Week 05 예제: 포인터 기초 종합
 *
 * 빌드: gcc -std=c11 -Wall -Wextra example01.c -o example01
 * 실행: ./example01
 */
#include <stdio.h>

/* 포인터로 두 값을 교환 */
void swap(int *a, int *b) {
    int temp = *a;
    *a = *b;
    *b = temp;
}

/* 포인터로 배열 순회 */
void print_array(const int *arr, int n) {
    printf("[");
    for (int i = 0; i < n; i++) {
        if (i > 0) printf(", ");
        printf("%d", *(arr + i));
    }
    printf("]\n");
}

/* 포인터로 다중 반환 */
void divide(int dividend, int divisor, int *quotient, int *remainder) {
    *quotient = dividend / divisor;
    *remainder = dividend % divisor;
}

int main(void) {
    /* 1. 기본 포인터 */
    int x = 42;
    int *p = &x;
    printf("x = %d, *p = %d\n", x, *p);
    *p = 100;
    printf("수정 후 x = %d\n\n", x);

    /* 2. swap */
    int a = 10, b = 20;
    printf("swap 전: a=%d, b=%d\n", a, b);
    swap(&a, &b);
    printf("swap 후: a=%d, b=%d\n\n", a, b);

    /* 3. 배열과 포인터 */
    int nums[] = {5, 3, 8, 1, 9};
    printf("배열: ");
    print_array(nums, 5);

    /* 4. 다중 반환 */
    int q, r;
    divide(17, 5, &q, &r);
    printf("\n17 / 5 = %d 나머지 %d\n", q, r);

    return 0;
}
