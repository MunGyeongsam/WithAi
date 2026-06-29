# Week 07 정답과 해설

---

## 문제 1 정답

```c
#include <stdio.h>
#include <stdlib.h>

int main(void) {
    int n;
    printf("정수 개수: ");
    scanf("%d", &n);

    int *arr = (int *)malloc(n * sizeof(int));
    if (arr == NULL) {
        printf("할당 실패\n");
        return 1;
    }

    for (int i = 0; i < n; i++) {
        arr[i] = i + 1;
    }
    for (int i = 0; i < n; i++) {
        printf("%d ", arr[i]);
    }
    printf("\n");

    free(arr);
    return 0;
}
```

---

## 문제 2 정답

```c
#include <stdio.h>
#include <stdlib.h>

int my_strlen(const char *s) {
    int len = 0;
    while (s[len] != '\0') len++;
    return len;
}

char *my_strdup(const char *s) {
    int len = my_strlen(s);
    char *copy = (char *)malloc((len + 1) * sizeof(char));
    if (copy == NULL) return NULL;

    for (int i = 0; i <= len; i++) {  /* <= 로 '\0'까지 복사 */
        copy[i] = s[i];
    }
    return copy;
}

int main(void) {
    char *s = my_strdup("Philosophy");
    if (s != NULL) {
        printf("%s\n", s);
        free(s);
    }
    return 0;
}
```

**해설:** len + 1로 할당해야 '\0'까지 들어간다. 호출자가 free 책임.

---

## 문제 3 정답

```c
#include <stdio.h>
#include <stdlib.h>

int main(void) {
    int capacity = 4;
    int size = 0;
    int *arr = (int *)malloc(capacity * sizeof(int));
    if (arr == NULL) return 1;

    for (int i = 0; i < 20; i++) {
        if (size >= capacity) {
            capacity *= 2;
            int *tmp = (int *)realloc(arr, capacity * sizeof(int));
            if (tmp == NULL) { free(arr); return 1; }
            arr = tmp;
            printf("확장: capacity = %d\n", capacity);
        }
        arr[size++] = i;
    }

    printf("데이터: ");
    for (int i = 0; i < size; i++) printf("%d ", arr[i]);
    printf("\n");

    free(arr);
    return 0;
}
```

---

## 문제 4 정답

```c
#include <stdio.h>
#include <stdlib.h>

int main(void) {
    int rows = 3, cols = 4;

    /* 행 포인터 배열 할당 */
    int **matrix = (int **)malloc(rows * sizeof(int *));
    if (matrix == NULL) return 1;

    /* 각 행 할당 */
    for (int r = 0; r < rows; r++) {
        matrix[r] = (int *)malloc(cols * sizeof(int));
        if (matrix[r] == NULL) return 1;
    }

    /* 값 채우기 */
    for (int r = 0; r < rows; r++) {
        for (int c = 0; c < cols; c++) {
            matrix[r][c] = r * 10 + c;
        }
    }

    /* 출력 */
    for (int r = 0; r < rows; r++) {
        for (int c = 0; c < cols; c++) {
            printf("%3d ", matrix[r][c]);
        }
        printf("\n");
    }

    /* 해제: 각 행 먼저, 그 다음 행 포인터 배열 */
    for (int r = 0; r < rows; r++) {
        free(matrix[r]);
    }
    free(matrix);
    return 0;
}
```

**해설:** 해제 순서가 중요! 먼저 각 행을 해제하고, 마지막에 행 포인터 배열을 해제.

---

## 문제 5 정답

버그:
1. `g1 = g2;` → g1이 가리키던 메모리의 주소를 잃음 (메모리 누수)
2. `free(g2);` → g1 == g2이므로 같은 메모리를 두 번 해제 (double free)
3. `malloc(50)` → name이 45자 이상이면 버퍼 오버플로우

수정:
```c
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

char *make_greeting(const char *name) {
    size_t needed = strlen("Hello, !") + strlen(name) + 1;
    char *buf = (char *)malloc(needed);
    if (buf == NULL) return NULL;
    sprintf(buf, "Hello, %s!", name);
    return buf;
}

int main(void) {
    char *g1 = make_greeting("Alice");
    char *g2 = make_greeting("Bob");

    printf("%s\n", g1);
    printf("%s\n", g2);

    free(g1);  /* 각각 해제 */
    free(g2);
    return 0;
}
```
