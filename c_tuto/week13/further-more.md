# Week 13 더 알아보기 (Further More)

---

## 1. Token Pasting으로 자동 테스트 등록

```c
#define TEST(name) static void test_##name(void)
#define RUN(name) do { printf("  %s...", #name); test_##name(); printf("OK\n"); } while(0)

TEST(add) { assert(1 + 1 == 2); }
TEST(sub) { assert(3 - 1 == 2); }

int main(void) { RUN(add); RUN(sub); }
```

---

## 2. 매크로 위생(Hygiene) 문제

매크로 내부 임시 변수가 외부 이름과 충돌할 수 있다:
```c
#define SWAP(a,b) do { int tmp = a; a = b; b = tmp; } while(0)
int tmp = 10, y = 20;
SWAP(tmp, y);  /* 내부 tmp와 외부 tmp 충돌! */
```

해결: `_`나 `__` 접두사, 또는 `__LINE__`을 이름에 포함.

---

## 3. 생각해볼 질문

- Rust의 매크로는 C와 어떻게 다른가? (hygienic macro)
- #define으로 새로운 문법(DSL)을 만드는 것이 좋은 생각인가?
- 매크로를 전혀 안 쓰고 C를 작성할 수 있을까?
