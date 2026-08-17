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
	Lifetime = true,
})

local notifier = WinWare:CreateNotification()
local function notify(message)
	notifier.new({ Title = "WINWARE", Content = message, Duration = 2 })
end

window:AddTabLabel("MODULES")
local combat = window:AddTab({ Name = "Combat", Icon = "sword" })
local movement = window:AddTab({ Name = "Movement", Icon = "person-running" })
local visuals = window:AddTab({ Name = "Visuals", Icon = "eye" })
local player = window:AddTab({ Name = "Player", Icon = "person" })
local misc = window:AddTab({ Name = "Misc", Icon = "nine-dots-grid" })
window:AddTabLabel("SETTINGS")
local settings = window:AddTab({ Name = "Settings", Icon = "gear" })
local configManager = window:AddTab({ Name = "Config Manager", Icon = "page" })

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

local movementMain = movement:AddSection({ Name = "MOVEMENT", Position = "left" })
movementMain:AddLabel("Enabled"):AddToggle({ Flag = "Movement.Enabled", Default = true })
movementMain:AddLabel("Walk Speed"):AddSlider({ Flag = "Movement.WalkSpeed", Min = 0, Max = 100, Default = 16, Size = 233 })
movementMain:AddLabel("Jump Power"):AddSlider({ Flag = "Movement.JumpPower", Min = 0, Max = 150, Default = 50, Size = 233 })
movementMain:AddLabel("Speed Mode"):AddDropdown({ Flag = "Movement.SpeedMode", Default = "Velocity", Values = { "Velocity", "CFrame", "WalkSpeed" }, Size = 110 })

local movementAssist = movement:AddSection({ Name = "ASSIST", Position = "right" })
movementAssist:AddLabel("Auto Sprint"):AddToggle({ Flag = "Movement.AutoSprint", Default = true })
movementAssist:AddLabel("Bunny Hop"):AddToggle({ Flag = "Movement.BunnyHop" })
movementAssist:AddLabel("No Slow"):AddToggle({ Flag = "Movement.NoSlow" })
movementAssist:AddLabel("Fly Key"):AddKeybind({ Flag = "Movement.FlyKey", Default = "F" })

local esp = visuals:AddSection({ Name = "ESP", Position = "left" })
esp:AddLabel("Enabled"):AddToggle({ Flag = "Visuals.ESP.Enabled", Default = true })
esp:AddLabel("Boxes"):AddToggle({ Flag = "Visuals.ESP.Boxes", Default = true })
esp:AddLabel("Names"):AddToggle({ Flag = "Visuals.ESP.Names", Default = true })
esp:AddLabel("Max Distance"):AddSlider({ Flag = "Visuals.ESP.Distance", Min = 100, Max = 5000, Default = 1500, Size = 233 })

local worldVisuals = visuals:AddSection({ Name = "WORLD", Position = "right" })
worldVisuals:AddLabel("Fullbright"):AddToggle({ Flag = "Visuals.World.Fullbright" })
worldVisuals:AddLabel("Field of View"):AddSlider({ Flag = "Visuals.World.FOV", Min = 60, Max = 120, Default = 70, Size = 233 })
worldVisuals:AddLabel("Crosshair"):AddDropdown({ Flag = "Visuals.World.Crosshair", Default = "Dot", Values = { "Dot", "Cross", "Circle", "Off" }, Size = 100 })
worldVisuals:AddLabel("Accent Color"):AddColorPicker({ Flag = "Visuals.World.Accent", Default = "#0056FF" })

local localPlayer = player:AddSection({ Name = "LOCAL PLAYER", Position = "left" })
localPlayer:AddLabel("Infinite Jump"):AddToggle({ Flag = "Player.InfiniteJump" })
localPlayer:AddLabel("Noclip"):AddToggle({ Flag = "Player.Noclip" })
localPlayer:AddLabel("Gravity"):AddSlider({ Flag = "Player.Gravity", Min = 0, Max = 300, Default = 196, Size = 233 })
localPlayer:AddLabel("Hip Height"):AddSlider({ Flag = "Player.HipHeight", Min = 0, Max = 10, Default = 2, Rounding = 1, Size = 233 })

local character = player:AddSection({ Name = "CHARACTER", Position = "right" })
character:AddLabel("Anti AFK"):AddToggle({ Flag = "Player.AntiAFK", Default = true })
character:AddLabel("Auto Respawn"):AddToggle({ Flag = "Player.AutoRespawn" })
character:AddLabel("Animation"):AddDropdown({ Flag = "Player.Animation", Default = "Default", Values = { "Default", "Robot", "Ninja", "Zombie" }, Size = 100 })
character:AddButton({ Name = "Respawn Character", Icon = "arrow-spin-clockwise", Callback = function() notify("Respawn requested") end })

local utility = misc:AddSection({ Name = "UTILITY", Position = "left" })
utility:AddLabel("Auto Rejoin"):AddToggle({ Flag = "Misc.AutoRejoin", Default = true })
utility:AddLabel("FPS Cap"):AddSlider({ Flag = "Misc.FPSCap", Min = 30, Max = 360, Default = 144, Size = 233 })
utility:AddLabel("Panic Key"):AddKeybind({ Flag = "Misc.PanicKey", Default = "End" })
utility:AddButton({ Name = "Server Hop", Icon = "arrow-spin-clockwise", Callback = function() notify("Searching for a server") end })

local automation = misc:AddSection({ Name = "AUTOMATION", Position = "right" })
automation:AddLabel("Auto Execute"):AddToggle({ Flag = "Misc.AutoExecute" })
automation:AddLabel("Notifications"):AddToggle({ Flag = "Misc.Notifications", Default = true })
automation:AddLabel("Join Mode"):AddDropdown({ Flag = "Misc.JoinMode", Default = "Friends", Values = { "Friends", "Lowest Ping", "Random" }, Size = 110 })
automation:AddButton({ Name = "Copy Job ID", Icon = "page", Callback = function() notify("Job ID copied") end })

local appearance = settings:AddSection({ Name = "APPEARANCE", Position = "left" })
appearance:AddLabel("Menu Blur"):AddToggle({ Flag = "Settings.MenuBlur", Default = true })
appearance:AddLabel("Watermark"):AddToggle({ Flag = "Settings.Watermark" })
appearance:AddLabel("Menu Opacity"):AddSlider({ Flag = "Settings.Opacity", Min = 0, Max = 100, Default = 90, Type = "%", Size = 233 })
appearance:AddLabel("Theme Color"):AddColorPicker({ Flag = "Settings.ThemeColor", Default = "#0056FF" })

local inputSettings = settings:AddSection({ Name = "INPUT", Position = "right" })
inputSettings:AddLabel("Menu Key"):AddKeybind({ Flag = "Settings.MenuKey", Default = "Insert" })
inputSettings:AddLabel("Save On Exit"):AddToggle({ Flag = "Settings.SaveOnExit", Default = true })
inputSettings:AddLabel("Open On Execute"):AddToggle({ Flag = "Settings.OpenOnExecute", Default = true })
inputSettings:AddLabel("Language"):AddDropdown({ Flag = "Settings.Language", Default = "English", Values = { "English", "Russian" }, Size = 100 })

local configActions = configManager:AddSection({ Name = "CONFIGURATION", Position = "left" })
configActions:AddLabel("Config Name"):AddTextInput({ Flag = "Config.Name", Placeholder = "Default", Default = "Default", Size = 120 })
configActions:AddLabel("Auto Save"):AddToggle({ Flag = "Config.AutoSave", Default = true })
configActions:AddButton({ Name = "Save Config", Icon = "check", Callback = function() notify("Config saved") end })
configActions:AddButton({ Name = "Load Config", Icon = "folder", Callback = function() notify("Config loaded") end })

local configProfiles = configManager:AddSection({ Name = "PROFILES", Position = "right" })
configProfiles:AddLabel("Selected"):AddDropdown({ Flag = "Config.Selected", Default = "Default", Values = { "Default", "Legit", "Rage" }, Size = 120 })
configProfiles:AddButton({ Name = "Refresh List", Icon = "arrow-spin-clockwise", Callback = function() notify("Config list refreshed") end })
configProfiles:AddButton({ Name = "Delete Config", Icon = "x", Callback = function() notify("Config deleted") end })
configProfiles:AddButton({ Name = "Reset Defaults", Icon = "gear", Callback = function() notify("Defaults restored") end })
