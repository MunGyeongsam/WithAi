# Week 10 더 알아보기 (Further More)

---

## 1. Flexible Array Member (C99)

구조체의 마지막 멤버를 크기 0인 배열로 선언:

```c
typedef struct {
    int length;
    char data[];  /* flexible array member */
} Buffer;

Buffer *buf = malloc(sizeof(Buffer) + 100);
buf->length = 100;
```

---

## 2. packed 구조체

패딩을 제거하고 싶을 때 (네트워크 패킷, 파일 형식):

```c
struct __attribute__((packed)) Header {
    char type;
    int length;
};
/* sizeof = 5 (패딩 없음, 정렬 보장 안 됨) */
```

> ⚠️ 비정렬 접근은 일부 CPU에서 성능 저하 또는 오류를 일으킨다.

---

## 3. 생각해볼 질문

- 구조체가 C++의 클래스와 다른 점은? (힌트: 함수 멤버, 접근 제어)
- 유니온으로 type punning을 하는 것은 표준에서 허용되는가?
- 비트필드 대신 비트 마스크를 쓰는 실전적 이유는?
