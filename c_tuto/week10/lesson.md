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

## 바이트 순서: Little-Endian vs Big-Endian

### 왜 알아야 하는가

위 유니온 예제에서 `0x12345678`을 저장했는데, 바이트 배열로 읽으면 `78 56 34 12`로 **거꾸로** 나왔다. 이것이 바로 **엔디안(endianness)** 문제다.

네트워크 통신, 파일 포맷 파싱, 하드웨어 레지스터 접근 등에서 엔디안을 모르면 데이터가 깨진다.

### 개념

4바이트 정수 `0x12345678`을 메모리에 저장할 때:

```
                주소:  [0x00] [0x01] [0x02] [0x03]
                        낮음 ──────────────→ 높음

Big-Endian:            12     34     56     78
(큰 쪽이 앞)           MSB ─────────────→ LSB

Little-Endian:         78     56     34     12
(작은 쪽이 앞)         LSB ─────────────→ MSB
```

| 용어 | 의미 |
|------|------|
| MSB (Most Significant Byte) | 가장 큰 자릿수 바이트 (0x12) |
| LSB (Least Significant Byte) | 가장 작은 자릿수 바이트 (0x78) |
| Big-Endian | MSB를 낮은 주소에 먼저 저장 |
| Little-Endian | LSB를 낮은 주소에 먼저 저장 |

> **이름의 유래**: 걸리버 여행기에서 달걀을 큰 쪽(big end)부터 깨는 파벌과 작은 쪽(little end)부터 깨는 파벌의 논쟁에서 따온 이름이다.

### 누가 어떤 방식을 쓰는가

| 방식 | 대표 플랫폼 |
|------|-------------|
| Little-Endian | x86, x86-64 (Intel/AMD), ARM (기본 모드), RISC-V |
| Big-Endian | 네트워크 프로토콜(TCP/IP), Java 바이트코드, 일부 MIPS, PowerPC |
| Bi-Endian | ARM (전환 가능), MIPS (설정 가능) |

> **현실**: 여러분이 사용하는 PC/Mac/스마트폰은 거의 100% **리틀 엔디안**이다.
> 하지만 네트워크로 데이터를 보내면 **빅 엔디안(네트워크 바이트 순서)**으로 변환해야 한다.

### 유니온으로 엔디안 확인하기

```c
#include <stdio.h>

int main(void) {
    union {
        int value;
        unsigned char bytes[sizeof(int)];
    } test;

    test.value = 1;  /* 0x00000001 */

    if (test.bytes[0] == 1) {
        printf("이 시스템은 Little-Endian\n");
        printf("메모리: [01] [00] [00] [00]\n");
    } else {
        printf("이 시스템은 Big-Endian\n");
        printf("메모리: [00] [00] [00] [01]\n");
    }
    return 0;
}
```

### 2바이트(short)로 보는 직관적 예시

숫자 `0x0102` (십진수 258)를 `short`(2바이트)로 저장:

```
Big-Endian:      [01] [02]   ← 사람이 읽는 순서와 같음
Little-Endian:   [02] [01]   ← 뒤집혀 있음
```

### 왜 Little-Endian이 유리한 경우가 있나

```c
int x = 5;
/* Little-Endian 메모리: [05] [00] [00] [00] */
```

- `int*`를 `char*`로 캐스팅해도 **같은 주소에서 값 5**를 읽을 수 있다
- 크기를 확장(1→2→4바이트)할 때 **시작 주소가 변하지 않는다**
- 하드웨어 산술 연산이 LSB부터 처리하므로 자연스럽다

### 네트워크 바이트 순서 변환

네트워크 통신 시 표준은 **Big-Endian**(네트워크 바이트 순서)이다. C 표준 라이브러리(`<arpa/inet.h>` 또는 Windows `<winsock2.h>`)가 변환 함수를 제공:

```c
#include <arpa/inet.h>  /* POSIX */

uint16_t port = 8080;
uint16_t net_port = htons(port);  /* Host to Network Short */
uint32_t addr = 0xC0A80001;       /* 192.168.0.1 */
uint32_t net_addr = htonl(addr);  /* Host to Network Long */

/* 받을 때는 반대 */
uint16_t host_port = ntohs(net_port);  /* Network to Host Short */
uint32_t host_addr = ntohl(net_addr);  /* Network to Host Long */
```

| 함수 | 역할 |
|------|------|
| `htons` | Host → Network (16비트) |
| `htonl` | Host → Network (32비트) |
| `ntohs` | Network → Host (16비트) |
| `ntohl` | Network → Host (32비트) |

### 파일 포맷에서의 엔디안

실제 파일 포맷 예시:

| 포맷 | 엔디안 |
|------|--------|
| BMP 이미지 | Little-Endian |
| PNG 이미지 | Big-Endian |
| WAV 오디오 | Little-Endian |
| MIDI | Big-Endian |
| PE (Windows EXE) | Little-Endian |
| ELF (Linux 실행파일) | 플랫폼 의존 (헤더에 명시) |

> ⚠️ **바이너리 파일을 읽을 때**: `fread`로 멀티바이트 값을 읽으면, 파일의 엔디안과 시스템의 엔디안이 다를 수 있다. 반드시 포맷 스펙을 확인하고 필요시 변환한다.

### 엔디안 안전한 직렬화 패턴

```c
#include <stdint.h>

/* 바이트 배열로 Big-Endian 기록 (이식 가능) */
void write_u32_be(unsigned char *buf, uint32_t val) {
    buf[0] = (val >> 24) & 0xFF;
    buf[1] = (val >> 16) & 0xFF;
    buf[2] = (val >>  8) & 0xFF;
    buf[3] = (val >>  0) & 0xFF;
}

/* 바이트 배열에서 Big-Endian 읽기 */
uint32_t read_u32_be(const unsigned char *buf) {
    return ((uint32_t)buf[0] << 24)
         | ((uint32_t)buf[1] << 16)
         | ((uint32_t)buf[2] <<  8)
         | ((uint32_t)buf[3] <<  0);
}
```

이 방식은 시스템 엔디안에 **상관없이** 동일하게 동작한다.

### 흔한 실수

```c
/* ❌ 위험: 엔디안에 따라 결과가 달라짐 */
uint32_t value;
fread(&value, 4, 1, file);  /* 파일이 Big-Endian이면? */

/* ✅ 안전: 바이트 단위로 읽고 조립 */
unsigned char buf[4];
fread(buf, 1, 4, file);
uint32_t value = read_u32_be(buf);
```

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

## 비트필드 + 엔디안: 왜 조합하면 어려운가

### 핵심 문제

비트필드는 두 가지 **구현 정의(implementation-defined)** 요소가 겹친다:

1. **엔디안**: 바이트가 메모리에 배치되는 순서
2. **비트 순서(bit order)**: 한 바이트(또는 워드) 안에서 비트필드가 MSB부터 채워지는지 LSB부터 채워지는지

C 표준(C11 §6.7.2.1)은 다음을 **규정하지 않는다**:
- 비트필드가 할당 단위 내에서 높은 비트부터 채워지는지 낮은 비트부터 채워지는지
- 할당 단위가 바이트 경계를 넘을 때의 배치

따라서 **같은 구조체 정의가 플랫폼마다 완전히 다른 메모리 레이아웃을 가질 수 있다**.

### 구체적 예시: 네트워크 패킷 헤더

IPv4 헤더의 처음 1바이트를 비트필드로 정의한다고 가정:

```c
/* RFC 791: Version(4비트) + IHL(4비트) */
struct IPv4_Byte0 {
    unsigned int version : 4;
    unsigned int ihl     : 4;
};
```

실제 네트워크 패킷의 첫 바이트가 `0x45` (Version=4, IHL=5)일 때:

```
비트:  0100  0101
       ^^^^  ^^^^
       ver=4 ihl=5

바이트 값: 0x45
```

**Big-Endian + MSB-first 컴파일러** (예: GCC on PowerPC):
```
비트 7 6 5 4 3 2 1 0
     [version ] [ihl    ]
      0 1 0 0   0 1 0 1
→ version=4, ihl=5  ✅ 의도대로
```

**Little-Endian + LSB-first 컴파일러** (예: GCC on x86):
```
비트 7 6 5 4 3 2 1 0
     [ihl    ] [version ]
      0 1 0 0   0 1 0 1
→ ihl=4?? version=5??  ❌ 뒤바뀜!
```

### 실제 리눅스 커널의 해결책

리눅스 `<linux/ip.h>`에서 IPv4 헤더를 정의하는 방법:

```c
struct iphdr {
#if defined(__LITTLE_ENDIAN_BITFIELD)
    __u8 ihl:4,
         version:4;          /* 순서를 뒤집는다! */
#elif defined(__BIG_ENDIAN_BITFIELD)
    __u8 version:4,
         ihl:4;              /* RFC 순서 그대로 */
#else
#error "Please fix <asm/byteorder.h>"
#endif
    __u8  tos;
    __be16 tot_len;
    /* ... */
};
```

> **핵심**: 리틀 엔디안 시스템에서는 비트필드 선언 순서를 **뒤집어야** 네트워크에서 온 바이트와 올바르게 매핑된다.

### 왜 이런 일이 벌어지는가 — 단계별 도해

8비트 값 `0xA5` (`1010 0101`)를 비트필드로 읽는 경우:

```c
struct TwoParts {
    unsigned char high : 4;  /* 상위 4비트를 의도 */
    unsigned char low  : 4;  /* 하위 4비트를 의도 */
};
```

**GCC x86 (Little-Endian, LSB-first)**:
```
메모리 바이트: 0xA5 = 1010 0101

비트필드 할당: LSB부터 채움
  high → 비트 [3:0] = 0101 = 5
  low  → 비트 [7:4] = 1010 = 10 (0xA)

결과: high=5, low=0xA  ← "high"라는 이름과 반대!
```

**GCC PowerPC (Big-Endian, MSB-first)**:
```
메모리 바이트: 0xA5 = 1010 0101

비트필드 할당: MSB부터 채움
  high → 비트 [7:4] = 1010 = 10 (0xA)
  low  → 비트 [3:0] = 0101 = 5

결과: high=0xA, low=5  ← 이름과 일치
```

### 검증 코드

```c
#include <stdio.h>
#include <string.h>

struct TwoParts {
    unsigned char high : 4;
    unsigned char low  : 4;
};

int main(void) {
    struct TwoParts tp;
    unsigned char byte = 0xA5;

    memcpy(&tp, &byte, 1);

    printf("바이트: 0x%02X\n", byte);
    printf("high = 0x%X (기대: 0xA)\n", tp.high);
    printf("low  = 0x%X (기대: 0x5)\n", tp.low);

    if (tp.high == 0x5) {
        printf("\n→ 이 시스템은 LSB-first 비트필드 (Little-Endian 전형)\n");
        printf("  비트필드 순서가 직관과 반대!\n");
    } else {
        printf("\n→ 이 시스템은 MSB-first 비트필드 (Big-Endian 전형)\n");
    }
    return 0;
}
```

x86에서 실행 결과:
```
바이트: 0xA5
high = 0x5 (기대: 0xA)
low  = 0xA (기대: 0x5)

→ 이 시스템은 LSB-first 비트필드 (Little-Endian 전형)
  비트필드 순서가 직관과 반대!
```

### 실전 규칙: 비트필드를 안전하게 쓰려면

| 상황 | 권장 방법 |
|------|-----------|
| 하드웨어 레지스터 매핑 | `#if`로 엔디안별 순서 분기 |
| 네트워크 패킷 파싱 | 비트필드 대신 **비트 마스크 + 시프트** 사용 |
| 파일 포맷 읽기/쓰기 | 비트필드 대신 **바이트 단위** 처리 |
| 프로그램 내부 플래그 | 비트필드 OK (외부 교환 안 하므로) |

### 이식 가능한 대안: 비트 마스크 + 시프트

```c
#include <stdint.h>

/* IPv4 첫 바이트에서 version과 ihl 추출 */
uint8_t raw_byte = 0x45;

uint8_t version = (raw_byte >> 4) & 0x0F;  /* 상위 4비트 */
uint8_t ihl     = (raw_byte >> 0) & 0x0F;  /* 하위 4비트 */

printf("version=%u, ihl=%u\n", version, ihl);
/* 어떤 플랫폼이든 항상: version=4, ihl=5 */
```

이 코드는:
- 엔디안에 무관하게 동일 결과
- 컴파일러 비트 배치에 무관
- 모든 플랫폼에서 **동일한 의미**

### 2바이트 이상 비트필드의 추가 복잡성

```c
struct CrossByte {
    unsigned int a : 6;   /* 6비트 */
    unsigned int b : 6;   /* 6비트 — 바이트 경계를 넘을 수 있다! */
    unsigned int c : 4;   /* 4비트 */
};
```

이 경우 `b`가 첫 번째 바이트의 끝과 두 번째 바이트의 시작에 걸칠 수 있다.
**엔디안에 따라 어떤 바이트의 어떤 비트에 `b`가 위치하는지 완전히 달라진다.**

> **결론**: 비트필드가 바이트 경계를 넘는 순간, 이식성은 사실상 없다고 봐야 한다.

### 최종 정리표

| 계층 | 표준이 규정하는가 | 결과 |
|------|-------------------|------|
| 바이트 순서 (엔디안) | ❌ 플랫폼 의존 | `int`의 바이트 배치가 다름 |
| 비트필드 할당 방향 | ❌ 구현 정의 | 같은 선언이 다른 비트 위치 |
| 비트필드 + 엔디안 | ❌ 이중 불확정 | 외부 데이터와 매핑 시 반드시 분기 또는 마스크 사용 |
| 비트 마스크/시프트 | ✅ 표준 보장 | 어디서든 같은 결과 |

> **한 줄 요약**: 비트필드는 "프로그램 내부에서만" 안전하다. 외부 세계(네트워크, 파일, 하드웨어)와 비트 단위로 대화할 때는 **시프트 + 마스크**를 쓴다.

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
