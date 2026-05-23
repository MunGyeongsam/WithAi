# Lua 5.1.5 게임 개발 강좌

> **대상**: C / C# 게임 개발 경험이 있는 학생  
> **목표**: Lua 언어를 익히고 LÖVE2D로 게임을 만들 수 있는 수준까지  
> **Lua 버전**: 5.1.5 (LÖVE2D 11.x 내장 버전, LuaJIT 호환)

---

## 학습 순서

### Phase 1: Lua 언어 기초 (C/C# 대비)

| # | 파일 | 주제 |
|---|------|------|
| 01 | [01_intro.md](01_intro.md) | Lua란? 왜 게임에서 쓰나? |
| 02 | [02_types_and_variables.md](02_types_and_variables.md) | 타입 & 변수 & 스코프 |
| 03 | [03_control_flow.md](03_control_flow.md) | 제어문 & 연산자 |
| 04 | [04_strings.md](04_strings.md) | 문자열 |
| 05 | [05_functions.md](05_functions.md) | 함수 |

### Phase 2: Lua 핵심 — 테이블과 OOP

| # | 파일 | 주제 |
|---|------|------|
| 06 | [06_tables_basics.md](06_tables_basics.md) | 테이블 기초 |
| 07 | [07_tables_advanced.md](07_tables_advanced.md) | 테이블 심화 |
| 08 | [08_metatables.md](08_metatables.md) | 메타테이블 |
| 09 | [09_oop_patterns.md](09_oop_patterns.md) | OOP 패턴 |
| 10 | [10_modules.md](10_modules.md) | 모듈 시스템 |

### Phase 3: LÖVE2D 기초

| # | 파일 | 주제 |
|---|------|------|
| 11 | [11_love2d_lifecycle.md](11_love2d_lifecycle.md) | LÖVE2D 생명주기 |
| 12 | [12_drawing.md](12_drawing.md) | 그리기 |
| 13 | [13_input.md](13_input.md) | 입력 처리 |
| 14 | [14_audio_and_assets.md](14_audio_and_assets.md) | 오디오 & 리소스 |

### Phase 4: 게임 개발 패턴

| # | 파일 | 주제 |
|---|------|------|
| 15 | [15_game_loop_pattern.md](15_game_loop_pattern.md) | 게임 루프 & 상태머신 |
| 16 | [16_entity_management.md](16_entity_management.md) | 엔티티 관리 |
| 17 | [17_collision.md](17_collision.md) | 충돌 처리 |
| 18 | [18_coroutines_for_games.md](18_coroutines_for_games.md) | 코루틴 활용 |
| 19 | [19_ecs_intro.md](19_ecs_intro.md) | ECS 패턴 입문 |

### Phase 5: 실전 & 최적화

| # | 파일 | 주제 |
|---|------|------|
| 20 | [20_error_handling.md](20_error_handling.md) | 에러 처리 |
| 21 | [21_performance.md](21_performance.md) | 성능 최적화 |
| 22 | [22_c_api_overview.md](22_c_api_overview.md) | C API 개요 |
| 23 | [23_mini_project.md](23_mini_project.md) | 미니 프로젝트 |

### 보조 자료

| 파일 | 용도 |
|------|------|
| [cheatsheet.md](cheatsheet.md) | Lua ↔ C/C# 빠른 비교표 |
| [lua_builtin_index.md](lua_builtin_index.md) | Lua 5.1 기본 함수/표준 라이브러리 색인 |
| [exercises/](exercises/) | 챕터별 연습문제 정답 코드 |

---

## 환경 설정

### LÖVE2D 설치
- **공식 사이트**: https://love2d.org/
- **버전**: 11.5 권장 (Lua 5.1 + LuaJIT)
- macOS: `brew install love`
- Windows: 공식 zip 또는 installer

### 실행 방법
```bash
# 프로젝트 폴더에서
love .

# 또는 특정 폴더 지정
love /path/to/game/
```

### 에디터 추천
- **VS Code** + Lua 확장 (sumneko lua-language-server)
- ZeroBrane Studio (Lua 전용 IDE)

---

## 표기 규칙

- `-- C/C# 비교` : C 또는 C#과 비교하는 코멘트
- `-- ⚠️ 주의` : 흔한 실수 또는 C/C#과 다른 동작
- `-- 💡 팁` : 실전에서 유용한 패턴
- **[연습문제]** : 각 챕터 끝에 위치, 정답은 `exercises/` 폴더
