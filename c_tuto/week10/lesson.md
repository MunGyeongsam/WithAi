# Week 10 강의: 구조체, 유니온, 비트필드

---

## 왜 구조체(struct)가 필요한가

학생 정보를 관리할 때:
```c
char name1[20]; int age1; double gpa1;
char name2[20]; int age2; double gpa2;
/* 학생이 100명이면? */
```

**구조체 = 서로 다른 타입의 데이터를 하나로 묶는 사용자 정의 타입**

비유: 서류 봉투. 이름표(char[]), 나이(int), 학점(double)을 하나의 봉투에 넣는 것.

---

## 구조체 선언과 사용

```c
#include <stdio.h>

struct Student {
    char name[20];
    int age;
    double gpa;
};

int main(void) {
    struct Student s1 = {"Kim", 22, 3.8};

    printf("이름: %s\n", s1.name);
    printf("나이: %d\n", s1.age);
    printf("학점: %.1f\n", s1.gpa);

    /* 멤버 수정 */
    s1.age = 23;
    return 0;
}
```

---

## typedef와 구조체

```c
typedef struct {
    char name[20];
    int age;
    double gpa;
} Student;

Student s1 = {"Kim", 22, 3.8};  /* struct 키워드 생략 가능 */
```

---

## 구조체 포인터와 -> 연산자

```c
void print_student(const Student *s) {
    printf("%s (%d) GPA=%.1f\n", s->name, s->age, s->gpa);
}
/* s->name 은 (*s).name과 같다 */
```

> **왜 포인터로 넘기는가?**
> 구조체가 크면 복사 비용이 크다. 포인터(8바이트)만 넘기면 효율적.

---

## 구조체 배열

```c
Student class[3] = {
    {"Kim", 22, 3.8},
    {"Lee", 21, 3.5},
    {"Park", 23, 4.0}
};

for (int i = 0; i < 3; i++) {
    print_student(&class[i]);
}
```

---

## 구조체 정렬(alignment)과 패딩(padding)

```c
struct Example {
    char a;     /* 1바이트 */
    /* 패딩 3바이트 (정렬 맞추기 위해) */
    int b;      /* 4바이트 */
    char c;     /* 1바이트 */
    /* 패딩 3바이트 */
};
/* sizeof = 12 (1+3+4+1+3) */
```

CPU는 정렬된 주소에서 데이터를 더 빨리 읽는다.
컴파일러가 자동으로 패딩을 삽입한다.

**멤버 순서를 바꾸면 크기가 달라질 수 있다:**
```c
struct Better {
    int b;      /* 4바이트 */
    char a;     /* 1바이트 */
    char c;     /* 1바이트 */
    /* 패딩 2바이트 */
};
/* sizeof = 8 (4+1+1+2) — 더 작다! */
```

---

## 유니온(union)

**같은 메모리 공간을 여러 타입으로 해석**:

```c
#include <stdio.h>

union IntBytes {
    int value;
    unsigned char bytes[4];
};

int main(void) {
    union IntBytes u;
    u.value = 0x12345678;

    printf("정수: 0x%X\n", u.value);
    printf("바이트: ");
    for (int i = 0; i < 4; i++) {
        printf("%02X ", u.bytes[i]);
    }
    printf("\n");
    return 0;
}
```

리틀 엔디안(little-endian) 시스템에서:
```
정수: 0x12345678
바이트: 78 56 34 12
```

> 유니온의 모든 멤버는 같은 시작 주소를 공유한다.
> 크기 = 가장 큰 멤버의 크기.

---

## 비트필드(bit-field)

비트 단위로 데이터를 묶을 때:

```c
#include <stdio.h>

struct Flags {
    unsigned int visible : 1;   /* 1비트: 0 또는 1 */
    unsigned int enabled : 1;   /* 1비트 */
    unsigned int mode    : 3;   /* 3비트: 0~7 */
    unsigned int level   : 4;   /* 4비트: 0~15 */
};

int main(void) {
    struct Flags f = {1, 1, 5, 12};
    printf("visible=%u enabled=%u mode=%u level=%u\n",
           f.visible, f.enabled, f.mode, f.level);
    printf("sizeof(Flags) = %zu\n", sizeof(struct Flags));
    return 0;
}
```

> ⚠️ 비트필드의 레이아웃은 **컴파일러/플랫폼 의존적**이다.
> 이식성이 필요하면 비트 마스크 연산을 사용한다:
> ```c
> #define VISIBLE_BIT  (1u << 0)
> #define ENABLED_BIT  (1u << 1)
> unsigned int flags = VISIBLE_BIT | ENABLED_BIT;
> ```

---

## Tagged Union 패턴

유니온 + 태그로 "현재 어떤 타입인지" 추적:

```c
typedef enum { SHAPE_CIRCLE, SHAPE_RECT } ShapeType;

typedef struct {
    ShapeType type;
    union {
        struct { double radius; } circle;
        struct { double w, h; } rect;
    };
} Shape;

double area(const Shape *s) {
    switch (s->type) {
    case SHAPE_CIRCLE: return 3.14159 * s->circle.radius * s->circle.radius;
    case SHAPE_RECT:   return s->rect.w * s->rect.h;
    }
    return 0;
}
```

---

## 자주 틀리는 포인트 3가지

1. **구조체 대입 시 깊은 복사 착각**
   ```c
   Student a = {"Kim", 22, 3.8};
   Student b = a;  /* 멤버별 복사 (배열 포함). OK. */
   /* 하지만 멤버가 포인터면? 얕은 복사(shallow copy)! */
   ```

2. **유니온에서 쓴 멤버와 읽는 멤버 불일치**
   ```c
   union { int i; float f; } u;
   u.f = 3.14;
   printf("%d", u.i);  /* type punning — 결과는 정의되지 않을 수 있음 */
   ```

3. **비트필드 주소 접근 불가**
   ```c
   struct Flags f;
   int *p = &f.visible;  /* 오류! 비트필드의 주소를 얻을 수 없다 */
   ```

---

## 이번 주 핵심 요약

| 개념 | 한 줄 요약 |
|------|-----------|
| struct | 서로 다른 타입을 하나로 묶는 사용자 정의 타입 |
| padding | CPU 정렬을 위해 컴파일러가 빈 공간 삽입 |
| union | 같은 메모리를 여러 타입으로 해석 |
| bit-field | 비트 단위 데이터 저장 (이식성 주의) |
| tagged union | 유니온 + 타입 태그로 안전한 다형성 |
