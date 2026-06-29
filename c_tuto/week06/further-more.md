# Week 06 더 알아보기 (Further More)

---

## 1. cdecl 도구

복잡한 선언을 영어로 번역해주는 온라인 도구:
- https://cdecl.org

입력: `int (*(*fp)(int))[10]`
출력: "declare fp as pointer to function (int) returning pointer to array 10 of int"

---

## 2. 표준 라이브러리의 함수 포인터 사용

- `qsort(base, n, size, compare)` — 범용 정렬
- `bsearch(key, base, n, size, compare)` — 이진 검색
- `atexit(func)` — 프로그램 종료 시 호출할 함수 등록
- `signal(sig, handler)` — 시그널 핸들러 등록

모두 함수 포인터를 매개변수로 받는 콜백 패턴이다.

---

## 3. 생각해볼 질문

- C++의 가상 함수(virtual function)는 내부적으로 함수 포인터 테이블(vtable)이다. 왜 그런 설계를 했을까?
- 함수 포인터로 "다형성(polymorphism)"을 흉내낼 수 있는가?
- typedef 없이 복잡한 선언을 쓸 때의 단점은 무엇인가?
