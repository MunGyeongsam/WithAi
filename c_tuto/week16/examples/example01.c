/*
 * Week 16 예제: 리팩터링 전/후 비교
 *
 * 빌드: gcc -std=c11 -Wall -Wextra -Werror example01.c -o example01
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* === 깔끔한 모듈 설계 데모 === */

#define MAX_ITEMS 100

typedef struct {
    char name[32];
    int quantity;
    double price;
} Item;

/* 함수 선언 (인터페이스) */
static void item_print(const Item *item);
static double item_total(const Item *item);
static double cart_total(const Item items[], int n);

/* 구현 */
static void item_print(const Item *item) {
    printf("  %-20s x%d  @%.0f  = %.0f\n",
           item->name, item->quantity, item->price,
           item_total(item));
}

static double item_total(const Item *item) {
    return item->quantity * item->price;
}

static double cart_total(const Item items[], int n) {
    double total = 0;
    for (int i = 0; i < n; i++) {
        total += item_total(&items[i]);
    }
    return total;
}

int main(void) {
    Item cart[] = {
        {"사과", 3, 1500},
        {"우유", 2, 2800},
        {"빵", 1, 3500}
    };
    int n = sizeof(cart) / sizeof(cart[0]);

    printf("=== 장바구니 ===\n");
    for (int i = 0; i < n; i++) {
        item_print(&cart[i]);
    }
    printf("---\n");
    printf("합계: %.0f원\n", cart_total(cart, n));

    return 0;
}
