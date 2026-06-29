# Week 07 강의: 동적 메모리 할당

---

## 왜 동적 메모리가 필요한가

지금까지 배열 크기를 컴파일 시점에 정했다:
```c
int scores[100];  /* 학생이 200명이면? 50명이면 낭비? */
```

**동적 메모리 할당** = 실행 중에 필요한 만큼만 메모리를 확보하고, 끝나면 돌려준다.

비유: 고정된 방(배열)이 아니라, 필요할 때 호텔 방을 예약(malloc)하고 떠날 때 체크아웃(free)하는 것.

---

## 메모리 영역 구조

프로그램의 메모리는 크게 4영역으로 나뉜다:

```
┌────────────────┐ 높은 주소
│   스택(Stack)   │ ← 지역 변수, 함수 호출 정보
├────────────────┤
│   힙(Heap)     │ ← malloc으로 할당하는 영역
├────────────────┤
│   데이터(Data)  │ ← 전역/static 변수
├────────────────┤
│   코드(Text)   │ ← 프로그램 명령어
└────────────────┘ 낮은 주소
```

- **스택**: 자동 관리. 함수 끝나면 자동 해제.
- **힙**: 수동 관리. 프로그래머가 할당/해제 책임.

---

## malloc, free 기본

```c
#include <stdio.h>
#include <stdlib.h>

int main(void) {
    int n = 5;

    /* 힙에 int 5개 공간 할당 */
    int *arr = (int *)malloc(n * sizeof(int));
    if (arr == NULL) {
        printf("메모리 할당 실패!\n");
        return 1;
    }

    /* 배열처럼 사용 */
    for (int i = 0; i < n; i++) {
        arr[i] = (i + 1) * 10;
    }
    for (int i = 0; i < n; i++) {
        printf("%d ", arr[i]);
    }
    printf("\n");

    /* 사용 끝나면 반드시 해제 */
    free(arr);
    arr = NULL;  /* 해제 후 NULL로 설정 (안전 습관) */
    return 0;
}
```

실행 결과: `10 20 30 40 50`

---

## malloc / calloc / realloc 비교

| 함수 | 용도 | 초기화 |
|------|------|--------|
| `malloc(size)` | size 바이트 할당 | 초기화 안 됨 (쓰레기 값) |
| `calloc(n, size)` | n * size 바이트 할당 | 0으로 초기화 |
| `realloc(ptr, new_size)` | 기존 블록 크기 변경 | 기존 데이터 보존 |

```c
/* calloc: 0으로 초기화된 메모리 */
int *arr = (int *)calloc(10, sizeof(int));

/* realloc: 크기 확장 (기존 데이터 유지) */
arr = (int *)realloc(arr, 20 * sizeof(int));
```

> ⚠️ realloc이 실패하면 NULL을 반환한다. 원래 포인터를 잃지 않도록 주의:
> ```c
> int *tmp = realloc(arr, new_size);
> if (tmp == NULL) { /* 실패 처리 */ }
> else { arr = tmp; }
> ```

---

## 메모리 누수(Memory Leak)

malloc으로 할당한 뒤 free하지 않으면 → **메모리 누수**

```c
void leak_example(void) {
    int *p = (int *)malloc(100 * sizeof(int));
    /* free(p); ← 이걸 빠뜨리면 누수! */
}  /* 함수 끝나면 p(주소)는 사라지지만, 힙 메모리는 그대로 남음 */
```

비유: 호텔 방 열쇠를 잃어버린 것. 방은 여전히 점유 중이지만 찾을 수 없다.

---

## 해제 후 사용(Use-After-Free)

```c
int *p = (int *)malloc(sizeof(int));
*p = 42;
free(p);
printf("%d\n", *p);  /* undefined behavior! 프로그램 죽을 수 있음 */
```

**해결: free 후 즉시 NULL 대입**
```c
free(p);
p = NULL;
/* 이제 *p하면 NULL 역참조 → 확실하게 즉시 죽음 (디버깅 쉬움) */
```

---

## 이중 해제(Double Free)

```c
free(p);
free(p);  /* 두 번 해제! undefined behavior! */
```

이것도 `p = NULL` 습관으로 방지 가능:
```c
free(p);
p = NULL;
free(p);   /* free(NULL)은 아무 일도 안 함 (안전) */
```

---

## 동적 배열 패턴: 크기 조절

```c
#include <stdio.h>
#include <stdlib.h>

int main(void) {
    int capacity = 4;
    int size = 0;
    int *arr = (int *)malloc(capacity * sizeof(int));

    /* 데이터 추가 시 필요하면 확장 */
    for (int i = 0; i < 10; i++) {
        if (size >= capacity) {
            capacity *= 2;  /* 2배로 확장 */
            int *tmp = (int *)realloc(arr, capacity * sizeof(int));
            if (tmp == NULL) { free(arr); return 1; }
            arr = tmp;
            printf("  (확장: capacity=%d)\n", capacity);
        }
        arr[size++] = i * 10;
    }

    printf("최종: ");
    for (int i = 0; i < size; i++) printf("%d ", arr[i]);
    printf("\n");

    free(arr);
    return 0;
}
```

> 이 패턴이 C++의 std::vector, Java의 ArrayList의 내부 원리이다.

---

## 자주 틀리는 포인트 3가지

1. **malloc 반환값 NULL 검사 안 함**
   ```c
   int *p = malloc(1000000000);  /* 실패할 수 있다! */
   *p = 42;  /* p가 NULL이면 즉시 죽음 */
   ```

2. **realloc 결과를 원래 포인터에 바로 대입**
   ```c
   arr = realloc(arr, new_size);  /* 실패 시 arr = NULL → 원래 메모리 누수 */
   ```

3. **sizeof(포인터)와 sizeof(배열) 혼동**
   ```c
   int *p = malloc(10 * sizeof(int));
   printf("%zu\n", sizeof(p));   /* 8 (포인터 크기!) */
   /* sizeof(p)로는 할당된 크기를 알 수 없다 */
   ```

---

## 이번 주 핵심 요약

| 개념 | 한 줄 요약 |
|------|-----------|
| malloc | 힙에서 지정 크기만큼 메모리 확보 |
| free | 할당된 메모리를 운영체제에 반환 |
| calloc | malloc + 0 초기화 |
| realloc | 기존 블록 크기 변경 (데이터 유지) |
| 메모리 누수 | free 안 하면 프로그램이 점점 메모리를 잡아먹음 |
| use-after-free | 해제한 메모리 접근 → undefined behavior |
