# Week 11 정답과 해설

---

## 문제 1 정답

```c
#include <stdio.h>

int main(void) {
    FILE *fp = fopen("numbers.txt", "w");
    if (fp == NULL) { perror("fopen"); return 1; }

    for (int i = 1; i <= 100; i++) {
        fprintf(fp, "%d\n", i);
    }

    fclose(fp);
    printf("numbers.txt 생성 완료\n");
    return 0;
}
```

---

## 문제 2 정답

```c
#include <stdio.h>

int main(int argc, char *argv[]) {
    if (argc < 2) {
        printf("사용법: %s <파일>\n", argv[0]);
        return 1;
    }

    FILE *fp = fopen(argv[1], "r");
    if (fp == NULL) { perror(argv[1]); return 1; }

    int lines = 0;
    int ch;
    while ((ch = fgetc(fp)) != EOF) {
        if (ch == '\n') lines++;
    }
    fclose(fp);

    printf("%s: %d lines\n", argv[1], lines);
    return 0;
}
```

---

## 문제 3 정답

```c
#include <stdio.h>

int main(int argc, char *argv[]) {
    if (argc != 3) {
        printf("사용법: %s <source> <dest>\n", argv[0]);
        return 1;
    }

    FILE *src = fopen(argv[1], "rb");
    if (src == NULL) { perror(argv[1]); return 1; }

    FILE *dst = fopen(argv[2], "wb");
    if (dst == NULL) { perror(argv[2]); fclose(src); return 1; }

    unsigned char buf[4096];
    size_t n;
    while ((n = fread(buf, 1, sizeof(buf), src)) > 0) {
        fwrite(buf, 1, n, dst);
    }

    fclose(dst);
    fclose(src);
    printf("복사 완료: %s -> %s\n", argv[1], argv[2]);
    return 0;
}
```

---

## 문제 4 정답

```c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct {
    char name[20];
    int age;
    double gpa;
} Student;

int cmp_gpa_desc(const void *a, const void *b) {
    double ga = ((const Student *)a)->gpa;
    double gb = ((const Student *)b)->gpa;
    if (gb > ga) return 1;
    if (gb < ga) return -1;
    return 0;
}

int main(void) {
    FILE *fp = fopen("students.csv", "r");
    if (fp == NULL) { perror("fopen"); return 1; }

    Student students[100];
    int count = 0;
    char line[128];

    while (fgets(line, sizeof(line), fp) && count < 100) {
        line[strcspn(line, "\n")] = '\0';
        sscanf(line, "%[^,],%d,%lf",
               students[count].name,
               &students[count].age,
               &students[count].gpa);
        count++;
    }
    fclose(fp);

    qsort(students, count, sizeof(Student), cmp_gpa_desc);

    for (int i = 0; i < count; i++) {
        printf("%s (age %d) GPA=%.1f\n",
               students[i].name, students[i].age, students[i].gpa);
    }
    return 0;
}
```

---

## 문제 5 정답

```c
#include <stdio.h>
#include <time.h>

void log_write(const char *level, const char *msg) {
    FILE *fp = fopen("app.log", "a");
    if (fp == NULL) return;

    time_t now = time(NULL);
    struct tm *t = localtime(&now);
    fprintf(fp, "[%s] %04d-%02d-%02d %02d:%02d:%02d - %s\n",
            level,
            t->tm_year + 1900, t->tm_mon + 1, t->tm_mday,
            t->tm_hour, t->tm_min, t->tm_sec,
            msg);
    fclose(fp);
}

int main(void) {
    log_write("INFO", "프로그램 시작");
    log_write("WARN", "설정 파일 없음, 기본값 사용");
    log_write("ERROR", "데이터베이스 연결 실패");

    printf("로그가 app.log에 기록되었습니다.\n");
    return 0;
}
```
