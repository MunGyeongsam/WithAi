# Week 13 정답과 해설

---

## 문제 1 정답

```c
#include <stdio.h>

#define ARRAY_SIZE(arr) (sizeof(arr) / sizeof((arr)[0]))

int main(void) {
    int nums[] = {1, 2, 3, 4, 5};
    double vals[] = {1.1, 2.2, 3.3};
    char str[] = "Hello";

    printf("int 배열: %zu개\n", ARRAY_SIZE(nums));     /* 5 */
    printf("double 배열: %zu개\n", ARRAY_SIZE(vals));   /* 3 */
    printf("char 배열: %zu개\n", ARRAY_SIZE(str));     /* 6 (null 포함) */
    return 0;
}
```

---

## 문제 2 정답

```c
#define CLAMP(val, lo, hi) ((val) < (lo) ? (lo) : ((val) > (hi) ? (hi) : (val)))
```

---

## 문제 3 정답

```c
#include <stdio.h>

#define ERROR_LIST(X)         \
    X(SUCCESS, "성공")        \
    X(INVALID_ARG, "잘못된 인자") \
    X(OUT_OF_MEMORY, "메모리 부족") \
    X(IO_ERROR, "입출력 오류")

#define ENUM_ENTRY(code, desc) code,
typedef enum { ERROR_LIST(ENUM_ENTRY) ERROR_COUNT } ErrCode;

#define STR_ENTRY(code, desc) [code] = desc,
static const char *err_str[] = { ERROR_LIST(STR_ENTRY) };

int main(void) {
    for (int i = 0; i < ERROR_COUNT; i++) {
        printf("%d: %s\n", i, err_str[i]);
    }
    return 0;
}
```

---

## 문제 4 정답

```c
#include <stdio.h>

#define PRINT(x) _Generic((x), \
    int:         printf("%d\n", (x)), \
    double:      printf("%f\n", (x)), \
    const char*: printf("%s\n", (x)), \
    char*:       printf("%s\n", (x))  \
)

int main(void) {
    PRINT(42);
    PRINT(3.14);
    PRINT("hello");
    return 0;
}
```

---

## 문제 5 정답

```c
#include <stdio.h>

#ifndef VERBOSE
#define VERBOSE 0
#endif

#if VERBOSE >= 1
#define LOG_ERROR(fmt, ...) fprintf(stderr, "[ERROR] " fmt "\n", ##__VA_ARGS__)
#else
#define LOG_ERROR(fmt, ...) ((void)0)
#endif

#if VERBOSE >= 2
#define LOG_INFO(fmt, ...) fprintf(stderr, "[INFO] " fmt "\n", ##__VA_ARGS__)
#else
#define LOG_INFO(fmt, ...) ((void)0)
#endif

int main(void) {
    LOG_INFO("프로그램 시작");
    LOG_ERROR("파일을 찾을 수 없습니다");
    LOG_INFO("프로그램 종료");
    return 0;
}
```

빌드: `gcc -DVERBOSE=2 main.c`
