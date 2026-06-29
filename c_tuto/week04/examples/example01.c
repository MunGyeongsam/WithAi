/*
 * Week 04 예제: 배열과 문자열 종합
 *
 * 빌드: gcc -std=c11 -Wall -Wextra example01.c -o example01
 * 실행: ./example01
 */
#include <stdio.h>

/* 문자열 길이 */
int my_strlen(const char s[]) {
    int len = 0;
    while (s[len] != '\0') len++;
    return len;
}

/* 문자열 역순 복사 */
void reverse(char dest[], const char src[]) {
    int len = my_strlen(src);
    for (int i = 0; i < len; i++) {
        dest[i] = src[len - 1 - i];
    }
    dest[len] = '\0';
}

/* 두 문자열이 같은지 비교 */
int my_strcmp(const char a[], const char b[]) {
    int i = 0;
    while (a[i] != '\0' && a[i] == b[i]) i++;
    return a[i] - b[i];
}

int main(void) {
    /* 배열 기초 */
    int nums[] = {3, 1, 4, 1, 5, 9};
    int n = sizeof(nums) / sizeof(nums[0]);

    printf("배열: ");
    for (int i = 0; i < n; i++) {
        printf("%d ", nums[i]);
    }
    printf("\n");

    /* 문자열 처리 */
    char word[] = "Philosophy";
    char rev[20];

    printf("원본: %s (길이: %d)\n", word, my_strlen(word));
    reverse(rev, word);
    printf("역순: %s\n", rev);

    /* 비교 */
    printf("abc vs abc: %d\n", my_strcmp("abc", "abc"));  /* 0 */
    printf("abc vs abd: %d\n", my_strcmp("abc", "abd"));  /* 음수 */

    return 0;
}
