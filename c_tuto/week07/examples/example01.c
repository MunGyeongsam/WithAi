/*
 * Week 07 예제: 동적 메모리 할당 종합
 *
 * 빌드: gcc -std=c11 -Wall -Wextra example01.c -o example01
 * 실행: ./example01
 */
#include <stdio.h>
#include <stdlib.h>

/* 동적 배열에 값 추가 (용량 부족 시 확장) */
int *push(int *arr, int *size, int *capacity, int value) {
    if (*size >= *capacity) {
        *capacity *= 2;
        int *tmp = (int *)realloc(arr, *capacity * sizeof(int));
        if (tmp == NULL) {
            free(arr);
            return NULL;
        }
        arr = tmp;
    }
    arr[(*size)++] = value;
    return arr;
}

int main(void) {
    int capacity = 2;
    int size = 0;
    int *arr = (int *)malloc(capacity * sizeof(int));

    if (arr == NULL) return 1;

    for (int i = 0; i < 8; i++) {
        arr = push(arr, &size, &capacity, i * 5);
        if (arr == NULL) return 1;
    }

    printf("size=%d, capacity=%d\n", size, capacity);
    printf("데이터: ");
    for (int i = 0; i < size; i++) {
        printf("%d ", arr[i]);
    }
    printf("\n");

    free(arr);
    return 0;
}
