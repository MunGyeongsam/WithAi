# Week 03 정답과 해설

---

## 문제 1 정답

```c
#include <stdio.h>

int main(void) {
    int score = 85;

    if (score >= 90) {
        printf("학점: A
");
    } else if (score >= 80) {
        printf("학점: B
");
    } else if (score >= 70) {
        printf("학점: C
");
    } else if (score >= 60) {
        printf("학점: D
");
    } else {
        printf("학점: F
");
    }
    return 0;
}
```

**해설:**
- 조건 순서가 중요하다. 큰 값부터 검사해야 올바르게 분류된다.
- 만약 score >= 70을 먼저 검사하면 80점도 C로 분류되는 버그가 생긴다.
- else if 체인에서는 위 조건이 거짓일 때만 아래로 내려온다.

---

## 문제 2 정답

```c
#include <stdio.h>

int main(void) {
    for (int dan = 2; dan <= 9; dan++) {
        printf("=== %d단 ===
", dan);
        for (int i = 1; i <= 9; i++) {
            printf("%d x %d = %d
", dan, i, dan * i);
        }
        printf("
");
    }
    return 0;
}
```

**해설:**
- 이중 for문(nested loop): 바깥은 단, 안쪽은 곱하는 수를 담당한다.
- 안쪽 루프가 9번 끝나면 바깥 루프가 1 증가하고, 안쪽이 다시 1부터 시작한다.

---

## 문제 3 정답

```c
#include <stdio.h>

int is_prime(int n) {
    if (n <= 1) return 0;  /* 1 이하는 소수가 아님 */
    if (n <= 3) return 1;  /* 2, 3은 소수 */

    if (n % 2 == 0) return 0;  /* 짝수는 소수가 아님 */

    for (int i = 3; i * i <= n; i += 2) {
        if (n % i == 0) return 0;
    }
    return 1;
}

int main(void) {
    printf("1~100 사이의 소수:
");
    for (int n = 2; n <= 100; n++) {
        if (is_prime(n)) {
            printf("%d ", n);
        }
    }
    printf("
");
    return 0;
}
```

실행 결과:
```
1~100 사이의 소수:
2 3 5 7 11 13 17 19 23 29 31 37 41 43 47 53 59 61 67 71 73 79 83 89 97
```

**해설:**
- i * i <= n 조건: 제곱근까지만 검사하면 충분하다 (수학적 성질).
- i += 2: 짝수는 이미 제외했으므로 홀수만 검사한다.
- 함수의 반환값을 0/1로 통일하면, if 조건에서 바로 사용할 수 있다.

---

## 문제 4 정답

```c
#include <stdio.h>

void call_counter(void) {
    static int count = 0;  /* 첫 호출 때만 초기화, 이후 값 유지 */
    count++;
    printf("%d번째 호출입니다
", count);
}

int main(void) {
    for (int i = 0; i < 5; i++) {
        call_counter();
    }
    return 0;
}
```

**해설:**
- static 변수는 함수가 끝나도 사라지지 않는다 (프로그램 종료까지 유지).
- 초기화(= 0)는 프로그램 시작 시 딱 한 번만 수행된다.
- static이 없으면 매번 count = 0으로 시작하여 항상 "1번째"가 출력된다.

---

## 문제 5 정답

```c
#include <stdio.h>

void calculate(int a, int b, char op) {
    switch (op) {
    case '+':
        printf("%d + %d = %d
", a, b, a + b);
        break;
    case '-':
        printf("%d - %d = %d
", a, b, a - b);
        break;
    case '*':
        printf("%d * %d = %d
", a, b, a * b);
        break;
    case '/':
        if (b == 0) {
            printf("0으로 나눌 수 없습니다
");
        } else {
            printf("%d / %d = %d
", a, b, a / b);
        }
        break;
    default:
        printf("지원하지 않는 연산자입니다
");
        break;
    }
}

int main(void) {
    calculate(10, 3, '+');
    calculate(10, 3, '-');
    calculate(10, 3, '*');
    calculate(10, 3, '/');
    calculate(10, 0, '/');
    calculate(10, 3, '&');
    return 0;
}
```

실행 결과:
```
10 + 3 = 13
10 - 3 = 7
10 * 3 = 30
10 / 3 = 3
0으로 나눌 수 없습니다
지원하지 않는 연산자입니다
```

**해설:**
- switch는 정수/문자 값의 분기에 적합하다.
- 각 case 끝에 break가 필수! 없으면 아래 case로 계속 실행된다.
- default는 예상치 못한 입력을 처리하는 안전망이다.
- 0으로 나누기(division by zero)는 프로그램을 즉시 종료시킬 수 있으므로, 반드시 사전에 검사한다.
