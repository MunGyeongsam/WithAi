# Lua ↔ C / C# 빠른 비교표

> C/C# 개발자가 Lua 코드를 작성할 때 빠르게 참조하는 치트시트.

---

## 기본 문법

| 항목 | C | C# | Lua |
|------|---|-----|-----|
| 주석 | `// 한줄` `/* 여러줄 */` | `// 한줄` `/* 여러줄 */` | `-- 한줄` `--[[ 여러줄 ]]` |
| 변수 선언 | `int x = 5;` | `int x = 5;` `var x = 5;` | `local x = 5` |
| 상수 | `const int X = 5;` | `const int X = 5;` | (관례: `local X = 5`) |
| null/nil | `NULL` | `null` | `nil` |
| 출력 | `printf("hi\n");` | `Console.WriteLine("hi");` | `print("hi")` |
| 문장 끝 | `;` 필수 | `;` 필수 | 없음 (선택적) |

## 타입

| C | C# | Lua |
|---|-----|-----|
| `int`, `float`, `double` | `int`, `float`, `double` | `number` (전부 double) |
| `char*` | `string` | `string` (불변) |
| `int[]` | `int[]`, `List<int>` | `table` (1-based!) |
| `struct` | `class`, `struct` | `table` |
| `enum` | `enum` | (없음, 테이블로 대체) |
| `void*` | `object` | `userdata` |

## 제어문

| C / C# | Lua |
|---------|-----|
| `if (x > 0) { }` | `if x > 0 then end` |
| `else if` | `elseif` (붙여 씀) |
| `switch (x) { case: }` | (없음, if-elseif 또는 테이블 디스패치) |
| `for (i=0; i<10; i++)` | `for i = 0, 9 do end` (끝값 포함!) |
| `while (x) { }` | `while x do end` |
| `do { } while (x);` | `repeat until not x` |
| `break;` | `break` |
| `continue;` | (Lua 5.1에 없음! goto는 LuaJIT 가능) |
| `x++; x += 5;` | `x = x + 1; x = x + 5` |
| `x ? a : b` | `x and a or b` (⚠️ a가 false면 깨짐) |

## 비교/논리 연산

| C / C# | Lua |
|---------|-----|
| `==` | `==` |
| `!=` | `~=` ⚠️ |
| `&&` | `and` |
| `\|\|` | `or` |
| `!` | `not` |
| `0`은 false | `0`은 **true** ⚠️ |
| `""`은 true(C#) | `""`은 **true** |
| `null`은 false | `nil`은 false |

## 함수

| C / C# | Lua |
|---------|-----|
| `int add(int a, int b) { return a+b; }` | `local function add(a, b) return a+b end` |
| 반환값 1개 | 반환값 여러 개 가능 |
| `out`, `ref` 파라미터 | 다중 반환으로 대체 |
| 함수 오버로딩 | (없음, 조건분기로 대체) |
| `delegate`, `Func<>` | 함수가 일급 객체 |
| 람다: `(x) => x * 2` | `function(x) return x * 2 end` |

## 문자열

| C / C# | Lua |
|---------|-----|
| `+` (C#) 연결 | `..` 연결 |
| `string.Format("{0}", x)` | `string.format("%s", x)` |
| `str.Length` | `#str` |
| `str.Substring(0, 5)` | `string.sub(str, 1, 5)` (1-based!) |
| `str.ToUpper()` | `string.upper(str)` 또는 `str:upper()` |
| `Regex.Match()` | `string.match()` (Lua 패턴 ≠ 정규식) |
| `StringBuilder` | `table.concat()` |

## 배열 / 컬렉션

| C / C# | Lua |
|---------|-----|
| `int[] arr = {1,2,3};` | `local arr = {1,2,3}` |
| 0-based 인덱스 | 1-based 인덱스 ⚠️ |
| `arr.Length` / `list.Count` | `#arr` |
| `list.Add(x)` | `arr[#arr+1] = x` 또는 `table.insert(arr, x)` |
| `list.RemoveAt(i)` | `table.remove(arr, i)` |
| `list.Sort()` | `table.sort(arr)` |
| `Dictionary<K,V>` | `table` (같은 것!) |
| `dict[key] = val` | `t[key] = val` (동일) |
| `dict.Remove(key)` | `t[key] = nil` |
| `foreach (var x in list)` | `for i, v in ipairs(arr) do end` |
| `foreach (var kv in dict)` | `for k, v in pairs(t) do end` |

## OOP

| C# | Lua |
|-----|-----|
| `class Enemy { }` | `local Enemy = {}; Enemy.__index = Enemy` |
| `new Enemy()` | `Enemy.new()` (직접 구현) |
| `this.hp` | `self.hp` (`: 문법`으로 자동 전달) |
| `base.Method()` | `ParentClass.Method(self)` (직접 호출) |
| `obj.Method()` | `obj:Method()` (`:` = self 자동 전달) |
| 상속: `class B : A` | `setmetatable(B, {__index = A})` |
| `interface` | (없음, 덕 타이핑) |
| `operator +` | `__add` 메타메서드 |
| `override` | 같은 이름으로 재정의 (자동 오버라이드) |
| `virtual` | (모든 메서드가 virtual) |
| `is` 타입 체크 | `type(x) == "table"` + instanceof 직접 구현 |

## 에러 처리

| C# | Lua |
|-----|-----|
| `try { } catch { }` | `pcall(func)` |
| `throw new Exception()` | `error("msg")` |
| `finally { }` | (없음, 수동 정리) |
| 스택 트레이스 자동 | `xpcall()` + `debug.traceback()` |
| `Debug.Assert()` | `assert(condition, msg)` |

## 모듈

| C# | Lua |
|-----|-----|
| `using System;` | `local sys = require("system")` |
| `namespace MyGame { }` | `local M = {} ... return M` |
| `public` / `private` | 반환 테이블에 포함 / 미포함 |
| `static` 클래스 | 모듈 테이블 |

## 흔한 실수 TOP 10

1. **배열 인덱스가 1부터** (`arr[0]`은 nil)
2. **`!=` 대신 `~=`**
3. **`0`이 참** (C에서는 거짓)
4. **`local` 빼먹으면 전역** (자동으로!)
5. **`++`, `+=` 없음** (`x = x + 1`)
6. **`continue` 없음** (Lua 5.1)
7. **문자열 연결은 `..`** (`+` 하면 숫자 변환!)
8. **`:` vs `.` 혼동** (self 전달 여부)
9. **`#` 연산자가 nil 구멍에서 불안정**
10. **정수 나눗셈 없음** (`7/2 = 3.5`, `math.floor` 필요)
