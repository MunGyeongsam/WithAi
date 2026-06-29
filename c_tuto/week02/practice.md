# Week 02 연습문제

---

## 문제 1: sizeof 탐험 (난이도: ★☆☆)

다음 타입들의 크기를 `sizeof`로 출력하는 프로그램을 작성하시오:
- `char`, `short`, `int`, `long`, `long long`
- `float`, `double`
- `unsigned int`

출력 형식:
```
char      = ? bytes
short     = ? bytes
...
```

---

## 문제 2: 온도 변환기 (난이도: ★☆☆)

섭씨(Celsius) 0도부터 100도까지, 10도 간격으로 화씨(Fahrenheit) 변환표를 출력하시오.

공식: `F = C * 9.0 / 5.0 + 32.0`

출력 예시:
```
  C     F
  0  32.0
 10  50.0
 20  68.0
 ...
100 212.0
```

> 힌트: 정수 나눗셈 함정을 피하려면 `9.0 / 5.0`처럼 실수 리터럴을 사용한다.

---

## 문제 3: 정수 나눗셈 vs 실수 나눗셈 (난이도: ★★☆)

다음 4가지 계산의 결과를 **먼저 종이에 예측**한 뒤, 프로그램으로 확인하시오:

```c
int    r1 = 7 / 2;
double r2 = 7 / 2;
double r3 = 7.0 / 2;
double r4 = (double)7 / 2;
```

제출물:
1. 예측값 4개
2. 실제 출력 결과
3. r2의 결과가 3.5가 아닌 이유를 한 줄로 설명

---

## 문제 4: signed/unsigned 실험 (난이도: ★★☆)

다음 프로그램의 출력을 **먼저 예측**한 뒤 실행하시오:

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

제출물:
1. 예측한 출력 2줄
2. 실제 출력 2줄
3. 왜 그런 결과가 나오는지 각각 한 줄씩 설명

---

## 문제 5: 오버플로우 관찰 (난이도: ★★★)

1. `<limits.h>`에서 `INT_MAX` 값을 출력하시오.
2. `INT_MAX + 1`의 결과를 출력하시오.
3. `UINT_MAX + 1`의 결과를 출력하시오 (unsigned int 사용).
4. signed와 unsigned 오버플로우의 차이를 2줄 이내로 설명하시오.

> 힌트: signed 오버플로우는 undefined behavior, unsigned는 wrap-around (0으로 돌아감)
