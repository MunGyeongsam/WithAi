# Week 14 연습문제

---

## 문제 1: 헤더/소스 분리 (난이도: ★☆☆)

문자열 유틸리티 모듈을 분리하시오:
- str_util.h: my_strlen, my_strcpy, my_strcmp 선언
- str_util.c: 구현
- main.c: 테스트

---

## 문제 2: static 함수 활용 (난이도: ★★☆)

모듈의 내부 도우미 함수를 static으로 숨기시오.
외부에서 호출 시도하면 링크 오류가 나는 것을 확인할 것.

---

## 문제 3: Makefile 작성 (난이도: ★★☆)

3개 이상의 소스 파일로 구성된 프로젝트의 Makefile을 작성하시오.
- `make`: 빌드
- `make clean`: 정리
- 헤더 의존성 포함

---

## 문제 4: 정적 라이브러리 (난이도: ★★★)

문자열 + 수학 유틸을 하나의 정적 라이브러리(libutil.a)로 묶고,
main.c에서 라이브러리를 링크해서 사용하시오.

---

## 문제 5: 인터페이스 설계 (난이도: ★★★)

"동적 배열(dynamic array)" 모듈을 설계하시오:
- dynarray.h: 타입 정의 + create, push, get, size, destroy 선언
- dynarray.c: 구현 (malloc/realloc/free)
- main.c: 사용 예시
