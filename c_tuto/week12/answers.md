# Week 12 정답과 해설

---

## 문제 1 정답

```c
/* point.h */
#ifndef POINT_H
#define POINT_H

typedef struct {
    double x;
    double y;
} Point;

double point_distance(const Point *a, const Point *b);

#endif /* POINT_H */
```

---

## 문제 2 정답

```c
#include <stdio.h>

#ifdef DEBUG
#define LOG(fmt, ...) \
    fprintf(stderr, "[%s:%d] " fmt "\n", __FILE__, __LINE__, ##__VA_ARGS__)
#else
#define LOG(fmt, ...) ((void)0)
#endif

int main(void) {
    int x = 42;
    LOG("프로그램 시작");
    LOG("x = %d", x);
    printf("Hello\n");
    return 0;
}
```

빌드:
```bash
gcc -DDEBUG main.c -o main    # 로그 출력
gcc main.c -o main            # 로그 없음
```

---

## 문제 3 정답

```c
#define MAX(a, b) ((a) > (b) ? (a) : (b))
#define MIN(a, b) ((a) < (b) ? (a) : (b))
```

**한계:** `MAX(i++, j++)`처럼 부작용 있는 인자에는 여전히 위험.
C11에서는 `_Generic`이나 GCC의 `__typeof__` 확장으로 해결 가능:

```c
#define SAFE_MAX(a, b) ({ \
    __typeof__(a) _a = (a); \
    __typeof__(b) _b = (b); \
    _a > _b ? _a : _b; \
})
```

---

## 문제 4 정답

```c
#include <stdio.h>

int main(void) {
#if defined(_WIN32)
    printf("Windows detected\n");
#elif defined(__APPLE__)
    printf("macOS detected\n");
#elif defined(__linux__)
    printf("Linux detected\n");
#else
    printf("Unknown OS\n");
#endif
    return 0;
}
```

---

## 문제 5 정답

```c
#include <stdio.h>

#define COLORS(X) \
    X(RED)        \
    X(GREEN)      \
    X(BLUE)

/* enum 생성 */
#define ENUM_ITEM(name) name,
typedef enum { COLORS(ENUM_ITEM) COLOR_COUNT } Color;

/* 문자열 변환 */
#define STRING_ITEM(name) #name,
static const char *color_names[] = { COLORS(STRING_ITEM) };

const char *color_to_string(Color c) {
    if (c >= 0 && c < COLOR_COUNT) return color_names[c];
    return "UNKNOWN";
}

int main(void) {
    for (Color c = RED; c < COLOR_COUNT; c++) {
        printf("%d: %s\n", c, color_to_string(c));
    }
    return 0;
}
```

실행 결과:
```
0: RED
1: GREEN
2: BLUE
```
