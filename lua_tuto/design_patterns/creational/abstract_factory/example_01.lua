local dark = {
	button = function()
		return { theme = "dark", name = "dark button" }
	end,
	panel = function()
		return {
			theme = "dark",
			name = "dark panel",
			attach = function(self, button)
				return self.theme == button.theme
			end
		}
	end
}
local light = {
	button = function()
		return { theme = "light", name = "light button" }
	end,
	panel = function()
		return {
			theme = "light",
			name = "light panel",
			attach = function(self, button)
				return self.theme == button.theme
			end
		}
	end
}

local function build_screen(factory)
	local button = factory.button()
	local panel = factory.panel()
	return {
		button = button,
		panel = panel,
		compatible = panel:attach(button)
	}
end

local screen = build_screen(dark)
assert(screen.button.name == "dark button")
assert(screen.panel.name == "dark panel" and screen.compatible)

local mixed_panel = light.panel()
assert(not mixed_panel:attach(screen.button))
print(screen.button.name, screen.panel.name, screen.compatible)
