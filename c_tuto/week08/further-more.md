# Week 08 더 알아보기 (Further More)

---

## 1. 성능 관점: 단순 루프 vs 최적화

실제 libc의 strlen, memcpy는 단순 바이트 루프가 아니다:
- 워드(word) 단위(4/8바이트)로 처리
- SIMD 명령어 활용 (SSE, AVX)
- 분기 예측 최적화

우리의 구현은 "정확성"이 목표. 성능은 나중에 프로파일링 후 개선.

---

## 2. restrict 키워드 (C99)

```c
void *memcpy(void *restrict dest, const void *restrict src, size_t n);
```

`restrict`는 "dest와 src가 겹치지 않음을 보장"하는 약속.
컴파일러가 더 공격적으로 최적화할 수 있게 해준다.

---

## 3. 생각해볼 질문

- my_strlen을 재귀로 구현할 수 있을까? 성능은?
- snprintf는 왜 sprintf보다 안전한가?
- 표준 라이브러리가 없는 환경(베어메탈, BIOS)에서 코딩하면 어떤 함수부터 만들어야 할까?
