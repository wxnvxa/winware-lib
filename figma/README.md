# WinWare UI Library

WinWare is a Roblox client UI library that recreates the WinWare Figma design: a centered dark glass window, navigation sidebar, profile block, two-column sections, toggles, sliders, and dropdowns.

The implementation is derived from the MIT-licensed NeverLose Roblox UI project by 4lpacaLoL. The original copyright and MIT license are retained in `LICENSE`.

## Install

Place `winware.luau` in a ModuleScript and require it from a LocalScript:

```luau
local WinWare = require(path.to.winware)
```

The library renders into `Players.LocalPlayer.PlayerGui`, so it works in a normal Roblox client environment.

## Remote loading

For environments that explicitly provide both `loadstring` and `game:HttpGet`, load the published Figma build directly:

```luau
local WinWare = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/wxnvxa/winware-lib/main/figma/winware.luau"
))()
```

In a normal Roblox experience, use a ModuleScript and `require` instead. Standard Roblox clients do not enable `loadstring` for arbitrary remote source.

## Minimal example

```luau
local WinWare = require(path.to.winware)

local window = WinWare:CreateWindow({
    Title = "WINWARE",
    Username = "korsHuesos",
    Expires = "Until August 15, 2026",
    Keybind = Enum.KeyCode.Insert,
})

window:AddTabLabel("MODULES")
local combat = window:AddTab({ Name = "Combat", Icon = "swords" })

local ragebot = combat:AddSection({ Name = "RAGEBOT", Position = "left" })
ragebot:AddToggle({ Name = "Enabled", Flag = "Ragebot.Enabled" })
ragebot:AddSlider({ Name = "FOV", Flag = "Ragebot.FOV", Min = 0, Max = 180, Default = 90 })
ragebot:AddDropdown({
    Name = "Target",
    Flag = "Ragebot.Target",
    Default = "Head",
    Values = { "Head", "Torso", "Closest" },
})
```

`WinWare.Flags` stores every option that supplies a `Flag`.

## API

- `WinWare:CreateWindow(config)`
- `window:AddTabLabel(text)`
- `window:AddTab({ Name, Icon })`
- `window:SetAccount({ Username, Expires, Profile })`
- `window:SetScale(number)`
- `window:ToggleInterface(boolean?)`
- `window:Destroy()`
- `tab:AddSection({ Name, Position = "left" | "right" })`
- `section:AddToggle({ Name, Default, Flag, Callback })`
- `section:AddSlider({ Name, Min, Max, Default, Flag, Callback })`
- `section:AddDropdown({ Name, Values, Default, Flag, Callback })`
