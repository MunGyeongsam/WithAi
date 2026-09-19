# Observer

[전체 검토 기준과 학습 순서](../../STUDY_GUIDE.md)

## 핵심 정의

Observer는 Subject(발행자)의 상태 변화나 사건을 여러 Observer(구독자)에게 자동으로 전달해 발행자와 수신자를 느슨하게 연결하는 패턴입니다. Subject는 구독자가 UI인지 로그인지 알지 않고, 정해진 알림 계약만 호출합니다.

Publisher/Subscriber, Event-Subscriber, Listener는 같은 구조를 가리키는 이름입니다. 이 문서에서는 Subject를 발행자, Observer를 구독자로 부릅니다.

## 해결하려는 문제

점수나 재고처럼 한 객체의 변화에 여러 객체가 반응해야 할 때, 발행자가 UI·로그·사운드·업적을 직접 호출하면 새 기능마다 발행자를 수정해야 합니다. 반대로 수신자가 계속 발행자의 상태를 조회하면 불필요한 확인 작업이 반복됩니다.

Observer는 관심 있는 객체만 런타임에 구독하고, 발행자는 사건이 발생할 때 등록된 구독자에게만 알리게 합니다. 구독자는 필요 없어지면 해제할 수 있으므로, 수신자 집합이 처음부터 정해져 있지 않거나 수명에 따라 바뀌는 경우에 적합합니다.

```mermaid
flowchart LR
	Subject[Subject: 상태 변경] -->|notify| UI[Observer: UI]
	Subject -->|notify| Log[Observer: Log]
	Subject -->|notify| Achievement[Observer: 업적]
	UI -->|unsubscribe| Subject
```

### 역할

- **Subject**: 구독 목록을 관리하고 상태 변화가 일어나면 Observer에 알립니다.
- **Observer**: 알림을 받아 자신의 표현이나 작업을 갱신합니다.
- **Client**: Subject와 필요한 Observer를 연결하고 구독 해제를 관리합니다.

## 도입 절차

1. 다른 객체와 독립적으로 유지할 핵심 기능을 발행자로 정하고, 그 변화에 반응할 코드를 구독자로 분리합니다.
2. 모든 구독자가 지킬 알림 계약을 정합니다. Lua에서는 동일한 인자의 콜백 또는 `update` 메서드가 그 계약입니다.
3. 발행자에 구독 목록과 `subscribe`, `unsubscribe`, `notify`를 둡니다. 여러 발행자가 같은 관리 규칙을 쓴다면 이벤트 디스패처 테이블로 분리합니다.
4. 중요한 상태 변화 뒤에만 `notify`를 호출하고, 필요한 이벤트 정보나 발행자 자신을 전달합니다.
5. Client가 구독자 생성·등록·해제 시점을 소유하게 합니다.

## Lua에서의 표현

Lua에서는 Observer 객체를 별도 클래스보다 함수 콜백 또는 `update` 메서드를 가진 테이블로 표현합니다. Subject의 `subscribe`가 해제 함수를 반환하게 하면 구독자의 수명을 호출자가 관리하기 쉽습니다.

### Push와 Pull

- **Push**: Subject가 변경된 값이나 payload를 Observer에게 직접 전달합니다.
- **Pull**: Subject 자신을 전달하고 Observer가 필요한 값을 getter로 읽습니다.

Push는 간단하지만 이벤트 계약이 커질 수 있고, Pull은 Observer가 필요한 정보만 가져가지만 Subject 참조가 노출됩니다.

### 알림 정책

- 등록 순서가 결과에 영향을 주지 않도록 설계합니다. 순서가 필요하면 명시적으로 우선순위를 관리합니다.
- 리스너가 알림 중 자신이나 다른 리스너를 해제할 수 있다면 구독 목록의 복사본을 순회합니다. `example_05.lua`가 이 방식을 사용합니다.
- 한 리스너의 오류를 전파해 나머지 알림도 중단할지, `pcall`로 기록하고 계속할지 정책을 정합니다.
- 구독자는 해제하지 않으면 발행자에 계속 참조될 수 있으므로, 화면이나 엔티티의 종료 시점에 해제합니다.

## 예제별 학습 순서

- `example_01.lua`: 하나의 온도 변화가 화면과 로그 Observer에 전달되고 로그 구독을 해제합니다.
- `example_02.lua`: `update` 메서드를 가진 UI·업적 Observer를 등록합니다.
- `example_03.lua`: Pull 방식으로 Observer가 Inventory의 현재 상태를 조회합니다.
- `example_04.lua`: 같은 업적 이벤트의 중복 알림을 Subject가 차단합니다.
- `example_05.lua`: 이벤트 이름별 채널, 개별 리스너 해제, 알림 중 해제해도 안전한 스냅샷 순회를 구현합니다.

## 다른 패턴과의 차이

- **Observer와 Mediator**: Observer는 한 Subject의 변화를 여러 구독자에게 방송하고, Mediator는 여러 참가자의 상호작용 순서와 조건을 조정합니다.
- **Observer와 Command**: Observer는 현재 사건을 등록된 여러 수신자에게 알리고, Command는 실행할 요청 자체를 값으로 만들어 큐잉·기록·취소할 수 있게 합니다.
- **Observer와 State**: State는 Context가 현재 상태에 행동을 위임하고, Observer는 상태 변화의 수신자들을 갱신합니다.
- **Observer와 직접 호출**: 구독자가 늘어도 Subject의 코드를 바꾸지 않아야 Observer의 이점이 생깁니다.

## Lua와 LÖVE2D에서의 유용성

- 점수·체력·인벤토리 변경을 UI, 사운드, 업적에 전달할 때
- `love.keypressed`나 게임 이벤트를 여러 시스템에 연결할 때
- 게임 상태 변화와 렌더링 상태를 분리할 때
- 모듈 간 직접 참조를 줄일 때

콜백이 객체를 강하게 캡처하면 객체가 사라진 뒤에도 Subject가 참조를 유지할 수 있습니다. 반드시 `unsubscribe` 계약을 제공하고, 알림 중 구독 목록을 수정할 때는 복사본을 순회하거나 변경을 다음 프레임으로 미뤄야 합니다. 콜백 하나의 오류가 나머지 Observer를 막을지 여부도 정책으로 정해야 합니다.
- 적합한 경우: UI 갱신, 점수판, 이벤트 버스
- 주의점: 구독 해제, 호출 순서, 콜백 중 오류 처리, 알림 중 구독 목록 변경을 설계하기

## 읽는 포인트

- Subject가 Observer의 이름이나 구체적인 메서드를 직접 호출하지 않는가?
- Observer를 여러 개 등록해도 Subject의 변경 코드는 바뀌지 않는가?
- 구독 해제 없이 객체가 사라져 콜백이 남는 문제를 어떻게 막는가?
- 단순 함수 호출 목록이면 충분한지, 이벤트 이름과 수명 관리가 필요한지 판단하는가?

## State와의 차이

State는 하나의 Context가 현재 상태 객체에 행동을 위임하는 패턴입니다. Observer는 하나의 Subject 변화가 여러 독립적인 Observer에게 전달되는 패턴입니다. State의 전이와 Observer의 알림을 함께 사용할 수도 있지만 두 책임은 다릅니다.
