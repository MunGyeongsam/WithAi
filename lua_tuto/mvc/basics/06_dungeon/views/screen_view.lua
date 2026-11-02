-- screen_view.lua
-- 합성(Composite) View. 여러 위젯을 모드별 레이아웃에 따라 위에서 아래로 쌓아 한 화면을 만든다.
-- LÖVE2D 라면 love.draw() 에서 각 패널의 draw 를 차례로 부르는 것과 같은 역할이다.
--
-- 위젯 규약: widget.title (문자열), widget:lines(game) → 문자열 배열 또는 nil(숨김)

local WIDTH = 64

local ScreenView = {}
ScreenView.__index = ScreenView

-- widgets: { status = StatusView, enemy = EnemyView, ... }
-- layouts: { explore = { "status", "inventory", ... }, battle = {...}, ... }
function ScreenView.new(write, widgets, layouts)
  return setmetatable({
    write = write or print,
    widgets = widgets,
    layouts = layouts,
    notice = nil, -- 화면 전용 상태: 다음 render 한 번만 보이는 알림
  }, ScreenView)
end

function ScreenView:showNotice(message)
  self.notice = message
end

local function displayWidth(text)
  local width = 0
  for lead in text:gmatch("[\1-\127\194-\244][\128-\191]*") do
    local byte = lead:byte()
    -- 한글 음절(U+AC00~U+D7A3)은 UTF-8 첫 바이트가 0xEA~0xED, 화면에서 2칸을 차지한다.
    width = width + ((byte >= 0xEA and byte <= 0xED) and 2 or 1)
  end
  return width
end

local function header(title)
  local text = "-- " .. title .. " "
  return text .. string.rep("-", math.max(0, WIDTH - displayWidth(text)))
end

function ScreenView:render(game)
  local write = self.write
  write(string.rep("=", WIDTH))
  local layout = self.layouts[game.mode] or self.layouts.default
  for _, name in ipairs(layout) do
    local widget = assert(self.widgets[name], "등록되지 않은 위젯: " .. name)
    local lines = widget:lines(game)
    if lines then
      write(header(widget.title))
      for _, line in ipairs(lines) do
        write("  " .. line)
      end
    end
  end
  if self.notice then
    write("  ! " .. self.notice)
    self.notice = nil
  end
end

return ScreenView
