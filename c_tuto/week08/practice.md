# Week 08 연습문제

---

## 문제 1: my_strchr 구현 (난이도: ★☆☆)

문자열에서 특정 문자가 처음 나타나는 위치의 포인터를 반환하시오.
없으면 NULL 반환.

```c
char *my_strchr(const char *s, int c);
```

---

## 문제 2: my_strcat 구현 (난이도: ★★☆)

dest 뒤에 src를 이어붙이는 함수를 구현하시오.

```c
char *my_strcat(char *dest, const char *src);
```

테스트: dest="Hello", src=" World" → "Hello World"

---

## 문제 3: my_memset 구현 (난이도: ★★☆)

n 바이트를 특정 값(바이트)으로 채우는 함수:

```c
void *my_memset(void *s, int c, size_t n);
```

---

## 문제 4: my_strstr 구현 (난이도: ★★★)

문자열에서 부분 문자열을 찾는 함수:

```c
char *my_strstr(const char *haystack, const char *needle);
/* needle이 처음 나타나는 위치 포인터 반환. 없으면 NULL */
```

테스트:
- my_strstr("Hello World", "World") → "World" 시작 위치
- my_strstr("Hello", "xyz") → NULL
- my_strstr("Hello", "") → "Hello" (빈 needle은 항상 찾음)

---

## 문제 5: 테스트 하네스 작성 (난이도: ★★★)

위에서 구현한 함수들에 대해 최소 3개씩의 테스트 케이스를 작성하시오.
반드시 포함할 경계값:
- 빈 문자열
- 한 글자 문자열
- 찾는 값이 없는 경우
