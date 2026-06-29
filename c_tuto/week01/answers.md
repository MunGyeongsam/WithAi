# Week 01 정답과 해설

---

## 문제 1 정답

```c
#include <stdio.h>

int main(void) {
    printf("이름: 김철수\n");
    printf("나이: 22\n");
    printf("좋아하는 것: 독서, 음악, 산책\n");
    return 0;
}
```

**해설:**
- 각 정보를 `printf`로 한 줄씩 출력한다.
- `\n`을 빼먹으면 모든 내용이 한 줄에 붙어서 나온다.
- 문자열 안의 한글은 그대로 출력된다.

---

## 문제 2 정답

```c
#include <stdio.h>

int main(void) {
    printf("%d + %d = %d\n", 10, 20, 10 + 20);
    printf("%d - %d = %d\n", 10, 20, 10 - 20);
    printf("%d * %d = %d\n", 10, 20, 10 * 20);
    return 0;
}
```

**해설:**
- `%d`는 정수를 출력할 자리를 표시한다.
- 세 번째 인자에 `10 + 20`처럼 계산식을 직접 쓸 수 있다.
- 컴파일러가 계산을 대신 해주는 것이 아니라, 실행 시점에 계산된다.

---

## 문제 3 정답

1. `return 0;` → 종료 코드 `0` (정상 종료)
2. `return 1;` → 종료 코드 `1` (비정상 종료 또는 오류 표시)
3. 설명: "0은 성공, 0이 아닌 값은 실패 또는 오류를 의미한다."

---

## 문제 4 정답

1. 경고 메시지 예:
```
warning: variable 'x' is uninitialized when used here
```

2. 수정 코드:
```c
#include <stdio.h>

int main(void) {
    int x = 0;  /* 초기화(initialization) 추가 */
    printf("%d\n", x);
    return 0;
}
```

3. 설명: "초기화하지 않은 변수에는 쓰레기 값(garbage value)이 들어 있어서, 실행할 때마다 결과가 달라질 수 있다."

---

## 문제 5 정답

| 단계 | 입력 | 출력 | 설명 |
|------|------|------|------|
| 전처리 | hello.c | hello.i (확장된 소스) | #include 등 지시문을 처리해서 하나의 큰 소스로 합친다 |
| 컴파일 | hello.i | hello.s (어셈블리) | C 코드를 CPU 명령어에 가까운 어셈블리 언어로 번역한다 |
| 어셈블 | hello.s | hello.o (오브젝트) | 어셈블리를 0과 1로 된 기계어로 변환한다 |
| 링크 | hello.o + 라이브러리 | hello (실행 파일) | printf 등 외부 기능과 합쳐 완성된 실행 파일을 만든다 |
