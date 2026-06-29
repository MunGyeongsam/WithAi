# Week 11 강의: 파일 입출력과 오류 처리

---

## 왜 파일 I/O가 필요한가

지금까지 프로그램은 실행이 끝나면 모든 데이터가 사라졌다.
**파일 입출력** = 데이터를 디스크에 저장하고 다시 읽어오는 기술.

비유: 칠판(메모리)에 쓴 내용은 지우면 사라지지만,
노트(파일)에 적으면 영구 보존된다.

---

## FILE 포인터와 fopen

```c
#include <stdio.h>

int main(void) {
    FILE *fp = fopen("data.txt", "w");  /* 쓰기 모드로 열기 */
    if (fp == NULL) {
        perror("fopen");  /* 실패 이유 출력 */
        return 1;
    }

    fprintf(fp, "Hello, File!\n");
    fprintf(fp, "숫자: %d\n", 42);

    fclose(fp);  /* 반드시 닫기! */
    return 0;
}
```

### 파일 열기 모드

| 모드 | 의미 | 파일 없으면 |
|------|------|------------|
| "r" | 읽기 | 실패 (NULL) |
| "w" | 쓰기 (기존 내용 삭제) | 새로 생성 |
| "a" | 추가 (끝에 이어쓰기) | 새로 생성 |
| "r+" | 읽기+쓰기 | 실패 |
| "w+" | 읽기+쓰기 (삭제 후 생성) | 새로 생성 |

---

## 파일 읽기

### 한 줄씩 읽기: fgets

```c
#include <stdio.h>

int main(void) {
    FILE *fp = fopen("data.txt", "r");
    if (fp == NULL) { perror("fopen"); return 1; }

    char line[256];
    while (fgets(line, sizeof(line), fp) != NULL) {
        printf("읽음: %s", line);  /* fgets는 \n을 포함 */
    }

    fclose(fp);
    return 0;
}
```

### 서식으로 읽기: fscanf

```c
int age;
char name[50];
fscanf(fp, "%s %d", name, &age);
```

> ⚠️ fscanf는 공백/줄바꿈 처리가 까다롭다. fgets + sscanf 조합을 권장.

---

## 바이너리 파일 읽기/쓰기

```c
/* 쓰기 */
FILE *fp = fopen("data.bin", "wb");
int nums[] = {1, 2, 3, 4, 5};
fwrite(nums, sizeof(int), 5, fp);
fclose(fp);

/* 읽기 */
fp = fopen("data.bin", "rb");
int buf[5];
fread(buf, sizeof(int), 5, fp);
fclose(fp);
```

---

## 오류 처리 패턴

### 원칙: 실패할 수 있는 모든 함수의 반환값을 검사한다

```c
FILE *fp = fopen(filename, "r");
if (fp == NULL) {
    perror("fopen");  /* "fopen: No such file or directory" 형태로 출력 */
    return -1;
}
```

### errno와 perror

- `errno`: 마지막 오류 번호를 저장하는 전역 변수
- `perror(msg)`: msg + ": " + errno에 해당하는 설명을 출력
- `strerror(errno)`: errno를 문자열로 변환

```c
#include <stdio.h>
#include <errno.h>
#include <string.h>

FILE *fp = fopen("없는파일.txt", "r");
if (fp == NULL) {
    printf("에러 번호: %d\n", errno);
    printf("에러 설명: %s\n", strerror(errno));
}
```

---

## 자원 해제 보장: goto cleanup 패턴

여러 자원을 열었을 때, 중간에 실패하면 이미 열린 것들을 정리해야 한다:

```c
int process_files(const char *in_path, const char *out_path) {
    FILE *fin = NULL;
    FILE *fout = NULL;
    int ret = -1;

    fin = fopen(in_path, "r");
    if (fin == NULL) { perror("input"); goto cleanup; }

    fout = fopen(out_path, "w");
    if (fout == NULL) { perror("output"); goto cleanup; }

    /* 작업 수행 */
    char line[256];
    while (fgets(line, sizeof(line), fin)) {
        fputs(line, fout);
    }
    ret = 0;  /* 성공 */

cleanup:
    if (fout) fclose(fout);
    if (fin)  fclose(fin);
    return ret;
}
```

> 이 패턴은 리눅스 커널에서 널리 사용된다. goto를 구조화된 정리에만 사용하면 안전하다.

---

## 줄 수 세기 (실용 예제)

```c
#include <stdio.h>

int count_lines(const char *filename) {
    FILE *fp = fopen(filename, "r");
    if (fp == NULL) return -1;

    int count = 0;
    int ch;
    while ((ch = fgetc(fp)) != EOF) {
        if (ch == '\n') count++;
    }

    fclose(fp);
    return count;
}

int main(int argc, char *argv[]) {
    if (argc < 2) {
        printf("사용법: %s <파일>\n", argv[0]);
        return 1;
    }
    int lines = count_lines(argv[1]);
    if (lines < 0) { perror("count_lines"); return 1; }
    printf("%d lines\n", lines);
    return 0;
}
```

---

## 자주 틀리는 포인트 3가지

1. **fclose를 빠뜨림**
   - 파일 핸들 누수. 운영체제가 허용하는 열린 파일 수에 한계가 있다.
   - 쓰기 모드에서 fclose 없으면 데이터가 디스크에 안 쓰일 수 있다(버퍼링).

2. **fgets의 \n을 고려하지 않음**
   - fgets는 줄바꿈도 버퍼에 포함한다. 필요하면 제거해야 한다:
   ```c
   line[strcspn(line, "\n")] = '\0';
   ```

3. **"w" 모드로 의도치 않게 기존 파일 삭제**
   - "w"는 기존 내용을 완전히 지운다. 추가하려면 "a" 사용.

---

## 이번 주 핵심 요약

| 개념 | 한 줄 요약 |
|------|-----------|
| fopen/fclose | 파일 열기/닫기. NULL 검사 필수 |
| fgets | 한 줄 읽기 (안전, 크기 제한) |
| fprintf | 서식 있는 파일 쓰기 |
| fread/fwrite | 바이너리 블록 단위 읽기/쓰기 |
| perror | 오류 원인을 사람이 읽을 수 있게 출력 |
| goto cleanup | 여러 자원의 안전한 정리 패턴 |
