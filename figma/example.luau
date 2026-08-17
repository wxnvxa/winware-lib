-- Standalone remote example. The environment must provide loadstring and game:HttpGet.
local WinWare = loadstring(game:HttpGet(
	"https://wxnvxa.github.io/winware-lib/figma/winware.luau"
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
local combat = window:AddTab({ Name = "Combat", Icon = "sword" })
window:AddTab({ Name = "Movement", Icon = "person-running" })
window:AddTab({ Name = "Visuals", Icon = "eye" })
window:AddTab({ Name = "Player", Icon = "person" })
window:AddTab({ Name = "Misc", Icon = "nine-dots-grid" })
window:AddTabLabel("SETTINGS")
window:AddTab({ Name = "Settings", Icon = "gear" })
window:AddTab({ Name = "Config Manager", Icon = "page" })

local ragebot = combat:AddSection({ Name = "RAGEBOT", Position = "left" })
local rageEnabled = ragebot:AddLabel("Enabled")
rageEnabled:AddToggle({ Flag = "Ragebot.Enabled" })
local rageOptions = rageEnabled:AddOption({ Name = "Ragebot", Width = 320, Height = 480 })
rageOptions:AddSlider({ Name = "Range", Flag = "Ragebot.Range", Min = 0, Max = 10, Default = 4 })
rageOptions:AddSlider({ Name = "Ticks", Flag = "Ragebot.Ticks", Min = 1, Max = 20, Default = 10 })
rageOptions:AddSlider({ Name = "Timeout ticks", Flag = "Ragebot.TimeoutTicks", Min = 0, Max = 10, Default = 5 })
rageOptions:AddSlider({ Name = "Boost timer", Flag = "Ragebot.BoostTimer", Min = 0, Max = 5, Default = 2 })
rageOptions:AddSlider({ Name = "Recover timer", Flag = "Ragebot.RecoverTimer", Min = 0, Max = 1, Default = 0.8, Rounding = 1 })
rageOptions:AddSlider({ Name = "Drift budget in ms", Flag = "Ragebot.DriftBudget", Min = 0, Max = 200, Default = 100 })
rageOptions:AddToggle({ Name = "Only while approaching", Flag = "Ragebot.OnlyWhileApproaching", Default = true })
rageOptions:AddToggle({ Name = "Players only", Flag = "Ragebot.PlayersOnly", Default = true })
rageOptions:AddToggle({ Name = "Debug", Flag = "Ragebot.Debug" })
local rageTeamCheck = ragebot:AddLabel("TeamCheck")
rageTeamCheck:AddToggle({ Flag = "Ragebot.TeamCheck" })
local rageTeamOptions = rageTeamCheck:AddOption({ Name = "TeamCheck", Width = 320, Height = 245 })
rageTeamOptions:AddToggle({ Name = "Players only", Flag = "Ragebot.TeamCheck.PlayersOnly", Default = true })
rageTeamOptions:AddToggle({ Name = "Ignore friends", Flag = "Ragebot.TeamCheck.IgnoreFriends", Default = true })
rageTeamOptions:AddSlider({ Name = "Update rate", Flag = "Ragebot.TeamCheck.UpdateRate", Min = 1, Max = 30, Default = 10 })
ragebot:AddLabel("AutoFire"):AddToggle({ Flag = "Ragebot.AutoFire", Default = true })
ragebot:AddLabel("FOV"):AddSlider({ Flag = "Ragebot.FOV", Min = 0, Max = 180, Default = 90, Size = 233 })
ragebot:AddLabel("Target"):AddDropdown({ Flag = "Ragebot.Target", Default = "Head", Values = { "Head", "Torso", "Closest" }, Size = 100 })

local aimbot = combat:AddSection({ Name = "AIMBOT", Position = "right" })
local aimEnabled = aimbot:AddLabel("Enabled")
aimEnabled:AddToggle({ Flag = "Aimbot.Enabled" })
local aimOptions = aimEnabled:AddOption({ Name = "Aimbot", Width = 320, Height = 350 })
aimOptions:AddSlider({ Name = "Smoothing", Flag = "Aimbot.Smoothing", Min = 0, Max = 100, Default = 18 })
aimOptions:AddSlider({ Name = "Prediction", Flag = "Aimbot.Prediction", Min = 0, Max = 1, Default = 0.15, Rounding = 2 })
aimOptions:AddSlider({ Name = "Deadzone", Flag = "Aimbot.Deadzone", Min = 0, Max = 20, Default = 2 })
aimOptions:AddToggle({ Name = "Visible check", Flag = "Aimbot.VisibleCheck", Default = true })
aimOptions:AddToggle({ Name = "Players only", Flag = "Aimbot.PlayersOnly", Default = true })
local aimTeamCheck = aimbot:AddLabel("TeamCheck")
aimTeamCheck:AddToggle({ Flag = "Aimbot.TeamCheck" })
local aimTeamOptions = aimTeamCheck:AddOption({ Name = "TeamCheck", Width = 320, Height = 245 })
aimTeamOptions:AddToggle({ Name = "Ignore friends", Flag = "Aimbot.TeamCheck.IgnoreFriends", Default = true })
aimTeamOptions:AddToggle({ Name = "Ignore same team", Flag = "Aimbot.TeamCheck.IgnoreSameTeam", Default = true })
aimTeamOptions:AddSlider({ Name = "Update rate", Flag = "Aimbot.TeamCheck.UpdateRate", Min = 1, Max = 30, Default = 10 })
aimbot:AddLabel("AutoFire"):AddToggle({ Flag = "Aimbot.AutoFire", Default = true })
aimbot:AddLabel("FOV"):AddSlider({ Flag = "Aimbot.FOV", Min = 0, Max = 180, Default = 90, Size = 233 })
aimbot:AddLabel("Target"):AddDropdown({ Flag = "Aimbot.Target", Default = "Head", Values = { "Head", "Torso", "Closest" }, Size = 100 })
