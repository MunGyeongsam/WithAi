# Visitor

[전체 검토 기준과 학습 순서](../../STUDY_GUIDE.md)

## 핵심 개념

Visitor는 객체 구조와 그 구조에 수행할 연산을 분리하는 패턴입니다. 객체 종류가 안정적이고, 구조에 적용할 연산이 계속 늘어날 때 유용합니다.

```mermaid
sequenceDiagram
	participant Client as 호출 코드
	participant Element as Element
	participant Visitor as Visitor
	Client->>Element: accept(visitor)
	Element->>Visitor: visit_concrete_element(self)
	Visitor-->>Client: 연산 결과
```

이 흐름을 **이중 디스패치**라고 부릅니다. `accept`가 어떤 구체 Element인지 알고 Visitor의 알맞은 `visit_*` 메서드를 호출하기 때문입니다.

### 역할

- **Element**: 자신의 종류에 맞는 Visitor 메서드를 호출하는 `accept`를 제공합니다.
- **Concrete Element**: Enemy, Circle, Weapon처럼 구조에 속한 데이터입니다.
- **Visitor**: 각 Element에 대한 하나의 연산을 모아 둡니다.
- **Client**: Element 구조를 순회하며 Visitor를 적용합니다.

## Lua에서의 표현

Lua에서는 Visitor와 Element를 테이블로 만들고 `accept`와 `visit_*` 함수 계약을 명시합니다.

```lua
local enemy = {
	accept = function(self, visitor)
		return visitor:visit_enemy(self)
	end
}
```

작은 데이터에는 `handlers[element.kind](element)` 형태의 타입 함수 테이블로 축약할 수 있습니다. 이 방식은 실용적이지만 명시적인 `accept`가 없으므로 전통적인 Visitor와는 구분해야 합니다.

## 예제별 학습 순서

- `example_01.lua`: Enemy와 Coin의 `accept`가 조회 Visitor로 이중 디스패치합니다.
- `example_02.lua`: Circle과 Square에 면적 연산 Visitor를 적용합니다.
- `example_03.lua`: Weapon과 Armor의 설명 연산을 구조에서 분리합니다.
- `example_04.lua`: Player와 NPC의 표시 이름 연산을 별도 Visitor로 둡니다.
- `example_05.lua`: Number와 Text 토큰을 직렬화 Visitor로 처리합니다.

## Visitor를 선택하는 기준

Visitor는 **Element 종류는 안정적이고 연산 종류가 늘어나는 경우**에 적합합니다. 새 연산은 Visitor 하나를 추가하면 되지만, 새 Element 종류를 추가할 때는 모든 Visitor에 `visit_new_element`를 추가해야 합니다.

- 종류가 자주 늘어나면 일반 다형성이나 타입별 함수 테이블이 더 편할 수 있습니다.
- 연산이 하나뿐이면 Element 메서드로 두는 편이 단순합니다.
- 타입 종류와 연산이 모두 적다면 Visitor는 과한 추상화입니다.
- Iterator와 혼동하지 않습니다. Iterator는 원소 타입을 구분하지 않고 "다음 원소 접근"만 캡슐화하고, Visitor는 "원소 종류별 연산"을 이중 디스패치로 분리합니다. Iterator로 순회하며 각 원소에 Visitor를 적용해 함께 쓸 수도 있습니다.

## C++ STL로 비교하기 (Iterator vs Visitor)

두 패턴의 핵심 차이는 **"무엇을 순회하느냐"(Iterator)** 와 **"순회하면서 무엇을 할지를 분리"(Visitor)** 입니다. C++ STL에서 각각 분명하게 드러납니다.

### Iterator — STL의 `iterator`

STL 컨테이너는 내부 구조(연속 배열, 연결 리스트, 트리)를 숨기고 **동일한 순회 인터페이스**를 제공합니다. 이것이 Iterator 패턴 그 자체입니다.

```cpp
std::vector<int> v = {1, 2, 3};
std::list<int>   l = {1, 2, 3};

// 내부 구조가 완전히 다른데도 순회 코드는 동일하다
for (auto it = v.begin(); it != v.end(); ++it) std::cout << *it;
for (auto it = l.begin(); it != l.end(); ++it) std::cout << *it;
```

| 패턴 역할 | STL 대응 |
|-----------|----------|
| `Aggregate` (집합체) | `vector`, `list`, `map` |
| `createIterator()` | `begin()`, `end()` |
| `Iterator.next()` | `++it` |
| `Iterator.current()` | `*it` |
| `Iterator.hasNext()` | `it != end()` |

클라이언트는 내부 구현을 몰라도 됩니다. `std::sort`나 `std::find` 같은 알고리즘이 모든 컨테이너에 재사용되는 것도 iterator 추상화 덕분입니다.

### Visitor — `std::variant` + `std::visit`

Visitor는 **데이터 구조는 그대로 두고, 그 위에서 수행할 "연산"을 바깥에서 주입**합니다. C++17의 `std::variant` / `std::visit`가 전형적인 예입니다.

```cpp
using Shape = std::variant<Circle, Rectangle, Triangle>;

// Visitor: 타입별로 다른 동작을 모아 둔 객체
struct AreaVisitor {
	double operator()(const Circle& c)    const { return 3.14 * c.r * c.r; }
	double operator()(const Rectangle& r) const { return r.w * r.h; }
	double operator()(const Triangle& t)  const { return 0.5 * t.base * t.height; }
};

Shape s = Circle{2.0};
double area = std::visit(AreaVisitor{}, s); // 실제 타입에 맞는 operator() 호출
```

| 패턴 역할 | STL 대응 |
|-----------|----------|
| `Element` 계층 | `variant`가 담는 각 타입(`Circle`, `Rectangle`…) |
| `Visitor` | `AreaVisitor` (타입별 `operator()` 묶음) |
| `accept(visitor)` | `std::visit(visitor, var)` |
| `visit_*()` | 오버로딩된 `operator()` |

`std::visit`가 **이중 디스패치**를 대신해 줍니다. `variant`에 실제로 어떤 타입이 들어 있는지(런타임)와 어떤 연산을 할지(`AreaVisitor`)를 조합해 올바른 함수를 호출합니다. 둘레 계산 `PerimeterVisitor`를 추가해도 `Circle` 같은 데이터 타입은 수정하지 않습니다.

### 두 패턴을 함께 쓰기

실무에서는 iterator로 컨테이너를 돌면서 각 원소에 visitor를 적용하는 식으로 자주 결합합니다.

```cpp
std::vector<Shape> shapes = {Circle{1}, Rectangle{2, 3}};
double total = 0;
for (auto it = shapes.begin(); it != shapes.end(); ++it) // Iterator: 순회
	total += std::visit(AreaVisitor{}, *it);             // Visitor: 타입별 연산
```

```
Iterator : 구조를 숨기고 "순회"를 통일   → 원소를 하나씩 꺼내는 책임
Visitor  : 구조는 열어두고 "연산"을 분리  → 꺼낸 원소마다 타입별 처리
```

> 참고: 전통적 GoF Visitor는 `accept(Visitor&)` 가상 함수와 `visitCircle()` 같은 메서드로 구현하지만, 모던 C++에서는 상속 없이 같은 효과를 내는 `variant`/`visit` 조합을 더 선호합니다. 위 Lua 예제의 `accept`/`visit_*` 계약이 GoF 방식에 해당합니다.

## 게임 개발 시나리오

객체 구조는 그대로 두고 새 연산을 분리해 추가할 때 Visitor가 유용합니다.

- **엔티티별 연산 분리**: 적·아이템·발사체 같은 엔티티에 대해 렌더·충돌·저장 연산을 각각 방문자로 분리해, 엔티티 클래스를 건드리지 않고 연산을 늘립니다.
- **타일맵 처리**: 벽·물·아이템 타일에 대해 면적 집계·직렬화 같은 서로 다른 연산을 방문자로 적용합니다.
- **씬 그래프 순회 연산**: 씬 트리를 순회하며 경계상자 계산·통계 수집을 방문자로 수행합니다.
- **스킬 트리 평가**: 스킬 노드에 대해 비용 계산·유효성 검사 같은 연산을 방문자로 분리합니다.

## Lua와 LÖVE2D에서의 유용성

- 여러 엔티티 종류에 통계 집계, 저장, 디버그 표시를 추가할 때
- AST나 설정 트리에 분석·검증·직렬화 연산을 추가할 때
- 게임 오브젝트 구조는 유지하면서 렌더링·충돌 검사·리플레이 데이터를 별도 처리할 때

Visitor가 Element의 내부 필드를 과도하게 읽으면 캡슐화가 약해집니다. 필요한 데이터 조회 메서드를 제공하고, Visitor가 직접 모든 내부 상태를 조작하지 않도록 주의합니다.
