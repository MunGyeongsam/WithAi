# Week 15 정답과 해설

이번 주는 프로젝트 구현이므로, 핵심 모듈별 정답 코드를 제공합니다.
전체 코드는 강의 노트(lesson.md)에 포함되어 있습니다.

---

## 핵심 체크포인트

### 1. 구조체 정의 확인
- Contact에 name, phone, email 필드가 있는가?
- 적절한 크기 상수(#define)를 사용하는가?

### 2. 동적 배열 확장 확인
- ab_add에서 capacity 초과 시 realloc하는가?
- realloc 실패 시 기존 데이터를 보존하는가?

### 3. 파일 I/O 확인
- CSV 형식으로 저장/로드가 일관적인가?
- fopen 실패 시 오류 처리하는가?
- fclose를 모든 경로에서 호출하는가?

### 4. 메모리 관리 확인
- ab_destroy에서 entries와 ab 모두 free하는가?
- 프로그램 종료 전 ab_destroy를 호출하는가?

### 5. 테스트 예시

```c
/* test_addressbook.c */
#include <stdio.h>
#include <assert.h>
#include <string.h>
#include "addressbook.h"

int main(void) {
    AddressBook *ab = ab_create(2);
    assert(ab != NULL);

    /* 추가 */
    Contact c1 = {"Kim", "010-1234", "kim@test.com"};
    assert(ab_add(ab, &c1) == 0);

    /* 검색 */
    const Contact *found = ab_find(ab, "Kim");
    assert(found != NULL);
    assert(strcmp(found->phone, "010-1234") == 0);

    /* 없는 이름 검색 */
    assert(ab_find(ab, "Nobody") == NULL);

    /* 삭제 */
    assert(ab_remove(ab, "Kim") == 0);
    assert(ab_find(ab, "Kim") == NULL);

    /* 용량 초과 확장 */
    for (int i = 0; i < 10; i++) {
        Contact c = {"", "", ""};
        sprintf(c.name, "User%d", i);
        ab_add(ab, &c);
    }
    assert(ab->count == 10);

    ab_destroy(ab);
    printf("모든 테스트 통과\n");
    return 0;
}
```
