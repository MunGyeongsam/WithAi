-- conf.lua
-- 겔러그 모놀리식 단계별 빌드(2주차) 창 설정. (LÖVE 11.x / LuaJIT)

function love.conf(t)
  t.window.title = "Galaga (Steps) - Week02"
  t.window.width = 600
  t.window.height = 800
  t.window.resizable = false
  t.console = false
end
