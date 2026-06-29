# Week 09 더 알아보기 (Further More)

---

## 1. UndefinedBehaviorSanitizer (UBSan)

```bash
gcc -fsanitize=undefined -g code.c -o code
```

감지: 정수 오버플로우, 0으로 나누기, NULL 역참조, 배열 경계 초과 등.
ASan과 함께 사용 가능: `-fsanitize=address,undefined`

---

## 2. INT_MIN의 itoa 문제

INT_MIN = -2147483648인데, -(-2147483648)은 int로 표현 불가 (오버플로우).
해결법: unsigned로 변환 후 처리, 또는 특수 케이스로 하드코딩.

---

## 3. 생각해볼 질문

- 왜 표준 C에는 itoa가 없을까? (sprintf로 대체 가능)
- 테스트를 먼저 작성하고 구현하는 방식(TDD)의 장점은?
- memcpy가 restrict를 사용하면 컴파일러가 어떤 최적화를 할 수 있을까?
