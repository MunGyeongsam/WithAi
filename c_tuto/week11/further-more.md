# Week 11 더 알아보기 (Further More)

---

## 1. 표준 입출력의 버퍼링

- **전체 버퍼링(full)**: 파일. 버퍼가 찰 때 또는 fclose 시 flush.
- **줄 버퍼링(line)**: 터미널 stdout. '\n' 시 flush.
- **버퍼 없음(unbuffered)**: stderr. 즉시 출력.

```c
setvbuf(fp, NULL, _IONBF, 0);  /* 버퍼링 끄기 */
fflush(fp);                     /* 즉시 디스크에 쓰기 */
```

---

## 2. tmpfile()과 임시 파일

```c
FILE *tmp = tmpfile();  /* 자동으로 이름 생성, 닫으면 삭제 */
fprintf(tmp, "임시 데이터\n");
rewind(tmp);
/* 읽기... */
fclose(tmp);  /* 자동 삭제 */
```

---

## 3. 생각해볼 질문

- 왜 운영체제는 열 수 있는 파일 수를 제한하는가?
- fflush(stdout)은 언제 필요한가? (힌트: printf 후 입력 대기)
- 네트워크 소켓도 파일 디스크립터인 이유는? (Unix 철학: "Everything is a file")
