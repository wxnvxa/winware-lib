-- Standalone remote example. The environment must provide loadstring and game:HttpGet.
local WinWare = loadstring(game:HttpGet(
	"https://raw.githubusercontent.com/wxnvxa/winware-lib/main/figma/winware.luau"
))()

local window = WinWare:CreateWindow({
	Name = "WINWARE",
	Content = "",
	Size = WinWare.Scales.Default,
	Keybind = "Insert",
})

window:SetAccount({
	Username = "korsHuesos",
	Expires = "Until August 15, 2026",
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
ragebot:AddLabel("Enabled"):AddToggle({ Flag = "Ragebot.Enabled" })
ragebot:AddLabel("TeamCheck"):AddToggle({ Flag = "Ragebot.TeamCheck" })
ragebot:AddLabel("AutoFire"):AddToggle({ Flag = "Ragebot.AutoFire", Default = true })
ragebot:AddLabel("FOV"):AddSlider({ Flag = "Ragebot.FOV", Min = 0, Max = 180, Default = 90, Size = 233 })
ragebot:AddLabel("Target"):AddDropdown({ Flag = "Ragebot.Target", Default = "Head", Values = { "Head", "Torso", "Closest" }, Size = 100 })

local aimbot = combat:AddSection({ Name = "AIMBOT", Position = "right" })
aimbot:AddLabel("Enabled"):AddToggle({ Flag = "Aimbot.Enabled" })
aimbot:AddLabel("TeamCheck"):AddToggle({ Flag = "Aimbot.TeamCheck" })
aimbot:AddLabel("AutoFire"):AddToggle({ Flag = "Aimbot.AutoFire", Default = true })
aimbot:AddLabel("FOV"):AddSlider({ Flag = "Aimbot.FOV", Min = 0, Max = 180, Default = 90, Size = 233 })
aimbot:AddLabel("Target"):AddDropdown({ Flag = "Aimbot.Target", Default = "Head", Values = { "Head", "Torso", "Closest" }, Size = 100 })
