-- FileScores.lua (어댑터: SCORES 포트)
-- 파일에 최고 점수를 둔다. 파일 시스템(fs)은 주입받는다 — 실행 시 love.filesystem, 테스트는 가짜 표.
-- 파일은 시스템 경계: 내용을 믿지 않고 숫자인지 검사한다.

local class = require("class")

local FileScores = class()

FileScores.FILE = "best.txt"

--- @param fs table read(name) → string|nil, write(name, text), getInfo(name) → table|nil
function FileScores:init(fs)
  self.fs = fs
end

function FileScores:loadBest()
  if not self.fs.getInfo(FileScores.FILE) then
    return 0
  end
  local text = self.fs.read(FileScores.FILE)
  local n = tonumber(text and text:match("^%s*(%d+)%s*$"))
  return n or 0
end

function FileScores:saveBest(n)
  self.fs.write(FileScores.FILE, tostring(math.floor(n)))
end

return FileScores
