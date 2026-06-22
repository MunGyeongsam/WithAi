--tst.lua

local k = require'kutil'

local students = [[
        1		2023391007		김관현		게임제작		3학년		이길순		
		2		2025391001		김기환		게임제작		3학년		이길순		
		3		2022281007		김도언		게임제작		3학년		이길순		
		5		2025392005		김시우		게임제작		3학년		이길순		
		8		2025391009		김호준		게임제작		3학년		이길순		
		9		2021391007		남윤호		게임제작		3학년		이길순		
		10		2025391013		배정원		게임제작		3학년		이길순		
		11		2023391016		서원		게임제작		3학년		이길순		
		12		2023391017		신현성		게임제작		3학년		이길순		
		13		2022391001		심예성		게임제작		3학년		이길순		
		14		2025391016		안찬영		게임제작		3학년		이길순		
		15		2024392009		윤지우		게임제작		3학년		이길순		
		16		2024391010		이상혁		게임제작		3학년		이길순		
		17		2025391018		이준상		게임제작		3학년		이길순		
		18		2021281005		이현민		게임제작		3학년		이길순		
		19		2024391014		임진섭		게임제작		3학년		이길순		
		20		2024391017		최상희		게임제작		3학년		이길순		
]]


do
    -- 학생 정보 파싱
    local studentList = {}
    for line in students:gmatch("[^\n]+") do
        local fields = {}
        for field in line:gmatch("%S+") do
            table.insert(fields, field)
        end
        if #fields >= 3 then
            table.insert(studentList, {
                number = fields[1],
                id = fields[2],
                name = fields[3]
            })
        end
    end

    -- Fisher-Yates 셔플로 랜덤하게 섞기
    math.randomseed(os.time())
    for i = #studentList, 2, -1 do
        local j = math.random(1, i)
        studentList[i], studentList[j] = studentList[j], studentList[i]
    end

    -- 랜덤 순서로 번호와 이름만 출력
    for _, student in ipairs(studentList) do
        print(string.format("%s. %s", student.number, student.name))
    end
end

