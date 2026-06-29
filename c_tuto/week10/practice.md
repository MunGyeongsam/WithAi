# Week 10 연습문제

---

## 문제 1: 학생 구조체 (난이도: ★☆☆)

Student 구조체(이름, 학번, GPA)를 정의하고, 3명의 학생 배열을 만들어
GPA가 가장 높은 학생의 이름을 출력하시오.

---

## 문제 2: sizeof와 패딩 (난이도: ★★☆)

다음 구조체들의 sizeof를 예측하고 확인하시오:

```c
struct A { char a; int b; char c; };
struct B { int b; char a; char c; };
struct C { char a; char c; int b; };
```

멤버 순서가 크기에 미치는 영향을 설명하시오.

---

## 문제 3: 유니온으로 엔디안 확인 (난이도: ★★☆)

유니온을 사용해 현재 시스템이 리틀 엔디안인지 빅 엔디안인지 판별하는 프로그램을 작성하시오.

---

## 문제 4: 비트 마스크 플래그 (난이도: ★★★)

파일 권한 시스템을 비트 마스크로 구현하시오:
- READ = 4 (bit 2)
- WRITE = 2 (bit 1)
- EXEC = 1 (bit 0)

함수: set_permission, has_permission, remove_permission, print_permissions

---

## 문제 5: Tagged Union (난이도: ★★★)

도형(원, 사각형, 삼각형)을 tagged union으로 정의하고,
면적 계산 함수를 작성하시오.
