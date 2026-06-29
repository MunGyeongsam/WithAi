# Week 10 정답과 해설

---

## 문제 1 정답

```c
#include <stdio.h>

typedef struct {
    char name[20];
    int id;
    double gpa;
} Student;

int main(void) {
    Student students[3] = {
        {"Kim", 101, 3.8},
        {"Lee", 102, 4.2},
        {"Park", 103, 3.5}
    };

    int best = 0;
    for (int i = 1; i < 3; i++) {
        if (students[i].gpa > students[best].gpa) {
            best = i;
        }
    }
    printf("최고 GPA: %s (%.1f)\n", students[best].name, students[best].gpa);
    return 0;
}
```

---

## 문제 2 정답

```c
#include <stdio.h>

struct A { char a; int b; char c; };
struct B { int b; char a; char c; };
struct C { char a; char c; int b; };

int main(void) {
    printf("A: %zu\n", sizeof(struct A));  /* 12 */
    printf("B: %zu\n", sizeof(struct B));  /* 8 */
    printf("C: %zu\n", sizeof(struct C));  /* 8 */
    return 0;
}
```

**해설:** struct A는 char(1) + pad(3) + int(4) + char(1) + pad(3) = 12.
B와 C는 int를 먼저 배치하거나 char를 연속 배치해서 패딩이 줄어든다.

---

## 문제 3 정답

```c
#include <stdio.h>

int main(void) {
    union { int i; unsigned char c; } u;
    u.i = 1;

    if (u.c == 1) {
        printf("리틀 엔디안 (little-endian)\n");
    } else {
        printf("빅 엔디안 (big-endian)\n");
    }
    return 0;
}
```

**해설:** 1을 int로 저장하면, 리틀 엔디안에서는 첫 바이트가 0x01.

---

## 문제 4 정답

```c
#include <stdio.h>

#define PERM_READ  (1u << 2)  /* 4 */
#define PERM_WRITE (1u << 1)  /* 2 */
#define PERM_EXEC  (1u << 0)  /* 1 */

void set_permission(unsigned int *flags, unsigned int perm) {
    *flags |= perm;
}

int has_permission(unsigned int flags, unsigned int perm) {
    return (flags & perm) != 0;
}

void remove_permission(unsigned int *flags, unsigned int perm) {
    *flags &= ~perm;
}

void print_permissions(unsigned int flags) {
    printf("%c%c%c\n",
        has_permission(flags, PERM_READ)  ? 'r' : '-',
        has_permission(flags, PERM_WRITE) ? 'w' : '-',
        has_permission(flags, PERM_EXEC)  ? 'x' : '-');
}

int main(void) {
    unsigned int perms = 0;
    set_permission(&perms, PERM_READ);
    set_permission(&perms, PERM_EXEC);
    print_permissions(perms);  /* r-x */

    remove_permission(&perms, PERM_EXEC);
    print_permissions(perms);  /* r-- */
    return 0;
}
```

---

## 문제 5 정답

```c
#include <stdio.h>
#include <math.h>

typedef enum { CIRCLE, RECT, TRIANGLE } ShapeType;

typedef struct {
    ShapeType type;
    union {
        struct { double radius; } circle;
        struct { double w, h; } rect;
        struct { double base, height; } tri;
    };
} Shape;

double area(const Shape *s) {
    switch (s->type) {
    case CIRCLE:   return 3.14159265 * s->circle.radius * s->circle.radius;
    case RECT:     return s->rect.w * s->rect.h;
    case TRIANGLE: return 0.5 * s->tri.base * s->tri.height;
    }
    return 0;
}

int main(void) {
    Shape shapes[] = {
        {CIRCLE, .circle = {5.0}},
        {RECT, .rect = {3.0, 4.0}},
        {TRIANGLE, .tri = {6.0, 3.0}}
    };

    for (int i = 0; i < 3; i++) {
        printf("면적: %.2f\n", area(&shapes[i]));
    }
    return 0;
}
```
