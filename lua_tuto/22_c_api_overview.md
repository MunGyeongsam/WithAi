# 22. C API 개요 (선택)

> Lua가 C/C++ 엔진에 임베딩되는 원리.  
> LÖVE2D 내부가 이 방식으로 동작한다.  
> C 경험이 있으므로 원리를 이해하면 LÖVE2D를 더 잘 활용할 수 있다.

## Lua-C 통신: 가상 스택

```
Lua와 C는 "가상 스택"을 통해 값을 주고받는다.

Lua 코드                    C 코드
─────────                  ──────
                    ┌─────────────┐
result = add(3, 4)  │   Stack     │  int add(lua_State *L)
                    │  [1] = 3    │  {
                    │  [2] = 4    │      int a = lua_tointeger(L, 1);
                    │             │      int b = lua_tointeger(L, 2);
                    │  result = 7 │      lua_pushinteger(L, a + b);
                    └─────────────┘      return 1;  // 반환값 1개
                                     }
```

## 최소 임베딩 예제 (C)

```c
#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>

int main(void) {
    // 1. Lua 상태 생성
    lua_State *L = luaL_newstate();
    luaL_openlibs(L);          // 표준 라이브러리 열기
    
    // 2. Lua 코드 실행
    luaL_dostring(L, "print('Hello from Lua!')");
    
    // 3. Lua 파일 실행
    luaL_dofile(L, "script.lua");
    
    // 4. 정리
    lua_close(L);
    return 0;
}
```

## C에서 Lua 함수 호출

```c
// Lua: function damage(hp, amount) return hp - amount end

// C에서 호출:
lua_getglobal(L, "damage");   // 스택에 함수 push
lua_pushinteger(L, 100);      // 첫 번째 인자: hp = 100
lua_pushinteger(L, 30);       // 두 번째 인자: amount = 30
lua_call(L, 2, 1);            // 인자 2개, 반환값 1개

int result = lua_tointeger(L, -1);  // 스택 꼭대기에서 결과 가져오기
lua_pop(L, 1);                      // 스택에서 제거

printf("Result: %d\n", result);     // 70
```

## Lua에서 호출할 C 함수 등록

```c
// C 함수 (Lua에서 호출 가능)
static int l_shoot(lua_State *L) {
    double x = luaL_checknumber(L, 1);
    double y = luaL_checknumber(L, 2);
    double angle = luaL_checknumber(L, 3);
    
    // C 엔진에서 총알 생성
    create_bullet(x, y, angle);
    
    // 성공 여부 반환
    lua_pushboolean(L, 1);
    return 1;    // 반환값 1개
}

// 등록
lua_register(L, "shoot", l_shoot);
```

```lua
-- Lua에서 사용
shoot(100, 200, 3.14)
```

## C 모듈 (라이브러리)

```c
// mylib.c
static int l_add(lua_State *L) {
    int a = luaL_checkinteger(L, 1);
    int b = luaL_checkinteger(L, 2);
    lua_pushinteger(L, a + b);
    return 1;
}

static int l_multiply(lua_State *L) {
    int a = luaL_checkinteger(L, 1);
    int b = luaL_checkinteger(L, 2);
    lua_pushinteger(L, a * b);
    return 1;
}

// 함수 테이블
static const luaL_Reg mylib[] = {
    {"add", l_add},
    {"multiply", l_multiply},
    {NULL, NULL}    // 종료 표시
};

// 모듈 열기 함수
int luaopen_mylib(lua_State *L) {
    luaL_register(L, "mylib", mylib);
    return 1;
}
```

```lua
-- Lua에서 사용
local mylib = require("mylib")   -- .so/.dll 자동 로드
print(mylib.add(3, 4))           -- 7
print(mylib.multiply(3, 4))      -- 12
```

## LÖVE2D 내부 구조

```
LÖVE2D = C++ 엔진 + Lua 스크립팅

love.graphics.circle("fill", 400, 300, 50)
→ Lua 호출
→ C++의 Graphics::circle() 실행
→ OpenGL 렌더링

실제 흐름:
1. love.graphics = C++에서 등록한 Lua 테이블
2. circle = 테이블의 C 함수 (lua_CFunction)
3. 인자를 Lua 스택에서 읽어 C++ 코드 실행
```

```
-- LÖVE2D가 제공하는 모듈 (전부 C++로 구현):
love.graphics   → SDL2 + OpenGL
love.audio      → OpenAL
love.physics    → Box2D
love.filesystem → PhysicsFS
love.timer      → SDL2 timer
love.keyboard   → SDL2 input
love.mouse      → SDL2 input
love.window     → SDL2 window
```

## 스택 조작 함수 요약

```c
// 값 push (C → 스택)
lua_pushnil(L);
lua_pushboolean(L, 1);
lua_pushinteger(L, 42);
lua_pushnumber(L, 3.14);
lua_pushstring(L, "hello");
lua_pushcfunction(L, my_func);

// 값 read (스택 → C) — 양수: 바닥부터, 음수: 꼭대기부터
int b = lua_toboolean(L, 1);
int n = lua_tointeger(L, 2);
double d = lua_tonumber(L, -1);     // 꼭대기
const char *s = lua_tostring(L, -2);

// 타입 확인
int type = lua_type(L, 1);   // LUA_TNIL, LUA_TNUMBER, LUA_TSTRING, ...
int isNum = lua_isnumber(L, 1);

// 스택 조작
lua_pop(L, n);           // n개 제거
lua_gettop(L);           // 스택 크기
lua_settop(L, n);        // 스택 크기 설정
lua_pushvalue(L, idx);   // 복사
lua_remove(L, idx);      // 특정 위치 제거
lua_insert(L, idx);      // 특정 위치에 삽입

// 테이블 조작
lua_newtable(L);                    // {} 생성
lua_getfield(L, idx, "key");       // t.key
lua_setfield(L, idx, "key");       // t.key = 스택 꼭대기
lua_rawgeti(L, idx, n);            // t[n] (메타메서드 무시)
lua_rawseti(L, idx, n);            // t[n] = 스택 꼭대기

// 전역 테이블
lua_getglobal(L, "name");          // 전역 변수 읽기
lua_setglobal(L, "name");          // 전역 변수 설정
```

## 실전: C 확장으로 성능 크리티컬 코드 작성

```c
// 대량 충돌 검사를 C로 구현하면 10~100배 빠를 수 있다
static int l_checkCollisions(lua_State *L) {
    // 인자: bullets 테이블, enemies 테이블
    luaL_checktype(L, 1, LUA_TTABLE);
    luaL_checktype(L, 2, LUA_TTABLE);
    
    int bulletCount = lua_objlen(L, 1);
    int enemyCount = lua_objlen(L, 2);
    
    lua_newtable(L);  // 결과 테이블
    int resultIdx = 0;
    
    for (int i = 1; i <= bulletCount; i++) {
        lua_rawgeti(L, 1, i);
        lua_getfield(L, -1, "x"); double bx = lua_tonumber(L, -1); lua_pop(L, 1);
        lua_getfield(L, -1, "y"); double by = lua_tonumber(L, -1); lua_pop(L, 1);
        lua_getfield(L, -1, "radius"); double br = lua_tonumber(L, -1); lua_pop(L, 1);
        lua_pop(L, 1);  // bullet 테이블 pop
        
        for (int j = 1; j <= enemyCount; j++) {
            lua_rawgeti(L, 2, j);
            lua_getfield(L, -1, "x"); double ex = lua_tonumber(L, -1); lua_pop(L, 1);
            lua_getfield(L, -1, "y"); double ey = lua_tonumber(L, -1); lua_pop(L, 1);
            lua_getfield(L, -1, "radius"); double er = lua_tonumber(L, -1); lua_pop(L, 1);
            lua_pop(L, 1);  // enemy 테이블 pop
            
            double dx = ex - bx, dy = ey - by;
            double distSq = dx*dx + dy*dy;
            double radiusSum = br + er;
            
            if (distSq <= radiusSum * radiusSum) {
                resultIdx++;
                lua_newtable(L);
                lua_pushinteger(L, i); lua_setfield(L, -2, "bullet");
                lua_pushinteger(L, j); lua_setfield(L, -2, "enemy");
                lua_rawseti(L, -2, resultIdx);
            }
        }
    }
    
    return 1;  // 결과 테이블 반환
}
```

> 이 장은 참고용이다. LÖVE2D 게임 개발에서 C API를 직접 사용할 일은 드물다.  
> 하지만 LÖVE2D가 **왜** 빠른지, 확장은 **어떻게** 하는지 이해하는 데 도움이 된다.

---

## 연습문제

### 연습 22-1: 스택 추적
아래 C 코드의 스택 상태를 각 줄마다 그려라.

```c
lua_pushinteger(L, 10);    // 스택: ?
lua_pushstring(L, "hello"); // 스택: ?
lua_pushinteger(L, 20);    // 스택: ?
lua_remove(L, 2);          // 스택: ?
lua_pushvalue(L, 1);       // 스택: ?
```

### 연습 22-2: 개념 이해
`love.graphics.circle("fill", 400, 300, 50)` 호출 시:
1. Lua 스택에 어떤 값들이 올라가는가?
2. C++ 쪽에서 어떤 순서로 값을 읽는가?
3. 반환값은 있는가?

### 연습 22-3: (선택) C 함수 작성
두 2D 벡터의 내적을 계산하는 C 함수를 작성하라 (의사 코드도 가능).
Lua에서 `dot(x1, y1, x2, y2)` 형태로 호출할 수 있어야 한다.

---

[← 이전: 21. 성능 최적화](21_performance.md) | [다음: 23. 미니 프로젝트 →](23_mini_project.md)

## 모범 답안

### 22-1
스택 변화:
1. `pushinteger(10)` -> `[10]`
2. `pushstring("hello")` -> `[10, "hello"]`
3. `pushinteger(20)` -> `[10, "hello", 20]`
4. `remove(2)` -> `[10, 20]`
5. `pushvalue(1)` -> `[10, 20, 10]`

### 22-2
`love.graphics.circle("fill", 400, 300, 50)` 호출 시 Lua 스택 인자는 순서대로 타입 문자열과 숫자 3개가 올라간다.
C++ 바인딩 함수는 인덱스 1부터 순차적으로 읽고, 보통 반환값이 없으면 `return 0`이다.

### 22-3
```c
static int l_dot(lua_State* L) {
    double x1 = luaL_checknumber(L, 1);
    double y1 = luaL_checknumber(L, 2);
    double x2 = luaL_checknumber(L, 3);
    double y2 = luaL_checknumber(L, 4);
    lua_pushnumber(L, x1 * x2 + y1 * y2);
    return 1;
}
```
