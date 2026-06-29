# Week 13 강의: 매크로 심화

---

## 왜 매크로 심화가 필요한가

12주차에서 기본 매크로를 배웠다. 이번 주는:
- 함수형 매크로의 **부작용 문제** 해결
- `#`, `##` 연산자 실전 활용
- **X-Macro** 패턴으로 enum/문자열 동기화
- 매크로 vs inline 함수 선택 기준

---

## 가변 인자 매크로 (Variadic macro)

```c
#define LOG(level, fmt, ...) \
    fprintf(stderr, "[%s] " fmt "\n", level, ##__VA_ARGS__)

LOG("INFO", "서버 시작");
LOG("ERROR", "포트 %d 열기 실패", 8080);
```

- `...`은 가변 인자를 받는다.
- `__VA_ARGS__`로 치환된다.
- `##__VA_ARGS__`: 인자가 없을 때 앞의 쉼표를 제거 (GCC 확장).

---

## 매크로의 부작용 문제와 해결

### 문제 상황

```c
#define MAX(a, b) ((a) > (b) ? (a) : (b))

int x = 3, y = 5;
int z = MAX(x++, y++);
/* 전개: ((x++) > (y++) ? (x++) : (y++)) */
/* x나 y가 두 번 증가! undefined behavior */
```

### 해결 1: inline 함수 (C99)

```c
static inline int max_int(int a, int b) {
    return a > b ? a : b;
}
```

- 타입 안전
- 부작용 없음
- 디버거에서 추적 가능

### 해결 2: GCC typeof 확장 (비표준)

```c
#define SAFE_MAX(a, b) ({ \
    __typeof__(a) _a = (a); \
    __typeof__(b) _b = (b); \
    _a > _b ? _a : _b; \
})
```

---

## X-Macro 패턴 상세

### 문제: enum과 문자열을 동기화하기 어렵다

```c
enum Error { ERR_NONE, ERR_FILE, ERR_MEM, ERR_NET };
/* 새 에러를 추가하면 문자열 배열도 동시에 수정해야 한다 → 실수 위험 */
```

### 해결: X-Macro

```c
/* 정의는 한 곳에서만 */
#define ERROR_LIST(X) \
    X(ERR_NONE, "성공")      \
    X(ERR_FILE, "파일 오류") \
    X(ERR_MEM,  "메모리 부족") \
    X(ERR_NET,  "네트워크 오류")

/* enum 생성 */
#define ENUM_ENTRY(code, desc) code,
typedef enum { ERROR_LIST(ENUM_ENTRY) ERROR_COUNT } ErrorCode;

/* 문자열 배열 생성 */
#define STRING_ENTRY(code, desc) desc,
static const char *error_messages[] = { ERROR_LIST(STRING_ENTRY) };

const char *error_str(ErrorCode e) {
    if (e >= 0 && e < ERROR_COUNT) return error_messages[e];
    return "알 수 없는 오류";
}
```

---

## 매크로 vs inline 선택 기준

| 상황 | 선택 | 이유 |
|------|------|------|
| 타입에 무관한 연산 | 매크로 | 제네릭 동작 |
| 타입 안전성 필요 | inline 함수 | 컴파일러 타입 검사 |
| 컴파일 시점 상수 | #define | sizeof, 배열 크기 |
| 디버깅 용이성 | inline 함수 | 스택 추적 가능 |
| 코드 생성 (enum 등) | 매크로 + X-Macro | 반복 제거 |

---

## 실전 매크로 모음

```c
/* 배열 원소 개수 */
#define ARRAY_SIZE(arr) (sizeof(arr) / sizeof((arr)[0]))

/* 구조체 멤버 오프셋 */
#define OFFSETOF(type, member) ((size_t)&((type *)0)->member)

/* 컴파일 시점 검증 */
#define STATIC_ASSERT(cond, msg) \
    typedef char static_assert_##msg[(cond) ? 1 : -1]

/* 미사용 매개변수 경고 억제 */
#define UNUSED(x) ((void)(x))
```

---

## _Generic (C11): 타입 기반 분기

```c
#include <stdio.h>

#define print_val(x) _Generic((x), \
    int:    printf("%d\n", (x)),    \
    double: printf("%f\n", (x)),    \
    char*:  printf("%s\n", (x))     \
)

int main(void) {
    print_val(42);       /* %d */
    print_val(3.14);     /* %f */
    print_val("hello");  /* %s */
    return 0;
}
```

---

## 자주 틀리는 포인트 3가지

1. **다중 줄 매크로에서 \ 뒤에 공백**
   - `\` 뒤에 보이지 않는 공백이 있으면 줄 연결이 끊어진다.

2. **매크로 이름에 소문자 사용**
   - 관례: 매크로는 ALL_CAPS. 소문자면 함수로 오해.

3. **do-while(0) 패턴 생략**
   ```c
   #define SWAP(a,b) { int t=a; a=b; b=t; }
   if (cond) SWAP(x, y); else foo();  /* 문법 오류! */
   /* do-while(0)으로 감싸야 안전 */
   ```

---

## 이번 주 핵심 요약

| 개념 | 한 줄 요약 |
|------|-----------|
| 가변 인자 매크로 | ...와 __VA_ARGS__로 printf 스타일 매크로 |
| 부작용 문제 | 매크로 인자가 여러 번 평가됨 → inline 또는 임시 변수 |
| X-Macro | 한 곳의 정의에서 enum+문자열 동시 생성 |
| _Generic | C11의 타입 기반 컴파일 시점 분기 |
