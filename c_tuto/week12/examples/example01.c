/*
 * Week 12 예제: 전처리기 활용
 *
 * 빌드: gcc -std=c11 -Wall -Wextra -DDEBUG example01.c -o example01
 */
#include <stdio.h>

/* 디버그 매크로 */
#ifdef DEBUG
#define LOG(fmt, ...) fprintf(stderr, "[%s:%d] " fmt "\n", __FILE__, __LINE__, ##__VA_ARGS__)
#else
#define LOG(fmt, ...) ((void)0)
#endif

/* 안전한 MAX */
#define MAX(a, b) ((a) > (b) ? (a) : (b))

/* 배열 크기 */
#define ARRAY_SIZE(arr) (sizeof(arr) / sizeof((arr)[0]))

int main(void) {
    LOG("프로그램 시작");

    int nums[] = {3, 7, 1, 9, 4};
    int n = ARRAY_SIZE(nums);
    LOG("배열 크기 = %d", n);

    int biggest = nums[0];
    for (int i = 1; i < n; i++) {
        biggest = MAX(biggest, nums[i]);
    }

    printf("최대값: %d\n", biggest);
    LOG("프로그램 종료");
    return 0;
}
