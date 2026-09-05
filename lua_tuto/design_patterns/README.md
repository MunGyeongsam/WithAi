# Lua 디자인 패턴 예제

Lua 5.1/LuaJIT에서 실행할 수 있는 작은 독립 예제 모음입니다.

상세한 개념 설명, 협력 구조, Lua 구현 기준, Mermaid 그림, 패턴별 판단 기준은 [단계별 학습 가이드](STUDY_GUIDE.md)에서 확인합니다.

## 구성

### 생성 패턴

`creational/`에는 객체 생성 책임을 분리하는 5개 패턴이 있습니다.

- `abstract_factory/`
- `builder/`
- `factory_method/`
- `prototype/`
- `singleton/`

### 구조 패턴

`structural/`에는 객체와 모듈을 더 큰 구조로 조합하는 7개 패턴이 있습니다.

- `adapter/`
- `bridge/`
- `composite/`
- `decorator/`
- `facade/`
- `flyweight/`
- `proxy/`

### 행동 패턴

`behavioral/`에는 알고리즘과 객체 간 책임을 나누는 10개 패턴이 있습니다.

- `chain_of_responsibility/`
- `command/`
- `iterator/`
- `mediator/`
- `memento/`
- `observer/`
- `state/`
- `strategy/`
- `template_method/`
- `visitor/`

각 패턴 폴더에는 `README.md`와 `example_01.lua`부터 `example_05.lua`까지 5개의 독립 예제가 있습니다.

## 중요도·난이도 요약

중요도는 게임 코드에서의 재사용성과 영향도, 난이도는 Lua에서 이해·구현하는 부담을 뜻합니다. 상세한 판단 근거는 [STUDY_GUIDE.md](STUDY_GUIDE.md)에 있습니다.

| 학습 단계 | 우선 패턴 | 중요도·난이도 요약 |
| --- | --- | --- |
| 1단계 | `strategy`, `state`, `observer`, `factory_method`, `command` | 실전 중요도가 높고 Lua 기본기와 직접 연결됨 |
| 2단계 | `adapter`, `facade`, `composite`, `memento`, `decorator`, `mediator`, `prototype` | 실제 시스템 확장과 결합도 문제에 유용함 |
| 3단계 | `proxy`, `chain_of_responsibility`, `abstract_factory`, `bridge`, `flyweight`, `template_method` | 구조가 커지고 변경 축이 늘어날 때 학습 |
| 4단계 | `singleton`, `builder`, `iterator`, `visitor` | Lua의 단순한 함수·테이블 대안과 비교하며 학습 |

## 추천 학습 순서

1. `strategy` → `state` → `observer`
2. `factory_method` → `command`
3. `adapter` → `facade` → `composite`
4. `decorator` → `memento` → `prototype` → `mediator`
5. `proxy` → `chain_of_responsibility` → `abstract_factory`
6. `bridge` → `flyweight` → `template_method`
7. `singleton` → `builder` → `iterator` → `visitor`

README에서는 대표 예제 하나를 먼저 읽고, 나머지 예제는 응용 차이를 비교하는 방식으로 학습합니다. 패턴별 상세 정의, 협력 다이어그램, Lua식 대안, LÖVE2D 적용 판단은 [STUDY_GUIDE.md](STUDY_GUIDE.md)를 기준으로 확인합니다.

## 실행

저장소 루트에서 다음처럼 실행합니다.

```sh
lua lua_tuto/design_patterns/creational/singleton/example_01.lua
```

모든 예제의 문법만 확인하려면 다음 명령을 사용할 수 있습니다.

```sh
for file in lua_tuto/design_patterns/*/*/*.lua; do lua "$file" >/dev/null || exit 1; done
```
