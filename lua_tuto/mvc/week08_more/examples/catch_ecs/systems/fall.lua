-- fall.lua (ECS 시스템)
-- falling + position 을 가진 모든 엔티티를 한 칸 내린다.

return function(world)
  for _, id in ipairs(world:query("falling", "position")) do
    local pos = world:get(id, "position")
    pos.row = pos.row + 1
  end
end
