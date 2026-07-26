return function(env)
    local globalEnv = (getgenv and getgenv()) or _G
    if not (globalEnv and globalEnv.__WW_L == true) then
        error("WinWare module must be loaded through the official loader", 0)
    end
    if type(env) ~= "table" then
        error("WinWare module env missing", 0)
    end

    local State = env.State
    local Settings = env.Settings
    local Services = env.Services
    local Theme = env.Theme
    local RuntimeUtils = env.Utils
    local websiteUser = env.websiteUser
    local websitePublicId = env.websitePublicId
    local encodeValue = env.encodeValue
    local decodeValue = env.decodeValue
    local resolveEnumName = env.resolveEnumName
    local EnumItem = env.EnumItem
    local Drawing = env.Drawing

    local function ResolveEnum(enumType, name)
        if type(EnumItem) == "function" then
            local item = EnumItem(enumType, name)
            if item then return item end
        end
        if type(resolveEnumName) == "function" then
            return resolveEnumName(name, enumType)
        end
        local ok, item = pcall(function()
            return enumType and enumType[name]
        end)
        if ok then return item end
        return nil
    end

    local KEY_ESCAPE = ResolveEnum(Enum.KeyCode, "Escape")
    local KEY_DELETE = ResolveEnum(Enum.KeyCode, "Delete")
    local KEY_RIGHT_ALT = ResolveEnum(Enum.KeyCode, "RightAlt")

    local function ResolveWatermarkUser(raw)
        local value = tostring(raw or "")
        value = value:gsub("[%c]", ""):gsub("^%s+", ""):gsub("%s+$", "")
        if value == "" or value == "[[USERNAME]]" then
            if type(globalEnv) == "table" then
                value = tostring(globalEnv.__WW_USERNAME or globalEnv.__WW_SITE_USERNAME or "")
                value = value:gsub("[%c]", ""):gsub("^%s+", ""):gsub("%s+$", "")
            end
            if value == "" or value == "[[USERNAME]]" then
                local lp = State and State.LocalPlayer
                value = (lp and lp.Name) or "User"
            end
        end
        return string.sub(value, 1, 32)
    end

    websiteUser = ResolveWatermarkUser(websiteUser)

    local function ResolveWatermarkPublicId(raw)
        local value = tostring(raw or "")
        value = value:gsub("[%c]", ""):gsub("^%s+", ""):gsub("%s+$", "")
        if value == "" or value == "[[PUBLIC_USER_ID]]" then
            if type(globalEnv) == "table" then
                value = tostring(globalEnv.__WW_PUBLIC_USER_ID or globalEnv.__WW_PUBLIC_UID or "")
                value = value:gsub("[%c]", ""):gsub("^%s+", ""):gsub("%s+$", "")
            end
        end
        if value == "" or value == "[[PUBLIC_USER_ID]]" then
            value = "unknown"
        end
        return string.sub(value, 1, 48)
    end

    websitePublicId = ResolveWatermarkPublicId(websitePublicId)

    local Ui = {}

    function Ui.ResetUiColorTokens()
        Settings.Colors.MainStart = Theme.Colors.NearBlack2
        Settings.Colors.MainEnd = Theme.Colors.NearBlack
        Settings.Colors.Accent = Theme.Colors.Accent
        Settings.Colors.AccentSoft = Theme.Colors.AccentSoft
        Settings.Colors.PillBg = Theme.Colors.Surface
        Settings.Colors.TextWhite = Theme.Colors.White
        Settings.Colors.TextGray = Theme.Colors.GraySoft
        Settings.Colors.TextMuted = Theme.Colors.Gray
        Settings.Colors.TextLight = Theme.Colors.GrayLight
        Settings.Colors.IconColor = Theme.Colors.GrayLight
    end

    function Ui.GetColorLuma(color)
        if typeof(color) ~= "Color3" then return 0 end
        return (color.R * 0.299) + (color.G * 0.587) + (color.B * 0.114)
    end

    function Ui.EnsureThemeContrast()
        if not Settings or type(Settings.Colors) ~= "table" then return end
        local palette = Settings.Colors
        local fallback = {
            MainStart = Theme.Colors.NearBlack2,
            MainEnd = Theme.Colors.NearBlack,
            PillBg = Theme.Colors.Surface,
            TextWhite = Theme.Colors.White,
            TextGray = Theme.Colors.GraySoft,
            TextMuted = Theme.Colors.Gray,
            TextLight = Theme.Colors.GrayLight,
            IconColor = Theme.Colors.GrayLight,
            Accent = Theme.Colors.Accent,
            AccentSoft = Theme.Colors.AccentSoft,
        }

        for key, value in pairs(fallback) do
            if typeof(palette[key]) ~= "Color3" then
                palette[key] = value
            end
        end

        if Ui.GetColorLuma(palette.MainStart) < 0.09 then palette.MainStart = fallback.MainStart end
        if Ui.GetColorLuma(palette.MainEnd) < 0.07 then palette.MainEnd = fallback.MainEnd end
        if Ui.GetColorLuma(palette.PillBg) < 0.07 then palette.PillBg = fallback.PillBg end
        if Ui.GetColorLuma(palette.TextWhite) < 0.82 then palette.TextWhite = fallback.TextWhite end
        if Ui.GetColorLuma(palette.TextLight) < 0.74 then palette.TextLight = fallback.TextLight end
        if Ui.GetColorLuma(palette.TextGray) < 0.62 then palette.TextGray = fallback.TextGray end
        if Ui.GetColorLuma(palette.TextMuted) < 0.5 then palette.TextMuted = fallback.TextMuted end
        if Ui.GetColorLuma(palette.IconColor) < 0.55 then palette.IconColor = fallback.IconColor end
    end

    function Ui.ComputeUILayout()
        local view = (State and State.Camera and State.Camera.ViewportSize) or Vector2.new(1280, 720)
        local w, h = view.X, view.Y
        local edge = 14
        local gap = math.clamp(math.floor(w * 0.01), 10, 14)
        local sideW = math.clamp(math.floor(w * 0.12), 136, 158)
        local mainW = math.clamp(math.floor(w * 0.43), 500, 610)
        local rightW = math.clamp(math.floor(w * 0.19), 230, 280)
        local mainH = math.clamp(math.floor(h * 0.66), 390, 470)

        if w < 1060 then
            rightW = math.clamp(math.floor(w * 0.22), 210, 240)
        end

        local groupW = sideW + mainW + gap + rightW
        if groupW > (w - edge * 2) then
            local overflow = groupW - (w - edge * 2)
            rightW = math.max(190, rightW - overflow)
            groupW = sideW + mainW + gap + rightW
        end
        if groupW > (w - edge * 2) then
            local overflow = groupW - (w - edge * 2)
            mainW = math.max(420, mainW - overflow)
            groupW = sideW + mainW + gap + rightW
        end
        if groupW > (w - edge * 2) then
            rightW = math.max(0, (w - edge * 2) - sideW - mainW - gap)
            groupW = sideW + mainW + gap + rightW
        end

        local sidebarX = math.max(edge, math.floor((w - groupW) / 2))
        local mainX = sidebarX + sideW
        local rightX = mainX + mainW + gap
        local mainY = math.max(18, math.floor((h - mainH) / 2))

        Theme.Layout.WindowWidth = mainW
        Theme.Layout.WindowMaxHeight = mainH
        Theme.Layout.CategoryWidth = sideW
        Theme.Layout.RightWidth = rightW
        Theme.Layout.RightHeight = mainH
        Theme.Layout.MainX = mainX
        Theme.Layout.MainY = mainY
        Theme.Layout.SidebarX = sidebarX
        Theme.Layout.RightX = rightX
        Theme.Layout.Edge = edge
        Theme.Layout.Top = mainY
        Theme.Layout.Gap = gap
        Theme.Layout.GroupWidth = sideW + mainW + rightW + gap
        Settings.Layout.WindowWidth = mainW
    end

    function Ui.Tween(obj, props, time)
        local info = TweenInfo.new(time or (Theme and Theme.Anim and Theme.Anim.Normal) or 0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = Services.TweenService:Create(obj, info, props)
        tween:Play()
        return tween
    end

    function Ui.GetSoftGradientPair(accentStrength)
        local strength = math.clamp(accentStrength or 0.12, 0, 0.45)
        local neutralFrom = Theme.Colors.Input or Theme.Colors.Surface or Settings.Colors.MainEnd
        local neutralTo = Theme.Colors.SurfaceHigh or Theme.Colors.Surface or Settings.Colors.MainStart
        local blueLift = Settings.Colors.Accent:Lerp(Color3.new(1, 1, 1), 0.72)
        local from = neutralFrom:Lerp(Settings.Colors.Accent, strength * 0.035)
        local to = neutralTo:Lerp(blueLift, strength * 0.12)
        return from, to
    end

    function Ui.ApplyGradient(obj, startColor, endColor, rotation, transparency)
        if not obj then return nil end
        local gradient = obj:FindFirstChild("WWGradient")
        if not gradient or not gradient:IsA("UIGradient") then
            gradient = Instance.new("UIGradient")
            gradient.Name = "WWGradient"
            gradient.Parent = obj
        end
        gradient.Rotation = rotation or 70
        gradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, startColor or Settings.Colors.MainEnd),
            ColorSequenceKeypoint.new(1, endColor or Settings.Colors.MainStart)
        })
        if transparency then
            gradient.Transparency = transparency
        end
        return gradient
    end

    function Ui.EnsureScale(obj, defaultScale)
        if not obj then return nil end
        local scale = obj:FindFirstChildOfClass("UIScale")
        if not scale then
            scale = Instance.new("UIScale")
            scale.Parent = obj
        end
        scale.Scale = defaultScale or scale.Scale or 1
        return scale
    end

    function Ui.PulseScale(scaleObj, downScale, downTime, upTime)
        if not scaleObj then return end
        local pressedScale = downScale or 0.95
        local downTween = Ui.Tween(scaleObj, {Scale = pressedScale}, downTime or 0.06)
        downTween.Completed:Once(function()
            if scaleObj and scaleObj.Parent then
                Ui.Tween(scaleObj, {Scale = 1}, upTime or 0.14)
            end
        end)
    end

    function Ui.ApplyCorner(obj, radius)
        if not obj then return nil end
        local corner = obj:FindFirstChildOfClass("UICorner")
        if not corner then
            corner = Instance.new("UICorner")
            corner.Parent = obj
        end
        corner.CornerRadius = UDim.new(0, radius or Theme.Corner.Small or 6)
        return corner
    end

    function Ui.ApplyStroke(obj, color, transparency, thickness)
        if not obj then return nil end
        local stroke = obj:FindFirstChild("WWStroke")
        if not stroke or not stroke:IsA("UIStroke") then
            stroke = obj:FindFirstChildOfClass("UIStroke")
        end
        if not stroke then
            stroke = Instance.new("UIStroke")
            stroke.Name = "WWStroke"
            stroke.Parent = obj
        end
        stroke.Color = color or Theme.Stroke.Color
        stroke.Transparency = transparency or Theme.Stroke.Transparency or 0.4
        stroke.Thickness = thickness or 1
        return stroke
    end

    function Ui.ApplyShadow(obj, options)
        if not obj then return nil end
        options = options or {}
        local shadow = obj:FindFirstChild("WWShadow")
        if not shadow or shadow.ClassName ~= "UIShadow" then
            local ok, created = pcall(Instance.new, "UIShadow")
            if not ok or not created then return nil end
            shadow = created
            shadow.Name = "WWShadow"
            shadow.Parent = obj
        end

        local function setProp(prop, value)
            pcall(function()
                shadow[prop] = value
            end)
        end

        setProp("Color", options.Color or Color3.new(0, 0, 0))
        setProp("Transparency", options.Transparency or 0.34)
        setProp("BlurRadius", options.BlurRadius or UDim.new(0, 24))
        setProp("Offset", options.Offset or UDim2.fromOffset(0, 6))
        setProp("Spread", options.Spread or UDim2.fromOffset(4, 4))
        setProp("ZIndex", options.ZIndex or -1)
        return shadow
    end

    function Ui.MakeDraggable(handle, frame)
        if not handle or not frame then return end
        local dragging = false
        local dragStart
        local startPos

        table.insert(State.UnloadConnections, handle.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = frame.Position
                local endedConn
                endedConn = input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                        if endedConn then
                            endedConn:Disconnect()
                            endedConn = nil
                        end
                    end
                end)
            end
        end))

        table.insert(State.UnloadConnections, Services.UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - dragStart
                frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end))
    end

    Ui.ResetUiColorTokens()
    Ui.EnsureThemeContrast()
    Ui.ComputeUILayout()

    Library = {
        Modules = {}, Opened = false, GlobalHUDState = false,
        Settings = { Blur = true }, HudSettings = { Watermark = true, Keybinds = true },
        NextX = Settings.Layout.StartX, NextY = Settings.Layout.StartY, Tooltip = nil,
        Windows = {}, Categories = {}, ActiveCategory = nil
    }
    local ActiveColorPicker = nil
    local ActiveDropdown = nil
    local ModuleKeybindBuckets = {}
    local ModuleKeybindCaptureCount = 0
    local reparentThread
    local UiTextBright = Settings.Colors.TextWhite
    local UiTextSoft = Settings.Colors.TextGray
    local UiTextMuted = Settings.Colors.TextMuted
    local UiPanelBlack = Theme.Colors.Black
    local UiPanelDark = Theme.Colors.NearBlack
    local UiPanelMid = Theme.Colors.Surface or Settings.Colors.PillBg
    local UiPanelSoft = Theme.Colors.SurfaceHigh or Settings.Colors.MainStart
    local UiInputDark = Theme.Colors.Input or Settings.Colors.MainEnd
    local UiBorder = Theme.Colors.Border or Theme.Stroke.Color
    local UiBorderSoft = Theme.Colors.BorderSoft or Theme.Stroke.Color
    local UiAccent = Settings.Colors.Accent or Color3.fromRGB(30, 111, 255)
    local UiAccentDeep = Theme.Colors.AccentDeep or Color3.fromRGB(37, 99, 235)
    local UiAccentMid = Theme.Colors.AccentMid or Color3.fromRGB(59, 130, 246)
    local UiAccentSoft = Settings.Colors.AccentSoft or Color3.fromRGB(96, 165, 250)
    local UiFieldBg = (Theme.Colors.Input or UiInputDark)
    local UiFieldHover = UiFieldBg:Lerp(UiAccentSoft, 0.08)
    local UiFieldBorder = (Theme.Colors.BorderSoft or UiBorderSoft)
    local UiPlaceholderStrong = UiTextSoft:Lerp(UiTextBright, 0.42)
    local UiButtonBg = (Theme.Colors.SurfaceHigh or UiPanelSoft)
