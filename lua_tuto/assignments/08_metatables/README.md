# [게임시스템설계(2A)] 실습 과제 — 08. 메타테이블

> 목표: `__index`, `__newindex`, 산술·비교 메타메서드, `__call`, `__tostring`을
> **게임 데이터(기본값·설정·스탯·적)** 에 직접 적용하고, 테스트로 동작을 증명한다.

- 선행 학습: [08_metatables.md](../../08_metatables.md)
- 작성 파일: [metatable_tasks.lua](metatable_tasks.lua) (TODO 채우기)
- 보고서: `REPORT_08_metatables.md` (문제 6, 1쪽 이내)
- 배점: 코드 90점 (자동 테스트) + 보고서 10점 = **100점**
- 환경: Lua 5.1 / LuaJIT 호환 문법만 사용, LÖVE 불필요
- AI 사용: 가능. 단, 문제 6에서 **내 코드 줄 번호로** 설명할 수 있어야 한다.

---

## 실행 방법

저장소 루트에서:

```sh
lua lua_tuto/assignments/08_metatables/metatable_tasks_test.lua
```

- `luajit` 으로 바꿔 실행해도 된다.
- VS Code 에서는 `metatable_tasks_test.lua` 를 열고 task **"Lua: Run current file"** 실행.
- 마지막에 문제별 점수와 `N passed, M failed` 가 출력된다. 모두 통과하면 종료 코드 0.

---

## 문제 1. 기본값 테이블 `M.withDefaults(t, defaults)` — 15점

- `t` 에 없는 키를 읽으면 `defaults` 에서 값을 가져온다.
- `t` 자체를 반환한다. `defaults` 의 키를 `t` 에 **복사하면 안 된다** (`pairs(t)` 에 안 보여야 함).
- `defaults` 를 나중에 바꾸면 그 값이 바로 보인다.

## 문제 2. 읽기 전용 테이블 `M.readOnly(t)` — 15점

- 읽기는 원본 `t` 의 값을 돌려준다.
- 어떤 키든 쓰기를 시도하면 `error("read-only: <key>")` 가 발생한다.
- **이미 있는 키**를 덮어쓰는 것도 막아야 한다. (힌트: `__newindex` 는 언제 호출되는가?)

## 문제 3. `Stats` 값 타입 — 25점

| 사용 | 동작 |
| --- | --- |
| `Stats.new({atk = 20})` | 빠진 필드는 `Stats.DEFAULT` (`hp=100, atk=10, def=5`) 로 채움. 인자 생략 가능 |
| `a + b` | 필드별 합으로 **새** Stats (원본 불변) |
| `s * 2`, `2 * s` | 필드별 스칼라 곱 |
| `a == b` | 세 필드가 모두 같으면 `true` |
| `tostring(s)` | `"Stats(hp=100, atk=10, def=5)"` (`%g`, 필드 순서 고정) |
| `s:power()` | `atk * 2 + def` |

- 인스턴스 테이블에는 `hp`, `atk`, `def` 세 키만 있어야 한다 (메서드는 `__index` 로 찾는다).

## 문제 4. 변경 감시 프록시 `M.tracked(t, onChange)` — 20점

- 프록시에 값을 쓰면 원본 `t` 에 저장하고 `onChange(key, old, new)` 를 호출한다.
- 이미 있는 키를 수정할 때도 호출된다.
- 값이 같으면(`old == new`) 호출하지 않는다.
- 프록시 자체는 항상 **비어 있어야** 한다.

## 문제 5. `Enemy` — `__call` 팩토리 + `__lt` 정렬 — 15점

- `Enemy.new(name, hp)` 와 `Enemy(name, hp)` 둘 다 인스턴스를 만든다.
- 생성할 때마다 `Enemy.count` 가 1 증가하고, 인스턴스 `id` 는 생성 순번이다.
- `a < b` : `hp` 오름차순, 같으면 `id` 오름차순 → `table.sort(list)` 가 비교 함수 없이 동작해야 한다.
- `tostring(e)` → `"Slime#1(hp=50)"`

## 문제 6. 보고서 `REPORT_08_metatables.md` — 10점

각 3~6줄, **내 코드의 줄 번호를 인용**해서 답한다.

1. (3점) 문제 2·4에서 프록시를 **빈 테이블**로 만든 이유를 `__newindex` 호출 조건으로 설명하라.
2. (3점) 문제 3에서 `2 * s` 가 동작하는 이유를 `__mul` 의 인자 순서로 설명하라.
3. (2점) `rawget` / `rawset` 을 써야 하는 상황을 내 코드 또는 예시 하나로 설명하라.
4. (2점) Lua 5.1 에서 `__len` 을 테이블에 걸어도 `#t` 가 바뀌지 않는다. 이 과제에서 이를 피하기 위해 어떤 선택을 했는지(또는 했을지) 쓰라.

---

## 제출

- 압축파일 `학번_이름_08_metatables.zip`
  - `metatable_tasks.lua`
  - `REPORT_08_metatables.md`
  - 테스트 실행 결과 화면 캡처 1장 (마지막 점수 부분)
- 마감: 수업 게시판 공지 참조

## 감점

- 전역 변수 사용 (문제당 −2점)
- 테스트 파일 수정 후 통과 (해당 문제 0점) — 채점은 원본 테스트로 다시 실행한다.
- 보고서에 줄 번호 인용 없음 (해당 문항 −50%)
