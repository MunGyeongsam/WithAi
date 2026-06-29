# Week 01 더 알아보기 (Further More)

---

## 1. 빌드 단계를 눈으로 확인하기

각 단계의 산출물을 직접 만들어 볼 수 있다:

```bash
# 전처리 결과 보기
gcc -E hello.c -o hello.i

# 어셈블리 보기
gcc -S hello.c -o hello.s

# 오브젝트 파일 만들기
gcc -c hello.c -o hello.o

# 링크해서 실행 파일 만들기
gcc hello.o -o hello
```

`hello.i` 파일을 열어보면, #include로 가져온 내용이 수천 줄로 펼쳐져 있는 것을 볼 수 있다.

---

## 2. 컴파일러는 왜 여러 종류가 있는가

- **gcc** : 리눅스/macOS에서 가장 흔한 컴파일러
- **clang** : macOS 기본 컴파일러 (gcc 호환)
- **MSVC** : Windows Visual Studio 전용

어떤 컴파일러를 쓰든, 표준 C 코드를 작성하면 동일하게 동작해야 한다.
이것을 **이식성(portability)**이라 한다.

---

## 3. main 함수의 두 가지 형태

```c
int main(void)          // 인자 없음 (이 강좌에서 사용)
int main(int argc, char *argv[])  // 명령줄 인자 받기 (나중에 배움)
```

지금은 첫 번째 형태만 쓴다. 두 번째는 14주차 이후에 다룬다.

---

## 4. 생각해볼 질문

- "컴퓨터가 이해하는 언어"와 "사람이 이해하는 언어"는 왜 다를까?
- 번역(컴파일)이 필요 없는 언어도 있을까? (힌트: 인터프리터 언어)
- 경고를 무시하는 습관이 왜 위험할까?
