# Week 14 정답과 해설

---

## 문제 1 정답

```c
/* str_util.h */
#ifndef STR_UTIL_H
#define STR_UTIL_H
#include <stddef.h>

size_t my_strlen(const char *s);
char *my_strcpy(char *dest, const char *src);
int my_strcmp(const char *s1, const char *s2);

#endif
```

```c
/* str_util.c */
#include "str_util.h"

size_t my_strlen(const char *s) {
    size_t n = 0;
    while (s[n]) n++;
    return n;
}

char *my_strcpy(char *dest, const char *src) {
    char *ret = dest;
    while (*src) *dest++ = *src++;
    *dest = '\0';
    return ret;
}

int my_strcmp(const char *s1, const char *s2) {
    while (*s1 && *s1 == *s2) { s1++; s2++; }
    return (unsigned char)*s1 - (unsigned char)*s2;
}
```

빌드: `gcc -std=c11 -Wall main.c str_util.c -o test`

---

## 문제 5 정답

```c
/* dynarray.h */
#ifndef DYNARRAY_H
#define DYNARRAY_H

typedef struct {
    int *data;
    int size;
    int capacity;
} DynArray;

DynArray *dynarray_create(int initial_cap);
int dynarray_push(DynArray *da, int value);
int dynarray_get(const DynArray *da, int index);
int dynarray_size(const DynArray *da);
void dynarray_destroy(DynArray *da);

#endif
```

```c
/* dynarray.c */
#include <stdlib.h>
#include "dynarray.h"

DynArray *dynarray_create(int initial_cap) {
    DynArray *da = (DynArray *)malloc(sizeof(DynArray));
    if (!da) return NULL;
    da->data = (int *)malloc(initial_cap * sizeof(int));
    if (!da->data) { free(da); return NULL; }
    da->size = 0;
    da->capacity = initial_cap;
    return da;
}

int dynarray_push(DynArray *da, int value) {
    if (da->size >= da->capacity) {
        int new_cap = da->capacity * 2;
        int *tmp = (int *)realloc(da->data, new_cap * sizeof(int));
        if (!tmp) return -1;
        da->data = tmp;
        da->capacity = new_cap;
    }
    da->data[da->size++] = value;
    return 0;
}

int dynarray_get(const DynArray *da, int index) {
    return da->data[index];
}

int dynarray_size(const DynArray *da) {
    return da->size;
}

void dynarray_destroy(DynArray *da) {
    if (da) {
        free(da->data);
        free(da);
    }
}
```
