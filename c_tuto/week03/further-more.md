# Week 03 더 알아보기 (Further More)

---

## 1. 삼항 연산자 (ternary operator)

if-else를 한 줄로 축약할 수 있다:

```c
int max = (a > b) ? a : b;
/* a > b가 참이면 a, 거짓이면 b */
```

복잡한 경우에는 오히려 가독성이 떨어지므로, 단순한 경우에만 사용한다.

---

## 2. goto문 - 왜 쓰지 않는가

C에는 goto라는 무조건 점프 명령이 있다:

```c
goto cleanup;
/* ... */
cleanup:
    free(ptr);
    return -1;
```

goto를 남용하면 코드 흐름이 꼬여서 이해하기 어려워진다 ("스파게티 코드").
단, 에러 처리에서 자원을 정리할 때는 예외적으로 허용되는 관례가 있다 (리눅스 커널 코딩 스타일).

---

## 3. 재귀 함수 (recursive function) 맛보기

함수가 자기 자신을 호출하는 기법:

```c
#include <stdio.h>

int factorial(int n) {
    if (n <= 1) return 1;        /* 종료 조건(base case) */
    return n * factorial(n - 1); /* 재귀 호출 */
}

int main(void) {
    printf("5! = %d
", factorial(5));  /* 120 */
    return 0;
}
```

재귀는 강력하지만, 종료 조건을 빠뜨리면 무한 루프(스택 오버플로우)가 된다.
자세한 내용은 5~6주차에서 다룬다.

---

## 4. 생각해볼 질문

- for와 while은 사실 서로 변환 가능하다. 그런데 왜 둘 다 존재하는가?
- 함수의 적절한 길이는 몇 줄일까? (힌트: 한 화면에 들어오는 정도)
- 전역 변수를 많이 쓰면 왜 위험한가?
