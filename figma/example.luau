local WinWare = require(script.Parent.winware)

local window = WinWare:CreateWindow({
	Title = "WINWARE",
	Username = "korsHuesos",
	Expires = "Until August 15, 2026",
	Keybind = Enum.KeyCode.Insert,
})

window:AddTabLabel("MODULES")
local combat = window:AddTab({ Name = "Combat", Icon = "swords" })
window:AddTab({ Name = "Movement", Icon = "person-running" })
window:AddTab({ Name = "Visuals", Icon = "eye" })
window:AddTab({ Name = "Player", Icon = "person" })
window:AddTab({ Name = "Misc", Icon = "dice-five" })
window:AddTabLabel("SETTINGS")
window:AddTab({ Name = "Settings", Icon = "settings" })
window:AddTab({ Name = "Config Manager", Icon = "file" })

local ragebot = combat:AddSection({ Name = "RAGEBOT", Position = "left" })
ragebot:AddToggle({ Name = "Enabled", Flag = "Ragebot.Enabled" })
ragebot:AddToggle({ Name = "TeamCheck", Flag = "Ragebot.TeamCheck" })
ragebot:AddToggle({ Name = "AutoFire", Flag = "Ragebot.AutoFire", Default = true })
ragebot:AddSlider({ Name = "FOV", Flag = "Ragebot.FOV", Min = 0, Max = 180, Default = 90 })
ragebot:AddDropdown({ Name = "Target", Flag = "Ragebot.Target", Default = "Head", Values = { "Head", "Torso", "Closest" } })

local aimbot = combat:AddSection({ Name = "AIMBOT", Position = "right" })
aimbot:AddToggle({ Name = "Enabled", Flag = "Aimbot.Enabled" })
aimbot:AddToggle({ Name = "TeamCheck", Flag = "Aimbot.TeamCheck" })
aimbot:AddToggle({ Name = "AutoFire", Flag = "Aimbot.AutoFire", Default = true })
aimbot:AddSlider({ Name = "FOV", Flag = "Aimbot.FOV", Min = 0, Max = 180, Default = 90 })
aimbot:AddDropdown({ Name = "Target", Flag = "Aimbot.Target", Default = "Head", Values = { "Head", "Torso", "Closest" } })
