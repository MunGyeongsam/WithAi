# Week 15 강의: 미니 프로젝트 — 텍스트 주소록

---

## 프로젝트 목표

지금까지 배운 모든 것을 조합해서 **실제 동작하는 프로그램**을 만든다:
- 구조체 (데이터 모델)
- 동적 메모리 (가변 크기 배열)
- 파일 I/O (데이터 저장/로드)
- 모듈 분리 (헤더/소스)
- 오류 처리 (NULL 검사, 반환 코드)

---

## 요구사항 명세

### 기능

| 번호 | 기능 | 설명 |
|------|------|------|
| 1 | 추가 | 이름, 전화번호, 이메일 입력 |
| 2 | 목록 | 전체 연락처 출력 |
| 3 | 검색 | 이름으로 검색 |
| 4 | 삭제 | 이름으로 삭제 |
| 5 | 저장 | 파일에 저장 (CSV) |
| 6 | 불러오기 | 파일에서 로드 |
| 0 | 종료 | 프로그램 종료 |

---

## 설계: 모듈 분해

```
contact.h / contact.c     → Contact 구조체, 비교/출력 함수
addressbook.h / addressbook.c → 주소록 관리 (추가/삭제/검색)
storage.h / storage.c     → 파일 저장/불러오기
main.c                    → 메뉴 루프
```

---

## 데이터 구조

```c
/* contact.h */
#ifndef CONTACT_H
#define CONTACT_H

#define NAME_LEN 50
#define PHONE_LEN 20
#define EMAIL_LEN 50

typedef struct {
    char name[NAME_LEN];
    char phone[PHONE_LEN];
    char email[EMAIL_LEN];
} Contact;

void contact_print(const Contact *c);

#endif
```

---

## 주소록 모듈

```c
/* addressbook.h */
#ifndef ADDRESSBOOK_H
#define ADDRESSBOOK_H

#include "contact.h"

typedef struct {
    Contact *entries;
    int count;
    int capacity;
} AddressBook;

AddressBook *ab_create(int initial_cap);
void ab_destroy(AddressBook *ab);
int ab_add(AddressBook *ab, const Contact *c);
int ab_remove(AddressBook *ab, const char *name);
const Contact *ab_find(const AddressBook *ab, const char *name);
void ab_list(const AddressBook *ab);

#endif
```

---

## 구현 핵심 부분

### 추가 (동적 확장)

```c
int ab_add(AddressBook *ab, const Contact *c) {
    if (ab->count >= ab->capacity) {
        int new_cap = ab->capacity * 2;
        Contact *tmp = realloc(ab->entries, new_cap * sizeof(Contact));
        if (!tmp) return -1;
        ab->entries = tmp;
        ab->capacity = new_cap;
    }
    ab->entries[ab->count++] = *c;  /* 구조체 복사 */
    return 0;
}
```

### 검색

```c
const Contact *ab_find(const AddressBook *ab, const char *name) {
    for (int i = 0; i < ab->count; i++) {
        if (strcmp(ab->entries[i].name, name) == 0) {
            return &ab->entries[i];
        }
    }
    return NULL;
}
```

### 삭제 (마지막 원소와 교환)

```c
int ab_remove(AddressBook *ab, const char *name) {
    for (int i = 0; i < ab->count; i++) {
        if (strcmp(ab->entries[i].name, name) == 0) {
            ab->entries[i] = ab->entries[ab->count - 1];
            ab->count--;
            return 0;
        }
    }
    return -1;  /* not found */
}
```

---

## 파일 저장/로드 (CSV)

```c
int storage_save(const AddressBook *ab, const char *path) {
    FILE *fp = fopen(path, "w");
    if (!fp) return -1;

    for (int i = 0; i < ab->count; i++) {
        fprintf(fp, "%s,%s,%s\n",
                ab->entries[i].name,
                ab->entries[i].phone,
                ab->entries[i].email);
    }
    fclose(fp);
    return 0;
}

int storage_load(AddressBook *ab, const char *path) {
    FILE *fp = fopen(path, "r");
    if (!fp) return -1;

    char line[256];
    while (fgets(line, sizeof(line), fp)) {
        Contact c;
        if (sscanf(line, "%[^,],%[^,],%[^\n]", c.name, c.phone, c.email) == 3) {
            ab_add(ab, &c);
        }
    }
    fclose(fp);
    return 0;
}
```

---

## 메뉴 루프 (main.c)

```c
#include <stdio.h>
#include <string.h>
#include "addressbook.h"
#include "storage.h"

int main(void) {
    AddressBook *ab = ab_create(10);
    storage_load(ab, "contacts.csv");  /* 기존 데이터 로드 시도 */

    int choice;
    do {
        printf("\n=== 주소록 ===\n");
        printf("1. 추가  2. 목록  3. 검색  4. 삭제  5. 저장  0. 종료\n");
        printf("선택: ");
        scanf("%d", &choice);

        switch (choice) {
        case 1: {
            Contact c;
            printf("이름: "); scanf("%s", c.name);
            printf("전화: "); scanf("%s", c.phone);
            printf("이메일: "); scanf("%s", c.email);
            ab_add(ab, &c);
            printf("추가 완료\n");
            break;
        }
        case 2: ab_list(ab); break;
        case 3: {
            char name[NAME_LEN];
            printf("검색할 이름: "); scanf("%s", name);
            const Contact *found = ab_find(ab, name);
            if (found) contact_print(found);
            else printf("찾을 수 없습니다\n");
            break;
        }
        case 4: {
            char name[NAME_LEN];
            printf("삭제할 이름: "); scanf("%s", name);
            if (ab_remove(ab, name) == 0) printf("삭제 완료\n");
            else printf("찾을 수 없습니다\n");
            break;
        }
        case 5:
            if (storage_save(ab, "contacts.csv") == 0)
                printf("저장 완료\n");
            else perror("저장 실패");
            break;
        }
    } while (choice != 0);

    ab_destroy(ab);
    return 0;
}
```

---

## 프로젝트 진행 순서

1. **명세 확인**: 기능 목록과 데이터 구조 결정
2. **모듈 분해**: 헤더 파일부터 작성 (인터페이스 설계)
3. **핵심 구현**: Contact, AddressBook 기본 기능
4. **테스트**: 각 함수별 단위 테스트
5. **파일 I/O 추가**: 저장/로드
6. **통합 테스트**: 메뉴에서 전체 흐름 확인
7. **리팩터링**: 코드 정리, 경고 제거

---

## 평가 기준

| 항목 | 배점 |
|------|------|
| 컴파일 경고 0개 | 20% |
| 기본 기능 동작 | 30% |
| 파일 저장/로드 | 20% |
| 모듈 분리 | 15% |
| 오류 처리 | 15% |
