# Week 04 강의: 배열과 문자열

---

## 왜 배열(array)이 필요한가

지금까지는 변수를 하나씩 선언했다:

```c
int score1 = 85;
int score2 = 90;
int score3 = 78;
/* 학생이 100명이면? 변수 100개? */
```

**배열 = 같은 타입의 데이터를 연속으로 묶어 저장하는 공간**

비유: 아파트의 호수. 같은 구조의 방이 연속으로 있고, 번호(인덱스)로 구분한다.

---

## 배열 선언과 초기화

```c
int scores[5];                    /* 선언만 (쓰레기 값) */
int scores[5] = {85, 90, 78, 92, 88};  /* 선언 + 초기화 */
int scores[] = {85, 90, 78, 92, 88};   /* 크기 자동 결정 (5개) */
int scores[5] = {85, 90};         /* 나머지는 0으로 초기화 */
int scores[5] = {0};              /* 전부 0 */
```

### 메모리 배치

| 인덱스 | 0 | 1 | 2 | 3 | 4 |
|--------|---|---|---|---|---|
| 값 | 85 | 90 | 78 | 92 | 88 |
| 주소 | 1000 | 1004 | 1008 | 1012 | 1016 |

> int가 4바이트이므로 주소가 4씩 증가한다.
> **인덱스는 0부터 시작한다!** (C의 가장 중요한 규칙 중 하나)

---

## 배열 접근

```c
#include <stdio.h>

int main(void) {
    int scores[5] = {85, 90, 78, 92, 88};

    /* 읽기 */
    printf("첫 번째 점수: %d\n", scores[0]);
    printf("세 번째 점수: %d\n", scores[2]);

    /* 쓰기 */
    scores[2] = 80;
    printf("수정된 세 번째: %d\n", scores[2]);

    /* 반복문으로 전체 순회 */
    int sum = 0;
    for (int i = 0; i < 5; i++) {
        sum += scores[i];
    }
    printf("합계: %d, 평균: %.1f\n", sum, (double)sum / 5);
    return 0;
}
```

실행 결과:
```
첫 번째 점수: 85
세 번째 점수: 78
수정된 세 번째: 80
합계: 435, 평균: 87.0
```

---

## 배열 경계 초과 (Buffer Overrun)

```c
int arr[3] = {10, 20, 30};
arr[3] = 99;   /* 인덱스 3은 존재하지 않는다! */
arr[-1] = 99;  /* 음수 인덱스도 위험! */
```

> ⚠️ **C는 배열 경계를 검사하지 않는다!**
> 경계 밖에 쓰면 다른 변수나 프로그램 메모리를 파괴한다.
> 이것이 보안 취약점(buffer overflow attack)의 원인이다.

---

## 문자열(string) = 문자 배열 + '\0'

C에는 전용 문자열 타입이 없다. 문자열은 **char 배열의 끝에 \0(null terminator)을 붙인 것**:

```
"Hello" 는 메모리에:
┌───┬───┬───┬───┬───┬────┐
│ H │ e │ l │ l │ o │ \0 │
└───┴───┴───┴───┴───┴────┘
  0   1   2   3   4   5     ← 인덱스
```

> 문자열 "Hello"는 5글자이지만, 배열은 최소 **6칸**이 필요하다 (\0 포함).

---

## 문자열 선언 방법

```c
char s1[] = "Hello";        /* 자동으로 크기 6, \0 포함 */
char s2[10] = "Hello";      /* 크기 10, 나머지 \0으로 채워짐 */
char s3[] = {'H','e','l','l','o','\0'};  /* 명시적 \0 */
/* char s4[] = {'H','e','l','l','o'};  ← \0 없음! 위험! */
```

---

## 문자열 길이 직접 구하기

strlen을 쓰기 전에, 원리를 이해하자:

```c
#include <stdio.h>

int my_strlen(const char s[]) {
    int len = 0;
    while (s[len] != '\0') {
        len++;
    }
    return len;
}

int main(void) {
    char name[] = "Philosophy";
    printf("길이: %d\n", my_strlen(name));  /* 10 */
    return 0;
}
```

**핵심**: \0을 만날 때까지 한 칸씩 전진하며 센다.
만약 \0이 없으면? → 메모리 끝까지 달려가서 프로그램이 죽는다.

---

## 문자열 복사

```c
#include <stdio.h>

void my_strcpy(char dest[], const char src[]) {
    int i = 0;
    while (src[i] != '\0') {
        dest[i] = src[i];
        i++;
    }
    dest[i] = '\0';  /* 반드시 종료 문자 복사! */
}

int main(void) {
    char original[] = "Hello";
    char copy[20];

    my_strcpy(copy, original);
    printf("복사본: %s\n", copy);
    return 0;
}
```

> ⚠️ **dest의 크기가 src보다 작으면?** → 버퍼 오버런!
> 이것이 strcpy가 위험하고, strncpy나 snprintf를 권장하는 이유다.

---

## 문자열 비교

문자열은 `==`로 비교할 수 없다 (주소를 비교하게 됨):

```c
#include <stdio.h>

int my_strcmp(const char a[], const char b[]) {
    int i = 0;
    while (a[i] != '\0' && a[i] == b[i]) {
        i++;
    }
    return a[i] - b[i];  /* 0이면 같음, 양수/음수면 사전순 비교 */
}

int main(void) {
    printf("%d\n", my_strcmp("abc", "abc"));  /* 0: 같다 */
    printf("%d\n", my_strcmp("abc", "abd"));  /* 음수: abc < abd */
    printf("%d\n", my_strcmp("abd", "abc"));  /* 양수: abd > abc */
    return 0;
}
```

---

## 표준 라이브러리 문자열 함수 (string.h)

| 함수 | 기능 | 주의사항 |
|------|------|----------|
| `strlen(s)` | 길이 반환 (\0 미포함) | - |
| `strcpy(dest, src)` | 복사 | dest 크기 보장 필요 |
| `strncpy(dest, src, n)` | 최대 n글자 복사 | \0 보장 안 될 수 있음 |
| `strcmp(a, b)` | 비교 | 0이면 같음 |
| `strcat(dest, src)` | 이어붙이기 | dest 크기 보장 필요 |

> 실전에서는 snprintf를 가장 안전하게 쓸 수 있다.

---

## 2차원 배열

```c
#include <stdio.h>

int main(void) {
    int matrix[2][3] = {
        {1, 2, 3},
        {4, 5, 6}
    };

    for (int row = 0; row < 2; row++) {
        for (int col = 0; col < 3; col++) {
            printf("%d ", matrix[row][col]);
        }
        printf("\n");
    }
    return 0;
}
```

실행 결과:
```
1 2 3
4 5 6
```

---

## 자주 틀리는 포인트 3가지

1. **\0을 잊어버리는 실수**
   ```c
   char s[5] = {'H','e','l','l','o'};  /* \0 없음! */
   printf("%s\n", s);  /* 쓰레기 문자까지 출력될 수 있음 */
   ```

2. **배열 크기 부족**
   ```c
   char name[5] = "Hello";  /* \0 들어갈 자리가 없다! */
   ```

3. **문자열을 ==로 비교**
   ```c
   if (name == "Hello") { }  /* 주소 비교! 항상 거짓! */
   /* strcmp(name, "Hello") == 0 으로 비교해야 한다 */
   ```

---

## 이번 주 핵심 요약

| 개념 | 한 줄 요약 |
|------|-----------|
| 배열 | 같은 타입 데이터의 연속 저장소, 인덱스 0부터 시작 |
| 경계 검사 | C는 하지 않으므로 프로그래머가 직접 확인 |
| 문자열 | char 배열 + \0 종료 문자 |
| \0 | 문자열의 끝을 표시, 빠뜨리면 치명적 버그 |
| 버퍼 오버런 | 배열 크기를 넘겨서 쓰면 보안 취약점 |
