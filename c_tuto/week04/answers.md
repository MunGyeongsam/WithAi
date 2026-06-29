# Week 04 정답과 해설

---

## 문제 1 정답

```c
#include <stdio.h>

int main(void) {
    int scores[] = {85, 90, 78, 92, 88, 76, 95, 80};
    int n = sizeof(scores) / sizeof(scores[0]);

    int sum = 0;
    for (int i = 0; i < n; i++) {
        sum += scores[i];
    }
    printf("합계: %d\n", sum);
    printf("평균: %.1f\n", (double)sum / n);
    return 0;
}
```

**해설:**
- `sizeof(scores) / sizeof(scores[0])`은 배열 원소 개수를 구하는 관용 표현이다.
- 평균 계산 시 `(double)sum / n`으로 캐스트해야 소수점이 나온다.

---

## 문제 2 정답

```c
#include <stdio.h>

void print_reverse(const char s[]) {
    /* 먼저 길이를 구한다 */
    int len = 0;
    while (s[len] != '\0') {
        len++;
    }
    /* 뒤에서부터 출력 */
    for (int i = len - 1; i >= 0; i--) {
        printf("%c", s[i]);
    }
    printf("\n");
}

int main(void) {
    print_reverse("Hello");  /* olleH */
    print_reverse("abc");    /* cba */
    return 0;
}
```

**해설:**
- 길이를 먼저 구한 뒤, 마지막 문자(인덱스 len-1)부터 0까지 역순 출력한다.
- `const`는 "이 함수 안에서 s를 수정하지 않겠다"는 약속이다.

---

## 문제 3 정답

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
    printf("%d\n", my_strlen("Hello"));  /* 5 */
    printf("%d\n", my_strlen(""));       /* 0 */
    printf("%d\n", my_strlen("A"));      /* 1 */
    return 0;
}
```

**해설:**
- 빈 문자열 ""은 첫 문자가 바로 '\0'이므로 while 진입 없이 0 반환.
- 이것이 strlen의 정확한 동작 원리이다.

---

## 문제 4 정답

```c
#include <stdio.h>

int my_strlen(const char s[]) {
    int len = 0;
    while (s[len] != '\0') len++;
    return len;
}

void trim(char s[]) {
    int len = my_strlen(s);

    /* 뒤쪽 공백 제거 */
    while (len > 0 && s[len - 1] == ' ') {
        len--;
    }
    s[len] = '\0';

    /* 앞쪽 공백 제거: 첫 비공백 위치 찾기 */
    int start = 0;
    while (s[start] == ' ') {
        start++;
    }

    /* 앞으로 이동 */
    if (start > 0) {
        int i = 0;
        while (s[start + i] != '\0') {
            s[i] = s[start + i];
            i++;
        }
        s[i] = '\0';
    }
}

int main(void) {
    char s1[] = "  Hello  ";
    char s2[] = "  Hi";
    char s3[] = "World  ";
    char s4[] = "NoSpace";

    trim(s1); printf("[%s]\n", s1);  /* [Hello] */
    trim(s2); printf("[%s]\n", s2);  /* [Hi] */
    trim(s3); printf("[%s]\n", s3);  /* [World] */
    trim(s4); printf("[%s]\n", s4);  /* [NoSpace] */
    return 0;
}
```

**해설:**
- 뒤쪽 제거: 끝에서부터 공백인 동안 len을 줄이고 '\0'을 놓는다.
- 앞쪽 제거: 비공백 시작점을 찾아 문자들을 앞으로 복사한다.
- 원본 배열을 직접 수정하므로 문자열 리터럴이 아닌 char 배열이어야 한다.

---

## 문제 5 정답

```c
#include <stdio.h>

int main(void) {
    char text[] = "Hello World";
    int freq[26] = {0};  /* a~z 빈도, 전부 0으로 초기화 */

    for (int i = 0; text[i] != '\0'; i++) {
        char c = text[i];
        /* 대문자를 소문자로 변환 */
        if (c >= 'A' && c <= 'Z') {
            c = c + ('a' - 'A');
        }
        /* 알파벳이면 빈도 증가 */
        if (c >= 'a' && c <= 'z') {
            freq[c - 'a']++;
        }
    }

    /* 빈도가 0이 아닌 것만 출력 */
    for (int i = 0; i < 26; i++) {
        if (freq[i] > 0) {
            printf("%c: %d\n", 'a' + i, freq[i]);
        }
    }
    return 0;
}
```

실행 결과:
```
d: 1
e: 1
h: 1
l: 3
o: 2
r: 1
w: 1
```

**해설:**
- `c - 'a'`로 문자를 0~25 인덱스로 변환한다 ('a'→0, 'b'→1, ..., 'z'→25).
- 대소문자 통합: 대문자에 32를 더하면 소문자가 된다 (ASCII 특성).
- 공백이나 숫자는 알파벳이 아니므로 무시된다.
