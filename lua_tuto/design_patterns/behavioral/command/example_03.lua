local audio = { music = false }

local function create_music_command(receiver, enabled)
	return {
		execute = function()
			receiver.music = enabled
		end
	}
end

local turn_on = create_music_command(audio, true)
local turn_off = create_music_command(audio, false)
turn_on.execute()
print(audio.music)
turn_off.execute()
print(audio.music)
