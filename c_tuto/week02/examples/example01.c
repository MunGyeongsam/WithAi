/*
 * Week 02 예제: 타입과 형변환 종합
 *
 * 학습 목표:
 * - 정수 나눗셈과 실수 나눗셈의 차이를 확인한다.
 * - sizeof로 각 타입의 크기를 조사한다.
 * - 명시적 캐스트(explicit cast)를 연습한다.
 *
 * 빌드: gcc -std=c11 -Wall -Wextra example01.c -o example01
 * 실행: ./example01
 */
#include <stdio.h>
#include <limits.h>

int main(void) {
    /* 1. 타입 크기 */
    printf("=== 타입 크기 ===\n");
    printf("int:    %zu bytes\n", sizeof(int));
    printf("double: %zu bytes\n", sizeof(double));
    printf("\n");

    /* 2. 정수 나눗셈 vs 실수 나눗셈 */
    printf("=== 나눗셈 ===\n");
    int a = 7, b = 2;
    printf("7 / 2 (정수)  = %d\n", a / b);
    printf("7 / 2 (실수)  = %.2f\n", (double)a / b);
    printf("\n");

    /* 3. 오버플로우 관찰 */
    printf("=== 범위 ===\n");
    printf("INT_MAX = %d\n", INT_MAX);
    printf("INT_MIN = %d\n", INT_MIN);

    unsigned int u = 0;
    printf("unsigned 0 - 1 = %u\n", u - 1);  /* wrap-around */

    return 0;
}
