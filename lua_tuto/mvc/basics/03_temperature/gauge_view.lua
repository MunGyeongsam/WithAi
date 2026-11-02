-- gauge_view.lua
-- View 2: 같은 Model 을 막대 그래프로 보여준다. (Model 하나 → View 여러 개)

local GAUGE_MIN, GAUGE_MAX, GAUGE_WIDTH = -20, 40, 30

local GaugeView = {}
GaugeView.__index = GaugeView

function GaugeView.new(write)
  return setmetatable({ write = write or print }, GaugeView)
end

function GaugeView:attach(model)
  return model:subscribe(function(m)
    self:render(m)
  end)
end

function GaugeView:render(model)
  local ratio = (model.celsius - GAUGE_MIN) / (GAUGE_MAX - GAUGE_MIN)
  ratio = math.max(0, math.min(1, ratio))
  local filled = math.floor(ratio * GAUGE_WIDTH + 0.5)
  local bar = string.rep("#", filled) .. string.rep(".", GAUGE_WIDTH - filled)
  self.write(string.format("  [막대] %d°C |%s| %d°C", GAUGE_MIN, bar, GAUGE_MAX))
end

return GaugeView
