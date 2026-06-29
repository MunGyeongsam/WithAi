/*
 * Week 14 예제: 모듈화 데모 (단일 파일 버전)
 * 실제로는 헤더/소스로 분리할 것.
 *
 * 빌드: gcc -std=c11 -Wall -Wextra example01.c -o example01
 */
#include <stdio.h>
#include <stdlib.h>

/* === 모듈: 스택(stack) === */
typedef struct {
    int *data;
    int top;
    int capacity;
} Stack;

Stack *stack_create(int cap) {
    Stack *s = malloc(sizeof(Stack));
    s->data = malloc(cap * sizeof(int));
    s->top = 0;
    s->capacity = cap;
    return s;
}

void stack_push(Stack *s, int val) {
    if (s->top < s->capacity) {
        s->data[s->top++] = val;
    }
}

int stack_pop(Stack *s) {
    if (s->top > 0) return s->data[--s->top];
    return -1;
}

int stack_is_empty(const Stack *s) { return s->top == 0; }

void stack_destroy(Stack *s) {
    free(s->data);
    free(s);
}

/* === 사용 === */
int main(void) {
    Stack *s = stack_create(10);

    stack_push(s, 10);
    stack_push(s, 20);
    stack_push(s, 30);

    while (!stack_is_empty(s)) {
        printf("%d ", stack_pop(s));
    }
    printf("\n");

    stack_destroy(s);
    return 0;
}
