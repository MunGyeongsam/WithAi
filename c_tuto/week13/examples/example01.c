/*
 * Week 13 예제: 매크로 심화 종합
 *
 * 빌드: gcc -std=c11 -Wall -Wextra -DDEBUG example01.c -o example01
 */
#include <stdio.h>

/* X-Macro로 방향 enum + 문자열 */
#define DIRECTIONS(X) \
    X(NORTH) X(SOUTH) X(EAST) X(WEST)

#define DIR_ENUM(name) name,
#define DIR_STR(name)  #name,

typedef enum { DIRECTIONS(DIR_ENUM) DIR_COUNT } Direction;
static const char *dir_names[] = { DIRECTIONS(DIR_STR) };

/* 안전한 매크로 */
#define ARRAY_SIZE(a) (sizeof(a) / sizeof((a)[0]))

/* 디버그 로그 */
#ifdef DEBUG
#define DBG(fmt, ...) fprintf(stderr, "[DBG %s:%d] " fmt "\n", \
    __FILE__, __LINE__, ##__VA_ARGS__)
#else
#define DBG(fmt, ...) ((void)0)
#endif

int main(void) {
    DBG("방향 테스트 시작");

    for (int i = 0; i < DIR_COUNT; i++) {
        printf("방향 %d: %s\n", i, dir_names[i]);
    }

    int arr[] = {10, 20, 30};
    DBG("배열 크기 = %zu", ARRAY_SIZE(arr));
    printf("합계: %d\n", arr[0] + arr[1] + arr[2]);

    return 0;
}
