# Week 13 연습문제

---

## 문제 1: ARRAY_SIZE 매크로 (난이도: ★☆☆)

배열 원소 개수를 구하는 ARRAY_SIZE 매크로를 작성하고,
int, double, char 배열에 각각 적용해 출력하시오.

---

## 문제 2: CLAMP 매크로 (난이도: ★★☆)

값을 최소~최대 범위로 제한하는 CLAMP 매크로를 작성하시오:

```c
#define CLAMP(val, lo, hi) /* ??? */

CLAMP(15, 0, 10)  /* 10 */
CLAMP(-5, 0, 10)  /* 0 */
CLAMP(7, 0, 10)   /* 7 */
```

---

## 문제 3: 에러 코드 X-Macro (난이도: ★★☆)

X-Macro로 에러 코드 enum과 문자열 변환 함수를 생성하시오.
에러: SUCCESS, INVALID_ARG, OUT_OF_MEMORY, IO_ERROR

---

## 문제 4: 타입별 출력 _Generic (난이도: ★★★)

_Generic을 사용해 int, double, const char* 각각에 맞는 형식으로 출력하는 PRINT 매크로를 작성하시오.

---

## 문제 5: 조건부 컴파일 실전 (난이도: ★★★)

VERBOSE 레벨(0, 1, 2)에 따라 다른 양의 정보를 출력하는 LOG 시스템을 매크로로 구현하시오:
- 0: 출력 없음
- 1: ERROR만
- 2: ERROR + INFO
