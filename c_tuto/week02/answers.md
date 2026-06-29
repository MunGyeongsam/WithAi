# Week 02 정답과 해설

---

## 문제 1 정답

```c
#include <stdio.h>

int main(void) {
    printf("char      = %zu bytes\n", sizeof(char));
    printf("short     = %zu bytes\n", sizeof(short));
    printf("int       = %zu bytes\n", sizeof(int));
    printf("long      = %zu bytes\n", sizeof(long));
    printf("long long = %zu bytes\n", sizeof(long long));
    printf("float     = %zu bytes\n", sizeof(float));
    printf("double    = %zu bytes\n", sizeof(double));
    printf("unsigned  = %zu bytes\n", sizeof(unsigned int));
    return 0;
}
```

**해설:**
- `%zu`는 `size_t` 타입 전용 서식 지정자이다. `sizeof`의 반환 타입이 `size_t`이므로 이것을 사용한다.
- `%d`를 쓰면 경고가 나올 수 있다 (타입 불일치).
- `unsigned int`의 크기는 `int`와 같다. 부호(sign) 비트를 음수 대신 양수 범위 확장에 쓸 뿐이다.

---

## 문제 2 정답

```c
#include <stdio.h>

int main(void) {
    printf("  C     F\n");
    for (int c = 0; c <= 100; c += 10) {
        double f = c * 9.0 / 5.0 + 32.0;
        printf("%3d %5.1f\n", c, f);
    }
    return 0;
}
```

실행 결과:
```
  C     F
  0  32.0
 10  50.0
 20  68.0
 30  86.0
 40 104.0
 50 122.0
 60 140.0
 70 158.0
 80 176.0
 90 194.0
100 212.0
```

**해설:**
- `%3d`는 최소 3칸 폭으로 정수를 오른쪽 정렬한다.
- `%5.1f`는 최소 5칸 폭, 소수점 1자리로 실수를 출력한다.
- `c * 9.0`에서 int × double → double로 자동 승격된다.
- 만약 `9 / 5`로 썼다면 `1`이 되어 결과가 모두 틀린다!

---

## 문제 3 정답

예측 및 실제 결과:

| 식 | 결과 | 이유 |
|----|------|------|
| `int r1 = 7 / 2` | `3` | 정수÷정수 = 정수, 소수점 버림 |
| `double r2 = 7 / 2` | `3.0` | 7/2=3(정수) 후에야 double로 변환 |
| `double r3 = 7.0 / 2` | `3.5` | 7.0은 double, 2가 승격되어 실수 나눗셈 |
| `double r4 = (double)7 / 2` | `3.5` | 명시적 캐스트로 7→7.0, 실수 나눗셈 |

```c
#include <stdio.h>

int main(void) {
    int    r1 = 7 / 2;
    double r2 = 7 / 2;
    double r3 = 7.0 / 2;
    double r4 = (double)7 / 2;

    printf("r1 = %d\n", r1);
    printf("r2 = %f\n", r2);
    printf("r3 = %f\n", r3);
    printf("r4 = %f\n", r4);
    return 0;
}
```

**r2가 3.5가 아닌 이유**: 나눗셈이 먼저 수행(7/2=3)된 후, 그 결과 3이 double 3.0으로 변환되기 때문.

---

## 문제 4 정답

예측/실제 출력:
```
u - 1 = 4294967295
-1 > 1 ? 1
```

설명:
- `u - 1`: unsigned 0에서 1을 빼면 언더플로우 → `UINT_MAX`(4294967295)로 돌아감 (wrap-around)
- `s > t`: -1(signed)과 1(unsigned) 비교 시, -1이 unsigned로 변환 → 4294967295 > 1 → 참(1)

```c
#include <stdio.h>

int main(void) {
    unsigned int u = 0;
    printf("u - 1 = %u\n", u - 1);
    
    int s = -1;
    unsigned int t = 1;
    printf("-1 > 1 ? %d\n", s > t);
    return 0;
}
```

---

## 문제 5 정답

```c
#include <stdio.h>
#include <limits.h>

int main(void) {
    printf("INT_MAX     = %d\n", INT_MAX);
    printf("INT_MAX + 1 = %d\n", INT_MAX + 1);  /* undefined behavior */

    unsigned int umax = UINT_MAX;
    printf("UINT_MAX     = %u\n", umax);
    printf("UINT_MAX + 1 = %u\n", umax + 1);
    return 0;
}
```

실행 결과 (일반적):
```
INT_MAX     = 2147483647
INT_MAX + 1 = -2147483648
UINT_MAX     = 4294967295
UINT_MAX + 1 = 0
```

**차이점:**
- signed 오버플로우: 미정의 동작(undefined behavior). 결과가 보장되지 않는다.
- unsigned 오버플로우: 정의된 동작. 0으로 되돌아간다(modular arithmetic).
