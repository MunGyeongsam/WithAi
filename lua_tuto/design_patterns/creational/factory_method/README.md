# Factory Method

[전체 검토 기준과 학습 순서](../../STUDY_GUIDE.md)

## 핵심 개념

Factory Method는 객체 생성 코드를 사용하는 코드에서 분리하고, **공통 생성 흐름은 유지한 채 구체 제품을 만드는 메서드만 바꾸는 패턴**입니다.

```mermaid
sequenceDiagram
	participant Client as 호출 코드
	participant Creator as Creator
	participant Method as create_product
	participant Product as Concrete Product
	Client->>Creator: spawn/create()
	Creator->>Method: Factory Method 호출
	Method-->>Creator: 제품 반환
	Creator-->>Client: 공통 계약의 제품
```
---
```mermaid
flowchart TB
	Client[호출 코드] --> Creator[Creator의 공통 흐름]
	Creator --> FactoryMethod[create_product]
	ConcreteCreatorA[Concrete Creator A] -.구현 교체.-> FactoryMethod
	ConcreteCreatorB[Concrete Creator B] -.구현 교체.-> FactoryMethod
	FactoryMethod --> Product[Product 공통 계약]
	Product --> ConcreteProductA[Concrete Product A]
	Product --> ConcreteProductB[Concrete Product B]
```

### 역할

- **Creator**: 제품을 만든 뒤 공통 후처리를 수행하는 흐름을 소유합니다.
- **Factory Method**: 실제 제품 생성을 하위 Creator나 주입된 함수에 맡깁니다.
- **Concrete Creator**: 어떤 Concrete Product를 만들지 결정합니다.
- **Product**: 호출 코드가 사용하는 공통 계약을 제공합니다.

전통적인 구현에서는 Creator를 상속한 Concrete Creator가 Factory Method를 오버라이드합니다. Lua에서는 상속 대신 메타테이블, Creator 생성 함수, 또는 생성 함수 주입으로 같은 의도를 표현할 수 있습니다.

Lua에는 클래스 상속이 필수는 아니므로 두 가지 표현을 구분합니다.

- 명시적 Factory Method: Creator 테이블의 `create_product`를 구체 Creator가 구현하고 공통 흐름이 호출함
- 실용적 Lua 변형: Creator가 생성 함수를 주입받아 공통 후처리와 생성 책임을 분리함

## 해결하려는 문제

호출 코드나 Creator의 여러 메서드가 `Slime`, `Boss`, `Popup`처럼 구체 제품을 직접 만들면, 새 제품을 추가할 때 생성한 뒤의 초기화·등록·전송 흐름도 함께 수정해야 합니다. 이 분기가 퍼지면 제품 종류에 따라 조건문이 늘고, 제품을 사용하는 코드가 구체 제품의 생성 방식에 결합됩니다.

Factory Method는 제품 생성 호출을 `create_product` 같은 메서드로 모읍니다. Creator의 본업은 제품을 만든 뒤 사용하는 공통 흐름이며, Factory Method는 그 흐름이 어떤 구체 제품을 사용할지만 바꿉니다. 모든 제품은 Creator가 실제로 사용하는 공통 계약을 지켜야 합니다.

## 읽는 포인트

- 호출 코드는 생성 결과의 공통 인터페이스만 사용합니다.
- Creator와 Product의 책임을 구분합니다.
- 모든 예제는 `create_*` 메서드와 공통 생성 흐름을 분리합니다.
- 제품 종류가 많아질 때 조건문을 호출 코드에 추가하지 않고 Concrete Creator를 추가하는 방향을 보여줍니다.

## 도입 절차

1. Creator가 실제로 사용하는 Product의 공통 동작을 정합니다.
2. Creator에 그 계약의 제품을 반환하는 `create_product` 메서드를 둡니다.
3. 직접 생성하던 부분을 Factory Method 호출로 바꾸고, 생성 이후의 공통 흐름은 Creator에 남깁니다.
4. 제품 종류별 Concrete Creator를 만들고 Factory Method만 다르게 구현합니다.
5. Creator가 기본 제품을 제공할지, 모든 구체 Creator가 구현하도록 둘지 결정합니다.

Factory Method는 매번 새 제품을 만들 필요가 없습니다. 계약을 지킨다면 캐시, 오브젝트 풀, 재사용 가능한 리소스에서 기존 제품을 반환할 수도 있습니다.

## 장점과 비용

- Creator와 Concrete Product의 결합을 줄이고, 제품 생성 코드를 한 곳에 모읍니다.
- 새 Product와 Creator를 추가해도 기존 호출 코드는 공통 계약을 계속 사용합니다.
- Lua에서는 메타테이블이나 함수 주입으로 상속 계층의 비용을 줄일 수 있습니다.
- 제품 종류가 적고 생성 후 공통 흐름이 없다면 단순 생성 함수가 더 명확합니다.
- 전통적인 구현은 Creator와 Product의 하위 타입이 늘어나 구조가 복잡해질 수 있습니다.

## 주의

단순 조건문 하나를 Factory Method라고 부르는 것보다, 생성 책임과 사용 책임이 실제로 분리되는지를 먼저 확인합니다. 제품 종류를 선택하는 코드와 제품을 사용하는 코드가 같은 곳에 있다면 아직 분리가 덜 된 것입니다.

## 예제별 학습 순서

- `example_01.lua`: 메타테이블 기반 Concrete Creator가 Enemy를 생성합니다.
- `example_02.lua`: Popup·Email Creator가 같은 전송 흐름에 서로 다른 알림 제품을 제공합니다.
- `example_03.lua`: 도형 Creator가 구체 도형과 공통 면적 계약을 생성합니다.
- `example_04.lua`: Parser Creator가 입력 종류별 Parser 제품을 생성합니다.
- `example_05.lua`: Weapon Creator가 무기 제품을 생성하고 공통 장비 흐름을 사용합니다.

## Simple Factory와의 차이

Simple Factory는 하나의 함수가 종류를 보고 제품을 선택해 생성합니다. Factory Method는 Creator의 공통 흐름은 유지하면서 구체 Creator가 제품 생성 방법을 바꿉니다. Lua에서는 상속 대신 메타테이블, 생성자 테이블, 또는 함수 주입으로 이 의도를 표현할 수 있습니다.

## 관련 패턴과의 차이

- **Abstract Factory**: 관련된 여러 제품군을 함께 생성합니다. Abstract Factory는 여러 Factory Method를 묶어 구성할 수 있습니다.
- **Template Method**: 알고리즘의 순서를 고정하고 일부 단계를 하위 구현이 바꾸게 합니다. Factory Method는 그런 템플릿 흐름 안에서 제품을 만드는 한 단계가 될 수 있습니다.
- **Prototype**: 기존 객체를 복제해 제품을 만듭니다. Factory Method는 Creator가 어떤 제품을 반환할지 하위 구현으로 바꿉니다.

## 게임 개발 시나리오

타입 식별자에 따라 알맞은 객체를 생성하되 호출자가 구체 클래스를 몰라도 되게 할 때 Factory Method가 유용합니다.

- **적 생성기**: 스폰 테이블의 `"goblin"`, `"archer"`, `"boss"` 같은 문자열로 해당 적 인스턴스를 만들어, 웨이브 데이터만 바꾸면 새 적이 등장합니다.
- **발사체 생성**: 무기 종류에 따라 일반 총알·유도 미사일·레이저를 만들어 반환하고, 발사 코드는 생성 방식을 알 필요가 없습니다.
- **파워업/아이템 생성**: 드롭 확률표에서 뽑힌 종류에 맞는 아이템 객체(회복·방패·점수)를 생성합니다.
- **타일 객체 생성**: 맵 데이터의 타일 코드로 벽·바닥·함정 객체를 생성합니다.

## Lua와 LÖVE2D에서의 유용성

- 적, 아이템, 투사체, 이펙트 생성 흐름을 공통화할 때
- 파일 형식별 Loader나 입력 장치별 Adapter를 생성할 때
- 테스트 Creator와 실제 Creator를 교체할 때
- 제품 생성 후 공통 초기화·등록·로깅을 항상 수행해야 할 때

제품이 하나뿐이거나 생성 분기가 단순하면 생성 함수 하나가 더 읽기 쉽습니다. Factory Method를 도입했다면 Creator의 공통 흐름과 Product의 계약이 실제로 존재해야 하며, 단순히 `kind`를 받아 조건문으로 반환하는 함수는 Simple Factory로 분류하는 편이 정확합니다.
