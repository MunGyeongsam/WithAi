local Score = { observers = {}, value = 0 }

function Score.subscribe(observer)
    Score.observers[#Score.observers + 1] = observer
end

function Score.add(points)
    Score.value = Score.value + points
    for _, observer in ipairs(Score.observers) do observer:update(Score) end
end

local scoreboard = { message = "" }
function scoreboard:update(subject)
    self.message = "점수: " .. subject.value
end

local achievement = { unlocked = false }
function achievement:update(subject)
    if subject.value >= 25 then self.unlocked = true end
end

Score.subscribe(scoreboard)
Score.subscribe(achievement)
Score.add(25)
assert(scoreboard.message == "점수: 25" and achievement.unlocked)
print(scoreboard.message, achievement.unlocked)
