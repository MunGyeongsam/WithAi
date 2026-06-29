# Week 12 연습문제

---

## 문제 1: Include Guard (난이도: ★☆☆)

point.h 헤더를 작성하시오:
- Point 구조체 (x, y 좌표)
- 거리 계산 함수 선언
- Include guard 포함

---

## 문제 2: DEBUG 매크로 (난이도: ★★☆)

DEBUG가 정의되었을 때만 동작하는 LOG 매크로를 작성하시오.
파일 이름과 줄 번호도 함께 출력할 것.

-DDEBUG 없이 빌드하면 출력이 없어야 한다.

---

## 문제 3: 안전한 MAX/MIN (난이도: ★★☆)

부작용 없는 MAX, MIN 매크로를 작성하고,
다음 테스트가 올바르게 동작함을 확인하시오:

```c
int a = 3, b = 5;
printf("%d\n", MAX(a, b));        /* 5 */
printf("%d\n", MAX(a + 1, b));    /* 5 */
printf("%d\n", MIN(10, 20));      /* 10 */
```

---

## 문제 4: 플랫폼 분기 (난이도: ★★★)

현재 운영체제에 따라 다른 메시지를 출력하는 프로그램을 작성하시오:
- Windows: "Windows detected"
- macOS: "macOS detected"
- Linux: "Linux detected"
- 기타: "Unknown OS"

---

## 문제 5: X-Macro 패턴 (난이도: ★★★)

X-Macro를 사용해 열거형(enum)과 문자열 변환 함수를 동시에 생성하시오:

```c
#define COLORS(X) \
    X(RED)       \
    X(GREEN)     \
    X(BLUE)

/* 이것으로 enum Color와 color_to_string() 모두 생성 */
```
