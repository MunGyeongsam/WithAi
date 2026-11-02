-- conf.lua
-- 겔러그 최종 템플릿(7주차) 창 설정.

function love.conf(t)
  t.identity = "galaga_mvc_week07" -- 저장 폴더 이름(love.filesystem.getSaveDirectory)
  t.window.title = "Galaga (Final) - Week07"
  t.window.width = 600
  t.window.height = 800
  t.window.resizable = false
  t.console = false
end
