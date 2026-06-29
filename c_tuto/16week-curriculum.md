# C 언어 16주 상세 커리큘럼 (K&R 기반)

기본 교재: The C Programming Language, 2nd Edition (Brian W. Kernighan, Dennis M. Ritchie)

운영 목표:
- 문법 암기보다 메모리 모델(memory model) 이해를 우선
- 표준 라이브러리(standard library)를 "사용"에서 "직접 구현"까지 확장
- 포인터 선언 해석(declarator reading), 전처리기(preprocessor), 매크로(macro), 유니온(union), 비트필드(bit-field) 심화

---

## 1주차: C 학습 셋업과 실행 모델

학습 목표:
- 컴파일 파이프라인(compilation pipeline) 이해
- 최소 C 프로그램 작성 및 빌드
- 경고(warning)를 학습 신호로 활용

교재 범위:
- Ch.1 개요

자세한 예제:
```c
#include <stdio.h>

int main(void) {
    // 프로그램 시작점(entry point)
    // 표준 출력(standard output)으로 메시지 출력
    printf("Hello, C world!\n");
    return 0;
}
```

연습문제:
1. 위 프로그램에 학번과 이름을 출력하도록 확장하라.
2. printf 서식(format)을 사용해 정수 3개를 열 맞춤으로 출력하라.

정답 요약:
- 함수 시그니처는 int main(void) 권장
- 줄바꿈은 \n 명시
- 반환값 return 0 유지

Further More:
- 전처리(preprocessing), 컴파일(compilation), 어셈블(assembly), 링크(linking) 각 단계 산출물 확인

---

## 2주차: 타입, 연산자, 형변환

학습 목표:
- 기본 타입과 범위 이해
- 암시적/명시적 형변환 구분
- 산술 오버플로우 위험 인지

교재 범위:
- Ch.2

자세한 예제:
```c
#include <stdio.h>

int main(void) {
    int a = 7;
    int b = 2;

    // 정수 나눗셈(integer division)
    int q = a / b;

    // 명시적 형변환(explicit cast)
    double dq = (double)a / b;

    printf("q=%d, dq=%.2f\n", q, dq);
    return 0;
}
```

연습문제:
1. 섭씨/화씨 변환 함수 2개를 작성하라.
2. int와 unsigned int 비교 시 주의사항을 사례로 설명하라.

정답 요약:
- int/int는 int 결과
- 실수 연산 필요 시 피연산자 중 하나를 실수형으로 변환

Further More:
- signed/unsigned 혼합 비교의 함정 실험

---

## 3주차: 제어문과 함수 기초

학습 목표:
- if/switch/for/while 정확히 사용
- 함수 분리 기준 이해
- 스코프(scope)와 수명(lifetime) 구분

교재 범위:
- Ch.3, Ch.4 일부

자세한 예제:
```c
#include <stdio.h>

static int classify(int x) {
    if (x < 0) return -1;
    if (x == 0) return 0;
    return 1;
}

int main(void) {
    int x = -3;
    printf("class=%d\n", classify(x));
    return 0;
}
```

연습문제:
1. switch로 학점(A~F) 분류기 구현
2. 절댓값, 최댓값 함수를 분리 구현

정답 요약:
- 함수는 단일 책임(single responsibility)으로 분리
- 매개변수와 반환 타입을 명확히 정의

Further More:
- static 함수의 내부 연결(internal linkage) 의미 정리

---

## 4주차: 배열과 문자열

학습 목표:
- 배열과 문자열의 관계 이해
- null 종료 문자(null terminator) 중요성 이해
- 문자열 처리의 경계 검증 습관화

교재 범위:
- Ch.1 일부, Ch.5 일부

자세한 예제:
```c
#include <stdio.h>

int main(void) {
    char name[16] = "KNR";

    // 문자열 길이 직접 계산(manual length)
    int len = 0;
    while (name[len] != '\0') {
        len++;
    }

    printf("len=%d\n", len);
    return 0;
}
```

연습문제:
1. 역순 문자열 출력 함수 작성
2. 공백 제거(trim) 함수 작성

정답 요약:
- 배열 크기 초과 접근 금지
- 종료 문자 유지 필수

Further More:
- 버퍼 오버런(buffer overrun) 사례 분석

---

## 5주차: 포인터 선언 해석 1

학습 목표:
- 포인터 기본 선언 해석
- 주소 연산(address arithmetic) 이해
- 배열과 포인터의 차이 구분

교재 범위:
- Ch.5 (5.1~5.3)

자세한 예제:
```c
#include <stdio.h>

int main(void) {
    int x = 10;
    int *p = &x; // p는 int를 가리키는 포인터(pointer to int)

    *p = 20;     // 역참조(dereference)로 x 수정
    printf("x=%d\n", x);
    return 0;
}
```

연습문제:
1. int *, double * 선언과 사용 비교
2. 포인터로 배열 원소 합 구하기

정답 요약:
- 선언은 "변수 이름 기준"으로 읽기
- *p는 값, p는 주소

Further More:
- 선언 읽기 규칙(right-left rule) 도입

---

## 6주차: 포인터 선언 해석 2 (심화)

학습 목표:
- 복합 선언(complex declarator) 해석
- 함수 포인터(function pointer) 사용
- 배열/함수/포인터 조합 선언 읽기

교재 범위:
- Ch.5 심화

자세한 예제:
```c
#include <stdio.h>

static int add(int a, int b) { return a + b; }

int main(void) {
    int (*fp)(int, int) = add; // fp는 함수 포인터(pointer to function)
    printf("%d\n", fp(2, 3));
    return 0;
}
```

연습문제:
1. 다음 선언을 해석하라: int (*arr[3])(void)
2. 콜백(callback) 기반 계산기 구현
3. int *fp(int)와 int (*fp)(int)의 차이를 코드로 증명

정답 요약:
- 괄호가 결합 우선순위를 바꾼다
- fp가 함수인지, 함수 포인터인지 먼저 판별

Further More:
- 선언 해석 퀴즈 20제 운영

---

## 7주차: 표준 라이브러리 지도

학습 목표:
- 주요 헤더별 역할 이해
- 함수 계약(contract: 입력/출력/부작용) 읽기
- 안전한 대체 API 선택 기준 수립

교재 범위:
- Ch.7, Ch.8 일부

자세한 예제:
```c
#include <stdio.h>
#include <string.h>

int main(void) {
    char s[32] = "abc";
    size_t n = strlen(s); // 문자열 길이(length)
    printf("n=%zu\n", n);
    return 0;
}
```

연습문제:
1. stdio.h, stdlib.h, string.h 핵심 함수 5개씩 용도 정리
2. memcpy와 memmove 차이를 예시로 설명

정답 요약:
- memcpy는 겹침(overlap) 미보장
- memmove는 겹침 상황에서도 안전

Further More:
- man page 읽는 법(사전 조건/사후 조건) 훈련

---

## 8주차: 표준 함수 직접 구현 1

학습 목표:
- 문자열 함수 동작 원리 이해
- 경계값 테스트 작성

교재 범위:
- Ch.5, Ch.7 연계

자세한 예제:
```c
#include <stddef.h>

size_t my_strlen(const char *s) {
    size_t n = 0;
    while (s[n] != '\0') {
        n++;
    }
    return n;
}
```

연습문제:
1. my_strcpy, my_strcmp 구현
2. 빈 문자열, 긴 문자열 테스트 케이스 작성

정답 요약:
- 포인터가 NULL인 경우 정책 명확화 필요
- 반환 규약을 표준 함수와 일치시킬 것

Further More:
- 성능 관점에서 루프 언롤링(loop unrolling) 토론

---

## 9주차: 표준 함수 직접 구현 2 + 테스트 하네스

학습 목표:
- 메모리 함수 구현 원리 이해
- 단위 테스트(unit test) 도입

교재 범위:
- Ch.5, Ch.8 연계

자세한 예제:
```c
#include <stddef.h>

void *my_memset(void *dst, int c, size_t n) {
    unsigned char *p = (unsigned char *)dst;
    for (size_t i = 0; i < n; i++) {
        p[i] = (unsigned char)c;
    }
    return dst;
}
```

연습문제:
1. my_memcpy 구현
2. my_memmove 구현 후 overlap 테스트 작성

정답 요약:
- memmove는 복사 방향(direction) 선택이 핵심
- 테스트 하네스로 경계값 자동 검증

Further More:
- sanitizer(ASan/UBSan) 활용 소개

---

## 10주차: 구조체, 유니온, 비트필드 심화

학습 목표:
- 구조체 정렬(alignment)과 패딩(padding) 이해
- 유니온 메모리 공유 모델 이해
- 비트필드의 구현 정의 이슈 이해

교재 범위:
- Ch.6

자세한 예제:
```c
#include <stdio.h>

struct Flags {
    unsigned int ready : 1; // 준비 상태(ready flag)
    unsigned int error : 1; // 오류 상태(error flag)
    unsigned int mode  : 2; // 동작 모드(mode)
};

int main(void) {
    struct Flags f = {1, 0, 2};
    printf("ready=%u error=%u mode=%u\n", f.ready, f.error, f.mode);
    return 0;
}
```

연습문제:
1. union으로 int/byte 뷰(view) 전환 예제 작성
2. 네트워크 헤더 유사 비트필드 모델링

정답 요약:
- 비트필드는 컴파일러/플랫폼 의존성이 있다
- 이식성(portability) 요구 시 마스크 연산 우선

Further More:
- strict aliasing 규칙과 union 사용 주의

---

## 11주차: 파일 입출력과 오류 처리

학습 목표:
- 파일 API 정확한 사용
- errno, perror, 반환값 기반 오류 처리 습관화

교재 범위:
- Ch.7, Ch.8

자세한 예제:
```c
#include <stdio.h>

int main(void) {
    FILE *fp = fopen("input.txt", "r");
    if (fp == NULL) {
        perror("fopen failed");
        return 1;
    }

    // 자원 해제(resource release)
    fclose(fp);
    return 0;
}
```

연습문제:
1. 파일의 줄 수(line count) 세기
2. CSV 한 줄 파싱 후 구조체 저장

정답 요약:
- 실패 경로에서 즉시 처리
- 성공/실패 경로 모두 fclose 보장

Further More:
- RAII 대체 패턴으로 goto cleanup 소개

---

## 12주차: 전처리기 심화

학습 목표:
- include guard, 조건부 컴파일 정확히 사용
- 빌드 플래그 기반 기능 분기 설계

교재 범위:
- Ch.4, Ch.11

자세한 예제:
```c
#ifndef MYLIB_H
#define MYLIB_H

// 공개 인터페이스(public interface)
int add(int a, int b);

#endif
```

연습문제:
1. DEBUG 매크로로 로그 on/off 구현
2. 플랫폼별 분기(#if defined(...)) 작성

정답 요약:
- 헤더 중복 포함 방지 필수
- 매크로 조건은 단순하고 명확하게 유지

Further More:
- 컴파일 단위(translation unit) 관점에서 include 비용 분석

---

## 13주차: 매크로 심화

학습 목표:
- 함수형 매크로 부작용 이해
- #, ##, X-macro 패턴 사용
- 매크로 vs inline 함수 선택 기준 수립

교재 범위:
- Ch.11 중심

자세한 예제:
```c
#include <stdio.h>

#define SQUARE(x) ((x) * (x))

int main(void) {
    int a = 3;
    printf("%d\n", SQUARE(a + 1));
    return 0;
}
```

연습문제:
1. MIN, MAX 매크로를 부작용 없이 설계해보라.
2. enum-문자열 변환에 X-macro 적용

정답 요약:
- 매크로 인자는 반드시 괄호 처리
- 부작용 표현식(a++) 전달 금지

Further More:
- inline 함수로 대체 가능한 매크로 식별

---

## 14주차: 모듈화와 라이브러리화

학습 목표:
- 헤더/소스 분리 원칙 이해
- 모듈 인터페이스 설계
- 정적 라이브러리 개념 이해

교재 범위:
- Ch.4, Ch.8 연계

자세한 예제:
```c
/* math_util.h */
#ifndef MATH_UTIL_H
#define MATH_UTIL_H
int sum_array(const int *a, int n);
#endif
```

연습문제:
1. 문자열 유틸 모듈 분리
2. 헤더 의존성 최소화 리팩터링

정답 요약:
- 헤더에는 선언, 소스에는 정의
- 불필요한 include 제거

Further More:
- API 안정성(호환성) 관점 버전 정책 설계

---

## 15주차: 미니 프로젝트 구현

학습 목표:
- 요구사항에서 설계로 연결
- 테스트 가능한 C 코드 작성
- 리뷰 가능한 코드 문서화

프로젝트 예시:
- 텍스트 기반 주소록 관리기(address book)
- 기능: 추가/검색/삭제/저장/불러오기

연습문제:
1. 핵심 기능 5개 명세 작성
2. 오류 코드 체계 정의

정답 요약:
- 명세 -> 모듈 분해 -> 구현 -> 테스트 순서 유지

Further More:
- 성능 측정(profiling) 기초 도입

---

## 16주차: 코드 리뷰와 최종 리팩터링

학습 목표:
- 동작/안전성/가독성/확장성 기준 리뷰
- 기술 부채(technical debt) 정리
- 다음 단계 학습 로드맵 수립

최종 점검 체크리스트:
- 컴파일 경고 0개
- 메모리 누수 0개(도구 점검)
- 실패 경로 테스트 완료
- README에 빌드/실행/테스트 절차 명시

연습문제:
1. 본인 프로젝트 코드 리뷰 보고서 작성
2. 리팩터링 전/후 차이 3가지 정리

정답 요약:
- 리뷰는 비난이 아니라 위험 제거 활동
- 재현 가능한 품질 증거(테스트 로그)가 핵심

Further More:
- 이후 심화 주제: 운영체제 API, 네트워크 프로그래밍, 임베디드 C

---

## 부록 A: 필수 직접 구현 함수 체크리스트

문자열/문자:
- my_strlen
- my_strcpy
- my_strncpy
- my_strcmp
- my_strncmp
- my_strchr

메모리:
- my_memset
- my_memcpy
- my_memmove
- my_memcmp

변환/유틸:
- my_atoi
- my_isdigit
- my_tolower

주의:
- 표준 함수명과 충돌하지 않도록 접두사 my_ 사용
- 함수 계약(입력, 반환, 예외 상황)을 문서화

## 부록 B: 포인터 선언 읽기 퀵 가이드

핵심 원칙:
1. 식별자 이름부터 시작
2. 오른쪽/왼쪽으로 우선순위 따라 읽기
3. 괄호가 묶은 부분 먼저 해석

연습 선언:
- int *p
- int **pp
- int (*fp)(int)
- int *fp(int)
- int (*arr[5])(void)
- int (*(*x[3])())[5]

권장 과제:
- 매주 선언 10개를 "한글 설명 + 원어 병기"로 해석해 제출
