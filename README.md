# WinWare Figma UI

Native Roblox/Luau port of the WinWare Figma interface. The library ships a single file with the window, tabs, sections, controls, config helpers and drag behavior.

The default window is `834x534`, the original `1250x800` Figma surface reduced by 1.5. It does not automatically upscale to the viewport.

## Run the complete example

```luau
loadstring(game:HttpGet(
	"https://raw.githubusercontent.com/wxnvxa/winware-lib/main/example.luau"
))()
```

## Load only the library

```luau
local WinWare = loadstring(game:HttpGet(
	"https://raw.githubusercontent.com/wxnvxa/winware-lib/main/winware.luau"
))()
```

## API example

```luau
local window = WinWare:CreateWindow({
    Name = "WINWARE",
    Content = "",
    Size = WinWare.Scales.Default,
    Keybind = "Insert",
})

-- Avatar and username come from Roblox. Omit Lifetime for "Never".
window:SetAccount({ Lifetime = true })

window:AddTabLabel("MODULES")
local combat = window:AddTab({ Name = "Combat", Icon = "sword" })
local ragebot = combat:AddSection({ Name = "RAGEBOT", Position = "left" })

ragebot:AddLabel("Enabled"):AddToggle({
    Default = false,
    Flag = "Ragebot.Enabled",
})

ragebot:AddLabel("FOV"):AddSlider({
    Default = 90,
    Min = 0,
    Max = 180,
    Size = 233,
    Flag = "Ragebot.FOV",
})

ragebot:AddLabel("Target"):AddDropdown({
    Default = "Head",
    Values = { "Head", "Torso", "Closest" },
    Size = 100,
    Flag = "Ragebot.Target",
})
```

Controls with a `Flag` are available through `WinWare.Flags[flag]` and retain the base `GetValue`/`SetValue` methods.

Released under the MIT license, see `LICENSE`.
