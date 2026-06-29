/*
 * Week 01 예제: 첫 번째 C 프로그램
 *
 * 학습 목표:
 * - printf로 문자열(string)을 화면에 출력한다.
 * - 서식 지정자(format specifier)로 숫자를 출력한다.
 * - 프로그램의 기본 구조(main 함수)를 익힌다.
 *
 * 빌드 방법:
 *   gcc -std=c11 -Wall -Wextra example01.c -o example01
 *
 * 실행 방법:
 *   ./example01
 */
#include <stdio.h>

int main(void) {
    /* 문자열 출력 */
    printf("=== C 언어 첫 프로그램 ===\n");
    printf("\n");

    /* 정수(integer) 출력 */
    printf("올해 연도: %d\n", 2026);

    /* 실수(floating point) 출력 */
    printf("원주율: %.4f\n", 3.14159);

    /* 계산 결과 출력 */
    printf("7 * 8 = %d\n", 7 * 8);

    /* 여러 값 한 줄에 출력 */
    printf("이름: %s, 나이: %d\n", "홍길동", 22);

    return 0;
}
