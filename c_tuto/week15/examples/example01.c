/*
 * Week 15 예제: 주소록 단일 파일 데모
 * (실제 프로젝트에서는 모듈로 분리할 것)
 *
 * 빌드: gcc -std=c11 -Wall -Wextra example01.c -o example01
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_NAME 50
#define MAX_PHONE 20

typedef struct {
    char name[MAX_NAME];
    char phone[MAX_PHONE];
} Contact;

typedef struct {
    Contact *data;
    int count;
    int capacity;
} Book;

Book *book_create(int cap) {
    Book *b = malloc(sizeof(Book));
    b->data = malloc(cap * sizeof(Contact));
    b->count = 0;
    b->capacity = cap;
    return b;
}

void book_add(Book *b, const char *name, const char *phone) {
    if (b->count >= b->capacity) {
        b->capacity *= 2;
        b->data = realloc(b->data, b->capacity * sizeof(Contact));
    }
    strncpy(b->data[b->count].name, name, MAX_NAME - 1);
    strncpy(b->data[b->count].phone, phone, MAX_PHONE - 1);
    b->count++;
}

void book_list(const Book *b) {
    for (int i = 0; i < b->count; i++) {
        printf("  %s : %s\n", b->data[i].name, b->data[i].phone);
    }
}

void book_destroy(Book *b) {
    free(b->data);
    free(b);
}

int main(void) {
    Book *b = book_create(2);

    book_add(b, "Kim", "010-1111");
    book_add(b, "Lee", "010-2222");
    book_add(b, "Park", "010-3333");

    printf("=== 주소록 ===\n");
    book_list(b);

    book_destroy(b);
    return 0;
}
