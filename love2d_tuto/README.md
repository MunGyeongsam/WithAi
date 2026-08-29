# LÖVE2D 게임 개발 강좌

> **대상**: Lua 기초 문법을 아는 학생 (변수, 함수, 테이블, 모듈 수준)
> **목표**: LÖVE2D로 2D 게임을 처음부터 끝까지 만들고 배포할 수 있는 수준까지
> **LÖVE2D 버전**: 11.5 (LuaJIT 기반)
> **선수 지식**: `lua_tuto/` Phase 1~2 수준 또는 동등한 Lua 경험

---

## 학습 순서

### Phase 1: LÖVE2D 입문

| # | 파일 | 주제 |
|---|------|------|
| 01 | [01_setup.md](01_setup.md) | 환경 설정 & 첫 실행 |
| 02 | [02_game_loop.md](02_game_loop.md) | 게임 루프 & 생명주기 |
| 03 | [03_drawing.md](03_drawing.md) | 그리기 기초 (도형, 색상, 좌표계) |
| 04 | [04_input.md](04_input.md) | 키보드 & 마우스 입력 |
| 05 | [05_movement.md](05_movement.md) | 움직임과 델타 타임 |

### Phase 2: 리소스 & 표현

| # | 파일 | 주제 |
|---|------|------|
| 06 | [06_images.md](06_images.md) | 이미지 & 스프라이트 |
| 07 | [07_animation.md](07_animation.md) | 스프라이트 애니메이션 |
| 08 | [08_text.md](08_text.md) | 텍스트 & 폰트 |
| 09 | [09_audio.md](09_audio.md) | 사운드 & 음악 |

### Phase 3: 게임 구조

| # | 파일 | 주제 |
|---|------|------|
| 10 | [10_scenes.md](10_scenes.md) | 씬 관리 (상태머신) |
| 11 | [11_collision.md](11_collision.md) | 충돌 처리 |
| 12 | [12_tilemap.md](12_tilemap.md) | 타일맵 |
| 13 | [13_camera.md](13_camera.md) | 카메라 & 뷰포트 |

### Phase 4: 고급 기능

| # | 파일 | 주제 |
|---|------|------|
| 14 | [14_physics.md](14_physics.md) | Box2D 물리 엔진 |
| 15 | [15_particles.md](15_particles.md) | 파티클 시스템 |
| 16 | [16_canvas.md](16_canvas.md) | 캔버스 & 렌더 타겟 |
| 17 | [17_shaders.md](17_shaders.md) | 셰이더 (GLSL) |

### Phase 5: 실전 & 배포

| # | 파일 | 주제 |
|---|------|------|
| 18 | [18_save_load.md](18_save_load.md) | 저장 & 불러오기 |
| 19 | [19_mobile.md](19_mobile.md) | 터치 입력 & 모바일 |
| 20 | [20_performance.md](20_performance.md) | 성능 최적화 |
| 21 | [21_distribution.md](21_distribution.md) | 빌드 & 배포 |
| 22 | [22_mini_project.md](22_mini_project.md) | 미니 프로젝트 (종합 게임) |

### 보조 자료

| 파일 | 용도 |
|------|------|
| [exercises/](exercises/) | 챕터별 실습 코드 |

---

## lua_tuto와의 관계

`lua_tuto/`는 **Lua 언어 자체**를 다루고, 이 강좌는 **LÖVE2D 프레임워크 활용**에 집중한다.
`lua_tuto/` Phase 3~5에서 LÖVE2D를 간략히 소개하지만, 이 강좌는 더 깊고 실습 중심이다.

```
lua_tuto/            → Lua 문법, 테이블, OOP, 모듈 (언어 중심)
love2d_tuto/         → LÖVE2D 그리기, 입력, 물리, 셰이더, 배포 (프레임워크 중심)
```

---

## 환경 설정

### LÖVE2D 설치
- **공식 사이트**: https://love2d.org/
- **버전**: 11.5 권장
- macOS: `brew install love` 또는 `love-11.5-mac/love.app` 사용
- Windows: `love-11.5-win64/` 폴더 사용 또는 공식 installer

### 실행 방법
```bash
# main.lua가 있는 폴더에서
love .

# VS Code task 사용
# "Love2D: Run project" task 실행
```

### 각 챕터 예제 실행
```bash
# 챕터별 예제 폴더에서
love exercises/ch03_drawing/
```
