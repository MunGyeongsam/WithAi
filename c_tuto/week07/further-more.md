# Week 07 더 알아보기 (Further More)

---

## 1. Valgrind로 메모리 누수 검사

```bash
gcc -g example.c -o example
valgrind --leak-check=full ./example
```

Valgrind는 모든 malloc/free를 추적해서 누수를 보고한다.
macOS에서는 AddressSanitizer가 대안:

```bash
gcc -fsanitize=address -g example.c -o example
./example
```

---

## 2. 메모리 풀(Memory Pool) 개념

게임이나 임베디드에서는 malloc/free가 느리거나 파편화(fragmentation)를 일으킨다.
대안: 큰 덩어리를 한번에 할당하고, 그 안에서 직접 관리.

---

## 3. 생각해볼 질문

- 가비지 컬렉터(garbage collector)가 있는 언어(Java, Python)에서는 왜 free가 없는가?
- malloc은 내부적으로 운영체제에 어떻게 메모리를 요청하는가? (brk, mmap)
- 메모리 누수가 1초에 1바이트씩 쌓이면, 프로그램이 며칠 만에 문제를 일으킬까?
