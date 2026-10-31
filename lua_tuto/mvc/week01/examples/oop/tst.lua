

--[[
requirements

Animal
  Mammal
    Dog
    Cat
  Bird
    Eagle
    Penguin

Animal
  속성 : name, age, energy, MAX_ENERGY
  함수 : speak, eat, sleep, getInfo

Mammal(1단계 상속)
  오버라이딩: 포유류의 울음
  추가 : warmBlooded

Bird(1단계 상속)
  오버라이딩: 새의 울음
  추가 : canFly, wingSpan


Dog, Cat, Eagle, Penguin(2단계 상속)
  각각 고유한 speak, move 구현
  특화 메서드 추가
--]]


local Animal = require "oop.Animal"
local Mammal = require "oop.Mammal"
local Bird = require "oop.Bird"
local Dog = require "oop.Dog"
local Cat = require "oop.Cat"
local Eagle = require "oop.Eagle"
local Penguin = require "oop.Penguin"


-- ============ 테스트 ============
local function run_tests()
   print("=== 동물 상속 및 오버라이딩 테스트 ===\n")
  
   local dog = Dog("Max")
   local cat = Cat("Whiskers")
   local eagle = Eagle("Sky")
   local penguin = Penguin("Waddles")
  
   -- 1. 부모 메서드 상속
   print("1. 부모 메서드 상속 (Animal.getInfo):")
   print("  ", dog:getInfo())
   print("  ", cat:getInfo())
   print("  ", eagle:getInfo())
   print("  ", penguin:getInfo())
   print()
  
   -- 2. 오버라이딩된 speak()
   print("2. 오버라이딩된 speak() - 각 동물마다 다른 울음:")
   print("  ", dog:speak())
   print("  ", cat:speak())
   print("  ", eagle:speak())
   print("  ", penguin:speak())
   print()
  
   -- 3. 오버라이딩된 move()
   print("3. 오버라이딩된 move() - 이동 방식이 다름:")
   print("  ", dog:move(50))
   print("  ", cat:move(30))
   print("  ", eagle:move(100))
   print("  ", penguin:move(20))
   print()
  
   -- 4. 자식별 특화 메서드
   print("4. 자식별 특화 메서드:")
   print("  ", dog:fetch())
   print("  ", cat:nap())
   print("  ", eagle:hunt())
   print("  ", penguin:dive())
   print()
  
   -- 5. 부모 메서드 호출 (eat, sleep)
   print("5. 부모 메서드 호출 (Animal.eat, Animal.sleep):")
   print("  ", dog:eat("bone"))
   print("  ", cat:sleep())
   print("  ", dog:getInfo())
   print()
  
   -- 6. 2단계 상속 확인
   print("6. 2단계 상속 메서드 체이닝:")
   dog.breed = "Golden Retriever"
   print("  Dog (Mammal > Animal):", dog:getInfo())
   eagle.hunting = true
   print("  Eagle (Bird > Animal):", eagle:getInfo())
   print()
  
   -- 7. 다형성 활용
   print("7. 다형성 - 같은 메서드, 다른 동작:")
   local animals = {dog, cat, eagle, penguin}
   for _, animal in ipairs(animals) do
       print("  " .. animal:speak())
   end
end

run_tests()

