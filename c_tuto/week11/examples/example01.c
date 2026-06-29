/*
 * Week 11 예제: 파일 I/O와 오류 처리
 *
 * 빌드: gcc -std=c11 -Wall -Wextra example01.c -o example01
 * 실행: ./example01
 */
#include <stdio.h>
#include <string.h>

int main(void) {
    /* 파일 쓰기 */
    FILE *fp = fopen("example.txt", "w");
    if (fp == NULL) { perror("fopen write"); return 1; }

    fprintf(fp, "이름: Kim\n");
    fprintf(fp, "나이: 22\n");
    fprintf(fp, "학과: 철학\n");
    fclose(fp);
    printf("파일 작성 완료\n");

    /* 파일 읽기 */
    fp = fopen("example.txt", "r");
    if (fp == NULL) { perror("fopen read"); return 1; }

    char line[128];
    printf("\n--- 파일 내용 ---\n");
    while (fgets(line, sizeof(line), fp)) {
        line[strcspn(line, "\n")] = '\0';  /* 줄바꿈 제거 */
        printf("> %s\n", line);
    }
    fclose(fp);

    return 0;
}
