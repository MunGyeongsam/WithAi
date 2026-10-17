-- 01_class_demo.lua
-- 메타테이블 클래스 유틸(class.lua)의 상속/오버라이드/생성자 동작을 확인한다.
-- 실행: cd lua_tuto/mvc/week01/examples && lua 01_class_demo.lua

local class = require("class")

local Animal = class()

function Animal:init(name)
  self.name = name
end

function Animal:speak()
  return self.name .. " makes a sound"
end

-- Dog 는 Animal 을 상속한다. init 은 물려받고 speak 만 오버라이드한다.
local Dog = class(Animal)

function Dog:speak()
  return self.name .. " barks"
end

local a = Animal("Generic")
local d = Dog("Rex")

print(a:speak())         -- Generic makes a sound
print(d:speak())         -- Rex barks        (오버라이드됨)
print("name:", d.name)   -- Rex              (부모 init 상속)

-- 인스턴스는 메서드를 공유한다: 같은 함수 참조인지 확인
local d2 = Dog("Max")
print("shared method:", d.speak == d2.speak)   -- true (메모리 공유)
