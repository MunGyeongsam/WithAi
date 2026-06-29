/*
 * Week 03 예제: 제어문과 함수 종합
 *
 * 학습 목표:
 * - if/else, for, 함수 분리를 조합한다.
 * - 함수의 반환값을 조건문에 활용한다.
 *
 * 빌드: gcc -std=c11 -Wall -Wextra example01.c -o example01
 * 실행: ./example01
 */
#include <stdio.h>

/* 함수 선언(prototype) */
int is_even(int n);
int max2(int a, int b);
int abs_val(int x);

int main(void) {
    /* 짝수/홀수 판별 */
    for (int i = 1; i <= 10; i++) {
        if (is_even(i)) {
            printf("%d: 짝수
", i);
        } else {
            printf("%d: 홀수
", i);
        }
    }
    printf("
");

    /* 최댓값 */
    printf("max(3, 7) = %d
", max2(3, 7));
    printf("max(-1, -5) = %d
", max2(-1, -5));

    /* 절댓값 */
    printf("|  5| = %d
", abs_val(5));
    printf("| -3| = %d
", abs_val(-3));

    return 0;
}

/* 함수 정의 */
int is_even(int n) {
    return n % 2 == 0;
}

int max2(int a, int b) {
    return (a > b) ? a : b;
}

int abs_val(int x) {
    if (x < 0) return -x;
    return x;
}
