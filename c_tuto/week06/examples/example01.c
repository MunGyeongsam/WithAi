/*
 * Week 06 예제: 함수 포인터와 콜백
 *
 * 빌드: gcc -std=c11 -Wall -Wextra example01.c -o example01
 * 실행: ./example01
 */
#include <stdio.h>

/* 연산 함수들 */
int add(int a, int b) { return a + b; }
int sub(int a, int b) { return a - b; }
int mul(int a, int b) { return a * b; }

/* typedef로 함수 포인터 타입 정의 */
typedef int (*BinaryOp)(int, int);

/* 콜백을 받는 함수 */
void apply_and_print(int a, int b, BinaryOp op, const char *name) {
    printf("%d %s %d = %d\n", a, name, b, op(a, b));
}

int main(void) {
    /* 함수 포인터 배열 */
    BinaryOp ops[] = {add, sub, mul};
    const char *names[] = {"add", "sub", "mul"};

    int a = 12, b = 4;
    for (int i = 0; i < 3; i++) {
        apply_and_print(a, b, ops[i], names[i]);
    }

    return 0;
}
