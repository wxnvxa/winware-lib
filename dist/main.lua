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

    local function UnregisterModuleKeybind(module)
        local oldKey = module and module._registeredKeybind
        if not oldKey then
            return
        end

        local bucket = ModuleKeybindBuckets[oldKey]
        if bucket then
            bucket[module] = nil
            if next(bucket) == nil then
                ModuleKeybindBuckets[oldKey] = nil
            end
        end
        module._registeredKeybind = nil
    end

    local function RegisterModuleKeybind(module, key)
        UnregisterModuleKeybind(module)
        if not module or typeof(key) ~= "EnumItem" or key.EnumType ~= Enum.KeyCode then
            return
        end

        local bucket = ModuleKeybindBuckets[key]
        if not bucket then
            bucket = {}
            ModuleKeybindBuckets[key] = bucket
        end
        bucket[module] = true
        module._registeredKeybind = key
    end

    local function SetModuleKeybindCapture(active)
        if active then
            ModuleKeybindCaptureCount = ModuleKeybindCaptureCount + 1
        else
            ModuleKeybindCaptureCount = math.max(0, ModuleKeybindCaptureCount - 1)
        end
    end

    local function DispatchModuleKeybind(input, gp)
        if gp or ModuleKeybindCaptureCount > 0 then return end
        if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
        if Services.UserInputService:GetFocusedTextBox() then return end

        local bucket = ModuleKeybindBuckets[input.KeyCode]
        if not bucket then return end

        for module in pairs(bucket) do
            if module.Keybind == input.KeyCode and module._toggleFromKeybind then
                module._toggleFromKeybind()
            end
        end
    end

    table.insert(State.UnloadConnections, Services.UserInputService.InputBegan:Connect(DispatchModuleKeybind))

    local function IsInputInsideFrame(input, frame)
        if not frame then return false end
        local pos = input.Position
        local framePos = frame.AbsolutePosition
        local frameSize = frame.AbsoluteSize
        return pos.X >= framePos.X
            and pos.X <= (framePos.X + frameSize.X)
            and pos.Y >= framePos.Y
            and pos.Y <= (framePos.Y + frameSize.Y)
    end

    local function DispatchActiveDropdownOutsideClick(input, gp)
        if gp or not ActiveDropdown then return end
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        if IsInputInsideFrame(input, ActiveDropdown.button) or IsInputInsideFrame(input, ActiveDropdown.list) then
            return
        end
        if ActiveDropdown.close then
            pcall(ActiveDropdown.close, false)
        end
    end

    table.insert(State.UnloadConnections, Services.UserInputService.InputBegan:Connect(DispatchActiveDropdownOutsideClick))
    local UiButtonHover = UiButtonBg:Lerp(UiAccentSoft, 0.1)
    local UiButtonBorder = UiBorderSoft:Lerp(UiAccentSoft, 0.12)
    local UiModuleInactiveBg = UiPanelMid:Lerp(UiButtonBg, 0.42)
    local UiModuleInactiveBorder = UiButtonBorder:Lerp(UiAccentSoft, 0.08)
    local UiModuleInactiveHoverBorder = UiButtonBorder:Lerp(UiAccentMid, 0.32)
    local UiDropdownBg = UiButtonBg:Lerp(UiTextBright, 0.065)
    local UiDropdownOptionBg = UiDropdownBg:Lerp(UiTextBright, 0.035)
    local UiDropdownOptionHover = UiDropdownOptionBg:Lerp(UiAccentSoft, 0.16)
    local UiDropdownOptionActive = UiAccentDeep:Lerp(UiButtonBg, 0.34)
    local UiDropdownArrowBg = UiDropdownBg:Lerp(UiTextBright, 0.055)
    local UiDropdownArrowHover = UiDropdownArrowBg:Lerp(UiAccentSoft, 0.16)
    local UiDropdownArrowBorder = UiButtonBorder:Lerp(UiAccentSoft, 0.18)
    local UiDropdownText = UiTextBright
    local UiDropdownMuted = UiTextSoft:Lerp(UiTextBright, 0.34)
    local UiToggleOffBg = UiFieldBg:Lerp(UiTextBright, 0.085)
    local UiToggleOffThumb = UiTextBright:Lerp(UiAccentSoft, 0.04)
    local UiToggleOffBorder = UiButtonBorder:Lerp(UiTextBright, 0.18)

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = Services.HttpService:GenerateGUID(false)
    getgenv()._ww_gui_ref = ScreenGui.Name
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- !!! ВАЖНО: Прячем GUI от детектора !!!
    local targetParent = (gethui and gethui()) or Services.CoreGui
    ScreenGui.Parent = targetParent

    reparentThread = task.spawn(function()
        while task.wait(1) do
            pcall(function()
                if ScreenGui and not ScreenGui.Parent then
                    ScreenGui.Parent = targetParent
                end
            end)
        end
    end)

    local BlurEffect = Instance.new("BlurEffect", Services.Lighting); BlurEffect.Name = Services.HttpService:GenerateGUID(false); BlurEffect.Size = 0
    local MenuDimOverlay = Instance.new("Frame")
    MenuDimOverlay.Name = "MenuDimOverlay"
    MenuDimOverlay.Parent = ScreenGui
    MenuDimOverlay.BackgroundColor3 = Color3.new(0, 0, 0)
    MenuDimOverlay.BackgroundTransparency = 1
    MenuDimOverlay.BorderSizePixel = 0
    MenuDimOverlay.Size = UDim2.fromScale(1, 1)
    MenuDimOverlay.Position = UDim2.fromScale(0, 0)
    MenuDimOverlay.Visible = false
    MenuDimOverlay.Active = false
    MenuDimOverlay.Selectable = false
    MenuDimOverlay.ZIndex = 2
    local ESPContainer = Instance.new("Folder", Services.CoreGui); ESPContainer.Name = Services.HttpService:GenerateGUID(false)
    local targetOutlineFolder = Instance.new("Folder", Services.CoreGui); targetOutlineFolder.Name = Services.HttpService:GenerateGUID(false)
    local globalOutlineFolder = Instance.new("Folder", Services.CoreGui); globalOutlineFolder.Name = Services.HttpService:GenerateGUID(false)

    local ghostPart = Instance.new("Part", Services.Workspace); ghostPart.Name = Services.HttpService:GenerateGUID(false); ghostPart.Transparency = 1; ghostPart.CanCollide = false; ghostPart.Anchored = true; ghostPart.Size = Vector3.new(2, 2, 1)
    local ghostBox = Instance.new("SelectionBox", ghostPart); ghostBox.Adornee = ghostPart; ghostBox.LineThickness = 0.05; ghostBox.Color3 = Color3.new(1, 1, 1); ghostBox.SurfaceTransparency = 1; ghostBox.Visible = false

    local FOVCircle
    if Drawing then
        FOVCircle = Drawing.new("Circle"); FOVCircle.Visible = false; FOVCircle.Radius = 100; FOVCircle.Color = Color3.fromRGB(255, 255, 255)
        FOVCircle.Thickness = 1; FOVCircle.Filled = false; FOVCircle.Transparency = 1; FOVCircle.ZIndex = 500
    end

    table.insert(State.UnloadConnections, Services.Players.PlayerRemoving:Connect(function(player)
        if State.TracersCache[player] then if State.TracersCache[player].Remove then State.TracersCache[player]:Remove() end; State.TracersCache[player] = nil end
        RuntimeUtils.ClearPlayerESP(player)
    end))

    local espImg = Instance.new("ImageLabel"); espImg.Name = "TargetESPImage"; espImg.Size = UDim2.new(0, Settings.TargetESPConstants.BASE_SIZE, 0, Settings.TargetESPConstants.BASE_SIZE); espImg.AnchorPoint = Vector2.new(0.5, 0.5); espImg.BackgroundTransparency = 1; espImg.ImageColor3 = Color3.new(1,1,1); espImg.Visible = false; espImg.ZIndex = 40; espImg.Parent = ScreenGui
    local TargetESPTextureOptions = {
        {Name = "Rework", File = "target_rework.png"},
        {Name = "Classic", File = "target.png"},
    }
    local TargetESPTextureNames = {}
    local TargetESPTextureLookup = {}
    for index, entry in ipairs(TargetESPTextureOptions) do
        TargetESPTextureNames[index] = entry.Name
        TargetESPTextureLookup[entry.Name] = entry
    end
    local TargetESPTextureAssets = {}

    local function ResolveTargetESPTextureEntry()
        local name = Settings.TargetESP and tostring(Settings.TargetESP.Texture or "") or ""
        return TargetESPTextureLookup[name] or TargetESPTextureLookup.Rework
    end

    local function EnsureWinWareImagesFolder()
        if not (isfolder and makefolder) then return end
        if not isfolder("WinWare") then
            makefolder("WinWare")
        end
        if not isfolder("WinWare/Images") then
            makefolder("WinWare/Images")
        end
    end

    local function LoadTargetESPTextureAsset(entry)
        if not entry then return "" end
        if TargetESPTextureAssets[entry.Name] ~= nil then
            return TargetESPTextureAssets[entry.Name]
        end
        local asset = ""
        if type(getcustomasset) == "function" then
            pcall(function()
                local path = "WinWare/Images/" .. entry.File
                EnsureWinWareImagesFolder()
                if isfile and not isfile(path) then
                    local data = game:HttpGet("https://api.sorrelhub.xyz/images/" .. entry.File)
                    if data and #data > 0 and writefile then
                        writefile(path, data)
                    end
                end
                local ok, resolved = pcall(getcustomasset, path)
                if ok and type(resolved) == "string" then asset = resolved end
            end)
        end
        TargetESPTextureAssets[entry.Name] = asset
        return asset
    end

    local function UpdateESPTexture()
        local entry = ResolveTargetESPTextureEntry()
        local asset = LoadTargetESPTextureAsset(entry)
        espImg.Image = asset ~= "" and asset or ""
        return entry and entry.Name or nil
    end
    task.spawn(UpdateESPTexture)
    local espGradient = Instance.new("UIGradient"); espGradient.Rotation = 45; espGradient.Parent = espImg
    local hudFrame = Instance.new("Frame")
    hudFrame.Name = "TargetHUD"
    hudFrame.Size = UDim2.new(0, 222, 0, 62)
    hudFrame.Position = UDim2.new(0.5, -111, 0.8, 0)
    hudFrame.BackgroundColor3 = UiPanelBlack
    hudFrame.BackgroundTransparency = 0.02
    hudFrame.BorderSizePixel = 0
    hudFrame.Visible = false
    hudFrame.Active = true
    hudFrame.Draggable = true
    hudFrame.Parent = ScreenGui
    hudFrame.ZIndex = 100
    Ui.ApplyCorner(hudFrame, Theme.Corner.Panel)
    if Ui.ApplyShadow then Ui.ApplyShadow(hudFrame) end
    local hudGradient
    local barGradient
    do
        local hStroke = Ui.ApplyStroke(hudFrame, UiAccent, 0.18, 2)
        hudGradient = hStroke and Ui.ApplyGradient(hStroke, UiAccentSoft, UiAccent, 112) or nil

        local hudAvatar = Instance.new("ImageLabel")
        hudAvatar.Name = "Avatar"
        hudAvatar.Size = UDim2.new(0, 42, 0, 42)
        hudAvatar.Position = UDim2.new(0, 9, 0.5, -21)
        hudAvatar.BackgroundColor3 = UiInputDark
        hudAvatar.BackgroundTransparency = 0
        hudAvatar.BorderSizePixel = 0
        hudAvatar.Parent = hudFrame
        hudAvatar.ZIndex = 101
        Ui.ApplyCorner(hudAvatar, Theme.Corner.Small)
        Ui.ApplyStroke(hudAvatar, UiAccentSoft, 0.32, 1)

        local hudName = Instance.new("TextLabel")
        hudName.Name = "NameLabel"
        hudName.Size = UDim2.new(1, -66, 0, 18)
        hudName.Position = UDim2.new(0, 60, 0, 8)
        hudName.BackgroundTransparency = 1
        hudName.TextColor3 = Settings.Colors.TextWhite
        hudName.Font = Enum.Font.GothamBold
        hudName.TextSize = 14
        hudName.TextXAlignment = Enum.TextXAlignment.Left
        hudName.TextTruncate = Enum.TextTruncate.AtEnd
        hudName.Parent = hudFrame
        hudName.ZIndex = 101

        local hudHpText = Instance.new("TextLabel")
        hudHpText.Name = "HpText"
        hudHpText.Size = UDim2.new(1, -66, 0, 15)
        hudHpText.Position = UDim2.new(0, 60, 0, 26)
        hudHpText.BackgroundTransparency = 1
        hudHpText.TextColor3 = UiTextSoft
        hudHpText.Font = Enum.Font.GothamSemibold
        hudHpText.TextSize = 11
        hudHpText.TextXAlignment = Enum.TextXAlignment.Left
        hudHpText.Parent = hudFrame
        hudHpText.ZIndex = 101

        local hudBarBg = Instance.new("Frame")
        hudBarBg.Size = UDim2.new(1, -70, 0, 7)
        hudBarBg.Position = UDim2.new(0, 60, 1, -15)
        hudBarBg.BackgroundColor3 = UiInputDark
        hudBarBg.BackgroundTransparency = 0
        hudBarBg.BorderSizePixel = 0
        hudBarBg.Parent = hudFrame
        hudBarBg.ZIndex = 101
        Ui.ApplyCorner(hudBarBg, Theme.Corner.Pill)

        local hudBarFill = Instance.new("Frame")
        hudBarFill.Name = "BarFill"
        hudBarFill.Size = UDim2.new(1, 0, 1, 0)
        hudBarFill.BackgroundColor3 = Settings.Colors.Accent
        hudBarFill.BorderSizePixel = 0
        hudBarFill.Parent = hudBarBg
        hudBarFill.ZIndex = 102
        Ui.ApplyCorner(hudBarFill, Theme.Corner.Pill)
        barGradient = Instance.new("UIGradient")
        barGradient.Color = ColorSequence.new(Settings.Colors.Accent, Settings.Colors.AccentSoft)
        barGradient.Parent = hudBarFill
    end
    local TooltipFrame = Instance.new("Frame"); TooltipFrame.Name = "Tooltip"; TooltipFrame.Parent = ScreenGui; TooltipFrame.BackgroundColor3 = UiPanelMid; TooltipFrame.BorderSizePixel = 0; TooltipFrame.Size = UDim2.new(0, 150, 0, 30); TooltipFrame.Visible = false; TooltipFrame.ZIndex = 300; TooltipFrame.BackgroundTransparency = 1; Instance.new("UICorner", TooltipFrame).CornerRadius = UDim.new(0, 4); local TooltipStroke = Instance.new("UIStroke", TooltipFrame); TooltipStroke.Color = UiBorder; TooltipStroke.Transparency = 0.52
    local TooltipLabel = Instance.new("TextLabel"); TooltipLabel.Parent = TooltipFrame; TooltipLabel.Font = Enum.Font.Gotham; TooltipLabel.TextSize = 13; TooltipLabel.TextColor3 = UiTextSoft; TooltipLabel.BackgroundTransparency = 1; TooltipLabel.Size = UDim2.new(1, -16, 1, -10); TooltipLabel.Position = UDim2.new(0, 8, 0, 5); TooltipLabel.TextXAlignment = Enum.TextXAlignment.Left; TooltipLabel.TextYAlignment = Enum.TextYAlignment.Top; TooltipLabel.TextWrapped = true; TooltipLabel.TextTransparency = 1
    local function ResolveColors(mode, primary, secondary)
        if mode == "White" then
            return Color3.fromRGB(255,255,255), Color3.fromRGB(230,230,230)
        elseif mode == "Black" then
            return Theme.Colors.NearBlack2, Theme.Colors.NearBlack
        elseif mode == "Accent" then
            return Settings.Colors.Accent, Settings.Colors.AccentSoft
        elseif mode == "CustomGradient" then
            return primary or Settings.Colors.Accent, secondary or (primary or Settings.Colors.Accent)
        else -- Custom or fallback
            local main = primary or Settings.Colors.Accent
            local fall = main:Lerp(Color3.new(0,0,0), 0.35)
            return main, secondary or fall
        end
    end

    local function ApplyReadableTextBox(box)
        if not box then return end
        box:SetAttribute("WinWareReadableInput", true)
        box.BackgroundTransparency = 1
        box.TextColor3 = UiTextBright
        box.PlaceholderColor3 = UiPlaceholderStrong
        box.TextTransparency = 0
        box.TextXAlignment = Enum.TextXAlignment.Left
        box.ClearTextOnFocus = false
    end

    local function CreateTextBoxShell(parent, options)
        options = options or {}
        local shell = Instance.new("Frame")
        shell.Name = options.Name or "InputShell"
        shell.Parent = parent
        local baseBg = options.BackgroundColor3 or UiFieldBg
        local hoverBg = options.HoverColor3 or UiFieldHover
        local focusBg = options.FocusColor3 or hoverBg
        local baseStrokeColor = options.StrokeColor or UiFieldBorder
        local hoverStrokeColor = options.HoverStrokeColor or UiButtonBorder
        local focusStrokeColor = options.FocusStrokeColor or UiAccentMid
        local baseStrokeTransparency = options.StrokeTransparency or 0.42
        local hoverStrokeTransparency = options.HoverStrokeTransparency or 0.28
        shell.BackgroundColor3 = baseBg
        shell.BackgroundTransparency = options.BackgroundTransparency or 0
        shell.BorderSizePixel = 0
        shell.Size = options.Size or UDim2.new(1, 0, 0, options.Height or 34)
        shell.Position = options.Position or UDim2.new(0, 0, 0, 0)
        shell.ZIndex = options.ZIndex or 8
        shell:SetAttribute("WinWareInputShell", true)
        Ui.ApplyCorner(shell, options.Corner or Theme.Corner.Small)
        local stroke = Ui.ApplyStroke(shell, baseStrokeColor, baseStrokeTransparency, 1)
        local from = options.GradientFrom or UiFieldBg
        local to = options.GradientTo or UiFieldBg:Lerp(UiTextBright, 0.055)
        local gradient = Ui.ApplyGradient(shell, from, to, options.Rotation or 90)
        if gradient then
            gradient.Offset = options.GradientOffset or Vector2.new(0, 0.52)
        end

        local padLeft = options.PaddingLeft or 12
        local padRight = options.PaddingRight or 12
        local box = Instance.new("TextBox")
        box.Name = options.TextBoxName or "Input"
        box.Parent = shell
        box.BackgroundTransparency = 1
        box.BorderSizePixel = 0
        box.Size = UDim2.new(1, -(padLeft + padRight), 1, 0)
        box.Position = UDim2.new(0, padLeft, 0, 0)
        box.Font = options.Font or Enum.Font.Gotham
        box.TextSize = options.TextSize or 14
        box.PlaceholderText = options.PlaceholderText or ""
        box.Text = options.Text or ""
        box.ZIndex = shell.ZIndex + 1
        ApplyReadableTextBox(box)

        local isFocused = false
        local function setHoverState(hovered)
            if isFocused then return end
            Ui.Tween(shell, {BackgroundColor3 = hovered and hoverBg or baseBg, BackgroundTransparency = 0}, Theme.Anim.Fast)
            if stroke then
                Ui.Tween(stroke, {Transparency = hovered and hoverStrokeTransparency or baseStrokeTransparency, Color = hovered and hoverStrokeColor or baseStrokeColor}, Theme.Anim.Fast)
            end
            if gradient then
                Ui.Tween(gradient, {Offset = Vector2.new(0, hovered and 0.22 or 0.52), Rotation = hovered and 104 or 90}, Theme.Anim.Normal)
            end
        end

        table.insert(State.UnloadConnections, shell.MouseEnter:Connect(function() setHoverState(true) end))
        table.insert(State.UnloadConnections, shell.MouseLeave:Connect(function() setHoverState(false) end))
        table.insert(State.UnloadConnections, box.Focused:Connect(function()
            isFocused = true
            Ui.Tween(shell, {BackgroundColor3 = focusBg, BackgroundTransparency = 0}, Theme.Anim.Fast)
            if stroke then
                Ui.Tween(stroke, {Transparency = 0.18, Color = focusStrokeColor}, Theme.Anim.Fast)
            end
            if gradient then
                Ui.Tween(gradient, {Offset = Vector2.new(0, 0.08), Rotation = 116}, Theme.Anim.Normal)
            end
        end))
        table.insert(State.UnloadConnections, box.FocusLost:Connect(function()
            isFocused = false
            Ui.Tween(shell, {BackgroundColor3 = baseBg, BackgroundTransparency = 0}, Theme.Anim.Fast)
            if stroke then
                Ui.Tween(stroke, {Transparency = baseStrokeTransparency, Color = baseStrokeColor}, Theme.Anim.Fast)
            end
            if gradient then
                Ui.Tween(gradient, {Offset = Vector2.new(0, 0.52), Rotation = 90}, Theme.Anim.Normal)
            end
        end))

        return shell, box, stroke, gradient
    end

    local function MarkReadableButton(label, defaultColor)
        if not label then return end
        defaultColor = defaultColor or UiTextSoft
        label:SetAttribute("WinWareReadableButtonLabel", true)
        label:SetAttribute("WinWareReadableButtonBaseColor", defaultColor)
        label.TextColor3 = defaultColor
        label.TextTransparency = 0
    end

    local function UpdateESPColor()
        local startColor, endColor = ResolveColors(
            Settings.TargetESP.ColorMode or "Accent",
            Settings.TargetESP.Color,
            Settings.TargetESP.GradientEnd
        )
        espImg.ImageColor3 = Color3.new(1, 1, 1)
        if espGradient then
            espGradient.Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, startColor),
                ColorSequenceKeypoint.new(1, endColor),
            }
        end
    end

    local function UpdateHUDColor()
        local mode = Settings.TargetHUD and Settings.TargetHUD.ColorMode or "Accent"
        local primary = Settings.TargetHUD and Settings.TargetHUD.Color or Settings.Colors.Accent
        local secondary = Settings.TargetHUD and Settings.TargetHUD.GradientEnd or primary
        local startColor, endColor = ResolveColors(mode, primary, secondary)
        local sequence = ColorSequence.new{ColorSequenceKeypoint.new(0, startColor), ColorSequenceKeypoint.new(1, endColor)}
        if hudGradient then hudGradient.Color = sequence end
        if barGradient then barGradient.Color = sequence end
    end

    -- Initialize visuals
    UpdateESPColor()
    UpdateHUDColor()
    local UpdateWatermarkVisibility
    local ApplyWatermarkSettings

    -- Watermark Widget
    do
    local WatermarkContainer = Instance.new("Frame")
    WatermarkContainer.Name = "WatermarkWidget"
    WatermarkContainer.Parent = ScreenGui
    WatermarkContainer.BackgroundColor3 = UiPanelDark
    WatermarkContainer.BackgroundTransparency = 0.04
    WatermarkContainer.AutomaticSize = Enum.AutomaticSize.None
    WatermarkContainer.Size = UDim2.fromOffset(0, 0)
    WatermarkContainer.Position = UDim2.fromOffset(Settings.Watermark.X, Settings.Watermark.Y)
    WatermarkContainer.Visible = false
    WatermarkContainer.ZIndex = 100
    Ui.ApplyCorner(WatermarkContainer, Theme.Corner.Ultra)
    if Ui.ApplyShadow then Ui.ApplyShadow(WatermarkContainer) end
    local wmStroke = Ui.ApplyStroke(WatermarkContainer, UiAccent, 0.2, 1)
    local wmFrom, wmTo = UiPanelDark, UiPanelBlack
    local wmGradient = Ui.ApplyGradient(WatermarkContainer, wmFrom, wmTo, 88)
    local wmStrokeGradient = wmStroke and Ui.ApplyGradient(wmStroke, UiAccentSoft, UiAccent, 108)
    if wmGradient then
        wmGradient.Offset = Vector2.new(0, 0.55)
    end
    local wmScale = Instance.new("UIScale", WatermarkContainer)

    local wmPadding = Instance.new("UIPadding", WatermarkContainer)
    local wmPadX = 8
    local wmPadY = 4
    local wmSpacing = 6
    wmPadding.PaddingLeft = UDim.new(0, wmPadX)
    wmPadding.PaddingRight = UDim.new(0, wmPadX)
    wmPadding.PaddingTop = UDim.new(0, wmPadY)
    wmPadding.PaddingBottom = UDim.new(0, wmPadY)
    local wmLayout = Instance.new("UIListLayout", WatermarkContainer)
    wmLayout.FillDirection = Enum.FillDirection.Horizontal
    wmLayout.Padding = UDim.new(0, wmSpacing)
    wmLayout.VerticalAlignment = Enum.VerticalAlignment.Center

    local wmAccent = Instance.new("Frame", WatermarkContainer)
    wmAccent.Size = UDim2.new(0, 3, 0, 16)
    wmAccent.BackgroundColor3 = Settings.Colors.Accent
    wmAccent.BorderSizePixel = 0
    Ui.ApplyCorner(wmAccent, Theme.Corner.Small)
    local wmAccentGradient = Ui.ApplyGradient(wmAccent, Settings.Colors.Accent, Settings.Colors.AccentSoft, 90)

    local wmClient = Instance.new("TextLabel", WatermarkContainer)
    wmClient.Text = "WINWARE"
    wmClient.Font = Enum.Font.GothamSemibold
    wmClient.TextSize = 12
    wmClient.TextColor3 = Settings.Colors.TextWhite
    wmClient.BackgroundTransparency = 1
    wmClient.AutomaticSize = Enum.AutomaticSize.None
    wmClient.Size = UDim2.fromOffset(0, 0)
    wmClient.TextXAlignment = Enum.TextXAlignment.Left

    local wmUser = Instance.new("TextLabel", WatermarkContainer)
    wmUser.Text = "» " .. tostring(websiteUser or "User") .. " | UID: " .. tostring(websitePublicId or "unknown")
    wmUser.Font = Enum.Font.GothamSemibold
    wmUser.TextSize = 12
    wmUser.TextColor3 = UiTextSoft
    wmUser.BackgroundTransparency = 1
    wmUser.AutomaticSize = Enum.AutomaticSize.None
    wmUser.Size = UDim2.fromOffset(0, 0)
    wmUser.TextXAlignment = Enum.TextXAlignment.Left

    local wmStats = Instance.new("TextLabel", WatermarkContainer)
    wmStats.Text = "| " .. os.date("%I:%M %p")
    wmStats.Font = Enum.Font.GothamSemibold
    wmStats.TextSize = 12
    wmStats.TextColor3 = UiTextSoft
    wmStats.BackgroundTransparency = 1
    wmStats.AutomaticSize = Enum.AutomaticSize.None
    wmStats.Size = UDim2.fromOffset(0, 0)
    wmStats.TextXAlignment = Enum.TextXAlignment.Left

    local wmScaledSize = Vector2.new(0, 0)

    local WatermarkCards = Instance.new("Frame")
    WatermarkCards.Name = "WatermarkCards"
    WatermarkCards.Parent = ScreenGui
    WatermarkCards.BackgroundTransparency = 1
    WatermarkCards.Size = UDim2.fromOffset(0, 0)
    WatermarkCards.Position = UDim2.fromOffset(Settings.Watermark.X, Settings.Watermark.Y)
    WatermarkCards.Visible = false
    WatermarkCards.ZIndex = 100

    local wmCardsScale = Instance.new("UIScale", WatermarkCards)
    wmCardsScale.Scale = 1

    local wmCardsRow = Instance.new("Frame")
    wmCardsRow.Parent = WatermarkCards
    wmCardsRow.BackgroundTransparency = 1
    wmCardsRow.Position = UDim2.fromOffset(0, 0)
    wmCardsRow.Size = UDim2.fromOffset(0, 0)
    wmCardsRow.ZIndex = 101

    local wmCardsRowLayout = Instance.new("UIListLayout")
    wmCardsRowLayout.Parent = wmCardsRow
    wmCardsRowLayout.FillDirection = Enum.FillDirection.Horizontal
    wmCardsRowLayout.Padding = UDim.new(0, 10)
    wmCardsRowLayout.SortOrder = Enum.SortOrder.LayoutOrder
    wmCardsRowLayout.VerticalAlignment = Enum.VerticalAlignment.Top

    local function CreateWatermarkCard(parent, iconText, valueText, width)
        local card = Instance.new("Frame")
        card.Parent = parent
        card.BackgroundColor3 = UiPanelMid
        card.BackgroundTransparency = 0.04
        card.Size = UDim2.fromOffset(width, 52)
        card.ZIndex = 101
        Ui.ApplyCorner(card, Theme.Corner.Big)
        if Ui.ApplyShadow then Ui.ApplyShadow(card) end
        local cardStroke = Ui.ApplyStroke(card, UiBorderSoft, 0.68, 1)
        if cardStroke then
            cardStroke.Color = UiBorderSoft
            cardStroke.Transparency = 0.68
        end

        local icon = Instance.new("TextLabel")
        icon.Parent = card
        icon.BackgroundTransparency = 1
        icon.Position = UDim2.fromOffset(12, 0)
        icon.Size = UDim2.new(0, 26, 1, 0)
        icon.Font = Enum.Font.GothamBold
        icon.Text = iconText
        icon.TextSize = 17
        icon.TextColor3 = Settings.Colors.TextWhite
        icon.TextXAlignment = Enum.TextXAlignment.Center
        icon.TextYAlignment = Enum.TextYAlignment.Center
        icon.ZIndex = 102

        local value = Instance.new("TextLabel")
        value.Parent = card
        value.BackgroundTransparency = 1
        value.Font = Enum.Font.GothamSemibold
        value.Text = valueText
        value.TextSize = 31
        value.TextScaled = true
        value.TextColor3 = Settings.Colors.TextWhite
        value.TextXAlignment = Enum.TextXAlignment.Left
        value.TextYAlignment = Enum.TextYAlignment.Center
        value.ZIndex = 102

        local leftPad = 12
        local gap = 8
        local rightPad = 12
        local iconTextSize = Services.TextService:GetTextSize(iconText, icon.TextSize, icon.Font, Vector2.new(math.huge, math.huge))
        local iconWidth = math.max(26, math.ceil(iconTextSize.X + 6))
        icon.Position = UDim2.fromOffset(leftPad, 0)
        icon.Size = UDim2.new(0, iconWidth, 1, 0)
        value.Position = UDim2.fromOffset(leftPad + iconWidth + gap, 0)
        value.Size = UDim2.new(1, -(leftPad + iconWidth + gap + rightPad), 1, 0)

        return {
            Frame = card,
            Icon = icon,
            Value = value,
        }
    end

    local wmCardClient = CreateWatermarkCard(wmCardsRow, "WW", "Beta", 200)
    local wmCardUser = CreateWatermarkCard(wmCardsRow, "U", websiteUser, 200)
    local wmCardPing = CreateWatermarkCard(wmCardsRow, "P", "0", 140)
    local wmCardFps = CreateWatermarkCard(wmCardsRow, "F", "0", 140)

    local wmTimeCard = Instance.new("Frame")
    wmTimeCard.Parent = WatermarkCards
    wmTimeCard.BackgroundColor3 = UiPanelMid
    wmTimeCard.BackgroundTransparency = 0.04
    wmTimeCard.Size = UDim2.fromOffset(92, 30)
    wmTimeCard.Position = UDim2.fromOffset(56, 54)
    wmTimeCard.ZIndex = 101
    Ui.ApplyCorner(wmTimeCard, Theme.Corner.Big)
    if Ui.ApplyShadow then Ui.ApplyShadow(wmTimeCard) end
    local wmTimeStroke = Ui.ApplyStroke(wmTimeCard, UiBorderSoft, 0.68, 1)
    if wmTimeStroke then
        wmTimeStroke.Color = UiBorderSoft
        wmTimeStroke.Transparency = 0.68
    end

    local wmTimeLabel = Instance.new("TextLabel")
    wmTimeLabel.Parent = wmTimeCard
    wmTimeLabel.BackgroundTransparency = 1
    wmTimeLabel.Size = UDim2.new(1, 0, 1, 0)
    wmTimeLabel.Font = Enum.Font.GothamSemibold
    wmTimeLabel.TextSize = 14
    wmTimeLabel.TextColor3 = Settings.Colors.TextWhite
    wmTimeLabel.Text = "00:00"
    wmTimeLabel.ZIndex = 102

    local wmCardsScaledSize = Vector2.new(0, 0)

    local function UpdateWatermarkSize(accentOn)
        local clientSize = Services.TextService:GetTextSize(wmClient.Text, wmClient.TextSize, wmClient.Font, Vector2.new(math.huge, math.huge))
        local userSize = Services.TextService:GetTextSize(wmUser.Text, wmUser.TextSize, wmUser.Font, Vector2.new(math.huge, math.huge))
        local statsSize = Services.TextService:GetTextSize(wmStats.Text, wmStats.TextSize, wmStats.Font, Vector2.new(math.huge, math.huge))

        wmClient.Size = UDim2.fromOffset(clientSize.X, clientSize.Y)
        wmUser.Size = UDim2.fromOffset(userSize.X, userSize.Y)
        wmStats.Size = UDim2.fromOffset(statsSize.X, statsSize.Y)

        local accentWidth = accentOn and 3 or 0
        local items = 3 + (accentOn and 1 or 0)
        local gaps = math.max(0, items - 1)
        local contentW = clientSize.X + userSize.X + statsSize.X + accentWidth + (wmSpacing * gaps)
        local contentH = math.max(clientSize.Y, math.max(userSize.Y, statsSize.Y))
        local baseW = math.ceil(contentW + (wmPadX * 2))
        local baseH = math.ceil(contentH + (wmPadY * 2))
        WatermarkContainer.Size = UDim2.fromOffset(baseW, baseH)
        wmScaledSize = Vector2.new(baseW * wmScale.Scale, baseH * wmScale.Scale)
        wmAccent.Size = UDim2.new(0, accentWidth, 0, contentH)
    end

    local function UpdateWatermarkCardsSize()
        local fallbackWidth = 200 + 200 + 140 + 140 + (10 * 3)
        local rowWidth = math.max(fallbackWidth, math.ceil(wmCardsRowLayout.AbsoluteContentSize.X))
        local rowHeight = 52
        wmCardsRow.Size = UDim2.fromOffset(rowWidth, rowHeight)
        local showTime = Settings.Watermark.ShowTime == true
        wmTimeCard.Visible = showTime
        if showTime then
            wmTimeCard.Position = UDim2.fromOffset(56, rowHeight + 2)
        end
        local totalHeight = rowHeight + (showTime and (2 + wmTimeCard.Size.Y.Offset) or 0)
        WatermarkCards.Size = UDim2.fromOffset(rowWidth, totalHeight)
        wmCardsScaledSize = Vector2.new(rowWidth * wmCardsScale.Scale, totalHeight * wmCardsScale.Scale)
    end

    local function IsWatermarkCardsStyle()
        return tostring(Settings.Watermark.Style or "Classic") == "Cards"
    end

    local function GetActiveWatermarkScaledSize()
        if IsWatermarkCardsStyle() then
            return wmCardsScaledSize
        end
        return wmScaledSize
    end

    UpdateWatermarkVisibility = function()
        local shouldShow = Library and Library.GlobalHUDState and Library.HudSettings and Library.HudSettings.Watermark
        local cardsStyle = IsWatermarkCardsStyle()
        WatermarkContainer.Visible = shouldShow and not cardsStyle
        WatermarkCards.Visible = shouldShow and cardsStyle
    end

    local function ClampWatermarkPosition(x, y)
        local view = State.Camera.ViewportSize
        local size = GetActiveWatermarkScaledSize()
        local maxX = math.max(0, view.X - size.X)
        local maxY = math.max(0, view.Y - size.Y)
        return math.clamp(x, 0, maxX), math.clamp(y, 0, maxY)
    end

    ApplyWatermarkSettings = function()
        local cfg = Settings.Watermark
        local baseTrans = math.clamp(cfg.Transparency or 0, 0, 1)
        local bgOn = cfg.Background ~= false
        local accentOn = cfg.Accent ~= false
        local BASE_BG = 0.08
        local EXTRA_BG = baseTrans * 0.45
        local computedBg = bgOn and math.clamp(BASE_BG + EXTRA_BG, 0, 0.80) or 1

        if cfg.Style ~= "Cards" and cfg.Style ~= "Classic" then
            cfg.Style = "Classic"
        end

        wmScale.Scale = math.clamp(cfg.Scale or 1, 0.5, 2)
        WatermarkContainer.BackgroundTransparency = computedBg
        if wmStroke then
            wmStroke.Transparency = bgOn and math.clamp(Theme.Stroke.Transparency + baseTrans * 0.30, 0, 0.95) or 1
        end
        if wmGradient then
            wmGradient.Offset = Vector2.new(0, bgOn and 0.5 or 0.65)
            wmGradient.Rotation = bgOn and 96 or 88
        end
        if wmStrokeGradient then
            wmStrokeGradient.Offset = Vector2.new(0, bgOn and 0.45 or 0.58)
            wmStrokeGradient.Rotation = bgOn and 112 or 108
        end
        wmAccent.Visible = accentOn
        wmAccent.BackgroundTransparency = baseTrans
        if wmAccentGradient then
            wmAccentGradient.Offset = Vector2.new(0, accentOn and 0.15 or 0.55)
            wmAccentGradient.Rotation = accentOn and 120 or 90
        end
        wmClient.TextColor3 = accentOn and Settings.Colors.Accent or Settings.Colors.TextWhite
        wmClient.TextTransparency = baseTrans
        wmUser.TextTransparency = baseTrans
        wmStats.TextTransparency = baseTrans
        UpdateWatermarkSize(accentOn)

        wmCardsScale.Scale = math.clamp(cfg.Scale or 1, 0.5, 2)
        local cardBgTrans = computedBg
        local cardTextColor = accentOn and Settings.Colors.Accent or Settings.Colors.TextWhite
        for _, entry in ipairs({wmCardClient, wmCardUser, wmCardPing, wmCardFps}) do
            entry.Frame.BackgroundTransparency = cardBgTrans
            entry.Value.TextTransparency = baseTrans
            entry.Icon.TextTransparency = baseTrans
        end
        wmCardClient.Value.TextColor3 = cardTextColor
        wmCardUser.Value.TextColor3 = Settings.Colors.TextWhite
        wmCardPing.Value.TextColor3 = Settings.Colors.TextWhite
        wmCardFps.Value.TextColor3 = Settings.Colors.TextWhite
        wmTimeCard.BackgroundTransparency = cardBgTrans
        wmTimeLabel.TextTransparency = baseTrans
        UpdateWatermarkCardsSize()

        local x, y = ClampWatermarkPosition(cfg.X or 0, cfg.Y or 0)
        Settings.Watermark.X = x
        Settings.Watermark.Y = y
        WatermarkContainer.Position = UDim2.fromOffset(x, y)
        WatermarkCards.Position = UDim2.fromOffset(x, y)
        UpdateWatermarkVisibility()
    end

    ApplyWatermarkSettings()

    table.insert(State.UnloadConnections, State.Camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
        ApplyWatermarkSettings()
        if HotkeysFrame and HotkeysFrame:FindFirstChildOfClass("UIScale") then
            local w = State.Camera.ViewportSize.X
            HotkeysFrame:FindFirstChildOfClass("UIScale").Scale = math.clamp(w / 1920, 0.6, 1)
        end
    end))

    local wmDragging = false
    local wmDragStart
    local wmStartPos
    local function BindWatermarkDrag(frame)
        table.insert(State.UnloadConnections, frame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                if Settings.Watermark.HoldKey and Settings.Watermark.HoldKeyCode then
                    if not Services.UserInputService:IsKeyDown(Settings.Watermark.HoldKeyCode) then
                        return
                    end
                end
                wmDragging = true
                wmDragStart = input.Position
                wmStartPos = frame.Position
            end
        end))
        table.insert(State.UnloadConnections, frame.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                wmDragging = false
            end
        end))
    end

    BindWatermarkDrag(WatermarkContainer)
    BindWatermarkDrag(WatermarkCards)

    table.insert(State.UnloadConnections, Services.UserInputService.InputChanged:Connect(function(input)
        if not wmDragging then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - wmDragStart
            local rawX = wmStartPos.X.Offset + delta.X
            local rawY = wmStartPos.Y.Offset + delta.Y
            local x, y = ClampWatermarkPosition(rawX, rawY)
            Settings.Watermark.X = x
            Settings.Watermark.Y = y
            WatermarkContainer.Position = UDim2.fromOffset(x, y)
            WatermarkCards.Position = UDim2.fromOffset(x, y)
        end
    end))

    local function GetApproxFps()
        local ok, fps = pcall(function()
            return Services.Workspace.GetRealPhysicsFPS and Services.Workspace:GetRealPhysicsFPS()
        end)
        if ok and type(fps) == "number" and fps > 0 then
            return math.floor(fps + 0.5)
        end
        return 0
    end

    task.spawn(function()
        while ScreenGui and ScreenGui.Parent do
            task.wait(1)
            local now = tick()
            local watermarkVisible = WatermarkContainer.Visible or WatermarkCards.Visible
            if watermarkVisible then
                if wmGradient then
                    wmGradient.Rotation = 88 + (math.sin(now * 0.9) * 9)
                end
                if wmStrokeGradient then
                    wmStrokeGradient.Rotation = 108 + (math.cos(now * 0.85) * 11)
                end
                if wmAccentGradient and wmAccent.Visible then
                    wmAccentGradient.Rotation = (now * 140) % 360
                end

                local pingMs = math.floor((RuntimeUtils.GetPingSeconds() * 1000) + 0.5)
                wmStats.Text = "| " .. os.date("%I:%M %p")
                wmCardPing.Value.Text = tostring(math.clamp(pingMs, 0, 999))
                wmCardFps.Value.Text = tostring(math.clamp(GetApproxFps(), 0, 999))
                if Settings.Watermark.ShowTime == true then
                    wmTimeLabel.Text = os.date("%H:%M")
                end
                UpdateWatermarkSize(Settings.Watermark.Accent ~= false)
                UpdateWatermarkCardsSize()
                local x, y = ClampWatermarkPosition(Settings.Watermark.X or 0, Settings.Watermark.Y or 0)
                if x ~= Settings.Watermark.X or y ~= Settings.Watermark.Y then
                    Settings.Watermark.X = x
                    Settings.Watermark.Y = y
                    WatermarkContainer.Position = UDim2.fromOffset(x, y)
                    WatermarkCards.Position = UDim2.fromOffset(x, y)
                end
                UpdateWatermarkVisibility()
            end
        end
    end)
    end

    local UIContainerCompatClass = "Frame"
    local function NewUIContainer()
        return Instance.new(UIContainerCompatClass)
    end

    -- Category sidebar
    local CategoryBar = NewUIContainer()
    CategoryBar.Name = "CategoryBar"
    CategoryBar.Parent = ScreenGui
    CategoryBar.BackgroundColor3 = UiPanelBlack
    CategoryBar.BackgroundTransparency = 0
    if CategoryBar:IsA("CanvasGroup") then
        CategoryBar.GroupTransparency = 0
        CategoryBar.GroupColor3 = Color3.new(1, 1, 1)
    end
    CategoryBar.Position = UDim2.new(0, Theme.Layout.SidebarX or Theme.Layout.Edge, 0, Theme.Layout.Top)
    CategoryBar.Size = UDim2.new(0, Theme.Layout.CategoryWidth, 0, Theme.Layout.WindowMaxHeight)
    CategoryBar.Visible = false
    CategoryBar.ZIndex = 90
    CategoryBar.ClipsDescendants = true
    Ui.ApplyCorner(CategoryBar, Theme.Corner.Window)
    if Ui.ApplyShadow then Ui.ApplyShadow(CategoryBar) end
    local catStroke = Ui.ApplyStroke(CategoryBar, UiBorder, 0.5, 1)
    local catFrom, catTo = UiPanelBlack, UiPanelDark
    local CategoryGradient = Ui.ApplyGradient(CategoryBar, catFrom, catTo, 96)
    local CategoryStrokeGradient = catStroke and Ui.ApplyGradient(catStroke, UiBorderSoft, UiBorder, 112)
    local CategoryScale = Instance.new("UIScale", CategoryBar); CategoryScale.Scale = 1

    local catPad = Instance.new("UIPadding", CategoryBar)
    catPad.PaddingTop = UDim.new(0, 10)
    catPad.PaddingBottom = UDim.new(0, 10)
    catPad.PaddingLeft = UDim.new(0, 9)
    catPad.PaddingRight = UDim.new(0, 9)

    local catLayout = Instance.new("UIListLayout", CategoryBar)
    catLayout.SortOrder = Enum.SortOrder.LayoutOrder
    catLayout.Padding = UDim.new(0, 7)

    local BrandHeader = Instance.new("Frame", CategoryBar)
    BrandHeader.Name = "BrandHeader"
    BrandHeader.BackgroundTransparency = 1
    BrandHeader.Size = UDim2.new(1, 0, 0, 42)
    BrandHeader.LayoutOrder = -30
    BrandHeader.ZIndex = 91

    local BrandMark = Instance.new("Frame", BrandHeader)
    BrandMark.BackgroundColor3 = UiAccent
    BrandMark.BorderSizePixel = 0
    BrandMark.Position = UDim2.new(0, 0, 0.5, -16)
    BrandMark.Size = UDim2.new(0, 32, 0, 32)
    BrandMark.ZIndex = 92
    Ui.ApplyCorner(BrandMark, Theme.Corner.Big)
    local BrandMarkGradient = Ui.ApplyGradient(BrandMark, UiAccent, UiAccentSoft, 45)
    Ui.ApplyStroke(BrandMark, UiAccentSoft, 0.32, 1)

    local BrandGlyph = Instance.new("TextLabel", BrandMark)
    BrandGlyph.BackgroundTransparency = 1
    BrandGlyph.Size = UDim2.new(1, 0, 1, 0)
    BrandGlyph.Text = "W"
    BrandGlyph.Font = Enum.Font.GothamBold
    BrandGlyph.TextSize = 18
    BrandGlyph.TextColor3 = UiTextBright
    BrandGlyph.ZIndex = 93

    local BrandTitle = Instance.new("TextLabel", BrandHeader)
    BrandTitle.BackgroundTransparency = 1
    BrandTitle.Position = UDim2.new(0, 40, 0, 0)
    BrandTitle.Size = UDim2.new(1, -40, 1, 0)
    BrandTitle.Text = "WinWare"
    BrandTitle.Font = Enum.Font.GothamBold
    BrandTitle.TextSize = 16
    BrandTitle.TextColor3 = UiTextBright
    BrandTitle.TextXAlignment = Enum.TextXAlignment.Left
    BrandTitle.ZIndex = 92

    local MainNavLabel = Instance.new("TextLabel", CategoryBar)
    MainNavLabel.BackgroundTransparency = 1
    MainNavLabel.Size = UDim2.new(1, 0, 0, 14)
    MainNavLabel.LayoutOrder = -20
    MainNavLabel.Text = "SECTIONS"
    MainNavLabel.Font = Enum.Font.GothamSemibold
    MainNavLabel.TextSize = 10
    MainNavLabel.TextColor3 = UiTextMuted
    MainNavLabel.TextXAlignment = Enum.TextXAlignment.Left
    MainNavLabel.ZIndex = 91

    -- Right side panel (Configs + Player Lists)
    local RightPanel = NewUIContainer()
    RightPanel.Name = "RightPanel"
    RightPanel.Parent = ScreenGui
    RightPanel.BackgroundColor3 = UiPanelBlack
    RightPanel.BackgroundTransparency = 0
    if RightPanel:IsA("CanvasGroup") then
        RightPanel.GroupTransparency = 0
        RightPanel.GroupColor3 = Color3.new(1, 1, 1)
    end
    RightPanel.Position = UDim2.new(0, Theme.Layout.RightX or (Theme.Layout.Edge + Theme.Layout.CategoryWidth + Theme.Layout.Gap + Theme.Layout.WindowWidth + Theme.Layout.Gap), 0, Theme.Layout.Top)
    RightPanel.Size = UDim2.new(0, Theme.Layout.RightWidth or 300, 0, Theme.Layout.RightHeight or Theme.Layout.WindowMaxHeight)
    RightPanel.Visible = false
    RightPanel.ZIndex = 90
    RightPanel.ClipsDescendants = true
    Ui.ApplyCorner(RightPanel, Theme.Corner.Window)
    if Ui.ApplyShadow then Ui.ApplyShadow(RightPanel) end
    local rightStroke = Ui.ApplyStroke(RightPanel, UiBorder, 0.5, 1)
    local RightPanelGradient = Ui.ApplyGradient(RightPanel, UiPanelBlack, UiPanelDark, 82)
    local RightStrokeGradient = rightStroke and Ui.ApplyGradient(rightStroke, UiBorderSoft, UiBorder, 104)
    local RightScale = Instance.new("UIScale", RightPanel); RightScale.Scale = 1

    local RightScroll = Instance.new("ScrollingFrame")
    RightScroll.Name = "RightScroll"
    RightScroll.Parent = RightPanel
    RightScroll.BackgroundTransparency = 1
    RightScroll.BorderSizePixel = 0
    RightScroll.Position = UDim2.new(0, 0, 0, 0)
    RightScroll.Size = UDim2.new(1, 0, 1, 0)
    RightScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    RightScroll.ScrollBarThickness = 0
    RightScroll.ScrollBarImageColor3 = UiAccentSoft
    RightScroll.ScrollBarImageTransparency = 0.24
    RightScroll.ScrollingDirection = Enum.ScrollingDirection.Y
    RightScroll.ClipsDescendants = true
    RightScroll.ZIndex = 91

    local rightPad = Instance.new("UIPadding", RightScroll)
    rightPad.PaddingTop = UDim.new(0, 10)
    rightPad.PaddingBottom = UDim.new(0, 14)
    rightPad.PaddingLeft = UDim.new(0, 10)
    rightPad.PaddingRight = UDim.new(0, 10)

    local rightLayout = Instance.new("UIListLayout", RightScroll)
    rightLayout.SortOrder = Enum.SortOrder.LayoutOrder
    rightLayout.Padding = UDim.new(0, 8)

    local function UpdateRightScrollCanvas()
        local contentHeight = rightLayout.AbsoluteContentSize.Y + rightPad.PaddingTop.Offset + rightPad.PaddingBottom.Offset + 2
        local viewportHeight = math.max(1, RightScroll.AbsoluteSize.Y)
        RightScroll.CanvasSize = UDim2.new(0, 0, 0, contentHeight)
        RightScroll.ScrollBarThickness = contentHeight > (viewportHeight + 1) and 3 or 0
    end
    table.insert(State.UnloadConnections, rightLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateRightScrollCanvas))
    table.insert(State.UnloadConnections, RightScroll:GetPropertyChangedSignal("AbsoluteSize"):Connect(UpdateRightScrollCanvas))

    local function CreateRightSection(title)
        local section = Instance.new("Frame")
        section.Parent = RightScroll
        section.BackgroundColor3 = UiPanelMid
        section.BackgroundTransparency = 0
        section.Size = UDim2.new(1, 0, 0, 0)
        section.AutomaticSize = Enum.AutomaticSize.Y
        section.ZIndex = 91
        Ui.ApplyCorner(section, Theme.Corner.Big)
        if Ui.ApplyShadow then Ui.ApplyShadow(section) end
        local sectionStroke = Ui.ApplyStroke(section, UiBorderSoft, 0.58, 1)
        local sectionGradient = Ui.ApplyGradient(section, UiPanelMid, UiPanelSoft, 88)
        local sectionStrokeGradient = sectionStroke and Ui.ApplyGradient(sectionStroke, UiBorderSoft, UiBorder, 106)

        local pad = Instance.new("UIPadding", section)
        pad.PaddingTop = UDim.new(0, 10)
        pad.PaddingBottom = UDim.new(0, 8)
        pad.PaddingLeft = UDim.new(0, 10)
        pad.PaddingRight = UDim.new(0, 10)

        local layout = Instance.new("UIListLayout", section)
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0, 8)

        local header = Instance.new("TextLabel", section)
        header.Text = title
        header.Font = Enum.Font.GothamBold
        header.TextSize = 14
        header.TextColor3 = UiTextBright
        header.BackgroundTransparency = 1
        header.Size = UDim2.new(1, 0, 0, 20)
        header.TextXAlignment = Enum.TextXAlignment.Left

        local body = Instance.new("Frame", section)
        body.BackgroundTransparency = 1
        body.Size = UDim2.new(1, 0, 0, 0)
        body.AutomaticSize = Enum.AutomaticSize.Y
        body.ZIndex = 92

        local bodyLayout = Instance.new("UIListLayout", body)
        bodyLayout.SortOrder = Enum.SortOrder.LayoutOrder
        bodyLayout.Padding = UDim.new(0, 6)
        table.insert(State.UnloadConnections, layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateRightScrollCanvas))
        table.insert(State.UnloadConnections, bodyLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateRightScrollCanvas))

        return body
    end

    local RightConfigsBody = CreateRightSection("Config Manager")
    local RightListsBody = CreateRightSection("Player Lists")
    task.defer(UpdateRightScrollCanvas)

    local function RightAddButton(parent, text, callback)
        local primary = text == "Save Config" or text == "Load Config"
        local button = Instance.new("TextButton")
        button.Parent = parent
        button.BackgroundTransparency = 1
        button.Size = UDim2.new(1, 0, 0, primary and 30 or 28)
        button.Text = ""
        button.AutoButtonColor = false
        button.ZIndex = 93

        local bg = Instance.new("Frame", button)
        bg.BackgroundColor3 = primary and UiAccentDeep or UiPanelBlack:Lerp(UiFieldBg, 0.32)
        bg.BackgroundTransparency = primary and 0 or 0.14
        bg.Size = UDim2.new(1, 0, 1, 0)
        bg.ZIndex = 93
        Ui.ApplyCorner(bg, Theme.Corner.Small)
        local bgStroke = Ui.ApplyStroke(bg, primary and UiAccentSoft or UiBorderSoft, primary and 0.34 or 0.64, 1)
        local bgGradient = Ui.ApplyGradient(bg, primary and UiAccent or UiPanelBlack:Lerp(UiFieldBg, 0.25), primary and UiAccentSoft or UiFieldBg:Lerp(UiAccentSoft, 0.05), 86)
        local clickScale = Ui.EnsureScale(bg, 1)

        local accentStrip = nil
        local arrow = nil
        if not primary then
            accentStrip = Instance.new("Frame", bg)
            accentStrip.BackgroundColor3 = UiAccentSoft
            accentStrip.BackgroundTransparency = 0.78
            accentStrip.BorderSizePixel = 0
            accentStrip.Position = UDim2.new(0, 0, 0, 6)
            accentStrip.Size = UDim2.new(0, 2, 1, -12)
            accentStrip.ZIndex = 94
            Ui.ApplyCorner(accentStrip, Theme.Corner.Pill)

            arrow = Instance.new("TextLabel", button)
            arrow.BackgroundTransparency = 1
            arrow.Position = UDim2.new(1, -20, 0, 0)
            arrow.Size = UDim2.new(0, 14, 1, 0)
            arrow.Font = Enum.Font.GothamBold
            arrow.Text = ">"
            arrow.TextSize = 11
            arrow.TextColor3 = UiTextMuted
            arrow.TextXAlignment = Enum.TextXAlignment.Center
            arrow.ZIndex = 94
        end

        local label = Instance.new("TextLabel", button)
        label.Text = text
        label.TextColor3 = primary and UiTextBright or UiTextSoft
        label.Font = Enum.Font.GothamSemibold
        label.TextSize = primary and 13 or 12
        label.BackgroundTransparency = 1
        label.Size = UDim2.new(1, primary and -12 or -32, 1, 0)
        label.Position = UDim2.new(0, primary and 6 or 12, 0, 0)
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.ZIndex = 94
        MarkReadableButton(label, primary and UiTextBright or UiTextSoft)

        table.insert(State.UnloadConnections, button.MouseButton1Click:Connect(function()
            Ui.PulseScale(clickScale, 0.94, 0.06, 0.16)
            if callback then callback() end
        end))
        table.insert(State.UnloadConnections, button.MouseEnter:Connect(function()
            Ui.Tween(label, {TextColor3 = UiTextBright}, Theme.Anim.Fast)
            Ui.Tween(bg, {BackgroundTransparency = primary and 0.0 or 0.04, BackgroundColor3 = primary and UiAccent or UiPanelBlack:Lerp(UiAccentDeep, 0.18)}, Theme.Anim.Fast)
            if bgStroke then Ui.Tween(bgStroke, {Transparency = 0.22, Color = primary and UiAccentSoft or UiAccentMid}, Theme.Anim.Fast) end
            if accentStrip then Ui.Tween(accentStrip, {BackgroundTransparency = 0.28, BackgroundColor3 = UiAccentSoft}, Theme.Anim.Fast) end
            if arrow then Ui.Tween(arrow, {TextColor3 = UiAccentSoft, Position = UDim2.new(1, -18, 0, 0)}, Theme.Anim.Fast) end
            if bgGradient then
                Ui.Tween(bgGradient, {Offset = Vector2.new(0, 0.2), Rotation = math.random(82, 102)}, Theme.Anim.Normal)
            end
        end))
        table.insert(State.UnloadConnections, button.MouseLeave:Connect(function()
            Ui.Tween(label, {TextColor3 = primary and UiTextBright or UiTextSoft}, Theme.Anim.Fast)
            Ui.Tween(bg, {BackgroundTransparency = primary and 0 or 0.14, BackgroundColor3 = primary and UiAccentDeep or UiPanelBlack:Lerp(UiFieldBg, 0.32)}, Theme.Anim.Fast)
            if bgStroke then Ui.Tween(bgStroke, {Transparency = primary and 0.34 or 0.64, Color = primary and UiAccentSoft or UiBorderSoft}, Theme.Anim.Fast) end
            if accentStrip then Ui.Tween(accentStrip, {BackgroundTransparency = 0.78, BackgroundColor3 = UiAccentSoft}, Theme.Anim.Fast) end
            if arrow then Ui.Tween(arrow, {TextColor3 = UiTextMuted, Position = UDim2.new(1, -20, 0, 0)}, Theme.Anim.Fast) end
            if bgGradient then
                Ui.Tween(bgGradient, {Offset = Vector2.new(0, 0.5), Rotation = 68}, Theme.Anim.Normal)
            end
        end))
        task.defer(UpdateRightScrollCanvas)
        return button
    end

    local function RightAddTextbox(parent, placeholder)
        local frame = Instance.new("Frame")
        frame.Parent = parent
        frame.BackgroundTransparency = 1
        frame.Size = UDim2.new(1, 0, 0, 34)
        frame.ZIndex = 93

        local shell, box, stroke = CreateTextBoxShell(frame, {
            PlaceholderText = placeholder or "",
            Name = "ConfigInputShell",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = UiPanelBlack:Lerp(UiInputDark, 0.45),
            ZIndex = 94,
            TextSize = 13,
            PaddingLeft = 16,
            PaddingRight = 10,
            StrokeColor = UiAccentSoft:Lerp(UiBorderSoft, 0.52),
            StrokeTransparency = 0.46,
            GradientFrom = UiPanelBlack:Lerp(UiInputDark, 0.42),
            GradientTo = UiInputDark:Lerp(UiAccentDeep, 0.06),
        })
        if shell then
            local inputStrip = Instance.new("Frame", shell)
            inputStrip.BackgroundColor3 = UiAccentSoft
            inputStrip.BackgroundTransparency = 0.46
            inputStrip.BorderSizePixel = 0
            inputStrip.Position = UDim2.new(0, 6, 0, 8)
            inputStrip.Size = UDim2.new(0, 2, 1, -16)
            inputStrip.ZIndex = shell.ZIndex + 2
            Ui.ApplyCorner(inputStrip, Theme.Corner.Pill)
        end
        if stroke then
            stroke.Thickness = 1
        end
        task.defer(UpdateRightScrollCanvas)
        return box
    end

    local function ApplyUILayout()
        Ui.ComputeUILayout()
        local mainX = Theme.Layout.MainX or Theme.Layout.Edge
        local mainY = Theme.Layout.MainY or Theme.Layout.Top
        CategoryBar.Position = UDim2.new(0, Theme.Layout.SidebarX or Theme.Layout.Edge, 0, mainY)
        CategoryBar.Size = UDim2.new(0, Theme.Layout.CategoryWidth, 0, Theme.Layout.WindowMaxHeight)
        RightPanel.Position = UDim2.new(0, Theme.Layout.RightX or (mainX + Theme.Layout.WindowWidth + Theme.Layout.Gap), 0, mainY)
        RightPanel.Size = UDim2.new(0, Theme.Layout.RightWidth or 300, 0, Theme.Layout.RightHeight or Theme.Layout.WindowMaxHeight)
        RightScroll.Position = UDim2.new(0, 0, 0, 0)
        RightScroll.Size = UDim2.new(1, 0, 1, 0)
        UpdateRightScrollCanvas()
        for _, win in ipairs(Library.Windows or {}) do
            if win and win.Frame then
                win.Frame.Position = UDim2.new(0, mainX, 0, mainY)
                win.Frame.Size = UDim2.new(0, Theme.Layout.WindowWidth, 0, Theme.Layout.WindowMaxHeight)
                if win.UpdateLayout then
                    win.UpdateLayout()
                end
            end
        end
    end

    local CanvasGroupColor = Color3.new(1, 1, 1)
    local function NormalizeCanvasGroup(group)
        if not group or not group:IsA("CanvasGroup") then return end
        group.GroupColor3 = CanvasGroupColor
        group.GroupTransparency = 0
    end

    local function NormalizeAllCanvasGroups(root)
        root = root or ScreenGui
        if not root then return end
        for _, obj in ipairs(root:GetDescendants()) do
            if obj:IsA("CanvasGroup") then
                NormalizeCanvasGroup(obj)
            end
        end
    end

    local function IsTextOnLightSurface(textObj)
        local parent = textObj and textObj.Parent
        if not parent or not parent:IsA("GuiObject") then return false end
        local transparency = parent.BackgroundTransparency
        if transparency == nil or transparency >= 0.5 then return false end
        return Ui.GetColorLuma(parent.BackgroundColor3) > 0.6
    end

    local function NormalizeTextContrast(root)
        root = root or ScreenGui
        if not root then return end
        for _, obj in ipairs(root:GetDescendants()) do
            if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
                if Ui.GetColorLuma(obj.TextColor3) < 0.2 and not IsTextOnLightSurface(obj) then
                    if obj.Font == Enum.Font.GothamBold or obj.Font == Enum.Font.GothamSemibold then
                        obj.TextColor3 = Settings.Colors.TextWhite
                    else
                        obj.TextColor3 = UiTextSoft
                    end
                end
            end
        end
    end

    local function NormalizeUiVisualState()
        Ui.EnsureThemeContrast()
        -- NormalizeAllCanvasGroups(ScreenGui)
        -- NormalizeTextContrast(ScreenGui)
        if Library and Library.Modules then
            for _, mod in ipairs(Library.Modules) do
                if mod._label then
                    mod._label.TextColor3 = UiTextBright
                    mod._label.TextTransparency = 0
                end
            end
        end
        if Library and Library.Categories then
            for name, entry in pairs(Library.Categories) do
                local active = Library.ActiveCategory == name
                if entry.Label then
                    entry.Label.TextColor3 = active and UiTextBright or UiTextBright:Lerp(UiTextSoft, 0.18)
                end
                if entry.Icon then
                    entry.Icon.TextColor3 = UiTextBright
                end
            end
        end
        for _, item in ipairs(ScreenGui:GetDescendants()) do
            if item:GetAttribute("WinWareReadableInput") and item:IsA("TextBox") then
                ApplyReadableTextBox(item)
            elseif item:GetAttribute("WinWareReadableButtonLabel") and (item:IsA("TextLabel") or item:IsA("TextButton")) then
                if item.TextTransparency > 0.05 or Ui.GetColorLuma(item.TextColor3) < 0.32 then
                    item.TextColor3 = item:GetAttribute("WinWareReadableButtonBaseColor") or UiTextSoft
                    item.TextTransparency = 0
                end
            end
        end
    end

    local function FadeInGroup(group, duration)
        if not group or not group:IsA("CanvasGroup") then return end
        NormalizeCanvasGroup(group)
        group.GroupTransparency = 0
    end

    table.insert(State.UnloadConnections, State.Camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
        if Library and Library.Opened then
            ApplyUILayout()
        end
    end))

    -- Sidebar section initials and order
    local CategoryIcons = {
        Combat = "C",
        Movement = "M",
        Visuals = "V",
        Player = "P",
        Misc = "M",
        Configs = "C",
        Settings = "S",
    }

    local CategoryOrder = {
        Combat = 1,
        Movement = 2,
        Visuals = 3,
        Player = 4,
        Misc = 5,
        Configs = 6,
        Settings = 7,
    }

    local function UpdateCategorySize()
        CategoryBar.Size = UDim2.new(0, Theme.Layout.CategoryWidth, 0, Theme.Layout.WindowMaxHeight)
    end
    catLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateCategorySize)

    function Library:RegisterCategory(name, frame)
        if not name or not frame then return end
        local rowBaseTrans = 0
        local rowHoverTrans = 0
        local rowActiveTrans = 0.0
        local button = Instance.new("TextButton")
        button.Name = name .. "Category"
        button.Parent = CategoryBar
        button.BackgroundColor3 = UiInputDark:Lerp(UiTextBright, 0.025)
        button.BackgroundTransparency = rowBaseTrans
        button.Size = UDim2.new(1, 0, 0, 36)
        button.Text = ""
        button.AutoButtonColor = false
        button.LayoutOrder = CategoryOrder[name] or 100
        Ui.ApplyCorner(button, Theme.Corner.Big)
        Ui.ApplyStroke(button, UiBorderSoft, 0.62, 1)
        local buttonStroke = button:FindFirstChildOfClass("UIStroke")
        local catBtnFrom, catBtnTo = Ui.GetSoftGradientPair(0.14)
        local buttonGradient = Ui.ApplyGradient(button, catBtnFrom, catBtnTo, 92)
        local buttonStrokeGradient = buttonStroke and Ui.ApplyGradient(buttonStroke, UiBorderSoft, UiBorder, 104)
        local buttonScale = Ui.EnsureScale(button, 1)
        if buttonGradient then
            buttonGradient.Offset = Vector2.new(0, 0.55)
        end
        local RowDivider = Instance.new("Frame", button)
        RowDivider.Name = "RowDivider"
        RowDivider.BackgroundColor3 = UiAccentSoft
        RowDivider.BackgroundTransparency = 1
        RowDivider.BorderSizePixel = 0
        RowDivider.Size = UDim2.new(0, 3, 1, -14)
        RowDivider.Position = UDim2.new(0, 5, 0, 7)
        RowDivider.ZIndex = 8
        Ui.ApplyCorner(RowDivider, Theme.Corner.Pill)

        local iconFrame = Instance.new("Frame", button)
        iconFrame.Size = UDim2.new(0, 24, 0, 24)
        iconFrame.Position = UDim2.new(0, 10, 0.5, -12)
        iconFrame.BackgroundColor3 = UiPanelBlack:Lerp(UiTextBright, 0.035)
        iconFrame.BackgroundTransparency = 0
        iconFrame.BorderSizePixel = 0
        Ui.ApplyCorner(iconFrame, Theme.Corner.Big)
        Ui.ApplyStroke(iconFrame, UiBorderSoft, 0.48, 1)
        local iconStroke = iconFrame:FindFirstChildOfClass("UIStroke")
        local iconFrom, iconTo = Ui.GetSoftGradientPair(0.2)
        local iconGradient = Ui.ApplyGradient(iconFrame, iconFrom, iconTo, 88)
        local iconStrokeGradient = iconStroke and Ui.ApplyGradient(iconStroke, UiBorderSoft, UiBorder, 108)
        if iconGradient then
            iconGradient.Offset = Vector2.new(0, 0.45)
        end

        local iconLabel = Instance.new("TextLabel", iconFrame)
        iconLabel.Text = CategoryIcons[name] or tostring(name):sub(1, 1)
        iconLabel.Font = Enum.Font.GothamBold
        iconLabel.TextSize = 12
        iconLabel.TextColor3 = UiTextBright
        iconLabel.BackgroundTransparency = 1
        iconLabel.Size = UDim2.new(1, 0, 1, 0)
        iconLabel.TextXAlignment = Enum.TextXAlignment.Center
        iconLabel.TextYAlignment = Enum.TextYAlignment.Center

        local textLabel = Instance.new("TextLabel", button)
        textLabel.Text = name
        textLabel.TextColor3 = UiTextBright:Lerp(UiTextSoft, 0.18)
        textLabel.Font = Enum.Font.GothamSemibold
        textLabel.TextSize = 13
        textLabel.BackgroundTransparency = 1
        textLabel.Position = UDim2.new(0, 42, 0, 0)
        textLabel.Size = UDim2.new(1, -48, 1, 0)
        textLabel.TextXAlignment = Enum.TextXAlignment.Left

        local activeBar = Instance.new("Frame", button)
        activeBar.Size = UDim2.new(0, 3, 1, -12)
        activeBar.Position = UDim2.new(0, 5, 0, 6)
        activeBar.BackgroundColor3 = UiAccent
        activeBar.BorderSizePixel = 0
        activeBar.Visible = false
        activeBar.ZIndex = 7
        Ui.ApplyCorner(activeBar, Theme.Corner.Big)
        local activeBarGradient = Ui.ApplyGradient(activeBar, UiAccent, UiAccentSoft, 98)
        if activeBarGradient then
            activeBarGradient.Offset = Vector2.new(0, 0.5)
        end
        iconFrame.ZIndex = 9
        iconLabel.ZIndex = 10
        textLabel.ZIndex = 10

        table.insert(State.UnloadConnections, button.MouseEnter:Connect(function()
            local active = Library.ActiveCategory == name
            Ui.Tween(button, {BackgroundTransparency = active and rowActiveTrans or rowHoverTrans}, Theme.Anim.Fast)
            Ui.Tween(textLabel, {TextColor3 = Settings.Colors.TextWhite}, Theme.Anim.Fast)
            Ui.Tween(iconLabel, {TextColor3 = UiTextBright}, Theme.Anim.Fast)
            Ui.Tween(iconFrame, {BackgroundColor3 = active and UiAccentDeep or UiPanelBlack:Lerp(UiAccentDeep, 0.22)}, Theme.Anim.Fast)
            if buttonStroke then
                Ui.Tween(buttonStroke, {Transparency = active and 0.12 or 0.34, Color = active and Settings.Colors.Accent or UiAccentMid}, Theme.Anim.Fast)
            end
            if iconStroke then
                Ui.Tween(iconStroke, {Transparency = active and 0.16 or 0.28, Color = UiAccentSoft}, Theme.Anim.Fast)
            end
            if buttonGradient then
                Ui.Tween(buttonGradient, {Offset = Vector2.new(0, 0.2), Rotation = math.random(84, 104)}, Theme.Anim.Normal)
            end
            if buttonStrokeGradient then
                Ui.Tween(buttonStrokeGradient, {Offset = Vector2.new(0, 0.2), Rotation = math.random(94, 114)}, Theme.Anim.Normal)
            end
            if iconGradient then
                Ui.Tween(iconGradient, {Offset = Vector2.new(0, 0.12), Rotation = math.random(95, 118)}, Theme.Anim.Normal)
            end
            if iconStrokeGradient then
                Ui.Tween(iconStrokeGradient, {Offset = Vector2.new(0, 0.18), Rotation = math.random(105, 130)}, Theme.Anim.Normal)
            end
            Ui.Tween(RowDivider, {BackgroundTransparency = 1}, Theme.Anim.Fast)
        end))
        table.insert(State.UnloadConnections, button.MouseLeave:Connect(function()
            local active = Library.ActiveCategory == name
            Ui.Tween(button, {BackgroundTransparency = active and rowActiveTrans or rowBaseTrans}, Theme.Anim.Fast)
            Ui.Tween(textLabel, {TextColor3 = active and UiTextBright or UiTextBright:Lerp(UiTextSoft, 0.18)}, Theme.Anim.Fast)
            Ui.Tween(iconLabel, {TextColor3 = active and UiTextBright or UiTextBright}, Theme.Anim.Fast)
            Ui.Tween(iconFrame, {BackgroundColor3 = active and UiAccentDeep or UiPanelBlack:Lerp(UiTextBright, 0.035)}, Theme.Anim.Fast)
            if buttonStroke then
                Ui.Tween(buttonStroke, {Transparency = active and 0.12 or 0.62, Color = active and Settings.Colors.Accent or UiBorderSoft}, Theme.Anim.Fast)
            end
            if iconStroke then
                Ui.Tween(iconStroke, {Transparency = active and 0.16 or 0.48, Color = active and UiAccentSoft or UiBorderSoft}, Theme.Anim.Fast)
            end
            if buttonGradient then
                Ui.Tween(buttonGradient, {Offset = Vector2.new(0, active and 0.08 or 0.55), Rotation = active and 108 or 72}, Theme.Anim.Normal)
            end
            if buttonStrokeGradient then
                Ui.Tween(buttonStrokeGradient, {Offset = Vector2.new(0, active and 0.1 or 0.48), Rotation = active and 118 or 96}, Theme.Anim.Normal)
            end
            if iconGradient then
                Ui.Tween(iconGradient, {Offset = Vector2.new(0, active and 0.08 or 0.45), Rotation = active and 125 or 88}, Theme.Anim.Normal)
            end
            if iconStrokeGradient then
                Ui.Tween(iconStrokeGradient, {Offset = Vector2.new(0, active and 0.06 or 0.38), Rotation = active and 138 or 110}, Theme.Anim.Normal)
            end
            Ui.Tween(RowDivider, {BackgroundTransparency = 1}, Theme.Anim.Fast)
        end))
        table.insert(State.UnloadConnections, button.MouseButton1Click:Connect(function()
            Ui.PulseScale(buttonScale, 0.93, 0.06, 0.16)
            Library:SetActiveCategory(name)
        end))

        Library.Categories[name] = {
            Button = button, Frame = frame, Accent = activeBar, AccentGradient = activeBarGradient,
            Label = textLabel, Icon = iconLabel, Scale = frame:FindFirstChildOfClass("UIScale"),
            ButtonScale = buttonScale, ButtonGradient = buttonGradient, ButtonStroke = buttonStroke,
            ButtonStrokeGradient = buttonStrokeGradient, IconGradient = iconGradient, IconStrokeGradient = iconStrokeGradient,
            IconFrame = iconFrame, IconStroke = iconStroke, RowDivider = RowDivider
        }
        UpdateCategorySize()
    end

    function Library:SetActiveCategory(name)
        if not name or not Library.Categories[name] then return end
        Library.ActiveCategory = name
        Settings.UIState.ActiveCategory = name
        local neutralCatFrom, neutralCatTo = Ui.GetSoftGradientPair(0.14)
        local neutralIconFrom, neutralIconTo = Ui.GetSoftGradientPair(0.2)
        for catName, entry in pairs(Library.Categories) do
            local isActive = catName == name
            if entry.Frame then
                entry.Frame.Visible = Library.Opened and isActive
                if entry.Frame:IsA("CanvasGroup") then
                    NormalizeCanvasGroup(entry.Frame)
                    entry.Frame.GroupTransparency = 0
                end
            end
            if isActive and entry.Scale then
                entry.Scale.Scale = 0.96
                Ui.Tween(entry.Scale, {Scale = 1}, Theme.Anim.Normal)
            end
            if entry.Button then
                entry.Button.BackgroundColor3 = isActive and UiInputDark:Lerp(UiAccentDeep, 0.34) or UiInputDark:Lerp(UiTextBright, 0.025)
                entry.Button.BackgroundTransparency = 0
            end
            if entry.Label then
                entry.Label.TextColor3 = isActive and UiTextBright or UiTextBright:Lerp(UiTextSoft, 0.18)
            end
            if entry.Icon then
                entry.Icon.TextColor3 = UiTextBright
            end
            if entry.IconFrame then
                entry.IconFrame.BackgroundColor3 = isActive and UiAccentDeep or UiPanelBlack:Lerp(UiTextBright, 0.035)
            end
            if entry.IconStroke then
                entry.IconStroke.Color = isActive and UiAccentSoft or UiBorderSoft
                entry.IconStroke.Transparency = isActive and 0.16 or 0.48
            end
            if entry.Accent then
                entry.Accent.Visible = isActive
                if entry.AccentGradient then
                    entry.AccentGradient.Color = ColorSequence.new(UiAccent, UiAccentSoft)
                    entry.AccentGradient.Rotation = isActive and 100 or 90
                    entry.AccentGradient.Offset = Vector2.new(0, isActive and 0.2 or 0.5)
                end
            end
            if entry.ButtonStroke then
                entry.ButtonStroke.Color = isActive and UiAccentSoft or UiBorderSoft
                entry.ButtonStroke.Transparency = isActive and 0.12 or 0.62
            end
            if entry.ButtonGradient then
                entry.ButtonGradient.Color = isActive
                    and ColorSequence.new({
                        ColorSequenceKeypoint.new(0, UiAccent),
                        ColorSequenceKeypoint.new(0.48, UiAccentMid),
                        ColorSequenceKeypoint.new(1, UiAccentSoft),
                    })
                    or ColorSequence.new(neutralCatFrom, neutralCatTo)
                if isActive then
                    entry.ButtonGradient.Color = ColorSequence.new(UiInputDark:Lerp(UiAccentDeep, 0.34), UiInputDark:Lerp(UiAccentDeep, 0.34):Lerp(UiAccentSoft, 0.16))
                end
                entry.ButtonGradient.Rotation = isActive and 108 or 72
                entry.ButtonGradient.Offset = Vector2.new(0, isActive and 0.08 or 0.55)
            end
            if entry.ButtonStrokeGradient then
                entry.ButtonStrokeGradient.Color = isActive and ColorSequence.new(UiAccentSoft, UiAccent) or ColorSequence.new(UiBorderSoft, UiBorder)
                entry.ButtonStrokeGradient.Rotation = isActive and 118 or 96
                entry.ButtonStrokeGradient.Offset = Vector2.new(0, isActive and 0.1 or 0.48)
            end
            if entry.RowDivider then
                entry.RowDivider.BackgroundTransparency = isActive and 0.0 or 1
            end
            if entry.IconGradient then
                entry.IconGradient.Color = isActive and ColorSequence.new(UiAccentSoft, UiAccent) or ColorSequence.new(neutralIconFrom, neutralIconTo)
                entry.IconGradient.Rotation = isActive and 125 or 88
                entry.IconGradient.Offset = Vector2.new(0, isActive and 0.08 or 0.45)
            end
            if entry.IconStrokeGradient then
                entry.IconStrokeGradient.Color = isActive and ColorSequence.new(UiAccentSoft, UiAccent) or ColorSequence.new(UiBorderSoft, UiBorder)
                entry.IconStrokeGradient.Rotation = isActive and 138 or 110
                entry.IconStrokeGradient.Offset = Vector2.new(0, isActive and 0.06 or 0.38)
            end
        end
    end
        local HotkeysFrame = NewUIContainer()
        HotkeysFrame.Name = "HotkeysList"
        HotkeysFrame.Parent = ScreenGui
        HotkeysFrame.BackgroundColor3 = UiPanelBlack
        HotkeysFrame.BackgroundTransparency = 0.02
        if HotkeysFrame:IsA("CanvasGroup") then
            HotkeysFrame.GroupTransparency = 0
            HotkeysFrame.GroupColor3 = CanvasGroupColor
        end
        HotkeysFrame.Position = UDim2.new(0.02, 0, 0.40, 0)
        HotkeysFrame.Size = UDim2.new(0, 216, 0, 0)
        HotkeysFrame.AutomaticSize = Enum.AutomaticSize.Y
        HotkeysFrame.Visible = false
        HotkeysFrame.ClipsDescendants = true
        HotkeysFrame.ZIndex = 100
        Ui.ApplyCorner(HotkeysFrame, Theme.Corner.Panel)
        if Ui.ApplyShadow then Ui.ApplyShadow(HotkeysFrame) end
        local hkStroke = Ui.ApplyStroke(HotkeysFrame, UiAccent, 0.18, 1)
        if hkStroke then
            hkStroke.Color = UiAccent
            hkStroke.Transparency = 0.18
        end
        local HKPadding = Instance.new("UIPadding", HotkeysFrame)
        HKPadding.PaddingTop = UDim.new(0, 7)
        HKPadding.PaddingBottom = UDim.new(0, 8)
        HKPadding.PaddingLeft = UDim.new(0, 8)
        HKPadding.PaddingRight = UDim.new(0, 8)
        local HotkeysScale = Instance.new("UIScale", HotkeysFrame)
        -- Autoscale similar to watermark based on viewport width
        local function UpdateHotkeyScale()
            local w = State.Camera.ViewportSize.X
            HotkeysScale.Scale = math.clamp(w / 1920, 0.75, 1)
        end
        UpdateHotkeyScale()
        local HKHeader = Instance.new("Frame")
        HKHeader.Parent = HotkeysFrame
        HKHeader.BackgroundColor3 = UiAccentDeep
        HKHeader.BackgroundTransparency = 0
        HKHeader.BorderSizePixel = 0
        HKHeader.Size = UDim2.new(1, 0, 0, 28)
        HKHeader.ZIndex = 101
        HKHeader.LayoutOrder = 0
        Ui.ApplyCorner(HKHeader, Theme.Corner.Small)
        Ui.ApplyGradient(HKHeader, UiAccentDeep, UiAccentSoft, 90)

        local HKTitle = Instance.new("TextLabel")
        HKTitle.Parent = HKHeader
        HKTitle.Text = "Keybinds"
        HKTitle.Font = Enum.Font.GothamBold
        HKTitle.TextSize = 14
        HKTitle.TextColor3 = Settings.Colors.TextWhite
        HKTitle.BackgroundTransparency = 1
        HKTitle.Position = UDim2.new(0, 0, 0, 0)
        HKTitle.Size = UDim2.new(1, 0, 1, 0)
        HKTitle.TextXAlignment = Enum.TextXAlignment.Center
        HKTitle.ZIndex = 101

        local HKIcon = Instance.new("ImageLabel")
        HKIcon.Parent = HKHeader
        HKIcon.Image = "rbxassetid://135835384488824"
        HKIcon.ImageColor3 = Settings.Colors.IconColor
        HKIcon.BackgroundTransparency = 1
        HKIcon.Position = UDim2.new(0, 8, 0, 9)
        HKIcon.Size = UDim2.new(0, 18, 0, 18)
        HKIcon.ZIndex = 101
        HKIcon.Visible = false

        -- divider under header
        if HotkeysFrame:FindFirstChild("HKHeaderDivider") then
            HotkeysFrame.HKHeaderDivider:Destroy()
        end
        local HKHeaderDivider = Instance.new("Frame")
        HKHeaderDivider.Name = "HKHeaderDivider"
        HKHeaderDivider.Parent = HotkeysFrame
        HKHeaderDivider.BackgroundColor3 = UiAccentSoft
        HKHeaderDivider.BackgroundTransparency = 0.72
        HKHeaderDivider.BorderSizePixel = 0
        HKHeaderDivider.Size = UDim2.new(1, 0, 0, 1)
        HKHeaderDivider.ZIndex = 101
        HKHeaderDivider.LayoutOrder = 1

    local HKList = Instance.new("UIListLayout")
    HKList.Parent = HotkeysFrame
    HKList.SortOrder = Enum.SortOrder.LayoutOrder
        HKList.Padding = UDim.new(0, 5)
        HKList.HorizontalAlignment = Enum.HorizontalAlignment.Center

    Ui.MakeDraggable(HKHeader, HotkeysFrame)
    local HotkeysUpdateQueued = false
    local HotkeysLastSignature = nil

    function Library:UpdateHotkeys()
        if HotkeysUpdateQueued then return end
        HotkeysUpdateQueued = true
        task.defer(function()
            HotkeysUpdateQueued = false
            if not Library.GlobalHUDState or not Library.HudSettings.Keybinds then
                HotkeysLastSignature = "hidden"
                HotkeysFrame.Visible = false
                return
            end

            local activeModules = {}
            local signatureParts = {}
            for _, mod in ipairs(Library.Modules) do
                local isActive = mod.Enabled
                if mod.StateGetter then
                    local ok, state = pcall(mod.StateGetter)
                    if ok and state ~= nil then
                        isActive = state
                    end
                end
                if isActive and mod.Keybind ~= nil then
                    table.insert(activeModules, mod)
                    signatureParts[#signatureParts + 1] = tostring(mod.Name) .. ":" .. tostring(mod.Keybind.Name)
                end
            end

            if #activeModules == 0 then
                HotkeysLastSignature = "empty"
                HotkeysFrame.Visible = false
                return
            end

            local signature = table.concat(signatureParts, "|")
            if signature == HotkeysLastSignature and HotkeysFrame.Visible then
                return
            end
            HotkeysLastSignature = signature

            local wasVisible = HotkeysFrame.Visible
            HotkeysFrame.Visible = true; for _, v in pairs(HotkeysFrame:GetChildren()) do if v.Name == "Entry" then v:Destroy() end end;
            local width = 216
            local entryH = 24
            HotkeysFrame.Size = UDim2.new(0, width, 0, 0)
            if not wasVisible then
                if HotkeysFrame:IsA("CanvasGroup") then
                    NormalizeCanvasGroup(HotkeysFrame)
                    HotkeysFrame.GroupTransparency = 0
                end
                if HotkeysScale then
                    HotkeysScale.Scale = 0.96
                    Ui.Tween(HotkeysScale, {Scale = 1}, Theme.Anim.Normal)
                end
            end
            if HotkeysFrame:FindFirstChild("HKHeaderDivider") then
                HotkeysFrame.HKHeaderDivider.LayoutOrder = 1
            end
            for i, mod in ipairs(activeModules) do
                local Entry = Instance.new("Frame"); Entry.Name = "Entry"; Entry.Parent = HotkeysFrame; Entry.BackgroundTransparency = 1; Entry.Size = UDim2.new(1, 0, 0, entryH); Entry.LayoutOrder = i + 1; Entry.ZIndex = 101;
                local EntryBg = Instance.new("Frame"); EntryBg.Parent = Entry; EntryBg.BackgroundColor3 = UiPanelBlack:Lerp(UiAccentDeep, 0.14); EntryBg.BackgroundTransparency = 0.02; EntryBg.Size = UDim2.new(1, 0, 1, 0); EntryBg.Position = UDim2.new(0, 0, 0, 0); EntryBg.ZIndex = 101; Ui.ApplyCorner(EntryBg, Theme.Corner.Small);
                Ui.ApplyStroke(EntryBg, UiAccentMid, 0.48, 1)
                local NameLabel = Instance.new("TextLabel"); NameLabel.Parent = Entry; NameLabel.Text = mod.Name; NameLabel.TextColor3 = Settings.Colors.TextWhite; NameLabel.Font = Enum.Font.GothamSemibold; NameLabel.TextSize = 12; NameLabel.BackgroundTransparency = 1; NameLabel.Position = UDim2.new(0, 12, 0, 0); NameLabel.Size = UDim2.new(1, -74, 1, 0); NameLabel.TextXAlignment = Enum.TextXAlignment.Left; NameLabel.TextTruncate = Enum.TextTruncate.AtEnd; NameLabel.ZIndex = 102;
                local KeyBadge = Instance.new("Frame"); KeyBadge.Parent = Entry; KeyBadge.BackgroundColor3 = UiAccentDeep; KeyBadge.BackgroundTransparency = 0.04; KeyBadge.Size = UDim2.new(0, 50, 0, 18); KeyBadge.Position = UDim2.new(1, -56, 0.5, -9); KeyBadge.ZIndex = 102; Ui.ApplyCorner(KeyBadge, Theme.Corner.Small);
                Ui.ApplyStroke(KeyBadge, UiAccentSoft, 0.34, 1)
                local KeyLabel = Instance.new("TextLabel"); KeyLabel.Parent = KeyBadge; KeyLabel.Text = "[" .. mod.Keybind.Name:sub(1,3) .. "]"; KeyLabel.TextColor3 = UiTextBright; KeyLabel.Font = Enum.Font.GothamBold; KeyLabel.TextSize = 11; KeyLabel.BackgroundTransparency = 1; KeyLabel.Size = UDim2.new(1, 0, 1, 0); KeyLabel.TextXAlignment = Enum.TextXAlignment.Center; KeyLabel.ZIndex = 103
                local Divider = Instance.new("Frame"); Divider.Parent = Entry; Divider.BackgroundColor3 = Settings.Colors.Accent; Divider.BackgroundTransparency = 0.26; Divider.BorderSizePixel = 0; Divider.Size = UDim2.new(0, 3, 1, -8); Divider.Position = UDim2.new(0, 4, 0, 4); Divider.ZIndex = 102; Ui.ApplyCorner(Divider, Theme.Corner.Pill);
            end;
            -- AutomaticSize.Y handles height; only animate width for consistency
            Ui.Tween(HotkeysFrame, {Size = UDim2.new(0, width, 0, HotkeysFrame.Size.Y.Offset)}, Theme.Anim.Normal)
        end)
    end

    -- Global search (top content toolbar, filters all categories)
    local GlobalSearchFrame = NewUIContainer()
    GlobalSearchFrame.Name = "GlobalSearch"
    GlobalSearchFrame.Parent = ScreenGui
    GlobalSearchFrame.BackgroundColor3 = UiPanelBlack
    GlobalSearchFrame.BackgroundTransparency = 1
    if GlobalSearchFrame:IsA("CanvasGroup") then
        GlobalSearchFrame.GroupTransparency = 0
        GlobalSearchFrame.GroupColor3 = CanvasGroupColor
    end
    GlobalSearchFrame.AnchorPoint = Vector2.new(0, 0)
    GlobalSearchFrame.Position = UDim2.new(0, Theme.Layout.MainX or 0, 0, Theme.Layout.MainY or 0)
    GlobalSearchFrame.Size = UDim2.new(0, 420, 0, 34)
    GlobalSearchFrame.Visible = false
    GlobalSearchFrame.ZIndex = 120
    Ui.ApplyCorner(GlobalSearchFrame, Theme.Corner.Panel)
    if Ui.ApplyShadow then Ui.ApplyShadow(GlobalSearchFrame) end
    local GlobalSearchFrameStroke = nil
    local GlobalSearchFrameGradient = nil
    local GlobalSearchFrameStrokeGradient = nil
    local GlobalSearchScale = Instance.new("UIScale", GlobalSearchFrame)
    GlobalSearchScale.Scale = 1

    local GlobalSearchShell, GlobalSearchBox = CreateTextBoxShell(GlobalSearchFrame, {
        Name = "SearchShell",
        TextBoxName = "GlobalSearchBox",
        PlaceholderText = "Search modules",
        Font = Enum.Font.GothamSemibold,
        TextSize = 15,
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        ZIndex = 121,
        PaddingLeft = 14,
        PaddingRight = 12,
        StrokeTransparency = 0.34,
    })
    if Ui.ApplyShadow then Ui.ApplyShadow(GlobalSearchShell) end

    local function UpdateGlobalSearchLayout()
        local mainX = Theme.Layout.MainX or Theme.Layout.Edge or 0
        local mainY = Theme.Layout.MainY or Theme.Layout.Top or 0
        local width = math.max(240, (Theme.Layout.WindowWidth or 520) - 24)
        GlobalSearchFrame.Position = UDim2.new(0, mainX + 12, 0, mainY + 10)
        GlobalSearchFrame.Size = UDim2.new(0, width, 0, 34)
    end
    UpdateGlobalSearchLayout()
    table.insert(State.UnloadConnections, State.Camera:GetPropertyChangedSignal("ViewportSize"):Connect(UpdateGlobalSearchLayout))

    Library.SearchQuery = ""
    function Library:ApplyGlobalSearch(query)
        local q = tostring(query or "")
        self.SearchQuery = q
        local firstMatchCategory = nil
        local hasQuery = q ~= ""
        for _, win in ipairs(self.Windows or {}) do
            if win and win.ApplySearch then
                win:ApplySearch(q)
            end
        end
        for _, mod in ipairs(self.Modules or {}) do
            local match = (q == "") or tostring(mod.Name):lower():find(q:lower(), 1, true) ~= nil
            if mod._button then mod._button.Visible = match end
            if match and not firstMatchCategory then
                firstMatchCategory = mod.Category
            end
        end
        -- Не переключаемся на другую вкладку, если строка поиска пуста (фикс: при повторном открытии оставляем прежнюю категорию)
        if hasQuery and firstMatchCategory then
            self:SetActiveCategory(firstMatchCategory)
        end
    end

    local function ShowGlobalSearch()
        if GlobalSearchFrame.Visible then return end
        UpdateGlobalSearchLayout()
        GlobalSearchFrame.Visible = true
        if GlobalSearchFrame:IsA("CanvasGroup") then
            NormalizeCanvasGroup(GlobalSearchFrame)
            GlobalSearchFrame.GroupTransparency = 0
        end
        GlobalSearchScale.Scale = 0.96
        GlobalSearchFrame.Position = UDim2.new(0, (Theme.Layout.MainX or 0) + 12, 0, (Theme.Layout.MainY or 0) + 4)
        if GlobalSearchFrameGradient then
            GlobalSearchFrameGradient.Offset = Vector2.new(0, 0.8)
            Ui.Tween(GlobalSearchFrameGradient, {Offset = Vector2.new(0, 0.25), Rotation = 100}, Theme.Anim.Slow)
        end
        if GlobalSearchFrameStrokeGradient then
            GlobalSearchFrameStrokeGradient.Offset = Vector2.new(0, 0.72)
            Ui.Tween(GlobalSearchFrameStrokeGradient, {Offset = Vector2.new(0, 0.28), Rotation = 122}, Theme.Anim.Slow)
        end
        Ui.Tween(GlobalSearchFrame, {Position = UDim2.new(0, (Theme.Layout.MainX or 0) + 12, 0, (Theme.Layout.MainY or 0) + 10)}, Theme.Anim.Normal)
        Ui.Tween(GlobalSearchScale, {Scale = 1}, Theme.Anim.Normal)
    end

    local function HideGlobalSearch()
        if not GlobalSearchFrame.Visible then return end
        Ui.Tween(GlobalSearchFrame, {Position = UDim2.new(0, (Theme.Layout.MainX or 0) + 12, 0, (Theme.Layout.MainY or 0) + 4)}, Theme.Anim.Normal)
        Ui.Tween(GlobalSearchScale, {Scale = 0.96}, Theme.Anim.Fast)
        if GlobalSearchFrameGradient then
            Ui.Tween(GlobalSearchFrameGradient, {Offset = Vector2.new(0, 0.52), Rotation = 86}, Theme.Anim.Normal)
        end
        if GlobalSearchFrameStrokeGradient then
            Ui.Tween(GlobalSearchFrameStrokeGradient, {Offset = Vector2.new(0, 0.48), Rotation = 105}, Theme.Anim.Normal)
        end
        task.delay(Theme.Anim.Normal + 0.02, function()
            if not Library.Opened then
                GlobalSearchFrame.Visible = false
            end
        end)
    end

    table.insert(State.UnloadConnections, GlobalSearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        Library:ApplyGlobalSearch(GlobalSearchBox.Text)
    end))

    table.insert(State.UnloadConnections, Services.UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == KEY_ESCAPE and (GlobalSearchBox:IsFocused() or GlobalSearchBox.Text ~= "") then
            GlobalSearchBox.Text = ""
            GlobalSearchBox:ReleaseFocus()
            Library:ApplyGlobalSearch("")
        end
    end))

    -- Footer text
    do
        local Footer = Instance.new("Frame")
        Footer.Name = "FooterText"
        Footer.Parent = ScreenGui
        Footer.BackgroundTransparency = 1
        Footer.AnchorPoint = Vector2.new(0.5, 1)
        Footer.Position = UDim2.new(0.5, 0, 1, -6)
        Footer.Size = UDim2.new(0, 320, 0, 28)
        Footer.ZIndex = 40
        Footer.Visible = false

        local FooterLayout = Instance.new("UIListLayout", Footer)
        FooterLayout.SortOrder = Enum.SortOrder.LayoutOrder
        FooterLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        FooterLayout.Padding = UDim.new(0, 2)

        local FooterLine1 = Instance.new("TextLabel", Footer)
        FooterLine1.Text = "winware | t.me/wwdevlog"
        FooterLine1.Font = Enum.Font.Gotham
        FooterLine1.TextSize = 12
        FooterLine1.TextColor3 = UiTextMuted
        FooterLine1.TextTransparency = 0.35
        FooterLine1.BackgroundTransparency = 1
        FooterLine1.Size = UDim2.new(1, 0, 0, 12)
        FooterLine1.TextXAlignment = Enum.TextXAlignment.Center

        local FooterLine2 = Instance.new("TextLabel", Footer)
        FooterLine2.Text = "sorrelhub.xyz"
        FooterLine2.Font = Enum.Font.Gotham
        FooterLine2.TextSize = 12
        FooterLine2.TextColor3 = UiTextMuted
        FooterLine2.TextTransparency = 0.4
        FooterLine2.BackgroundTransparency = 1
        FooterLine2.Size = UDim2.new(1, 0, 0, 12)
        FooterLine2.TextXAlignment = Enum.TextXAlignment.Center
    end

    function Library:SyncFromSettings()
        local function syncWarn(action, mod, err)
            warn("[WinWare UI] Sync failed (" .. tostring(action) .. ") for " .. tostring(mod and mod.Name or "Library") .. ": " .. tostring(err))
        end

        local openKey = Settings.OpenKey
        if openKey and typeof(openKey) ~= "EnumItem" then
            openKey = KEY_RIGHT_ALT
            Settings.OpenKey = openKey
        end
        if Settings.UIState and Settings.UIState.ActiveCategory then
            self.ActiveCategory = Settings.UIState.ActiveCategory
        end
        if self.MenuBind and self.MenuBind.SetKey then
            local ok, err = pcall(function()
                self.MenuBind:SetKey(openKey)
            end)
            if not ok then
                syncWarn("menu bind", nil, err)
            end
        end
        for _, mod in ipairs(self.Modules or {}) do
            if mod.StateGetter and mod.SetEnabled then
                local okState, state = pcall(mod.StateGetter)
                if okState and state ~= nil then
                    local okSet, setErr = pcall(function()
                        mod:SetEnabled(state, true, true, true)
                    end)
                    if not okSet then
                        syncWarn("module state", mod, setErr)
                    end
                elseif not okState then
                    syncWarn("state getter", mod, state)
                end
            end
            if mod.RefreshBind then
                local ok, err = pcall(function()
                    mod:RefreshBind()
                end)
                if not ok then
                    syncWarn("bind", mod, err)
                end
            end
            if mod.SyncControls then
                local ok, err = pcall(function()
                    mod:SyncControls()
                end)
                if not ok then
                    syncWarn("controls", mod, err)
                end
            end
        end
        local okBlur, blurErr = pcall(function()
            self:ApplyMenuBlurVisuals(true)
        end)
        if not okBlur then
            syncWarn("menu blur", nil, blurErr)
        end
        local okHotkeys, hotkeysErr = pcall(function()
            self:UpdateHotkeys()
        end)
        if not okHotkeys then
            syncWarn("hotkeys", nil, hotkeysErr)
        end
    end

    function Library:RefreshModuleStates()
        for _, mod in ipairs(self.Modules or {}) do
            if mod.StateGetter and mod.SetEnabled then
                local ok, state = pcall(mod.StateGetter)
                if ok and state ~= nil then
                    local okSet, setErr = pcall(function()
                        mod:SetEnabled(state, true, true, true)
                    end)
                    if not okSet then
                        warn("[WinWare UI] Refresh failed for " .. tostring(mod.Name) .. ": " .. tostring(setErr))
                    end
                elseif not ok then
                    warn("[WinWare UI] StateGetter failed for " .. tostring(mod.Name) .. ": " .. tostring(state))
                end
            end
            if mod._label then
                -- Enforce bright text after configs/theme edits
                mod._label.TextColor3 = UiTextBright
                mod._label.TextTransparency = 0
            end
        end
    end
    local NotifContainers = {}; local function setupNotifContainers() local positions = { TopRight = { Pos = UDim2.new(1, -10, 0, 10), Anchor = Vector2.new(1, 0) }, TopLeft = { Pos = UDim2.new(0, 10, 0, 10), Anchor = Vector2.new(0, 0) }, BottomRight = { Pos = UDim2.new(1, -10, 1, -10), Anchor = Vector2.new(1, 1) }, BottomLeft = { Pos = UDim2.new(0, 10, 1, -10), Anchor = Vector2.new(0, 1) } }; for name, data in pairs(positions) do local container = Instance.new("Frame"); container.Name = name .. "NotifContainer"; container.BackgroundTransparency = 1; container.Size = UDim2.new(0, 280, 0, 300); container.Position = data.Pos; container.AnchorPoint = data.Anchor; container.Parent = ScreenGui; container.ZIndex = 200; local layout = Instance.new("UIListLayout"); layout.Parent = container; layout.SortOrder = Enum.SortOrder.LayoutOrder; layout.Padding = UDim.new(0, 8); if name:find("Top") then layout.VerticalAlignment = Enum.VerticalAlignment.Top else layout.VerticalAlignment = Enum.VerticalAlignment.Bottom end; if name:find("Right") then layout.HorizontalAlignment = Enum.HorizontalAlignment.Right else layout.HorizontalAlignment = Enum.HorizontalAlignment.Left end; NotifContainers[name:gsub(" ", "")] = container end end; setupNotifContainers()
    local function CreateMarqueeAnimation(textLabel, containerWidth) local textSize = Services.TextService:GetTextSize(textLabel.Text, textLabel.TextSize, textLabel.Font, Vector2.new(math.huge, math.huge)); if textSize.X <= containerWidth then return end; local clipFrame = Instance.new("Frame", textLabel.Parent); clipFrame.BackgroundTransparency = 1; clipFrame.Size = textLabel.Size; clipFrame.Position = textLabel.Position; clipFrame.ClipsDescendants = true; textLabel.Parent = clipFrame; textLabel.Position = UDim2.new(0, 0, 0, 0); textLabel.Size = UDim2.new(0, textSize.X, 1, 0); task.spawn(function() while clipFrame and clipFrame.Parent do task.wait(2); if not (clipFrame and clipFrame.Parent) then break end; local duration = (textSize.X - containerWidth) / 40; local tween = Services.TweenService:Create(textLabel, TweenInfo.new(duration, Enum.EasingStyle.Linear), {Position = UDim2.new(0, containerWidth - textSize.X, 0, 0)}); tween:Play(); tween.Completed:Wait(); task.wait(2); if not (clipFrame and clipFrame.Parent) then break end; textLabel.Position = UDim2.new(0, 0, 0, 0) end end) end
    function Library:Notify(title, text, notifType, customDuration)
        if not Settings.Notifications.Enabled then return end

        local duration = customDuration or Settings.Notifications.Duration
        local notifFrame = Instance.new("Frame")
        notifFrame.Size = UDim2.new(1, 0, 0, 65)
        notifFrame.BackgroundColor3 = UiPanelDark
        notifFrame.BackgroundTransparency = 0.04
        notifFrame.ClipsDescendants = true
        notifFrame.ZIndex = 201

        local corner = Instance.new("UICorner", notifFrame)
        corner.CornerRadius = UDim.new(0, 8)

        local stroke = Instance.new("UIStroke", notifFrame)
        stroke.Color = UiBorder
        stroke.Transparency = 0.52
        stroke.Thickness = 1

        local accent = Instance.new("Frame", notifFrame)
        accent.Size = UDim2.new(0, 5, 1, 0)
        accent.BackgroundColor3 = Settings.Colors.Accent
        accent.BorderSizePixel = 0

        local titleLabel = Instance.new("TextLabel", notifFrame)
        titleLabel.Size = UDim2.new(1, -20, 0, 22)
        titleLabel.Position = UDim2.new(0, 15, 0, 8)
        titleLabel.Font = Enum.Font.GothamBold
        titleLabel.Text = title
        titleLabel.TextColor3 = Settings.Colors.TextWhite
        titleLabel.TextSize = 17
        titleLabel.BackgroundTransparency = 1
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left

        local textLabel = Instance.new("TextLabel", notifFrame)
        textLabel.Size = UDim2.new(1, -20, 0, 20)
        textLabel.Position = UDim2.new(0, 15, 0, 32)
        textLabel.Font = Enum.Font.Gotham
        textLabel.Text = text
        textLabel.TextColor3 = UiTextSoft
        textLabel.TextSize = 15
        textLabel.BackgroundTransparency = 1
        textLabel.TextXAlignment = Enum.TextXAlignment.Left

        local availableWidth = 280 - 25
        CreateMarqueeAnimation(titleLabel, availableWidth)
        CreateMarqueeAnimation(textLabel, availableWidth)

        if notifType == "Warn" then
            accent.BackgroundColor3 = Settings.Colors.AccentSoft
        elseif notifType == "Error" then
            accent.BackgroundColor3 = Color3.fromRGB(255, 91, 91)
        elseif notifType == "Green" then
            accent.BackgroundColor3 = Color3.fromRGB(80, 200, 120)
        end

        local posName = Settings.Notifications.Position:gsub(" ", "")
        local container = NotifContainers[posName]
        notifFrame.Parent = container

        local slideDirection = (posName:find("Right") and 1) or -1
        local endPos = UDim2.new(0, 0, notifFrame.Position.Y.Scale, notifFrame.Position.Y.Offset)
        local startPos = UDim2.new(0, 300 * slideDirection, endPos.Y.Scale, endPos.Y.Offset)
        notifFrame.Position = startPos

        local tweenInfoIn = TweenInfo.new(Theme.Anim.Slow, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        local tweenIn = Services.TweenService:Create(notifFrame, tweenInfoIn, {Position = endPos})
        tweenIn:Play()

        task.delay(duration, function()
            if not notifFrame.Parent then return end
            local tweenInfoOut = TweenInfo.new(Theme.Anim.Slow, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
            local tweenOut = Services.TweenService:Create(notifFrame, tweenInfoOut, {Position = startPos})
            tweenOut:Play()
            tweenOut.Completed:Wait()
            notifFrame:Destroy()
        end)
    end

    function Library:ApplyMenuBlurVisuals(instant)
        local opened = self.Opened == true
        local blurEnabled = self.Settings and self.Settings.Blur == true
        local blurSize = (opened and blurEnabled and Settings.BlurStrength) or 0
        local dimEnabled = opened and blurEnabled and Settings.BlurDarkness ~= false
        local dimTransparency = dimEnabled and 0.46 or 1

        if instant then
            BlurEffect.Size = blurSize
        else
            Ui.Tween(BlurEffect, {Size = blurSize}, blurSize > 0 and 0.5 or 0.3)
        end

        if MenuDimOverlay then
            if dimEnabled then
                MenuDimOverlay.Visible = true
            end

            if instant then
                MenuDimOverlay.BackgroundTransparency = dimTransparency
                MenuDimOverlay.Visible = dimEnabled
            else
                local tween = Ui.Tween(MenuDimOverlay, {BackgroundTransparency = dimTransparency}, dimEnabled and 0.28 or 0.22)
                if not dimEnabled and tween then
                    tween.Completed:Once(function()
                        if MenuDimOverlay and MenuDimOverlay.BackgroundTransparency >= 0.99 then
                            MenuDimOverlay.Visible = false
                        end
                    end)
                end
            end
        end
    end

    table.insert(State.UnloadConnections, Services.UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if Services.UserInputService:GetFocusedTextBox() then return end
        if Services.GuiService.MenuIsOpen then return end
        local keyToUse = Settings.OpenKey or KEY_RIGHT_ALT
        if input.KeyCode == keyToUse then Library:ToggleUI() end
    end))
    function Library:ToggleUI()
        self.Opened = not self.Opened
        UpdateWatermarkVisibility()
        if self.Opened then
            local openDur = 0.3
            -- Лёгкое делаем сразу (показать панели)
            ApplyUILayout()
            CategoryBar.Visible = true
            RightPanel.Visible = true
            GlobalSearchBox.Text = ""
            ShowGlobalSearch()

            local targetName = self.ActiveCategory
            if not targetName then
                local preferred = Settings.UIState.ActiveCategory
                if preferred and Library.Categories[preferred] then
                    targetName = preferred
                else
                    local bestName
                    local bestOrder = math.huge
                    for name, _ in pairs(Library.Categories) do
                        local order = (CategoryOrder and CategoryOrder[name]) or 999
                        if order < bestOrder then
                            bestOrder = order
                            bestName = name
                        end
                    end
                    targetName = bestName
                end
            end
            if targetName then
                self:SetActiveCategory(targetName)
            end

            -- Тяжёлое делаем асинхронно
            task.spawn(function()
                NormalizeUiVisualState()
            end)

            -- Анимации градиентов тоже асинхронно
            task.spawn(function()
                if CategoryScale then
                    CategoryScale.Scale = 0.96
                    Ui.Tween(CategoryScale, {Scale = 1}, openDur)
                end
                if RightScale then
                    RightScale.Scale = 0.96
                    Ui.Tween(RightScale, {Scale = 1}, openDur)
                end
                if CategoryGradient then
                    CategoryGradient.Offset = Vector2.new(0, 0.82)
                    Ui.Tween(CategoryGradient, {Offset = Vector2.new(0, 0.35), Rotation = 108}, openDur + 0.06)
                end
                if CategoryStrokeGradient then
                    CategoryStrokeGradient.Offset = Vector2.new(0, 0.74)
                    Ui.Tween(CategoryStrokeGradient, {Offset = Vector2.new(0, 0.32), Rotation = 126}, openDur + 0.06)
                end
                if RightPanelGradient then
                    RightPanelGradient.Offset = Vector2.new(0, 0.82)
                    Ui.Tween(RightPanelGradient, {Offset = Vector2.new(0, 0.3), Rotation = 96}, openDur + 0.06)
                end
                if RightStrokeGradient then
                    RightStrokeGradient.Offset = Vector2.new(0, 0.74)
                    Ui.Tween(RightStrokeGradient, {Offset = Vector2.new(0, 0.27), Rotation = 114}, openDur + 0.06)
                end
                for _, win in ipairs(Library.Windows or {}) do
                    if win and win.Frame and win.Frame.Visible and win._scale then
                        win._scale.Scale = 0.96
                        Ui.Tween(win._scale, {Scale = 1}, openDur)
                        if win._gradient then
                            win._gradient.Offset = Vector2.new(0, 0.78)
                            Ui.Tween(win._gradient, {Offset = Vector2.new(0, 0.34), Rotation = 94}, openDur + 0.05)
                        end
                        if win._strokeGradient then
                            win._strokeGradient.Offset = Vector2.new(0, 0.7)
                            Ui.Tween(win._strokeGradient, {Offset = Vector2.new(0, 0.3), Rotation = 112}, openDur + 0.05)
                        end
                    end
                end
            end)
        else
            -- закрытие без изменений
            GlobalSearchBox.Text = ""
            Library:ApplyGlobalSearch("")
            HideGlobalSearch()
            if CategoryGradient then
                Ui.Tween(CategoryGradient, {Offset = Vector2.new(0, 0.55), Rotation = 98}, Theme.Anim.Normal)
            end
            if CategoryStrokeGradient then
                Ui.Tween(CategoryStrokeGradient, {Offset = Vector2.new(0, 0.45), Rotation = 112}, Theme.Anim.Normal)
            end
            if RightPanelGradient then
                Ui.Tween(RightPanelGradient, {Offset = Vector2.new(0, 0.5), Rotation = 82}, Theme.Anim.Normal)
            end
            if RightStrokeGradient then
                Ui.Tween(RightStrokeGradient, {Offset = Vector2.new(0, 0.45), Rotation = 104}, Theme.Anim.Normal)
            end
            CategoryBar.Visible = false
            RightPanel.Visible = false
            for _, win in pairs(ScreenGui:GetChildren()) do
                if win.Name:match("Window") then win.Visible = false end
            end
        end
        self:ApplyMenuBlurVisuals(false)
    end
    function Library:ShowTooltip(anchor, text) if not text or text == "" then return end; TooltipLabel.Text = text; local textSize = Services.TextService:GetTextSize(text, TooltipLabel.TextSize, TooltipLabel.Font, Vector2.new(TooltipFrame.AbsoluteSize.X - 16, 999)); TooltipFrame.Size = UDim2.new(0, 160, 0, textSize.Y + 12); TooltipFrame.Position = UDim2.new(0, State.Mouse.X + 15, 0, State.Mouse.Y); TooltipFrame.Visible = true; Ui.Tween(TooltipFrame, {BackgroundTransparency = 0.1}, 0.2); Ui.Tween(TooltipLabel, {TextTransparency = 0}, 0.2) end
    function Library:HideTooltip() if TooltipFrame.Visible then local tween = Ui.Tween(TooltipFrame, {BackgroundTransparency = 1}, 0.2); Ui.Tween(TooltipLabel, {TextTransparency = 1}, 0.2); tween.Completed:Once(function() if TooltipFrame.BackgroundTransparency == 1 then TooltipFrame.Visible = false end end) end end
    table.insert(State.UnloadConnections, Services.UserInputService.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement and TooltipFrame.Visible then TooltipFrame.Position = UDim2.new(0, input.Position.X + 15, 0, input.Position.Y) end end))

    function Library:Confirm(options)
        options = options or {}
        if self._confirmOverlay and self._confirmOverlay.Parent then
            self._confirmOverlay:Destroy()
        end

        local overlay = Instance.new("TextButton")
        overlay.Name = "ConfirmOverlay"
        overlay.Parent = ScreenGui
        overlay.BackgroundColor3 = Color3.new(0, 0, 0)
        overlay.BackgroundTransparency = 1
        overlay.BorderSizePixel = 0
        overlay.Size = UDim2.fromScale(1, 1)
        overlay.Text = ""
        overlay.AutoButtonColor = false
        overlay.ZIndex = 500
        self._confirmOverlay = overlay

        local dialog = Instance.new("Frame")
        dialog.Name = "ConfirmDialog"
        dialog.Parent = overlay
        dialog.AnchorPoint = Vector2.new(0.5, 0.5)
        dialog.Position = UDim2.fromScale(0.5, 0.5)
        dialog.Size = UDim2.fromOffset(330, 148)
        dialog.BackgroundColor3 = UiPanelBlack
        dialog.BackgroundTransparency = 0
        dialog.BorderSizePixel = 0
        dialog.Active = true
        dialog.ZIndex = 501
        Ui.ApplyCorner(dialog, Theme.Corner.Panel)
        if Ui.ApplyShadow then Ui.ApplyShadow(dialog) end
        local stroke = Ui.ApplyStroke(dialog, UiAccentSoft, 0.22, 1)
        if stroke then
            Ui.ApplyGradient(stroke, UiAccentSoft, UiAccent, 108)
        end
        Ui.ApplyGradient(dialog, UiPanelBlack, UiPanelDark, 88)

        local title = Instance.new("TextLabel")
        title.Parent = dialog
        title.BackgroundTransparency = 1
        title.Position = UDim2.fromOffset(16, 12)
        title.Size = UDim2.new(1, -32, 0, 22)
        title.Font = Enum.Font.GothamBold
        title.TextSize = 14
        title.TextColor3 = UiTextBright
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.Text = options.Title or "Confirm"
        title.ZIndex = 502

        local message = Instance.new("TextLabel")
        message.Parent = dialog
        message.BackgroundTransparency = 1
        message.Position = UDim2.fromOffset(16, 42)
        message.Size = UDim2.new(1, -32, 0, 46)
        message.Font = Enum.Font.Gotham
        message.TextSize = 13
        message.TextColor3 = UiTextSoft
        message.TextXAlignment = Enum.TextXAlignment.Left
        message.TextYAlignment = Enum.TextYAlignment.Top
        message.TextWrapped = true
        message.Text = options.Message or "Are you sure?"
        message.ZIndex = 502

        local function close()
            if overlay and overlay.Parent then
                overlay:Destroy()
            end
            if self._confirmOverlay == overlay then
                self._confirmOverlay = nil
            end
        end

        local function addDialogButton(text, x, primary, callback)
            local button = Instance.new("TextButton")
            button.Parent = dialog
            button.Position = UDim2.new(1, x, 1, -42)
            button.Size = UDim2.fromOffset(86, 30)
            button.BackgroundColor3 = primary and UiAccentDeep or UiButtonBg
            button.BackgroundTransparency = 0
            button.Text = text
            button.TextColor3 = primary and UiTextBright or UiTextSoft
            button.Font = Enum.Font.GothamSemibold
            button.TextSize = 13
            button.AutoButtonColor = false
            button.ZIndex = 502
            Ui.ApplyCorner(button, Theme.Corner.Small)
            local btnStroke = Ui.ApplyStroke(button, primary and UiAccentSoft or UiButtonBorder, primary and 0.28 or 0.44, 1)

            table.insert(State.UnloadConnections, button.MouseEnter:Connect(function()
                Ui.Tween(button, {BackgroundColor3 = primary and UiAccent or UiButtonHover}, Theme.Anim.Fast)
                if btnStroke then Ui.Tween(btnStroke, {Transparency = 0.18, Color = UiAccentSoft}, Theme.Anim.Fast) end
            end))
            table.insert(State.UnloadConnections, button.MouseLeave:Connect(function()
                Ui.Tween(button, {BackgroundColor3 = primary and UiAccentDeep or UiButtonBg}, Theme.Anim.Fast)
                if btnStroke then Ui.Tween(btnStroke, {Transparency = primary and 0.28 or 0.44, Color = primary and UiAccentSoft or UiButtonBorder}, Theme.Anim.Fast) end
            end))
            table.insert(State.UnloadConnections, button.MouseButton1Click:Connect(function()
                close()
                if callback then callback() end
            end))
        end

        addDialogButton(options.CancelText or "Cancel", -188, false, options.OnCancel)
        addDialogButton(options.ConfirmText or "Yes", -96, true, options.OnConfirm)
        table.insert(State.UnloadConnections, overlay.MouseButton1Click:Connect(function()
            close()
            if options.OnCancel then options.OnCancel() end
        end))

        dialog.Size = UDim2.fromOffset(320, 140)
        Ui.Tween(overlay, {BackgroundTransparency = 0.42}, Theme.Anim.Fast)
        Ui.Tween(dialog, {Size = UDim2.fromOffset(330, 148)}, Theme.Anim.Normal)
        return overlay
    end

    function Library:CreateWindow(name)
        local Window = {}
        -- Main content panel aligned to the center layout
        local baseX = Theme.Layout.MainX or (Theme.Layout.Edge + Theme.Layout.CategoryWidth + Theme.Layout.Gap)
        local baseY = Theme.Layout.MainY or Theme.Layout.Top
        local MainFrame = NewUIContainer(); MainFrame.Name = name .. "Window"; MainFrame.Parent = ScreenGui; MainFrame.Position = UDim2.new(0, baseX, 0, baseY); MainFrame.Size = UDim2.new(0, Settings.Layout.WindowWidth, 0, 40); MainFrame.BackgroundColor3 = UiPanelBlack; MainFrame.Visible = false; MainFrame.ClipsDescendants = true; MainFrame.ZIndex = 5;
        if MainFrame:IsA("CanvasGroup") then
            MainFrame.GroupTransparency = 0
            MainFrame.GroupColor3 = CanvasGroupColor
        end
        local Corner = Instance.new("UICorner"); Corner.CornerRadius = UDim.new(0, Theme.Corner.Window); Corner.Parent = MainFrame
        if Ui.ApplyShadow then Ui.ApplyShadow(MainFrame) end
        local Stroke = Instance.new("UIStroke"); Stroke.Color = UiBorder; Stroke.Transparency = 0.5; Stroke.Thickness = 1; Stroke.Parent = MainFrame
        local winFrom, winTo = UiPanelBlack, UiPanelDark
        local MainGradient = Ui.ApplyGradient(MainFrame, winFrom, winTo, 78)
        local StrokeGradient = Ui.ApplyGradient(Stroke, UiBorderSoft, UiBorder, 98)
        if MainGradient then
            MainGradient.Offset = Vector2.new(0, 0.55)
        end
        local headerH = 54
        local Header = Instance.new("Frame"); Header.Parent = MainFrame; Header.BackgroundTransparency = 1; Header.Size = UDim2.new(1, 0, 0, headerH); Header.ZIndex = 6
        local HeaderDivider = Instance.new("Frame", Header)
        HeaderDivider.BackgroundColor3 = UiBorderSoft
        HeaderDivider.BackgroundTransparency = 0.62
        HeaderDivider.BorderSizePixel = 0
        HeaderDivider.Position = UDim2.new(0, 12, 1, -1)
        HeaderDivider.Size = UDim2.new(1, -24, 0, 1)
        HeaderDivider.ZIndex = 7
        local Title = Instance.new("TextLabel"); Title.Parent = Header; Title.Text = ""; Title.Font = Enum.Font.GothamBold; Title.TextSize = 13; Title.TextColor3 = Settings.Colors.TextWhite; Title.BackgroundTransparency = 1; Title.Position = UDim2.new(0, 14, 0, 0); Title.Size = UDim2.new(1, -24, 1, 0); Title.TextXAlignment = Enum.TextXAlignment.Left; Title.ZIndex = 7
        local MainScale = Instance.new("UIScale", MainFrame); MainScale.Scale = 1
        Window.Name = name
        Window.Frame = MainFrame
        Window._scale = MainScale
        Window._gradient = MainGradient
        Window._strokeGradient = StrokeGradient
        Library:RegisterCategory(name, MainFrame)
        local Container = Instance.new("ScrollingFrame"); Container.Parent = MainFrame; Container.BackgroundTransparency = 1; Container.Position = UDim2.new(0, 0, 0, headerH); Container.Size = UDim2.new(1, 0, 0, 0); Container.ClipsDescendants = true; Container.ZIndex = 6; Container.BorderSizePixel = 0; Container.CanvasSize = UDim2.new(0, 0, 0, 0); Container.ScrollBarThickness = 0; Container.ScrollBarImageColor3 = UiAccentSoft; Container.ScrollBarImageTransparency = 0.25; Container.ScrollingDirection = Enum.ScrollingDirection.Y
        Window.Container = Container
        table.insert(Library.Windows, Window)
        local ContentRoot = Instance.new("Frame", Container)
        ContentRoot.BackgroundTransparency = 1
        ContentRoot.Position = UDim2.new(0, 12, 0, 10)
        ContentRoot.Size = UDim2.new(1, -24, 0, 0)
        ContentRoot.ZIndex = 6

        local ContentLayout = Instance.new("UIListLayout"); ContentLayout.Parent = ContentRoot; ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder; ContentLayout.Padding = UDim.new(0, 10)

        local ModuleGrid = Instance.new("Frame", ContentRoot)
        ModuleGrid.BackgroundTransparency = 1
        ModuleGrid.Size = UDim2.new(1, 0, 0, 0)
        ModuleGrid.LayoutOrder = 1
        ModuleGrid.ZIndex = 6

        local ModuleColumns = Instance.new("UIListLayout", ModuleGrid)
        ModuleColumns.FillDirection = Enum.FillDirection.Horizontal
        ModuleColumns.HorizontalAlignment = Enum.HorizontalAlignment.Left
        ModuleColumns.SortOrder = Enum.SortOrder.LayoutOrder
        ModuleColumns.Padding = UDim.new(0, 10)

        local LeftColumn = Instance.new("Frame", ModuleGrid)
        LeftColumn.BackgroundTransparency = 1
        LeftColumn.Size = UDim2.new(0.5, -5, 0, 0)
        LeftColumn.AutomaticSize = Enum.AutomaticSize.Y
        LeftColumn.LayoutOrder = 1
        LeftColumn.ZIndex = 6
        local LeftLayout = Instance.new("UIListLayout", LeftColumn)
        LeftLayout.SortOrder = Enum.SortOrder.LayoutOrder
        LeftLayout.Padding = UDim.new(0, 8)
        LeftLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

        local RightColumn = Instance.new("Frame", ModuleGrid)
        RightColumn.BackgroundTransparency = 1
        RightColumn.Size = UDim2.new(0.5, -5, 0, 0)
        RightColumn.AutomaticSize = Enum.AutomaticSize.Y
        RightColumn.LayoutOrder = 2
        RightColumn.ZIndex = 6
        local RightLayout = Instance.new("UIListLayout", RightColumn)
        RightLayout.SortOrder = Enum.SortOrder.LayoutOrder
        RightLayout.Padding = UDim.new(0, 8)
        RightLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

        local UtilityStack = Instance.new("Frame", ContentRoot)
        UtilityStack.BackgroundTransparency = 1
        UtilityStack.Size = UDim2.new(1, 0, 0, 0)
        UtilityStack.AutomaticSize = Enum.AutomaticSize.Y
        UtilityStack.LayoutOrder = 2
        UtilityStack.ZIndex = 6
        local UtilityLayout = Instance.new("UIListLayout", UtilityStack)
        UtilityLayout.SortOrder = Enum.SortOrder.LayoutOrder
        UtilityLayout.Padding = UDim.new(0, 8)

        Window._leftColumn = LeftColumn
        Window._rightColumn = RightColumn
        Window._leftLayout = LeftLayout
        Window._rightLayout = RightLayout
        Window._utilityStack = UtilityStack
        Window._moduleCount = 0

        local function UpdateSize()
            local maxHeight = Theme.Layout.WindowMaxHeight or 420
            local viewHeight = math.max(140, maxHeight - headerH)
            local contentWidth = math.max(260, (Theme.Layout.WindowWidth or Settings.Layout.WindowWidth) - 24)
            ContentRoot.Size = UDim2.new(0, contentWidth, 0, ContentRoot.Size.Y.Offset)
            ModuleGrid.Size = UDim2.new(1, 0, 0, math.max(LeftLayout.AbsoluteContentSize.Y, RightLayout.AbsoluteContentSize.Y))
            UtilityStack.Visible = UtilityLayout.AbsoluteContentSize.Y > 0
            local height = ContentLayout.AbsoluteContentSize.Y + 20
            ContentRoot.Size = UDim2.new(0, contentWidth, 0, height)
            Container.CanvasSize = UDim2.new(0, 0, 0, height)
            Container.ScrollBarThickness = height > viewHeight and 3 or 0
            Container.Size = UDim2.new(1, 0, 0, viewHeight)
            MainFrame.Size = UDim2.new(0, Theme.Layout.WindowWidth, 0, maxHeight)
        end
        ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateSize)
        LeftLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateSize)
        RightLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateSize)
        UtilityLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateSize)
        Window.UpdateLayout = UpdateSize
        UpdateSize()

        Window._moduleEntries = {}
        function Window:ApplySearch(query)
            local q = (query or ""):lower()
            for _, mod in ipairs(Window._moduleEntries or {}) do
                local match = (q == "" or tostring(mod.Name):lower():find(q, 1, true) ~= nil)
                if mod._button then mod._button.Visible = match end
                if mod._settingsFrame then
                    if not match then
                        mod.SettingsOpen = false
                        mod._settingsFrame.Visible = false
                    end
                end
            end
            UpdateSize()
        end
        table.insert(State.UnloadConnections, Container:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
            Settings.UIState.WindowScroll[name] = {x = Container.CanvasPosition.X, y = Container.CanvasPosition.Y}
        end))
        if Settings.UIState.WindowScroll[name] then
            local stored = Settings.UIState.WindowScroll[name]
            if type(stored) == "table" and stored.x and stored.y then
                Container.CanvasPosition = Vector2.new(stored.x, stored.y)
            end
        end
        function Window:AddBind(text, default, call)
            UtilityStack.Visible = true
            local Button = Instance.new("TextButton")
            Button.Parent = UtilityStack
            Button.BackgroundTransparency = 1
            Button.Size = UDim2.new(1, 0, 0, 38)
            Button.Text = ""
            Button.AutoButtonColor = false
            Button.ZIndex = 7

            local Bg = Instance.new("Frame")
            Bg.Parent = Button
            Bg.BackgroundColor3 = UiPanelBlack:Lerp(UiAccentDeep, 0.14)
            Bg.BackgroundTransparency = 0
            Bg.Size = UDim2.new(1, 0, 1, 0)
            Bg.Position = UDim2.new(0, 0, 0, 0)
            Bg.ZIndex = 7
            Ui.ApplyCorner(Bg, Theme.Corner.Small)
            local bgStroke = Ui.ApplyStroke(Bg, UiAccentMid, 0.42, 1)
            local bgGradient = Ui.ApplyGradient(Bg, UiPanelBlack:Lerp(UiAccentDeep, 0.12), UiButtonBg:Lerp(UiAccentSoft, 0.08), 90)
            local bgStrokeGradient = bgStroke and Ui.ApplyGradient(bgStroke, UiAccentMid, UiAccentSoft, 108)
            local bgScale = Ui.EnsureScale(Bg, 1)
            if bgGradient then
                bgGradient.Offset = Vector2.new(0, 0.55)
            end

            local BindStrip = Instance.new("Frame")
            BindStrip.Parent = Bg
            BindStrip.BackgroundColor3 = UiAccentSoft
            BindStrip.BackgroundTransparency = 0.5
            BindStrip.BorderSizePixel = 0
            BindStrip.Position = UDim2.new(0, 8, 0, 8)
            BindStrip.Size = UDim2.new(0, 3, 1, -16)
            BindStrip.ZIndex = 8
            Ui.ApplyCorner(BindStrip, Theme.Corner.Pill)

            local Label = Instance.new("TextLabel")
            Label.Parent = Button
            Label.Text = text
            Label.TextColor3 = UiTextBright
            Label.Font = Enum.Font.GothamSemibold
            Label.TextSize = 14
            Label.BackgroundTransparency = 1
            Label.Position = UDim2.new(0, 20, 0, 0)
            Label.Size = UDim2.new(1, -92, 1, 0)
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.ZIndex = 8
            MarkReadableButton(Label, UiTextBright)

            local KeyBadge = Instance.new("Frame")
            KeyBadge.Parent = Button
            KeyBadge.BackgroundColor3 = UiAccentDeep:Lerp(UiPanelBlack, 0.18)
            KeyBadge.BackgroundTransparency = 0.04
            KeyBadge.BorderSizePixel = 0
            KeyBadge.Position = UDim2.new(1, -80, 0.5, -10)
            KeyBadge.Size = UDim2.new(0, 70, 0, 20)
            KeyBadge.ZIndex = 8
            Ui.ApplyCorner(KeyBadge, Theme.Corner.Small)
            local keyBadgeStroke = Ui.ApplyStroke(KeyBadge, UiAccentSoft, 0.42, 1)

            local KeyLabel = Instance.new("TextLabel")
            KeyLabel.Parent = KeyBadge
            KeyLabel.Text = default and ("["..default.Name.."]") or "[None]"
            KeyLabel.TextColor3 = Settings.Colors.TextWhite
            KeyLabel.Font = Enum.Font.GothamSemibold
            KeyLabel.TextSize = 12
            KeyLabel.BackgroundTransparency = 1
            KeyLabel.Position = UDim2.new(0, 0, 0, 0)
            KeyLabel.Size = UDim2.new(1, 0, 1, 0)
            KeyLabel.TextXAlignment = Enum.TextXAlignment.Center
            KeyLabel.TextTruncate = Enum.TextTruncate.AtEnd
            KeyLabel.ZIndex = 9
            MarkReadableButton(KeyLabel, UiTextBright)

            local currentKey = default
            local Bind = {}
            function Bind:SetKey(key)
                currentKey = key
                KeyLabel.Text = key and ("["..key.Name.."]") or "[None]"
            end
            Bind:SetKey(default)

            local isBinding = false

            table.insert(State.UnloadConnections, Button.MouseEnter:Connect(function()
                if isBinding then return end
                Ui.Tween(Bg, {BackgroundTransparency = 0.0, BackgroundColor3 = UiPanelBlack:Lerp(UiAccentDeep, 0.2)}, Theme.Anim.Fast)
                Ui.Tween(Label, {TextColor3 = UiTextBright}, Theme.Anim.Fast)
                if bgStroke then Ui.Tween(bgStroke, {Transparency = 0.22, Color = UiAccentMid}, Theme.Anim.Fast) end
                if keyBadgeStroke then Ui.Tween(keyBadgeStroke, {Transparency = 0.22, Color = UiAccentSoft}, Theme.Anim.Fast) end
                Ui.Tween(BindStrip, {BackgroundTransparency = 0.22}, Theme.Anim.Fast)
                if bgGradient then Ui.Tween(bgGradient, {Offset = Vector2.new(0, 0.2), Rotation = 100}, Theme.Anim.Normal) end
                if bgStrokeGradient then Ui.Tween(bgStrokeGradient, {Offset = Vector2.new(0, 0.22), Rotation = 116}, Theme.Anim.Normal) end
            end))
            table.insert(State.UnloadConnections, Button.MouseLeave:Connect(function()
                if isBinding then return end
                Ui.Tween(Bg, {BackgroundTransparency = 0.0, BackgroundColor3 = UiPanelBlack:Lerp(UiAccentDeep, 0.14)}, Theme.Anim.Fast)
                Ui.Tween(Label, {TextColor3 = UiTextBright}, Theme.Anim.Fast)
                if bgStroke then Ui.Tween(bgStroke, {Transparency = 0.42, Color = UiAccentMid}, Theme.Anim.Fast) end
                if keyBadgeStroke then Ui.Tween(keyBadgeStroke, {Transparency = 0.42, Color = UiAccentSoft}, Theme.Anim.Fast) end
                Ui.Tween(BindStrip, {BackgroundTransparency = 0.5}, Theme.Anim.Fast)
                if bgGradient then Ui.Tween(bgGradient, {Offset = Vector2.new(0, 0.55), Rotation = 74}, Theme.Anim.Normal) end
                if bgStrokeGradient then Ui.Tween(bgStrokeGradient, {Offset = Vector2.new(0, 0.5), Rotation = 98}, Theme.Anim.Normal) end
            end))

            table.insert(State.UnloadConnections, Button.MouseButton1Click:Connect(function()
                if isBinding then return end
                isBinding = true
                Ui.PulseScale(bgScale, 0.94, 0.06, 0.16)
                local previousKey = currentKey
                KeyLabel.Text = "Press..."
                KeyLabel.TextColor3 = Settings.Colors.Accent
                Ui.Tween(Bg, {BackgroundTransparency = 0.0, BackgroundColor3 = UiPanelBlack:Lerp(UiAccentDeep, 0.24)}, Theme.Anim.Fast)
                Ui.Tween(KeyBadge, {BackgroundColor3 = UiAccentDeep}, Theme.Anim.Fast)
                if bgStroke then Ui.Tween(bgStroke, {Transparency = 0.45, Color = Settings.Colors.Accent}, Theme.Anim.Fast) end
                if keyBadgeStroke then Ui.Tween(keyBadgeStroke, {Transparency = 0.18, Color = UiAccentSoft}, Theme.Anim.Fast) end
                if bgGradient then Ui.Tween(bgGradient, {Offset = Vector2.new(0, 0.08), Rotation = 118}, Theme.Anim.Normal) end

                local conn
                conn = Services.UserInputService.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        local key = input.KeyCode
                        if key == KEY_ESCAPE then
                            Bind:SetKey(previousKey)
                        elseif key == KEY_DELETE then
                            if call then call(nil) end
                            Bind:SetKey(nil)
                        else
                            if call then call(key) end
                            Bind:SetKey(key)
                        end
                        KeyLabel.TextColor3 = Settings.Colors.TextWhite
                        isBinding = false
                        Ui.Tween(Bg, {BackgroundTransparency = 0.0, BackgroundColor3 = UiPanelBlack:Lerp(UiAccentDeep, 0.14)}, Theme.Anim.Fast)
                        Ui.Tween(KeyBadge, {BackgroundColor3 = UiAccentDeep:Lerp(UiPanelBlack, 0.18)}, Theme.Anim.Fast)
                        if bgStroke then
                            bgStroke.Color = UiAccentMid
                            Ui.Tween(bgStroke, {Transparency = 0.42}, Theme.Anim.Fast)
                        end
                        if keyBadgeStroke then
                            keyBadgeStroke.Color = UiAccentSoft
                            Ui.Tween(keyBadgeStroke, {Transparency = 0.42}, Theme.Anim.Fast)
                        end
                        if bgGradient then Ui.Tween(bgGradient, {Offset = Vector2.new(0, 0.55), Rotation = 74}, Theme.Anim.Normal) end
                        conn:Disconnect()
                    end
                end)
            end))
            UpdateSize()
            return Bind
        end

        function Window:AddButton(text, callback)
            UtilityStack.Visible = true
            local Button = Instance.new("TextButton")
            Button.Parent = UtilityStack
            Button.BackgroundTransparency = 1
            Button.Size = UDim2.new(1, 0, 0, 40)
            Button.Text = ""
            Button.AutoButtonColor = false
            Button.ZIndex = 7

            local Bg = Instance.new("Frame")
            Bg.Parent = Button
            Bg.BackgroundColor3 = UiPanelBlack:Lerp(UiAccentDeep, 0.12)
            Bg.BackgroundTransparency = 0
            Bg.Size = UDim2.new(1, 0, 1, 0)
            Bg.Position = UDim2.new(0, 0, 0, 0)
            local c = Instance.new("UICorner", Bg); c.CornerRadius = UDim.new(0, Theme.Corner.Small)
            local bgStroke = Ui.ApplyStroke(Bg, UiAccentMid, 0.48, 1)
            local bgGradient = Ui.ApplyGradient(Bg, UiPanelBlack:Lerp(UiAccentDeep, 0.1), UiButtonBg:Lerp(UiAccentSoft, 0.07), 88)
            local bgStrokeGradient = bgStroke and Ui.ApplyGradient(bgStroke, UiAccentMid, UiAccentSoft, 108)
            local buttonScale = Ui.EnsureScale(Bg, 1)
            if bgGradient then
                bgGradient.Offset = Vector2.new(0, 0.55)
            end

            local ActionStrip = Instance.new("Frame")
            ActionStrip.Parent = Bg
            ActionStrip.BackgroundColor3 = UiAccentSoft
            ActionStrip.BackgroundTransparency = 0.62
            ActionStrip.BorderSizePixel = 0
            ActionStrip.Position = UDim2.new(0, 8, 0, 9)
            ActionStrip.Size = UDim2.new(0, 3, 1, -18)
            ActionStrip.ZIndex = 8
            Ui.ApplyCorner(ActionStrip, Theme.Corner.Pill)

            local Label = Instance.new("TextLabel")
            Label.Parent = Button
            Label.Text = text
            Label.TextColor3 = UiTextBright
            Label.Font = Enum.Font.GothamSemibold
            Label.TextSize = 14
            Label.BackgroundTransparency = 1
            Label.Position = UDim2.new(0, 20, 0, 0)
            Label.Size = UDim2.new(1, -52, 1, 0)
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.ZIndex = 8
            MarkReadableButton(Label, UiTextBright)

            local Arrow = Instance.new("TextLabel")
            Arrow.Parent = Button
            Arrow.Text = ">"
            Arrow.TextColor3 = UiAccentSoft
            Arrow.Font = Enum.Font.GothamBold
            Arrow.TextSize = 16
            Arrow.BackgroundTransparency = 1
            Arrow.Position = UDim2.new(1, -28, 0, 0)
            Arrow.Size = UDim2.new(0, 18, 1, 0)
            Arrow.TextXAlignment = Enum.TextXAlignment.Center
            Arrow.ZIndex = 8

            table.insert(State.UnloadConnections, Button.MouseButton1Click:Connect(function()
                Ui.PulseScale(buttonScale, 0.93, 0.06, 0.16)
                if callback then callback() end
            end))

            table.insert(State.UnloadConnections, Button.MouseEnter:Connect(function()
                Ui.Tween(Label, {TextColor3=UiTextBright}, Theme.Anim.Fast)
                Ui.Tween(Bg, {BackgroundTransparency = 0.0, BackgroundColor3 = UiPanelBlack:Lerp(UiAccentDeep, 0.2)}, Theme.Anim.Fast)
                Ui.Tween(ActionStrip, {BackgroundTransparency = 0.22}, Theme.Anim.Fast)
                Ui.Tween(Arrow, {TextColor3 = UiTextBright, Position = UDim2.new(1, -24, 0, 0)}, Theme.Anim.Fast)
                if bgStroke then Ui.Tween(bgStroke, {Transparency = 0.22, Color = UiAccentMid}, Theme.Anim.Fast) end
                if bgGradient then Ui.Tween(bgGradient, {Offset = Vector2.new(0, 0.2), Rotation = 98}, Theme.Anim.Normal) end
                if bgStrokeGradient then Ui.Tween(bgStrokeGradient, {Offset = Vector2.new(0, 0.2), Rotation = 114}, Theme.Anim.Normal) end
            end))
            table.insert(State.UnloadConnections, Button.MouseLeave:Connect(function()
                Ui.Tween(Label, {TextColor3=UiTextBright}, Theme.Anim.Fast)
                Ui.Tween(Bg, {BackgroundTransparency = 0.0, BackgroundColor3 = UiPanelBlack:Lerp(UiAccentDeep, 0.12)}, Theme.Anim.Fast)
                Ui.Tween(ActionStrip, {BackgroundTransparency = 0.62}, Theme.Anim.Fast)
                Ui.Tween(Arrow, {TextColor3 = UiAccentSoft, Position = UDim2.new(1, -28, 0, 0)}, Theme.Anim.Fast)
                if bgStroke then Ui.Tween(bgStroke, {Transparency = 0.48, Color = UiAccentMid}, Theme.Anim.Fast) end
                if bgGradient then Ui.Tween(bgGradient, {Offset = Vector2.new(0, 0.55), Rotation = 72}, Theme.Anim.Normal) end
                if bgStrokeGradient then Ui.Tween(bgStrokeGradient, {Offset = Vector2.new(0, 0.5), Rotation = 94}, Theme.Anim.Normal) end
            end))

            UpdateSize()
        end

        function Window:AddTextbox(name, placeholder)
            UtilityStack.Visible = true
            local Frame = Instance.new("Frame")
            Frame.Name = name
            Frame.Parent = UtilityStack
            Frame.BackgroundTransparency = 1
            Frame.Size = UDim2.new(1, 0, 0, 46)
            Frame.ZIndex = 7

            local Shell, TextBox = CreateTextBoxShell(Frame, {
                PlaceholderText = placeholder or "",
                Size = UDim2.new(1, 0, 1, -10),
                Position = UDim2.new(0, 0, 0, 5),
                ZIndex = 8,
                TextSize = 15,
                PaddingLeft = 18,
                PaddingRight = 12,
                StrokeTransparency = 0.32,
                BackgroundColor3 = UiPanelBlack:Lerp(UiInputDark, 0.55),
                HoverColor3 = UiPanelBlack:Lerp(UiInputDark, 0.68),
                FocusColor3 = UiPanelBlack:Lerp(UiAccentDeep, 0.16),
                StrokeColor = UiFieldBorder:Lerp(UiAccentSoft, 0.24),
                HoverStrokeColor = UiAccentMid,
                FocusStrokeColor = UiAccentSoft,
                HoverStrokeTransparency = 0.22,
                GradientFrom = UiPanelBlack:Lerp(UiInputDark, 0.48),
                GradientTo = UiInputDark:Lerp(UiAccentDeep, 0.08),
            })
            local InputStrip = Instance.new("Frame")
            InputStrip.Parent = Shell
            InputStrip.BackgroundColor3 = UiAccentSoft
            InputStrip.BackgroundTransparency = 0.66
            InputStrip.BorderSizePixel = 0
            InputStrip.Position = UDim2.new(0, 8, 0, 8)
            InputStrip.Size = UDim2.new(0, 2, 1, -16)
            InputStrip.ZIndex = 9
            Ui.ApplyCorner(InputStrip, Theme.Corner.Pill)

            UpdateSize()
            return TextBox
        end
        function Window:AddModule(modName, tooltip, callback, defaultState)
            local Module = {
                Name = modName,
                Category = Window.Name,
                Enabled = defaultState or false,
                Keybind = nil,
                HasSettings = false,
                SettingsOpen = false,
                StateGetter = nil,
                _label = nil,
                _bindLabel = nil,
                Controls = {},
                ControlsList = {}
            }
            table.insert(Library.Modules, Module)
            Window._moduleCount = (Window._moduleCount or 0) + 1
            local ModuleParent = (Window._moduleCount % 2 == 1) and LeftColumn or RightColumn
            local function GetModuleCardBg(active, hovered)
                if active then
                    return UiPanelBlack:Lerp(UiAccentDeep, hovered and 0.28 or 0.22)
                end
                return UiPanelBlack:Lerp(UiInputDark, hovered and 0.48 or 0.34)
            end
            local function GetModuleCardTo(active, hovered)
                if active then
                    return UiPanelBlack:Lerp(UiAccentSoft, hovered and 0.18 or 0.12)
                end
                return UiInputDark:Lerp(UiAccentDeep, hovered and 0.12 or 0.04)
            end
            local function GetModuleStrokeColor(active, hovered)
                if active then
                    return hovered and UiAccentSoft or UiAccentMid
                end
                return hovered and UiAccentMid or UiModuleInactiveBorder
            end
            local function GetModuleStrokeTrans(active, hovered)
                if active then
                    return hovered and 0.1 or 0.16
                end
                return hovered and 0.2 or 0.28
            end
            local function GetModuleDescColor(active)
                return active and UiTextBright:Lerp(UiAccentSoft, 0.1) or UiTextSoft:Lerp(UiTextBright, 0.2)
            end

            local Button = Instance.new("TextButton")
            Button.Parent = ModuleParent
            Button.BackgroundTransparency = 1
            Button.Size = UDim2.new(1, 0, 0, 74)
            Button.Text = ""
            Button.AutoButtonColor = false
            Button.LayoutOrder = Window._moduleCount * 2
            Button.ZIndex = 7

            -- Module card background
            local rowBaseTrans = 0
            local rowHoverTrans = 0.0
            local RowBg = Instance.new("Frame")
            RowBg.Parent = Button
            RowBg.BackgroundColor3 = GetModuleCardBg(Module.Enabled, false)
            RowBg.BackgroundTransparency = rowBaseTrans
            RowBg.Size = UDim2.new(1, 0, 1, 0)
            RowBg.Position = UDim2.new(0, 0, 0, 0)
            RowBg.ZIndex = 7
            Ui.ApplyCorner(RowBg, Theme.Corner.Big)
            local rowStroke = Ui.ApplyStroke(RowBg, GetModuleStrokeColor(Module.Enabled, false), GetModuleStrokeTrans(Module.Enabled, false), 1)
            local rowGradient = Ui.ApplyGradient(
                RowBg,
                GetModuleCardBg(Module.Enabled, false),
                GetModuleCardTo(Module.Enabled, false),
                Module.Enabled and 104 or 86
            )
            local rowStrokeGradient = rowStroke and Ui.ApplyGradient(
                rowStroke,
                GetModuleStrokeColor(Module.Enabled, false),
                Module.Enabled and UiAccentSoft or UiBorderSoft,
                112
            )
            local rowScale = Ui.EnsureScale(RowBg, 1)
            if rowGradient then
                rowGradient.Offset = Vector2.new(0, 0.56)
            end
            Module._rowBg = RowBg
            Module._rowStroke = rowStroke
            Module._rowGradient = rowGradient
            Module._rowStrokeGradient = rowStrokeGradient
            Module._rowScale = rowScale
            local RowDivider = Instance.new("Frame", RowBg)
            RowDivider.BackgroundColor3 = UiAccentSoft
            RowDivider.BackgroundTransparency = Module.Enabled and 0.08 or 1
            RowDivider.BorderSizePixel = 0
            RowDivider.Size = UDim2.new(0, 3, 1, -18)
            RowDivider.Position = UDim2.new(0, 8, 0, 9)
            RowDivider.ZIndex = 8
            Ui.ApplyCorner(RowDivider, Theme.Corner.Pill)

            local rightReserve = 58
            local labelLeft = 16

            local ClipFrame = Instance.new("Frame", Button)
            ClipFrame.BackgroundTransparency = 1
            ClipFrame.Position = UDim2.new(0, labelLeft, 0, 8)
            ClipFrame.Size = UDim2.new(1, -(labelLeft + rightReserve), 0, 24)
            ClipFrame.ClipsDescendants = true
            ClipFrame.ZIndex = 8

            local Label = Instance.new("TextLabel")
            Label.Parent = ClipFrame
            Label.Text = modName
            Label.TextColor3 = UiTextBright
            Label.TextTransparency = 0
            Label.TextStrokeTransparency = 1
            Label.Font = Enum.Font.GothamSemibold
            Label.TextSize = 15
            Label.BackgroundTransparency = 1
            Label.Position = UDim2.new(0, 0, 0, 0)
            Label.Size = UDim2.new(1, 0, 1, 0)
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.ZIndex = 8
            Module._label = Label

            local DescLabel = Instance.new("TextLabel")
            DescLabel.Parent = RowBg
            DescLabel.BackgroundTransparency = 1
            DescLabel.Position = UDim2.new(0, labelLeft, 0, 32)
            DescLabel.Size = UDim2.new(1, -(labelLeft + rightReserve), 0, 30)
            DescLabel.Text = tostring(tooltip or "")
            DescLabel.TextColor3 = GetModuleDescColor(Module.Enabled)
            DescLabel.TextTransparency = Module.Enabled and 0.02 or 0.0
            DescLabel.Font = Enum.Font.Gotham
            DescLabel.TextSize = 11
            DescLabel.TextWrapped = true
            DescLabel.TextXAlignment = Enum.TextXAlignment.Left
            DescLabel.TextYAlignment = Enum.TextYAlignment.Top
            DescLabel.ZIndex = 8
            Module._descLabel = DescLabel

            local textSize = Services.TextService:GetTextSize(modName, Label.TextSize, Label.Font, Vector2.new(math.huge, math.huge))
            local availableWidth = ClipFrame.AbsoluteSize.X
            if availableWidth == 0 then availableWidth = Settings.Layout.WindowWidth - 140 end

            if textSize.X > availableWidth then
                Label.Size = UDim2.new(0, textSize.X, 1, 0)
                local currentTween

                table.insert(State.UnloadConnections, Button.MouseEnter:Connect(function()
                    if currentTween then currentTween:Cancel() end
                    local duration = (textSize.X - availableWidth) / 40
                    currentTween = Services.TweenService:Create(Label, TweenInfo.new(duration, Enum.EasingStyle.Linear), {Position = UDim2.new(0, availableWidth - textSize.X, 0, 0)})
                    currentTween:Play()
                end))

                table.insert(State.UnloadConnections, Button.MouseLeave:Connect(function()
                    if currentTween then currentTween:Cancel() end
                    currentTween = Services.TweenService:Create(Label, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Position = UDim2.new(0, 0, 0, 0)})
                    currentTween:Play()
                end))
            end

            local Dots = Instance.new("TextLabel")
            Dots.Parent = Button
            Dots.Text = "*"
            Dots.TextColor3 = Module.Enabled and UiTextBright or UiAccentSoft
            Dots.BackgroundTransparency = 1
            Dots.Position = UDim2.new(1, -24, 0, 8)
            Dots.Size = UDim2.new(0, 18, 0, 18)
            Dots.Visible = false
            Dots.Font = Enum.Font.GothamBold
            Dots.ZIndex = 8

            local BindLabel = Instance.new("TextLabel")
            BindLabel.Parent = Button
            BindLabel.Text = ""
            BindLabel.TextColor3 = UiTextMuted
            BindLabel.BackgroundTransparency = 1
            BindLabel.Position = UDim2.new(1, -54, 0, 38)
            BindLabel.Size = UDim2.new(0, 44, 0, 18)
            BindLabel.Font = Enum.Font.Gotham
            BindLabel.TextSize = 11
            BindLabel.TextXAlignment = Enum.TextXAlignment.Right
            BindLabel.ZIndex = 8
            Module._bindLabel = BindLabel
            Module._button = Button

            local toggleOffColor = UiToggleOffBg
            local toggleStrokeColor = UiToggleOffBorder
            local toggleStrokeTrans = 0.18
            local ToggleIndicator = Instance.new("Frame")
            ToggleIndicator.Parent = Button
            ToggleIndicator.Size = UDim2.new(0, 44, 0, 22)
            ToggleIndicator.Position = UDim2.new(1, -54, 0, 11)
            ToggleIndicator.BackgroundColor3 = Module.Enabled and Settings.Colors.Accent or toggleOffColor
            ToggleIndicator.BackgroundTransparency = 0
            ToggleIndicator.BorderSizePixel = 0
            ToggleIndicator.ZIndex = 8
            Ui.ApplyCorner(ToggleIndicator, Theme.Corner.Pill)
            local toggleStroke = Ui.ApplyStroke(ToggleIndicator, toggleStrokeColor, toggleStrokeTrans, 1)
            local toggleOffGradFrom = toggleOffColor
            local toggleOffGradTo = toggleOffColor:Lerp(UiTextBright, 0.07)
            local toggleGradient = Ui.ApplyGradient(
                ToggleIndicator,
                Module.Enabled and Settings.Colors.Accent or toggleOffGradFrom,
                Module.Enabled and Settings.Colors.AccentSoft or toggleOffGradTo,
                90
            )
            local toggleStrokeGradient = toggleStroke and Ui.ApplyGradient(
                toggleStroke,
                Module.Enabled and Settings.Colors.AccentSoft or toggleOffGradTo,
                Module.Enabled and Settings.Colors.Accent or toggleOffGradFrom,
                104
            )
            if toggleGradient then
                toggleGradient.Offset = Vector2.new(0, 0.5)
            end

            local ToggleDot = Instance.new("Frame", ToggleIndicator)
            ToggleDot.Size = UDim2.new(0, 18, 0, 18)
            ToggleDot.Position = Module.Enabled and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
            ToggleDot.BackgroundColor3 = Module.Enabled and UiTextBright or UiToggleOffThumb
            ToggleDot.BorderSizePixel = 0
            ToggleDot.Visible = true
            Ui.ApplyCorner(ToggleDot, Theme.Corner.Pill)
            Module._toggle = ToggleIndicator
            Module._toggleDot = ToggleDot
            Module._toggleStroke = toggleStroke
            Module._toggleGradient = toggleGradient
            Module._toggleStrokeGradient = toggleStrokeGradient

            function Module:RegisterControl(control)
                if not control then return end
                table.insert(Module.ControlsList, control)
                if control.Key then
                    Module.Controls[control.Key] = control
                end
            end

            function Module:SetKeybind(key, silent)
                local resolved = key
                if typeof(resolved) ~= "EnumItem" then
                    if type(resolved) == "string" then
                        resolved = resolveEnumName(resolved, Enum.KeyCode)
                    elseif type(resolved) == "table" and type(resolved.name) == "string" then
                        resolved = resolveEnumName(resolved.name, Enum.KeyCode)
                    end
                end
                Module.Keybind = resolved
                RegisterModuleKeybind(Module, resolved)
                if Module.RefreshBind then
                    Module:RefreshBind()
                end
                if not silent then
                    Library:UpdateHotkeys()
                end
            end

            function Module:SerializeControls()
                local data = {}
                for _, control in ipairs(Module.ControlsList) do
                    if control and control.Key and control.GetValue then
                        data[control.Key] = encodeValue(control:GetValue())
                    end
                end
                return data
            end

            function Module:ApplyControlStates(states)
                if type(states) ~= "table" then return end
                for key, rawValue in pairs(states) do
                    local control = Module.Controls[key]
                    if control and control.SetValue then
                        local decoded = decodeValue(rawValue)
                        if decoded ~= nil then
                            control:SetValue(decoded, false)
                        end
                    end
                end
            end

            function Module:SyncControls()
                for _, control in ipairs(Module.ControlsList) do
                    if control and control.SetValue then
                        local getter = control.Getter or control.GetValue
                        if getter then
                            local ok, value = pcall(getter)
                            if ok and value ~= nil then
                                control:SetValue(value, false)
                            end
                        end
                    end
                end
            end

            function Module:RefreshBind()
                if Module._bindLabel then
                    if Module.Keybind then
                        Module._bindLabel.Text = "[" .. Module.Keybind.Name:sub(1, 3) .. "]"
                    else
                        Module._bindLabel.Text = ""
                    end
                end
            end

            function Module:SetEnabled(state, silent, skipHotkeys, force)
                local nextState = not not state
                if Module.Enabled == nextState and not force then
                    return
                end
                Module.Enabled = nextState
                if Module._label then
                    Module._label.TextColor3 = UiTextBright
                    Module._label.TextTransparency = 0
                end
                if Module._descLabel then
                    Ui.Tween(Module._descLabel, {
                        TextColor3 = GetModuleDescColor(nextState),
                        TextTransparency = nextState and 0.02 or 0.0
                    }, Theme.Anim.Fast)
                end
                if Dots then
                    Ui.Tween(Dots, {TextColor3 = nextState and UiTextBright or UiAccentSoft}, Theme.Anim.Fast)
                end
                if Module._toggle then
                    Ui.Tween(Module._toggle, {BackgroundColor3 = nextState and Settings.Colors.Accent or toggleOffColor}, Theme.Anim.Fast)
                end
                if Module._toggleStroke then
                    Ui.Tween(Module._toggleStroke, {
                        Transparency = nextState and 0.24 or toggleStrokeTrans,
                        Color = nextState and Settings.Colors.AccentSoft or toggleStrokeColor
                    }, Theme.Anim.Fast)
                end
                if Module._toggleGradient then
                    Module._toggleGradient.Color = ColorSequence.new(
                        nextState and Settings.Colors.Accent or toggleOffGradFrom,
                        nextState and Settings.Colors.AccentSoft or toggleOffGradTo
                    )
                    Ui.Tween(Module._toggleGradient, {
                        Offset = Vector2.new(0, nextState and 0.1 or 0.5),
                        Rotation = nextState and 122 or 84
                    }, Theme.Anim.Normal)
                end
                if Module._toggleStrokeGradient then
                    Module._toggleStrokeGradient.Color = ColorSequence.new(
                        nextState and Settings.Colors.AccentSoft or toggleOffGradTo,
                        nextState and Settings.Colors.Accent or toggleOffGradFrom
                    )
                    Ui.Tween(Module._toggleStrokeGradient, {
                        Offset = Vector2.new(0, nextState and 0.12 or 0.45),
                        Rotation = nextState and 136 or 104
                    }, Theme.Anim.Normal)
                end
                if Module._toggleDot then
                    Ui.Tween(Module._toggleDot, {
                        Size = UDim2.new(0, 18, 0, 18),
                        Position = nextState and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9),
                        BackgroundColor3 = nextState and UiTextBright or UiToggleOffThumb
                    }, Theme.Anim.Fast)
                end
                if Module._rowBg then
                    Ui.Tween(Module._rowBg, {BackgroundColor3 = GetModuleCardBg(nextState, false), BackgroundTransparency = rowBaseTrans}, Theme.Anim.Fast)
                end
                if Module._rowStroke then
                    Ui.Tween(Module._rowStroke, {Transparency = GetModuleStrokeTrans(nextState, false), Color = GetModuleStrokeColor(nextState, false)}, Theme.Anim.Fast)
                end
                if Module._rowGradient then
                    Module._rowGradient.Color = nextState
                        and ColorSequence.new({
                            ColorSequenceKeypoint.new(0, GetModuleCardBg(true, false)),
                            ColorSequenceKeypoint.new(0.52, GetModuleCardBg(true, false):Lerp(UiAccentMid, 0.08)),
                            ColorSequenceKeypoint.new(1, GetModuleCardTo(true, false)),
                        })
                        or ColorSequence.new(GetModuleCardBg(false, false), GetModuleCardTo(false, false))
                    Ui.Tween(Module._rowGradient, {
                        Offset = Vector2.new(0, nextState and 0.08 or 0.56),
                        Rotation = nextState and 116 or 74
                    }, Theme.Anim.Normal)
                end
                if Module._rowStrokeGradient then
                    Module._rowStrokeGradient.Color = nextState and ColorSequence.new(UiAccentSoft, UiAccent) or ColorSequence.new(UiModuleInactiveBorder, UiBorderSoft)
                    Ui.Tween(Module._rowStrokeGradient, {
                        Offset = Vector2.new(0, nextState and 0.1 or 0.5),
                        Rotation = nextState and 128 or 96
                    }, Theme.Anim.Normal)
                end
                if RowDivider then
                    Ui.Tween(RowDivider, {BackgroundTransparency = nextState and 0.08 or 1}, Theme.Anim.Fast)
                end
                if Module._rowScale and not silent then
                    Ui.PulseScale(Module._rowScale, 0.95, 0.05, 0.16)
                end
                local callbackFailed = false
                if callback then
                    local okCallback, callbackErr = pcall(callback, nextState)
                    if not okCallback then
                        callbackFailed = true
                        warn(("WinWare module callback failed for %s: %s"):format(tostring(modName), tostring(callbackErr)))
                        if not silent then
                            Library:Notify(modName, "Module callback failed", "Warn")
                        end
                    end
                end
                if not callbackFailed and not silent and Settings.Notifications.Enabled and Settings.Notifications.NotifyOnToggle then
                    Library:Notify(modName, (nextState and "Enabled" or "Disabled") .. "!", "Normal")
                end
                if not skipHotkeys then
                    Library:UpdateHotkeys()
                end
            end

            -- Collapsible settings panel for module controls
            local SettingsFrame = Instance.new("ScrollingFrame")
            SettingsFrame.Parent = ModuleParent
            SettingsFrame.BackgroundColor3 = UiPanelBlack:Lerp(UiAccentDeep, 0.08)
            SettingsFrame.BackgroundTransparency = 0
            SettingsFrame.Size = UDim2.new(1, -12, 0, 0)
            SettingsFrame.LayoutOrder = (Window._moduleCount * 2) + 1
            SettingsFrame.Visible = false
            SettingsFrame.ClipsDescendants = true
            SettingsFrame.ZIndex = 7
            SettingsFrame.BorderSizePixel = 0
            SettingsFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
            SettingsFrame.ScrollBarThickness = 3
            SettingsFrame.ScrollBarImageColor3 = Settings.Colors.Accent
            SettingsFrame.ScrollBarImageTransparency = 0.2
            SettingsFrame.ScrollingDirection = Enum.ScrollingDirection.Y
            Ui.ApplyCorner(SettingsFrame, Theme.Corner.Big)
            local settingsStroke = Ui.ApplyStroke(SettingsFrame, UiAccentMid, 0.42, 1)
            local settingsGradient = Ui.ApplyGradient(SettingsFrame, UiPanelBlack:Lerp(UiAccentDeep, 0.06), UiInputDark:Lerp(UiAccentDeep, 0.08), 86)
            local settingsStrokeGradient = settingsStroke and Ui.ApplyGradient(settingsStroke, UiAccentMid, UiBorderSoft, 108)
            Module._settingsFrame = SettingsFrame
            table.insert(Window._moduleEntries, Module)

            local SettingsList = Instance.new("UIListLayout")
            SettingsList.Parent = SettingsFrame
            SettingsList.Padding = UDim.new(0, 4)

            local SettingsAccent = Instance.new("Frame")
            SettingsAccent.Parent = SettingsFrame
            SettingsAccent.BackgroundColor3 = UiAccentSoft
            SettingsAccent.BackgroundTransparency = 0.34
            SettingsAccent.BorderSizePixel = 0
            SettingsAccent.Size = UDim2.new(1, -12, 0, 2)
            SettingsAccent.LayoutOrder = -10
            SettingsAccent.ZIndex = 8
            Ui.ApplyCorner(SettingsAccent, Theme.Corner.Pill)

            local SettingsPad = Instance.new("UIPadding")
            SettingsPad.Parent = SettingsFrame
            SettingsPad.PaddingTop = UDim.new(0, 8)
            SettingsPad.PaddingBottom = UDim.new(0, 8)
            SettingsPad.PaddingLeft = UDim.new(0, 6)
            SettingsPad.PaddingRight = UDim.new(0, 6)

            if Module.Enabled and callback then
                task.spawn(function() callback(true) end)
            end

            table.insert(State.UnloadConnections, Button.MouseEnter:Connect(function()
                Ui.Tween(RowBg, {BackgroundColor3 = GetModuleCardBg(Module.Enabled, true), BackgroundTransparency = rowHoverTrans}, Theme.Anim.Fast)
                if rowStroke then Ui.Tween(rowStroke, {Transparency = GetModuleStrokeTrans(Module.Enabled, true), Color = GetModuleStrokeColor(Module.Enabled, true)}, Theme.Anim.Fast) end
                if rowGradient then
                    rowGradient.Color = ColorSequence.new(GetModuleCardBg(Module.Enabled, true), GetModuleCardTo(Module.Enabled, true))
                    Ui.Tween(rowGradient, {Offset = Vector2.new(0, 0.2), Rotation = 102}, Theme.Anim.Normal)
                end
                if rowStrokeGradient then
                    rowStrokeGradient.Color = Module.Enabled and ColorSequence.new(UiAccentSoft, UiAccent) or ColorSequence.new(UiModuleInactiveHoverBorder, UiAccentMid)
                    Ui.Tween(rowStrokeGradient, {Offset = Vector2.new(0, 0.2), Rotation = 116}, Theme.Anim.Normal)
                end
                if Module._toggle and not Module.Enabled then
                    Ui.Tween(Module._toggle, {BackgroundColor3 = toggleOffColor:Lerp(UiAccentSoft, 0.08)}, Theme.Anim.Fast)
                end
                if Module._toggleStroke and not Module.Enabled then
                    Ui.Tween(Module._toggleStroke, {Transparency = 0.12, Color = toggleStrokeColor:Lerp(UiAccentMid, 0.35)}, Theme.Anim.Fast)
                end
            end))
            table.insert(State.UnloadConnections, Button.MouseLeave:Connect(function()
                local active = Module.Enabled
                Ui.Tween(RowBg, {BackgroundColor3 = GetModuleCardBg(active, false), BackgroundTransparency = active and 0.0 or rowBaseTrans}, Theme.Anim.Fast)
                if rowStroke then Ui.Tween(rowStroke, {Transparency = GetModuleStrokeTrans(active, false), Color = GetModuleStrokeColor(active, false)}, Theme.Anim.Fast) end
                if rowGradient then
                    rowGradient.Color = ColorSequence.new(GetModuleCardBg(active, false), GetModuleCardTo(active, false))
                    Ui.Tween(rowGradient, {Offset = Vector2.new(0, active and 0.08 or 0.56), Rotation = active and 116 or 74}, Theme.Anim.Normal)
                end
                if rowStrokeGradient then
                    rowStrokeGradient.Color = active and ColorSequence.new(UiAccentSoft, UiAccent) or ColorSequence.new(UiModuleInactiveBorder, UiBorderSoft)
                    Ui.Tween(rowStrokeGradient, {Offset = Vector2.new(0, active and 0.1 or 0.5), Rotation = active and 128 or 96}, Theme.Anim.Normal)
                end
                if Module._toggle then
                    Ui.Tween(Module._toggle, {BackgroundColor3 = active and Settings.Colors.Accent or toggleOffColor}, Theme.Anim.Fast)
                end
                if Module._toggleStroke then
                    Ui.Tween(Module._toggleStroke, {
                        Transparency = active and 0.24 or toggleStrokeTrans,
                        Color = active and Settings.Colors.AccentSoft or toggleStrokeColor
                    }, Theme.Anim.Fast)
                end
            end))

            local function GetSettingsHeights()
                local content = SettingsList.AbsoluteContentSize.Y + 12
                local maxH = math.floor(State.Camera.ViewportSize.Y * 0.6)
                return content, math.min(content, maxH)
            end

            local function SyncSettingsFrame(animated)
                local fullH, viewH = GetSettingsHeights()
                SettingsFrame.CanvasSize = UDim2.new(0, 0, 0, fullH)
                SettingsFrame.ScrollBarThickness = fullH > viewH and 3 or 0
                if Module.SettingsOpen then
                    if animated then
                        Ui.Tween(SettingsFrame, {Size = UDim2.new(1, -12, 0, viewH)}, 0.2)
                    else
                        SettingsFrame.Size = UDim2.new(1, -12, 0, viewH)
                    end
                end
                local maxY = math.max(0, fullH - viewH)
                if SettingsFrame.CanvasPosition.Y > maxY then
                    SettingsFrame.CanvasPosition = Vector2.new(0, maxY)
                end
            end

            local function Toggle()
                Module:SetEnabled(not Module.Enabled, false)
            end
            Module._toggleFromKeybind = Toggle

            local isBinding = false

            table.insert(State.UnloadConnections, Button.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 and not isBinding then
                    if rowScale then
                        Ui.PulseScale(rowScale, 0.94, 0.05, 0.16)
                    end
                    Toggle()
                elseif input.UserInputType == Enum.UserInputType.MouseButton2 and Module.HasSettings then
                    Module.SettingsOpen = not Module.SettingsOpen
                    SettingsFrame.Visible = true
                    SettingsFrame.CanvasPosition = Vector2.new(0, 0)
                    if Module.SettingsOpen then
                        SyncSettingsFrame(true)
                        if settingsStroke then
                            Ui.Tween(settingsStroke, {Transparency = 0.2, Color = Settings.Colors.Accent}, Theme.Anim.Fast)
                        end
                        if settingsGradient then
                            Ui.Tween(settingsGradient, {Offset = Vector2.new(0, 0.2), Rotation = 106}, Theme.Anim.Normal)
                        end
                        if settingsStrokeGradient then
                            Ui.Tween(settingsStrokeGradient, {Offset = Vector2.new(0, 0.2), Rotation = 122}, Theme.Anim.Normal)
                        end
                    else
                        Ui.Tween(SettingsFrame, {Size = UDim2.new(1, -12, 0, 0)}, 0.3)
                        if settingsStroke then
                            settingsStroke.Color = UiAccentMid
                            Ui.Tween(settingsStroke, {Transparency = 0.42}, Theme.Anim.Fast)
                        end
                        if settingsGradient then
                            Ui.Tween(settingsGradient, {Offset = Vector2.new(0, 0.6), Rotation = 82}, Theme.Anim.Normal)
                        end
                        if settingsStrokeGradient then
                            Ui.Tween(settingsStrokeGradient, {Offset = Vector2.new(0, 0.52), Rotation = 104}, Theme.Anim.Normal)
                        end
                    end
                    task.delay(0.3, function() if not Module.SettingsOpen then SettingsFrame.Visible = false end end)
                    task.wait(0.1); UpdateSize(); task.wait(0.25); UpdateSize()
                elseif input.UserInputType == Enum.UserInputType.MouseButton3 then
                    isBinding = true
                    SetModuleKeybindCapture(true)
                    BindLabel.Text = "..."
                    BindLabel.TextColor3 = Settings.Colors.Accent
                    local previousKey = Module.Keybind
                    local conn
                    conn = Services.UserInputService.InputBegan:Connect(function(k)
                        if k.UserInputType == Enum.UserInputType.Keyboard then
                            if k.KeyCode == KEY_ESCAPE then
                                Module:SetKeybind(previousKey, true)
                            elseif k.KeyCode == KEY_DELETE then
                                Module:SetKeybind(nil, true)
                            else
                                Module:SetKeybind(k.KeyCode, true)
                            end
                            Module:RefreshBind()
                            BindLabel.TextColor3 = UiTextMuted
                            isBinding = false
                            SetModuleKeybindCapture(false)
                            conn:Disconnect()
                            Library:UpdateHotkeys()
                        end
                    end)
                end
            end))


            SettingsList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                SyncSettingsFrame(false)
                if Module.SettingsOpen then
                    UpdateSize()
                end
            end)

            function Module:AddLabel(text)
                Module.HasSettings = true
                Dots.Visible = true

                local Frame = Instance.new("Frame")
                Frame.Parent = SettingsFrame
                Frame.BackgroundColor3 = UiFieldBg
                Frame.BackgroundTransparency = 0.06
                Frame.BorderSizePixel = 0
                Frame.Size = UDim2.new(1, 0, 0, 32)
                Frame.ZIndex = 8
                Ui.ApplyCorner(Frame, Theme.Corner.Small)
                Ui.ApplyStroke(Frame, UiButtonBorder, 0.42, 1)

                local Label = Instance.new("TextLabel")
                Label.Parent = Frame
                Label.Text = tostring(text or "")
                Label.TextColor3 = UiTextSoft
                Label.Font = Enum.Font.GothamSemibold
                Label.TextSize = 12
                Label.BackgroundTransparency = 1
                Label.Position = UDim2.new(0, 10, 0, 0)
                Label.Size = UDim2.new(1, -20, 1, 0)
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.TextTruncate = Enum.TextTruncate.AtEnd
                Label.ZIndex = 9

                local LabelControl = {Frame = Frame, Label = Label}
                function LabelControl:SetText(value)
                    Label.Text = tostring(value or "")
                end

                return LabelControl
            end

            function Module:AddToggle(text, default, call, getter)
                Module.HasSettings = true
                Dots.Visible = true

                local Frame = Instance.new("Frame")
                Frame.Parent = SettingsFrame
                Frame.BackgroundTransparency = 1
                Frame.Size = UDim2.new(1, 0, 0, 36)
                Frame.ZIndex = 8

                local Label = Instance.new("TextLabel")
                Label.Parent = Frame
                Label.Text = text
                Label.TextColor3 = UiTextBright
                Label.Font = Enum.Font.GothamSemibold
                Label.TextSize = 15
                Label.BackgroundTransparency = 1
                Label.Position = UDim2.new(0, 12, 0, 0)
                Label.Size = UDim2.new(1, -68, 1, 0)
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.ZIndex = 9

                local Btn = Instance.new("TextButton")
                Btn.Parent = Frame
                Btn.Size = UDim2.new(0, 46, 0, 24)
                Btn.Position = UDim2.new(1, -58, 0.5, -12)
                Btn.Text = ""
                Btn.AutoButtonColor = false
                Btn.BorderSizePixel = 0
                local offColor = UiToggleOffBg
                local strokeTrans = 0.18
                Btn.BackgroundColor3 = default and Settings.Colors.Accent or offColor
                Btn.BackgroundTransparency = 0
                Btn.ZIndex = 9

                local Corner = Instance.new("UICorner")
                Corner.CornerRadius = UDim.new(1, 0)
                Corner.Parent = Btn
                local btnStroke = Ui.ApplyStroke(Btn, default and Settings.Colors.AccentSoft or UiToggleOffBorder, default and 0.18 or strokeTrans, 1)
                local offGradFrom = offColor
                local offGradTo = offColor:Lerp(UiTextBright, 0.07)
                local btnGradient = Ui.ApplyGradient(
                    Btn,
                    default and Settings.Colors.Accent or offGradFrom,
                    default and Settings.Colors.AccentSoft or offGradTo,
                    90
                )
                local btnStrokeGradient = btnStroke and Ui.ApplyGradient(btnStroke, default and Settings.Colors.AccentSoft or UiToggleOffBorder, default and Settings.Colors.Accent or UiButtonBorder, 108)
                local btnScale = Ui.EnsureScale(Btn, 1)
                if btnGradient then
                    btnGradient.Offset = Vector2.new(0, default and 0.12 or 0.5)
                end

                local Check = Instance.new("ImageLabel")
                Check.Parent = Btn
                Check.Image = "rbxassetid://6031094667"
                Check.Size = UDim2.new(1, -6, 1, -6)
                Check.Position = UDim2.new(0, 3, 0, 3)
                Check.BackgroundTransparency = 1
                Check.Visible = false
                Check.ZIndex = 10

                local OffMark = Instance.new("Frame")
                OffMark.Parent = Btn
                OffMark.Size = UDim2.new(0, 18, 0, 18)
                OffMark.Position = default and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
                OffMark.BackgroundColor3 = default and UiTextBright or UiToggleOffThumb
                OffMark.BackgroundTransparency = 0
                OffMark.BorderSizePixel = 0
                OffMark.ZIndex = 10
                Ui.ApplyCorner(OffMark, Theme.Corner.Pill)

                local currentValue = not not default
                local function applyValue(nextValue, silent)
                    local value = not not nextValue
                    currentValue = value
                    Check.Visible = false
                    OffMark.Visible = true
                    Ui.Tween(Btn, {BackgroundColor3 = value and Settings.Colors.Accent or offColor}, 0.2)
                    Ui.Tween(OffMark, {
                        Position = value and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9),
                        BackgroundColor3 = value and UiTextBright or UiToggleOffThumb
                    }, Theme.Anim.Fast)
                    if btnStroke then
                        Ui.Tween(btnStroke, {Transparency = value and 0.18 or strokeTrans, Color = value and Settings.Colors.AccentSoft or UiToggleOffBorder}, Theme.Anim.Fast)
                    end
                    if btnGradient then
                        btnGradient.Color = ColorSequence.new(
                            value and Settings.Colors.Accent or offGradFrom,
                            value and Settings.Colors.AccentSoft or offGradTo
                        )
                        Ui.Tween(btnGradient, {Offset = Vector2.new(0, value and 0.1 or 0.5), Rotation = value and 126 or 86}, Theme.Anim.Normal)
                    end
                    if btnStrokeGradient then
                        btnStrokeGradient.Color = ColorSequence.new(
                            value and Settings.Colors.AccentSoft or UiToggleOffBorder,
                            value and Settings.Colors.Accent or UiButtonBorder
                        )
                        Ui.Tween(btnStrokeGradient, {Offset = Vector2.new(0, value and 0.1 or 0.45), Rotation = value and 136 or 108}, Theme.Anim.Normal)
                    end
                    if call and not silent then call(value) end
                end

                if currentValue and call then call(true) end

                table.insert(State.UnloadConnections, Btn.MouseEnter:Connect(function()
                    Ui.Tween(Label, {TextColor3 = UiTextBright}, Theme.Anim.Fast)
                    Ui.Tween(Btn, {BackgroundColor3 = currentValue and Settings.Colors.Accent or offColor:Lerp(UiAccentSoft, 0.08)}, Theme.Anim.Fast)
                    if btnStroke then Ui.Tween(btnStroke, {Transparency = currentValue and 0.14 or 0.12, Color = currentValue and Settings.Colors.AccentSoft or UiToggleOffBorder:Lerp(UiAccentMid, 0.35)}, Theme.Anim.Fast) end
                    if btnGradient then Ui.Tween(btnGradient, {Offset = Vector2.new(0, 0.2), Rotation = 108}, Theme.Anim.Normal) end
                end))
                table.insert(State.UnloadConnections, Btn.MouseLeave:Connect(function()
                    Ui.Tween(Label, {TextColor3 = UiTextBright}, Theme.Anim.Fast)
                    Ui.Tween(Btn, {BackgroundColor3 = currentValue and Settings.Colors.Accent or offColor}, Theme.Anim.Fast)
                    if btnStroke then Ui.Tween(btnStroke, {Transparency = currentValue and 0.18 or strokeTrans, Color = currentValue and Settings.Colors.AccentSoft or UiToggleOffBorder}, Theme.Anim.Fast) end
                    if btnGradient then Ui.Tween(btnGradient, {Offset = Vector2.new(0, currentValue and 0.1 or 0.5), Rotation = currentValue and 126 or 86}, Theme.Anim.Normal) end
                end))
                table.insert(State.UnloadConnections, Btn.MouseButton1Click:Connect(function()
                    Ui.PulseScale(btnScale, 0.9, 0.06, 0.14)
                    applyValue(not currentValue, false)
                end))
                Module:RegisterControl({
                    Key = text,
                    Type = "Toggle",
                    Getter = getter,
                    GetValue = function() return currentValue end,
                    SetValue = function(_, value, silent) applyValue(value, silent) end,
                })
                return Frame
            end

            function Module:AddSlider(text, min, max, default, call, step, getter)
                Module.HasSettings = true
                Dots.Visible = true

                local Frame = Instance.new("Frame")
                Frame.Parent = SettingsFrame
                Frame.BackgroundTransparency = 1
                Frame.Size = UDim2.new(1, 0, 0, 54)
                Frame.ZIndex = 8

                local Label = Instance.new("TextLabel")
                Label.Parent = Frame
                Label.Text = text
                Label.TextColor3 = UiTextBright
                Label.Font = Enum.Font.Gotham
                Label.TextSize = 16
                Label.BackgroundTransparency = 1
                Label.Position = UDim2.new(0, 12, 0, 0)
                Label.Size = UDim2.new(1, -66, 0, 24)
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.ZIndex = 9

                local ValueBox = Instance.new("TextBox")
                ValueBox.Parent = Frame
                ValueBox.Text = tostring(default)
                ValueBox.Size = UDim2.new(0, 46, 0, 24)
                ValueBox.Position = UDim2.new(1, -52, 0, 0)
                ValueBox.BackgroundColor3 = UiFieldBg
                ValueBox.BackgroundTransparency = 0.0
                ValueBox.TextColor3 = UiTextBright
                ValueBox.TextSize = 14
                ValueBox.Font = Enum.Font.GothamBold
                ValueBox.ZIndex = 9
                ValueBox.ClearTextOnFocus = false
                ValueBox.TextXAlignment = Enum.TextXAlignment.Center

                local VCorner = Instance.new("UICorner")
                VCorner.CornerRadius = UDim.new(0, 5)
                VCorner.Parent = ValueBox
                local valueStroke = Ui.ApplyStroke(ValueBox, UiFieldBorder, 0.38, 1)
                local valueGradient = Ui.ApplyGradient(ValueBox, UiFieldBg, UiFieldHover, 90)

                local Track = Instance.new("Frame")
                Track.Parent = Frame
                Track.BackgroundColor3 = UiFieldBg
                Track.BackgroundTransparency = 0.0
                Track.Size = UDim2.new(1, -24, 0, 8)
                Track.Position = UDim2.new(0, 12, 0, 40)
                Track.ZIndex = 9

                local TCorner = Instance.new("UICorner")
                TCorner.CornerRadius = UDim.new(1, 0)
                TCorner.Parent = Track
                local trackStroke = Ui.ApplyStroke(Track, UiFieldBorder, 0.48, 1)
                local trackGradient = Ui.ApplyGradient(Track, UiFieldBg, UiFieldHover, 90)

                local Fill = Instance.new("Frame")
                Fill.Parent = Track
                Fill.BackgroundColor3 = Settings.Colors.Accent
                Fill.ZIndex = 9

                local FCorner = Instance.new("UICorner")
                FCorner.CornerRadius = UDim.new(1, 0)
                FCorner.Parent = Fill
                local fillGradient = Ui.ApplyGradient(Fill, Settings.Colors.Accent, Settings.Colors.AccentSoft, 90)
                if fillGradient then
                    fillGradient.Offset = Vector2.new(0, 0.45)
                end

                local ClickBtn = Instance.new("TextButton")
                ClickBtn.Parent = Track
                ClickBtn.BackgroundTransparency = 1
                ClickBtn.Size = UDim2.new(1, 0, 4, 0)
                ClickBtn.Position = UDim2.new(0, 0, -1, 0)
                ClickBtn.Text = ""
                ClickBtn.ZIndex = 10

                local range = max - min
                if range == 0 then range = 1 end

                local sliderStep = step
                if not sliderStep then
                    if (min % 1 ~= 0) or (max % 1 ~= 0) or (range <= 10) then
                        sliderStep = 0.1
                    else
                        sliderStep = 1
                    end
                end

                local function getDecimals(stepValue)
                    if stepValue >= 1 then return 0 end
                    local decimals = 0
                    local test = stepValue
                    while decimals < 3 and math.abs(test - math.floor(test + 0.5)) > 1e-6 do
                        test = test * 10
                        decimals = decimals + 1
                    end
                    return decimals
                end

                local decimals = getDecimals(sliderStep)
                local displayDecimals = math.max(decimals, range <= 10 and 2 or 0)

                local function roundToDecimals(value, places)
                    local factor = 10 ^ math.max(0, places or 0)
                    if value >= 0 then
                        return math.floor((value * factor) + 0.5) / factor
                    end
                    return math.ceil((value * factor) - 0.5) / factor
                end

                local function normalizeValue(raw, snapToStep)
                    local value = tonumber(raw)
                    if not value then
                        value = tonumber(default) or min
                    end
                    if snapToStep and sliderStep and sliderStep > 0 then
                        if value <= min then
                            value = min
                        elseif value >= max then
                            value = max
                        else
                            value = math.floor((value / sliderStep) + 0.5) * sliderStep
                            value = roundToDecimals(value, decimals)
                        end
                    end
                    return math.clamp(value, min, max)
                end

                local function formatValue(value)
                    if displayDecimals > 0 then
                        local text = string.format("%." .. displayDecimals .. "f", value)
                        text = text:gsub("(%..-)0+$", "%1"):gsub("%.$", "")
                        return text
                    end
                    return tostring(math.floor(value + 0.5))
                end

                local currentValue = normalizeValue(default, false)
                local function applyValue(rawValue, silent, snapToStep)
                    local value = normalizeValue(rawValue, snapToStep == true)
                    currentValue = value
                    ValueBox.Text = formatValue(value)
                    local ratio = (value - min) / range
                    Fill.Size = UDim2.new(ratio, 0, 1, 0)
                    if fillGradient then
                        fillGradient.Rotation = 84 + (ratio * 54)
                    end
                    if call and not silent then call(value) end
                end
                applyValue(currentValue, true)

                local function Update(input)
                    local pos = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                    local value = min + (range * pos)
                    applyValue(value, false, true)
                end

                local isDragging = false

                table.insert(State.UnloadConnections, ClickBtn.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        isDragging = true
                        Ui.Tween(Label, {TextColor3 = UiTextBright}, Theme.Anim.Fast)
                        Ui.Tween(ValueBox, {BackgroundTransparency = 0.0}, Theme.Anim.Fast)
                        if valueStroke then Ui.Tween(valueStroke, {Transparency = 0.42, Color = Settings.Colors.Accent}, Theme.Anim.Fast) end
                        if trackStroke then Ui.Tween(trackStroke, {Transparency = 0.48, Color = Settings.Colors.Accent}, Theme.Anim.Fast) end
                        if valueGradient then Ui.Tween(valueGradient, {Offset = Vector2.new(0, 0.18), Rotation = 112}, Theme.Anim.Normal) end
                        if trackGradient then Ui.Tween(trackGradient, {Offset = Vector2.new(0, 0.2), Rotation = 106}, Theme.Anim.Normal) end
                        Update(input)
                    end
                end))

                table.insert(State.UnloadConnections, Services.UserInputService.InputChanged:Connect(function(input)
                    if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        Update(input)
                    end
                end))

                table.insert(State.UnloadConnections, Services.UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        isDragging = false
                        Ui.Tween(Label, {TextColor3 = UiTextBright}, Theme.Anim.Fast)
                        Ui.Tween(ValueBox, {BackgroundTransparency = 0.01}, Theme.Anim.Fast)
                        if valueStroke then Ui.Tween(valueStroke, {Transparency = 0.38, Color = UiFieldBorder}, Theme.Anim.Fast) end
                        if trackStroke then Ui.Tween(trackStroke, {Transparency = 0.48, Color = UiFieldBorder}, Theme.Anim.Fast) end
                        if valueGradient then Ui.Tween(valueGradient, {Offset = Vector2.new(0, 0.62), Rotation = 90}, Theme.Anim.Normal) end
                        if trackGradient then Ui.Tween(trackGradient, {Offset = Vector2.new(0, 0.55), Rotation = 90}, Theme.Anim.Normal) end
                    end
                end))
                table.insert(State.UnloadConnections, ValueBox.Focused:Connect(function()
                    Ui.Tween(Label, {TextColor3 = UiTextBright}, Theme.Anim.Fast)
                    Ui.Tween(ValueBox, {BackgroundTransparency = 0.0}, Theme.Anim.Fast)
                    if valueStroke then Ui.Tween(valueStroke, {Transparency = 0.42, Color = Settings.Colors.Accent}, Theme.Anim.Fast) end
                    if valueGradient then Ui.Tween(valueGradient, {Offset = Vector2.new(0, 0.12), Rotation = 116}, Theme.Anim.Normal) end
                end))
                table.insert(State.UnloadConnections, ValueBox.FocusLost:Connect(function()
                    local text = ValueBox.Text
                    if text == "" then
                        ValueBox.Text = formatValue(currentValue)
                        Ui.Tween(ValueBox, {BackgroundTransparency = 0.01}, Theme.Anim.Fast)
                        if valueStroke then Ui.Tween(valueStroke, {Transparency = 0.38, Color = UiFieldBorder}, Theme.Anim.Fast) end
                        if valueGradient then Ui.Tween(valueGradient, {Offset = Vector2.new(0, 0.62), Rotation = 90}, Theme.Anim.Normal) end
                        return
                    end
                    text = text:gsub(",", ".")
                    local num = tonumber(text)
                    if not num then
                        ValueBox.Text = formatValue(currentValue)
                        Ui.Tween(ValueBox, {BackgroundTransparency = 0.01}, Theme.Anim.Fast)
                        if valueStroke then Ui.Tween(valueStroke, {Transparency = 0.38, Color = UiFieldBorder}, Theme.Anim.Fast) end
                        if valueGradient then Ui.Tween(valueGradient, {Offset = Vector2.new(0, 0.62), Rotation = 90}, Theme.Anim.Normal) end
                        return
                    end
                    applyValue(num, false, false)
                    Ui.Tween(ValueBox, {BackgroundTransparency = 0.01}, Theme.Anim.Fast)
                    if valueStroke then Ui.Tween(valueStroke, {Transparency = 0.38, Color = UiFieldBorder}, Theme.Anim.Fast) end
                    if valueGradient then Ui.Tween(valueGradient, {Offset = Vector2.new(0, 0.62), Rotation = 90}, Theme.Anim.Normal) end
                end))
                Module:RegisterControl({
                    Key = text,
                    Type = "Slider",
                    Getter = getter,
                    GetValue = function() return currentValue end,
                    SetValue = function(_, value, silent) applyValue(value, silent, false) end,
                })
                return Frame
            end

            function Module:AddDropdown(text, options, default, call, getter)
                Module.HasSettings = true
                Dots.Visible = true
                options = type(options) == "table" and options or {}

                local DropFrame = Instance.new("Frame")
                DropFrame.Parent = SettingsFrame
                DropFrame.BackgroundTransparency = 1
                local collapsedHeight = 58
                DropFrame.Size = UDim2.new(1, 0, 0, collapsedHeight)
                DropFrame.ZIndex = 8

                local Label = Instance.new("TextLabel")
                Label.Parent = DropFrame
                Label.Text = text
                Label.TextColor3 = UiTextBright
                Label.Font = Enum.Font.Gotham
                Label.TextSize = 15
                Label.BackgroundTransparency = 1
                Label.Position = UDim2.new(0, 12, 0, 0)
                Label.Size = UDim2.new(1, -24, 0, 20)
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.ZIndex = 9

                local Button = Instance.new("TextButton")
                Button.Parent = DropFrame
                Button.BackgroundColor3 = UiPanelBlack:Lerp(UiInputDark, 0.6)
                Button.BackgroundTransparency = 0.0
                Button.Size = UDim2.new(1, -24, 0, 34)
                Button.Position = UDim2.new(0, 12, 0, 22)
                Button.Text = ""
                Button.ZIndex = 9
                Button.AutoButtonColor = false

                local Corner = Instance.new("UICorner")
                Corner.CornerRadius = UDim.new(0, 5)
                Corner.Parent = Button
                local buttonStroke = Ui.ApplyStroke(Button, UiAccentMid, 0.46, 1)
                local DropGradient = Ui.ApplyGradient(Button, UiPanelBlack:Lerp(UiInputDark, 0.56), UiDropdownOptionHover:Lerp(UiPanelBlack, 0.35), 90)
                if DropGradient then
                    DropGradient.Offset = Vector2.new(0, 0.55)
                end

                local ValueLabel = Instance.new("TextLabel")
                ValueLabel.Parent = Button
                ValueLabel.BackgroundTransparency = 1
                ValueLabel.Position = UDim2.new(0, 12, 0, 0)
                ValueLabel.Size = UDim2.new(1, -50, 1, 0)
                ValueLabel.Font = Enum.Font.GothamSemibold
                ValueLabel.TextSize = 15
                ValueLabel.TextColor3 = UiTextBright
                ValueLabel.TextXAlignment = Enum.TextXAlignment.Left
                ValueLabel.TextYAlignment = Enum.TextYAlignment.Center
                ValueLabel.TextTruncate = Enum.TextTruncate.AtEnd
                ValueLabel.ZIndex = 10
                MarkReadableButton(ValueLabel, UiTextBright)

                local ArrowSlot = Instance.new("Frame")
                ArrowSlot.Parent = Button
                ArrowSlot.BackgroundColor3 = UiDropdownArrowBg
                ArrowSlot.BackgroundTransparency = 0
                ArrowSlot.BorderSizePixel = 0
                ArrowSlot.Position = UDim2.new(1, -31, 0.5, -12)
                ArrowSlot.Size = UDim2.new(0, 24, 0, 24)
                ArrowSlot.ZIndex = 10
                Ui.ApplyCorner(ArrowSlot, Theme.Corner.Pill)
                local arrowSlotStroke = Ui.ApplyStroke(ArrowSlot, UiDropdownArrowBorder, 0.22, 1)

                local Arrow = Instance.new("TextLabel")
                Arrow.Parent = ArrowSlot
                Arrow.BackgroundTransparency = 1
                Arrow.Size = UDim2.new(1, 0, 1, 0)
                Arrow.Position = UDim2.new(0, 0, 0, 0)
                Arrow.Font = Enum.Font.GothamBold
                Arrow.Text = ">"
                Arrow.TextSize = 18
                Arrow.TextColor3 = UiTextBright
                Arrow.TextXAlignment = Enum.TextXAlignment.Center
                Arrow.TextYAlignment = Enum.TextYAlignment.Center
                Arrow.ZIndex = 11

                local ListFrame = Instance.new("Frame")
                ListFrame.Parent = DropFrame
                ListFrame.BackgroundColor3 = UiPanelBlack:Lerp(UiInputDark, 0.54)
                ListFrame.BackgroundTransparency = 0.0
                ListFrame.Position = UDim2.new(0, 12, 0, collapsedHeight)
                ListFrame.Size = UDim2.new(1, -24, 0, 0)
                ListFrame.Visible = false
                ListFrame.ZIndex = 15
                ListFrame.ClipsDescendants = true
                local listStroke = Ui.ApplyStroke(ListFrame, UiAccentMid, 0.44, 1)
                local ListGradient = Ui.ApplyGradient(ListFrame, UiPanelBlack:Lerp(UiInputDark, 0.52), UiButtonHover:Lerp(UiPanelBlack, 0.25), 88)
                if ListGradient then
                    ListGradient.Offset = Vector2.new(0, 0.6)
                end

                local LCorner = Instance.new("UICorner")
                LCorner.CornerRadius = UDim.new(0, 4)
                LCorner.Parent = ListFrame

                local LList = Instance.new("UIListLayout")
                LList.Parent = ListFrame
                LList.SortOrder = Enum.SortOrder.LayoutOrder
                LList.Padding = UDim.new(0, 2)
                local ListPad = Instance.new("UIPadding")
                ListPad.Parent = ListFrame
                ListPad.PaddingTop = UDim.new(0, 6)
                ListPad.PaddingBottom = UDim.new(0, 6)
                ListPad.PaddingLeft = UDim.new(0, 6)
                ListPad.PaddingRight = UDim.new(0, 6)

                local optionButtons = {}
                local isDropped = false

                local function isValidOption(value)
                    for _, opt in ipairs(options) do
                        if opt == value then
                            return true
                        end
                    end
                    if type(value) == "string" then
                        for _, opt in ipairs(options) do
                            if tostring(opt) == value then
                                return true
                            end
                        end
                    end
                    return false
                end

                local function fallbackOption()
                    if isValidOption(default) then
                        return default
                    end
                    return options[1]
                end

                local function normalizeDropdownValue(value)
                    if isValidOption(value) then
                        if type(value) == "string" then
                            for _, opt in ipairs(options) do
                                if tostring(opt) == value then
                                    return opt
                                end
                            end
                        end
                        return value
                    end
                    return fallbackOption()
                end
                local currentValue = normalizeDropdownValue(default)

                local refreshOptions
                local function applyValue(nextValue, silent)
                    currentValue = normalizeDropdownValue(nextValue)
                    ValueLabel.Text = tostring(currentValue or "-")
                    if refreshOptions then refreshOptions() end
                    if call and not silent then call(currentValue) end
                end

                refreshOptions = function()
                    for _, entry in ipairs(optionButtons) do
                        local btn = entry.button
                        local isActive = entry.value == currentValue
                        btn.BackgroundColor3 = isActive and UiDropdownOptionActive or UiDropdownOptionBg
                        btn.BackgroundTransparency = 0.0
                        if entry.label then
                            entry.label.TextColor3 = isActive and UiDropdownText or UiDropdownMuted
                            entry.label.TextTransparency = 0
                        end
                        if entry.indicator then
                            entry.indicator.BackgroundColor3 = isActive and UiAccentSoft or UiAccentMid
                            entry.indicator.BackgroundTransparency = isActive and 0.02 or 0.72
                        end
                        if entry.gradient then
                            entry.gradient.Color = ColorSequence.new(
                                isActive and UiDropdownOptionActive or UiDropdownOptionBg,
                                isActive and Settings.Colors.Accent:Lerp(UiDropdownOptionActive, 0.35) or UiDropdownBg
                            )
                            entry.gradient.Offset = Vector2.new(0, isActive and 0.14 or 0.55)
                            entry.gradient.Rotation = isActive and 120 or 92
                        end
                    end
                end

                local function listHeight()
                    return math.max(0, LList.AbsoluteContentSize.Y + 12)
                end

                local function setDropped(nextState, silent)
                    if isDropped == nextState then return end
                    isDropped = nextState
                    local height = listHeight()
                    if isDropped then
                        if ActiveDropdown and ActiveDropdown.frame ~= DropFrame and ActiveDropdown.close then
                            pcall(ActiveDropdown.close, true)
                        end
                        ActiveDropdown = {
                            frame = DropFrame,
                            button = Button,
                            list = ListFrame,
                            close = function(silentClose)
                                setDropped(false, silentClose)
                            end
                        }
                        ListFrame.Visible = true
                        Ui.Tween(DropFrame, {Size = UDim2.new(1, 0, 0, collapsedHeight + height + 2)}, 0.2)
                        Ui.Tween(ListFrame, {Size = UDim2.new(1, -24, 0, height)}, 0.2)
                        Ui.Tween(Button, {BackgroundTransparency = 0.0}, Theme.Anim.Fast)
                        if buttonStroke then Ui.Tween(buttonStroke, {Transparency = 0.16, Color = Settings.Colors.Accent}, Theme.Anim.Fast) end
                        if listStroke then Ui.Tween(listStroke, {Transparency = 0.24, Color = UiAccentMid}, Theme.Anim.Fast) end
                        Ui.Tween(ArrowSlot, {BackgroundColor3 = UiAccentDeep:Lerp(UiDropdownArrowBg, 0.18)}, Theme.Anim.Fast)
                        if arrowSlotStroke then Ui.Tween(arrowSlotStroke, {Transparency = 0.08, Color = UiAccentSoft}, Theme.Anim.Fast) end
                        Ui.Tween(Arrow, {Rotation = 90, TextColor3 = Settings.Colors.AccentSoft}, Theme.Anim.Fast)
                        if DropGradient then
                            Ui.Tween(DropGradient, {Offset = Vector2.new(0, 0.12), Rotation = 118}, Theme.Anim.Normal)
                        end
                        if ListGradient then
                            Ui.Tween(ListGradient, {Offset = Vector2.new(0, 0.2), Rotation = 106}, Theme.Anim.Normal)
                        end
                    else
                        if ActiveDropdown and ActiveDropdown.frame == DropFrame then
                            ActiveDropdown = nil
                        end
                        Ui.Tween(DropFrame, {Size = UDim2.new(1, 0, 0, collapsedHeight)}, 0.2)
                        Ui.Tween(ListFrame, {Size = UDim2.new(1, -24, 0, 0)}, 0.2)
                        Ui.Tween(Button, {BackgroundTransparency = 0.0}, Theme.Anim.Fast)
                        if buttonStroke then Ui.Tween(buttonStroke, {Transparency = 0.46, Color = UiAccentMid}, Theme.Anim.Fast) end
                        if listStroke then Ui.Tween(listStroke, {Transparency = 0.44, Color = UiAccentMid}, Theme.Anim.Fast) end
                        Ui.Tween(ArrowSlot, {BackgroundColor3 = UiDropdownArrowBg}, Theme.Anim.Fast)
                        if arrowSlotStroke then Ui.Tween(arrowSlotStroke, {Transparency = 0.22, Color = UiDropdownArrowBorder}, Theme.Anim.Fast) end
                        Ui.Tween(Arrow, {Rotation = 0, TextColor3 = UiTextBright}, Theme.Anim.Fast)
                        if DropGradient then
                            Ui.Tween(DropGradient, {Offset = Vector2.new(0, 0.55), Rotation = 92}, Theme.Anim.Normal)
                        end
                        if ListGradient then
                            Ui.Tween(ListGradient, {Offset = Vector2.new(0, 0.6), Rotation = 88}, Theme.Anim.Normal)
                        end
                        task.delay(0.2, function() if not isDropped then ListFrame.Visible = false end end)
                    end
                    if not silent then
                        task.delay(0.21, function()
                            SyncSettingsFrame(false)
                            UpdateSize()
                        end)
                    end
                end

                table.insert(State.UnloadConnections, Button.MouseButton1Click:Connect(function()
                    setDropped(not isDropped, false)
                end))
                table.insert(State.UnloadConnections, Button.MouseEnter:Connect(function()
                    if not isDropped then
                        Ui.Tween(Button, {BackgroundTransparency = 0.0}, Theme.Anim.Fast)
                        if buttonStroke then Ui.Tween(buttonStroke, {Transparency = 0.2, Color = UiAccentMid}, Theme.Anim.Fast) end
                        Ui.Tween(ArrowSlot, {BackgroundColor3 = UiDropdownArrowHover}, Theme.Anim.Fast)
                        if arrowSlotStroke then Ui.Tween(arrowSlotStroke, {Transparency = 0.14, Color = UiAccentMid}, Theme.Anim.Fast) end
                        Ui.Tween(Arrow, {TextColor3 = UiTextBright}, Theme.Anim.Fast)
                        if DropGradient then Ui.Tween(DropGradient, {Offset = Vector2.new(0, 0.2), Rotation = 108}, Theme.Anim.Normal) end
                    end
                end))
                table.insert(State.UnloadConnections, Button.MouseLeave:Connect(function()
                    if not isDropped then
                        Ui.Tween(Button, {BackgroundTransparency = 0.0}, Theme.Anim.Fast)
                        if buttonStroke then Ui.Tween(buttonStroke, {Transparency = 0.46, Color = UiAccentMid}, Theme.Anim.Fast) end
                        Ui.Tween(ArrowSlot, {BackgroundColor3 = UiDropdownArrowBg}, Theme.Anim.Fast)
                        if arrowSlotStroke then Ui.Tween(arrowSlotStroke, {Transparency = 0.22, Color = UiDropdownArrowBorder}, Theme.Anim.Fast) end
                        Ui.Tween(Arrow, {TextColor3 = UiTextBright}, Theme.Anim.Fast)
                        if DropGradient then Ui.Tween(DropGradient, {Offset = Vector2.new(0, 0.55), Rotation = 92}, Theme.Anim.Normal) end
                    end
                end))
                for _, opt in ipairs(options) do
                    local OptBtn = Instance.new("TextButton")
                    OptBtn.Parent = ListFrame
                    OptBtn.BackgroundColor3 = UiDropdownOptionBg
                    OptBtn.BackgroundTransparency = 0.0
                    OptBtn.Size = UDim2.new(1, 0, 0, 30)
                    OptBtn.Text = ""
                    OptBtn.TextColor3 = UiDropdownMuted
                    OptBtn.Font = Enum.Font.GothamSemibold
                    OptBtn.TextSize = 15
                    OptBtn.AutoButtonColor = false
                    OptBtn.ZIndex = 16
                    OptBtn.TextXAlignment = Enum.TextXAlignment.Left
                    Ui.ApplyCorner(OptBtn, Theme.Corner.Small)
                    local optGradient = Ui.ApplyGradient(OptBtn, UiDropdownOptionBg, UiDropdownBg, 90)

                    local Indicator = Instance.new("Frame")
                    Indicator.Parent = OptBtn
                    Indicator.BackgroundColor3 = UiAccentMid
                    Indicator.BackgroundTransparency = 0.72
                    Indicator.BorderSizePixel = 0
                    Indicator.Position = UDim2.new(0, 7, 0.5, -9)
                    Indicator.Size = UDim2.new(0, 3, 0, 18)
                    Indicator.ZIndex = 17
                    Ui.ApplyCorner(Indicator, Theme.Corner.Pill)

                    local OptionLabel = Instance.new("TextLabel")
                    OptionLabel.Parent = OptBtn
                    OptionLabel.BackgroundTransparency = 1
                    OptionLabel.Position = UDim2.new(0, 18, 0, 0)
                    OptionLabel.Size = UDim2.new(1, -26, 1, 0)
                    OptionLabel.Font = Enum.Font.GothamSemibold
                    OptionLabel.Text = tostring(opt)
                    OptionLabel.TextColor3 = UiDropdownMuted
                    OptionLabel.TextTransparency = 0
                    OptionLabel.TextSize = 15
                    OptionLabel.TextXAlignment = Enum.TextXAlignment.Left
                    OptionLabel.TextYAlignment = Enum.TextYAlignment.Center
                    OptionLabel.TextTruncate = Enum.TextTruncate.AtEnd
                    OptionLabel.ZIndex = 17

                    table.insert(optionButtons, {button = OptBtn, value = opt, gradient = optGradient, label = OptionLabel, indicator = Indicator})

                    table.insert(State.UnloadConnections, OptBtn.MouseButton1Click:Connect(function()
                        setDropped(false, false)
                        applyValue(opt, false)
                        refreshOptions()
                    end))
                    table.insert(State.UnloadConnections, OptBtn.MouseEnter:Connect(function()
                        if opt ~= currentValue then
                            Ui.Tween(OptBtn, {BackgroundColor3 = UiDropdownOptionHover, BackgroundTransparency = 0.0}, Theme.Anim.Fast)
                            Ui.Tween(OptionLabel, {TextColor3 = UiDropdownText, TextTransparency = 0}, Theme.Anim.Fast)
                            Ui.Tween(Indicator, {BackgroundTransparency = 0.28, BackgroundColor3 = UiAccentMid}, Theme.Anim.Fast)
                            if optGradient then
                                optGradient.Color = ColorSequence.new(UiDropdownOptionHover, UiDropdownBg:Lerp(UiAccentSoft, 0.08))
                                Ui.Tween(optGradient, {Offset = Vector2.new(0, 0.3), Rotation = 110}, Theme.Anim.Normal)
                            end
                        end
                    end))
                    table.insert(State.UnloadConnections, OptBtn.MouseLeave:Connect(function()
                        if optGradient then Ui.Tween(optGradient, {Offset = Vector2.new(0, 0.58), Rotation = 90}, Theme.Anim.Normal) end
                        refreshOptions()
                    end))
                end

                applyValue(currentValue, true)
                refreshOptions()
                if call then call(currentValue) end
                Module:RegisterControl({
                    Key = text,
                    Type = "Dropdown",
                    Getter = getter,
                    GetValue = function() return currentValue end,
                    SetValue = function(_, value, silent) applyValue(value, silent) end,
                })
            end

            function Module:AddMultiDropdown(text, options, default, call, getter)
                Module.HasSettings = true
                Dots.Visible = true
                options = type(options) == "table" and options or {}

                local DropFrame = Instance.new("Frame")
                DropFrame.Parent = SettingsFrame
                DropFrame.BackgroundTransparency = 1
                local collapsedHeight = 58
                DropFrame.Size = UDim2.new(1, 0, 0, collapsedHeight)
                DropFrame.ZIndex = 8

                local Label = Instance.new("TextLabel")
                Label.Parent = DropFrame
                Label.Text = text
                Label.TextColor3 = UiTextBright
                Label.Font = Enum.Font.Gotham
                Label.TextSize = 15
                Label.BackgroundTransparency = 1
                Label.Position = UDim2.new(0, 12, 0, 0)
                Label.Size = UDim2.new(1, -24, 0, 20)
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.ZIndex = 9

                local Button = Instance.new("TextButton")
                Button.Parent = DropFrame
                Button.BackgroundColor3 = UiPanelBlack:Lerp(UiInputDark, 0.6)
                Button.BackgroundTransparency = 0.0
                Button.Size = UDim2.new(1, -24, 0, 34)
                Button.Position = UDim2.new(0, 12, 0, 22)
                Button.Text = ""
                Button.ZIndex = 9
                Button.AutoButtonColor = false

                Ui.ApplyCorner(Button, Theme.Corner.Small)
                local buttonStroke = Ui.ApplyStroke(Button, UiAccentMid, 0.46, 1)
                local DropGradient = Ui.ApplyGradient(Button, UiPanelBlack:Lerp(UiInputDark, 0.56), UiDropdownOptionHover:Lerp(UiPanelBlack, 0.35), 90)
                if DropGradient then
                    DropGradient.Offset = Vector2.new(0, 0.55)
                end

                local ValueLabel = Instance.new("TextLabel")
                ValueLabel.Parent = Button
                ValueLabel.BackgroundTransparency = 1
                ValueLabel.Position = UDim2.new(0, 12, 0, 0)
                ValueLabel.Size = UDim2.new(1, -50, 1, 0)
                ValueLabel.Font = Enum.Font.GothamSemibold
                ValueLabel.TextSize = 15
                ValueLabel.TextColor3 = UiTextBright
                ValueLabel.TextXAlignment = Enum.TextXAlignment.Left
                ValueLabel.TextYAlignment = Enum.TextYAlignment.Center
                ValueLabel.TextTruncate = Enum.TextTruncate.AtEnd
                ValueLabel.ZIndex = 10
                MarkReadableButton(ValueLabel, UiTextBright)

                local ArrowSlot = Instance.new("Frame")
                ArrowSlot.Parent = Button
                ArrowSlot.BackgroundColor3 = UiDropdownArrowBg
                ArrowSlot.BackgroundTransparency = 0
                ArrowSlot.BorderSizePixel = 0
                ArrowSlot.Position = UDim2.new(1, -31, 0.5, -12)
                ArrowSlot.Size = UDim2.new(0, 24, 0, 24)
                ArrowSlot.ZIndex = 10
                Ui.ApplyCorner(ArrowSlot, Theme.Corner.Pill)
                local arrowSlotStroke = Ui.ApplyStroke(ArrowSlot, UiDropdownArrowBorder, 0.22, 1)

                local Arrow = Instance.new("TextLabel")
                Arrow.Parent = ArrowSlot
                Arrow.BackgroundTransparency = 1
                Arrow.Size = UDim2.new(1, 0, 1, 0)
                Arrow.Position = UDim2.new(0, 0, 0, 0)
                Arrow.Font = Enum.Font.GothamBold
                Arrow.Text = ">"
                Arrow.TextSize = 18
                Arrow.TextColor3 = UiTextBright
                Arrow.TextXAlignment = Enum.TextXAlignment.Center
                Arrow.TextYAlignment = Enum.TextYAlignment.Center
                Arrow.ZIndex = 11

                local ListFrame = Instance.new("Frame")
                ListFrame.Parent = DropFrame
                ListFrame.BackgroundColor3 = UiPanelBlack:Lerp(UiInputDark, 0.54)
                ListFrame.BackgroundTransparency = 0.0
                ListFrame.Position = UDim2.new(0, 12, 0, collapsedHeight)
                ListFrame.Size = UDim2.new(1, -24, 0, 0)
                ListFrame.Visible = false
                ListFrame.ZIndex = 15
                ListFrame.ClipsDescendants = true
                Ui.ApplyCorner(ListFrame, Theme.Corner.Small)
                local listStroke = Ui.ApplyStroke(ListFrame, UiAccentMid, 0.44, 1)
                local ListGradient = Ui.ApplyGradient(ListFrame, UiPanelBlack:Lerp(UiInputDark, 0.52), UiButtonHover:Lerp(UiPanelBlack, 0.25), 88)

                local LList = Instance.new("UIListLayout")
                LList.Parent = ListFrame
                LList.SortOrder = Enum.SortOrder.LayoutOrder
                LList.Padding = UDim.new(0, 2)
                local ListPad = Instance.new("UIPadding")
                ListPad.Parent = ListFrame
                ListPad.PaddingTop = UDim.new(0, 6)
                ListPad.PaddingBottom = UDim.new(0, 6)
                ListPad.PaddingLeft = UDim.new(0, 6)
                ListPad.PaddingRight = UDim.new(0, 6)

                local normalizedOptions = {}
                for _, opt in ipairs(options) do
                    if type(opt) == "table" then
                        table.insert(normalizedOptions, {
                            Label = tostring(opt.Label or opt.Name or opt.Value or ""),
                            Value = tostring(opt.Value or opt.Name or opt.Label or ""),
                        })
                    else
                        table.insert(normalizedOptions, {Label = tostring(opt), Value = tostring(opt)})
                    end
                end
                local validOptionValues = {}
                for _, opt in ipairs(normalizedOptions) do
                    validOptionValues[opt.Value] = true
                end

                local selected = {}
                local optionButtons = {}
                local isDropped = false

                local function normalizeSelection(value)
                    local result = {}
                    if type(value) ~= "table" then return result end
                    for key, enabled in pairs(value) do
                        local normalizedKey = tostring(key)
                        if type(key) == "number" then
                            local optionValue = tostring(enabled)
                            if validOptionValues[optionValue] then
                                result[optionValue] = true
                            end
                        elseif enabled and validOptionValues[normalizedKey] then
                            result[normalizedKey] = true
                        end
                    end
                    return result
                end

                local refreshOptions
                local function selectedSummary()
                    local labels = {}
                    for _, opt in ipairs(normalizedOptions) do
                        if selected[opt.Value] then
                            table.insert(labels, opt.Label)
                        end
                    end
                    return #labels > 0 and table.concat(labels, ", ") or "None"
                end

                local function emitValue()
                    local copy = {}
                    for _, opt in ipairs(normalizedOptions) do
                        copy[opt.Value] = selected[opt.Value] == true
                    end
                    return copy
                end

                local function applyValue(nextValue, silent)
                    selected = normalizeSelection(nextValue)
                    ValueLabel.Text = selectedSummary()
                    if refreshOptions then refreshOptions() end
                    if call and not silent then call(emitValue()) end
                end

                refreshOptions = function()
                    for _, entry in ipairs(optionButtons) do
                        local active = selected[entry.value] == true
                        entry.button.BackgroundColor3 = active and UiDropdownOptionActive or UiDropdownOptionBg
                        entry.button.BackgroundTransparency = 0.0
                        if entry.labelObject then
                            entry.labelObject.TextColor3 = active and UiDropdownText or UiDropdownMuted
                            entry.labelObject.TextTransparency = 0
                        end
                        if entry.indicator then
                            entry.indicator.BackgroundColor3 = active and UiAccentSoft or UiAccentMid
                            entry.indicator.BackgroundTransparency = active and 0.02 or 0.76
                        end
                        if entry.indicatorStroke then
                            entry.indicatorStroke.Color = active and UiTextBright or UiAccentSoft
                            entry.indicatorStroke.Transparency = active and 0.18 or 0.7
                        end
                        if entry.gradient then
                            entry.gradient.Color = ColorSequence.new(
                                active and UiDropdownOptionActive or UiDropdownOptionBg,
                                active and Settings.Colors.Accent:Lerp(UiDropdownOptionActive, 0.35) or UiDropdownBg
                            )
                            entry.gradient.Offset = Vector2.new(0, active and 0.14 or 0.55)
                            entry.gradient.Rotation = active and 120 or 92
                        end
                    end
                end

                local function listHeight()
                    return math.max(0, LList.AbsoluteContentSize.Y + 12)
                end

                local function setDropped(nextState, silent)
                    if isDropped == nextState then return end
                    isDropped = nextState
                    local height = listHeight()
                    if isDropped then
                        if ActiveDropdown and ActiveDropdown.frame ~= DropFrame and ActiveDropdown.close then
                            pcall(ActiveDropdown.close, true)
                        end
                        ActiveDropdown = {
                            frame = DropFrame,
                            button = Button,
                            list = ListFrame,
                            close = function(silentClose)
                                setDropped(false, silentClose)
                            end
                        }
                        ListFrame.Visible = true
                        Ui.Tween(DropFrame, {Size = UDim2.new(1, 0, 0, collapsedHeight + height + 2)}, 0.2)
                        Ui.Tween(ListFrame, {Size = UDim2.new(1, -24, 0, height)}, 0.2)
                        if buttonStroke then Ui.Tween(buttonStroke, {Transparency = 0.16, Color = Settings.Colors.Accent}, Theme.Anim.Fast) end
                        if listStroke then Ui.Tween(listStroke, {Transparency = 0.24, Color = UiAccentMid}, Theme.Anim.Fast) end
                        Ui.Tween(ArrowSlot, {BackgroundColor3 = UiAccentDeep:Lerp(UiDropdownArrowBg, 0.18)}, Theme.Anim.Fast)
                        if arrowSlotStroke then Ui.Tween(arrowSlotStroke, {Transparency = 0.08, Color = UiAccentSoft}, Theme.Anim.Fast) end
                        Ui.Tween(Arrow, {Rotation = 90, TextColor3 = Settings.Colors.AccentSoft}, Theme.Anim.Fast)
                        if DropGradient then Ui.Tween(DropGradient, {Offset = Vector2.new(0, 0.12), Rotation = 118}, Theme.Anim.Normal) end
                        if ListGradient then Ui.Tween(ListGradient, {Offset = Vector2.new(0, 0.2), Rotation = 106}, Theme.Anim.Normal) end
                    else
                        if ActiveDropdown and ActiveDropdown.frame == DropFrame then
                            ActiveDropdown = nil
                        end
                        Ui.Tween(DropFrame, {Size = UDim2.new(1, 0, 0, collapsedHeight)}, 0.2)
                        Ui.Tween(ListFrame, {Size = UDim2.new(1, -24, 0, 0)}, 0.2)
                        if buttonStroke then Ui.Tween(buttonStroke, {Transparency = 0.46, Color = UiAccentMid}, Theme.Anim.Fast) end
                        if listStroke then Ui.Tween(listStroke, {Transparency = 0.44, Color = UiAccentMid}, Theme.Anim.Fast) end
                        Ui.Tween(ArrowSlot, {BackgroundColor3 = UiDropdownArrowBg}, Theme.Anim.Fast)
                        if arrowSlotStroke then Ui.Tween(arrowSlotStroke, {Transparency = 0.22, Color = UiDropdownArrowBorder}, Theme.Anim.Fast) end
                        Ui.Tween(Arrow, {Rotation = 0, TextColor3 = UiTextBright}, Theme.Anim.Fast)
                        if DropGradient then Ui.Tween(DropGradient, {Offset = Vector2.new(0, 0.55), Rotation = 92}, Theme.Anim.Normal) end
                        if ListGradient then Ui.Tween(ListGradient, {Offset = Vector2.new(0, 0.6), Rotation = 88}, Theme.Anim.Normal) end
                        task.delay(0.2, function() if not isDropped then ListFrame.Visible = false end end)
                    end
                    if not silent then
                        task.delay(0.21, function()
                            SyncSettingsFrame(false)
                            UpdateSize()
                        end)
                    end
                end

                table.insert(State.UnloadConnections, Button.MouseButton1Click:Connect(function()
                    setDropped(not isDropped, false)
                end))
                table.insert(State.UnloadConnections, Button.MouseEnter:Connect(function()
                    if not isDropped then
                        if buttonStroke then Ui.Tween(buttonStroke, {Transparency = 0.2, Color = UiAccentMid}, Theme.Anim.Fast) end
                        Ui.Tween(ArrowSlot, {BackgroundColor3 = UiDropdownArrowHover}, Theme.Anim.Fast)
                        if arrowSlotStroke then Ui.Tween(arrowSlotStroke, {Transparency = 0.14, Color = UiAccentMid}, Theme.Anim.Fast) end
                        Ui.Tween(Arrow, {TextColor3 = UiTextBright}, Theme.Anim.Fast)
                        if DropGradient then Ui.Tween(DropGradient, {Offset = Vector2.new(0, 0.2), Rotation = 108}, Theme.Anim.Normal) end
                    end
                end))
                table.insert(State.UnloadConnections, Button.MouseLeave:Connect(function()
                    if not isDropped then
                        if buttonStroke then Ui.Tween(buttonStroke, {Transparency = 0.46, Color = UiAccentMid}, Theme.Anim.Fast) end
                        Ui.Tween(ArrowSlot, {BackgroundColor3 = UiDropdownArrowBg}, Theme.Anim.Fast)
                        if arrowSlotStroke then Ui.Tween(arrowSlotStroke, {Transparency = 0.22, Color = UiDropdownArrowBorder}, Theme.Anim.Fast) end
                        Ui.Tween(Arrow, {TextColor3 = UiTextBright}, Theme.Anim.Fast)
                        if DropGradient then Ui.Tween(DropGradient, {Offset = Vector2.new(0, 0.55), Rotation = 92}, Theme.Anim.Normal) end
                    end
                end))
                for _, opt in ipairs(normalizedOptions) do
                    local OptBtn = Instance.new("TextButton")
                    OptBtn.Parent = ListFrame
                    OptBtn.BackgroundColor3 = UiDropdownOptionBg
                    OptBtn.BackgroundTransparency = 0.0
                    OptBtn.Size = UDim2.new(1, 0, 0, 30)
                    OptBtn.Text = ""
                    OptBtn.TextColor3 = UiDropdownMuted
                    OptBtn.Font = Enum.Font.GothamSemibold
                    OptBtn.TextSize = 15
                    OptBtn.AutoButtonColor = false
                    OptBtn.ZIndex = 16
                    OptBtn.TextXAlignment = Enum.TextXAlignment.Left
                    Ui.ApplyCorner(OptBtn, Theme.Corner.Small)
                    local optGradient = Ui.ApplyGradient(OptBtn, UiDropdownOptionBg, UiDropdownBg, 90)

                    local Indicator = Instance.new("Frame")
                    Indicator.Parent = OptBtn
                    Indicator.BackgroundColor3 = UiAccentMid
                    Indicator.BackgroundTransparency = 0.76
                    Indicator.BorderSizePixel = 0
                    Indicator.Position = UDim2.new(0, 8, 0.5, -5)
                    Indicator.Size = UDim2.new(0, 10, 0, 10)
                    Indicator.ZIndex = 17
                    Ui.ApplyCorner(Indicator, 3)
                    local indicatorStroke = Ui.ApplyStroke(Indicator, UiAccentSoft, 0.7, 1)

                    local OptionLabel = Instance.new("TextLabel")
                    OptionLabel.Parent = OptBtn
                    OptionLabel.BackgroundTransparency = 1
                    OptionLabel.Position = UDim2.new(0, 26, 0, 0)
                    OptionLabel.Size = UDim2.new(1, -34, 1, 0)
                    OptionLabel.Font = Enum.Font.GothamSemibold
                    OptionLabel.Text = opt.Label
                    OptionLabel.TextColor3 = UiDropdownMuted
                    OptionLabel.TextTransparency = 0
                    OptionLabel.TextSize = 15
                    OptionLabel.TextXAlignment = Enum.TextXAlignment.Left
                    OptionLabel.TextYAlignment = Enum.TextYAlignment.Center
                    OptionLabel.TextTruncate = Enum.TextTruncate.AtEnd
                    OptionLabel.ZIndex = 17

                    table.insert(optionButtons, {
                        button = OptBtn,
                        value = opt.Value,
                        label = opt.Label,
                        gradient = optGradient,
                        labelObject = OptionLabel,
                        indicator = Indicator,
                        indicatorStroke = indicatorStroke,
                    })

                    table.insert(State.UnloadConnections, OptBtn.MouseButton1Click:Connect(function()
                        selected[opt.Value] = not selected[opt.Value]
                        ValueLabel.Text = selectedSummary()
                        refreshOptions()
                        if call then call(emitValue()) end
                    end))
                    table.insert(State.UnloadConnections, OptBtn.MouseEnter:Connect(function()
                        if selected[opt.Value] ~= true then
                            Ui.Tween(OptBtn, {BackgroundColor3 = UiDropdownOptionHover, BackgroundTransparency = 0.0}, Theme.Anim.Fast)
                            Ui.Tween(OptionLabel, {TextColor3 = UiDropdownText, TextTransparency = 0}, Theme.Anim.Fast)
                            Ui.Tween(Indicator, {BackgroundTransparency = 0.34, BackgroundColor3 = UiAccentMid}, Theme.Anim.Fast)
                            if indicatorStroke then Ui.Tween(indicatorStroke, {Transparency = 0.42, Color = UiAccentSoft}, Theme.Anim.Fast) end
                            if optGradient then
                                optGradient.Color = ColorSequence.new(UiDropdownOptionHover, UiDropdownBg:Lerp(UiAccentSoft, 0.08))
                                Ui.Tween(optGradient, {Offset = Vector2.new(0, 0.3), Rotation = 110}, Theme.Anim.Normal)
                            end
                        end
                    end))
                    table.insert(State.UnloadConnections, OptBtn.MouseLeave:Connect(function()
                        refreshOptions()
                    end))
                end

                applyValue(default, true)
                refreshOptions()
                if call then call(emitValue()) end
                Module:RegisterControl({
                    Key = text,
                    Type = "MultiDropdown",
                    Getter = getter,
                    GetValue = function() return emitValue() end,
                    SetValue = function(_, value, silent) applyValue(value, silent) end,
                })
                return DropFrame
            end

            function Module:AddColorPicker(text, default, call, getter)
                Module.HasSettings = true
                Dots.Visible = true

                local function resolveColor(value)
                    if typeof(value) == "Color3" then
                        return value
                    end
                    if type(value) == "table" then
                        local rr = value.r or value.R or 0
                        local gg = value.g or value.G or 0
                        local bb = value.b or value.B or 0
                        if rr <= 1 and gg <= 1 and bb <= 1 then
                            return Color3.new(rr, gg, bb)
                        end
                        return Color3.fromRGB(rr, gg, bb)
                    end
                    return Settings.Colors.Accent or Color3.fromRGB(255, 255, 255)
                end

                local function toByte(component)
                    return math.clamp(math.floor((component * 255) + 0.5), 0, 255)
                end

                local function toHex(color)
                    return string.format("#%02X%02X%02X", toByte(color.R), toByte(color.G), toByte(color.B))
                end

                local function toRgbText(color)
                    return string.format("RGB %d, %d, %d", toByte(color.R), toByte(color.G), toByte(color.B))
                end

                local function colorToHsv(color)
                    local ok, h, s, v = pcall(function()
                        return color:ToHSV()
                    end)
                    if ok and h ~= nil then
                        return h, s, v
                    end
                    return Color3.toHSV(color)
                end

                local initialColor = resolveColor(default)
                local hue, saturation, value = colorToHsv(initialColor)
                local currentColor = Color3.fromHSV(hue, saturation, value)

                local PickerFrame = Instance.new("Frame")
                PickerFrame.Parent = SettingsFrame
                PickerFrame.BackgroundTransparency = 1
                PickerFrame.Size = UDim2.new(1, 0, 0, 36)
                PickerFrame.ZIndex = 8
                PickerFrame.ClipsDescendants = true

                local TopPart = Instance.new("Frame")
                TopPart.Parent = PickerFrame
                TopPart.BackgroundTransparency = 1
                TopPart.Size = UDim2.new(1, 0, 0, 36)
                TopPart.ZIndex = 9

                local Label = Instance.new("TextLabel")
                Label.Parent = TopPart
                Label.Text = text
                Label.TextColor3 = UiTextBright
                Label.Font = Enum.Font.Gotham
                Label.TextSize = 15
                Label.BackgroundTransparency = 1
                Label.Position = UDim2.new(0, 12, 0, 0)
                Label.Size = UDim2.new(1, -138, 1, 0)
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.TextTruncate = Enum.TextTruncate.AtEnd
                Label.ZIndex = 10

                local HexLabel = Instance.new("TextLabel")
                HexLabel.Parent = TopPart
                HexLabel.Text = toHex(currentColor)
                HexLabel.TextColor3 = UiTextSoft
                HexLabel.Font = Enum.Font.GothamSemibold
                HexLabel.TextSize = 11
                HexLabel.BackgroundTransparency = 1
                HexLabel.Position = UDim2.new(1, -116, 0, 0)
                HexLabel.Size = UDim2.new(0, 68, 1, 0)
                HexLabel.TextXAlignment = Enum.TextXAlignment.Right
                HexLabel.ZIndex = 10

                local ColorButton = Instance.new("Frame")
                ColorButton.Parent = TopPart
                ColorButton.Size = UDim2.new(0, 34, 0, 22)
                ColorButton.Position = UDim2.new(1, -46, 0, 7)
                ColorButton.BackgroundColor3 = currentColor
                ColorButton.BorderSizePixel = 0
                ColorButton.ZIndex = 10
                Instance.new("UICorner", ColorButton).CornerRadius = UDim.new(0, 5)
                local colorButtonStroke = Ui.ApplyStroke(ColorButton, UiBorderSoft, 0.44, 1)
                local colorButtonGradient = Ui.ApplyGradient(ColorButton, currentColor:Lerp(Color3.new(0, 0, 0), 0.18), currentColor:Lerp(Color3.new(1, 1, 1), 0.16), 92)
                local colorButtonScale = Ui.EnsureScale(ColorButton, 1)
                if colorButtonGradient then
                    colorButtonGradient.Offset = Vector2.new(0, 0.45)
                end

                local TopButton = Instance.new("TextButton")
                TopButton.Parent = TopPart
                TopButton.BackgroundTransparency = 1
                TopButton.Size = UDim2.new(1, 0, 1, 0)
                TopButton.Text = ""
                TopButton.AutoButtonColor = false
                TopButton.ZIndex = 12

                local PickerPanel = Instance.new("Frame")
                PickerPanel.Parent = PickerFrame
                PickerPanel.BackgroundColor3 = UiPanelBlack:Lerp(UiAccentDeep, 0.1)
                PickerPanel.Position = UDim2.new(0, 10, 0, 40)
                PickerPanel.Size = UDim2.new(1, -20, 0, 158)
                PickerPanel.Visible = false
                PickerPanel.ZIndex = 15
                PickerPanel.ClipsDescendants = true
                Ui.ApplyCorner(PickerPanel, Theme.Corner.Small)
                local pickerStroke = Ui.ApplyStroke(PickerPanel, UiBorderSoft, 0.48, 1)
                local pickerGradient = Ui.ApplyGradient(PickerPanel, UiPanelBlack:Lerp(UiAccentDeep, 0.08), UiFieldBg:Lerp(UiAccentSoft, 0.04), 90)
                local pickerStrokeGradient = pickerStroke and Ui.ApplyGradient(pickerStroke, UiAccentMid, UiBorderSoft, 110)
                if pickerGradient then
                    pickerGradient.Offset = Vector2.new(0, 0.55)
                end

                local SVBox = Instance.new("Frame")
                SVBox.Parent = PickerPanel
                SVBox.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
                SVBox.BorderSizePixel = 0
                SVBox.Position = UDim2.new(0, 10, 0, 12)
                SVBox.Size = UDim2.new(1, -66, 0, 108)
                SVBox.ClipsDescendants = true
                SVBox.ZIndex = 16
                Ui.ApplyCorner(SVBox, Theme.Corner.Small)
                Ui.ApplyStroke(SVBox, UiBorderSoft, 0.34, 1)

                local WhiteLayer = Instance.new("Frame")
                WhiteLayer.Parent = SVBox
                WhiteLayer.BackgroundColor3 = Color3.new(1, 1, 1)
                WhiteLayer.BorderSizePixel = 0
                WhiteLayer.Size = UDim2.fromScale(1, 1)
                WhiteLayer.ZIndex = 17
                local WhiteGradient = Instance.new("UIGradient")
                WhiteGradient.Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 0),
                    NumberSequenceKeypoint.new(1, 1)
                })
                WhiteGradient.Parent = WhiteLayer

                local BlackLayer = Instance.new("Frame")
                BlackLayer.Parent = SVBox
                BlackLayer.BackgroundColor3 = Color3.new(0, 0, 0)
                BlackLayer.BorderSizePixel = 0
                BlackLayer.Size = UDim2.fromScale(1, 1)
                BlackLayer.ZIndex = 18
                local BlackGradient = Instance.new("UIGradient")
                BlackGradient.Rotation = 90
                BlackGradient.Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 1),
                    NumberSequenceKeypoint.new(1, 0)
                })
                BlackGradient.Parent = BlackLayer

                local SVSelector = Instance.new("Frame")
                SVSelector.Parent = SVBox
                SVSelector.AnchorPoint = Vector2.new(0.5, 0.5)
                SVSelector.BackgroundColor3 = Color3.new(1, 1, 1)
                SVSelector.BackgroundTransparency = 0.82
                SVSelector.BorderSizePixel = 0
                SVSelector.Size = UDim2.fromOffset(10, 10)
                SVSelector.ZIndex = 20
                Ui.ApplyCorner(SVSelector, Theme.Corner.Pill)
                Ui.ApplyStroke(SVSelector, Color3.new(1, 1, 1), 0.06, 1)
                local SelectorInner = Instance.new("Frame")
                SelectorInner.Parent = SVSelector
                SelectorInner.BackgroundTransparency = 1
                SelectorInner.Position = UDim2.fromOffset(2, 2)
                SelectorInner.Size = UDim2.new(1, -4, 1, -4)
                SelectorInner.ZIndex = 21
                Ui.ApplyCorner(SelectorInner, Theme.Corner.Pill)
                Ui.ApplyStroke(SelectorInner, Color3.new(0, 0, 0), 0.18, 1)

                local SVDrag = Instance.new("TextButton")
                SVDrag.Parent = SVBox
                SVDrag.BackgroundTransparency = 1
                SVDrag.Size = UDim2.fromScale(1, 1)
                SVDrag.Text = ""
                SVDrag.AutoButtonColor = false
                SVDrag.ZIndex = 22

                local HueBar = Instance.new("Frame")
                HueBar.Parent = PickerPanel
                HueBar.BackgroundColor3 = Color3.new(1, 1, 1)
                HueBar.BorderSizePixel = 0
                HueBar.Position = UDim2.new(1, -30, 0, 12)
                HueBar.Size = UDim2.new(0, 18, 0, 108)
                HueBar.ClipsDescendants = true
                HueBar.ZIndex = 16
                Ui.ApplyCorner(HueBar, Theme.Corner.Small)
                Ui.ApplyStroke(HueBar, UiBorderSoft, 0.34, 1)
                local HueGradient = Instance.new("UIGradient")
                HueGradient.Rotation = 90
                HueGradient.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 0)),
                    ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
                    ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
                    ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0, 255, 255)),
                    ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
                    ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
                    ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 0))
                })
                HueGradient.Parent = HueBar

                local HueSelector = Instance.new("Frame")
                HueSelector.Parent = PickerPanel
                HueSelector.BackgroundColor3 = Color3.new(1, 1, 1)
                HueSelector.BorderSizePixel = 0
                HueSelector.Size = UDim2.fromOffset(24, 3)
                HueSelector.ZIndex = 19
                Ui.ApplyCorner(HueSelector, Theme.Corner.Pill)
                Ui.ApplyStroke(HueSelector, Color3.new(0, 0, 0), 0.26, 1)

                local HueDrag = Instance.new("TextButton")
                HueDrag.Parent = HueBar
                HueDrag.BackgroundTransparency = 1
                HueDrag.Size = UDim2.fromScale(1, 1)
                HueDrag.Text = ""
                HueDrag.AutoButtonColor = false
                HueDrag.ZIndex = 22

                local Preview = Instance.new("Frame")
                Preview.Parent = PickerPanel
                Preview.BackgroundColor3 = currentColor
                Preview.BorderSizePixel = 0
                Preview.Position = UDim2.new(0, 10, 0, 130)
                Preview.Size = UDim2.new(0, 44, 0, 20)
                Preview.ZIndex = 16
                Ui.ApplyCorner(Preview, Theme.Corner.Small)
                Ui.ApplyStroke(Preview, UiBorderSoft, 0.38, 1)

                local PanelHex = Instance.new("TextLabel")
                PanelHex.Parent = PickerPanel
                PanelHex.BackgroundTransparency = 1
                PanelHex.Position = UDim2.new(0, 64, 0, 124)
                PanelHex.Size = UDim2.new(1, -78, 0, 15)
                PanelHex.Font = Enum.Font.GothamSemibold
                PanelHex.TextSize = 12
                PanelHex.TextColor3 = UiTextBright
                PanelHex.TextXAlignment = Enum.TextXAlignment.Left
                PanelHex.Text = toHex(currentColor)
                PanelHex.ZIndex = 16

                local RgbLabel = Instance.new("TextLabel")
                RgbLabel.Parent = PickerPanel
                RgbLabel.BackgroundTransparency = 1
                RgbLabel.Position = UDim2.new(0, 64, 0, 140)
                RgbLabel.Size = UDim2.new(1, -78, 0, 13)
                RgbLabel.Font = Enum.Font.Gotham
                RgbLabel.TextSize = 11
                RgbLabel.TextColor3 = UiTextSoft
                RgbLabel.TextXAlignment = Enum.TextXAlignment.Left
                RgbLabel.Text = toRgbText(currentColor)
                RgbLabel.ZIndex = 16

                local function refreshVisuals()
                    currentColor = Color3.fromHSV(hue, saturation, value)
                    local hueColor = Color3.fromHSV(hue, 1, 1)
                    local hex = toHex(currentColor)

                    SVBox.BackgroundColor3 = hueColor
                    SVSelector.Position = UDim2.new(saturation, 0, 1 - value, 0)
                    HueSelector.Position = UDim2.new(1, -33, 0, 12 + (hue * 108) - 1)

                    ColorButton.BackgroundColor3 = currentColor
                    Preview.BackgroundColor3 = currentColor
                    HexLabel.Text = hex
                    PanelHex.Text = hex
                    RgbLabel.Text = toRgbText(currentColor)

                    if colorButtonGradient then
                        colorButtonGradient.Color = ColorSequence.new({
                            ColorSequenceKeypoint.new(0, currentColor:Lerp(Color3.new(0, 0, 0), 0.18)),
                            ColorSequenceKeypoint.new(1, currentColor:Lerp(Color3.new(1, 1, 1), 0.16))
                        })
                    end
                end

                local function updateColorAndCallback(silent)
                    refreshVisuals()
                    if call and not silent then
                        pcall(call, currentColor)
                    end
                end

                local function applyColor(valueToApply, silent)
                    local color = resolveColor(valueToApply)
                    hue, saturation, value = colorToHsv(color)
                    updateColorAndCallback(silent)
                end

                local function isBeginInput(input)
                    return input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch
                end

                local function isMoveInput(input)
                    return input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch
                end

                local draggingSv = false
                local draggingHue = false

                local function updateSvFromInput(input)
                    if SVBox.AbsoluteSize.X <= 0 or SVBox.AbsoluteSize.Y <= 0 then return end
                    local relX = input.Position.X - SVBox.AbsolutePosition.X
                    local relY = input.Position.Y - SVBox.AbsolutePosition.Y
                    saturation = math.clamp(relX / SVBox.AbsoluteSize.X, 0, 1)
                    value = 1 - math.clamp(relY / SVBox.AbsoluteSize.Y, 0, 1)
                    updateColorAndCallback(false)
                end

                local function updateHueFromInput(input)
                    if HueBar.AbsoluteSize.Y <= 0 then return end
                    local relY = input.Position.Y - HueBar.AbsolutePosition.Y
                    hue = math.clamp(relY / HueBar.AbsoluteSize.Y, 0, 1)
                    updateColorAndCallback(false)
                end

                table.insert(State.UnloadConnections, SVDrag.InputBegan:Connect(function(input)
                    if isBeginInput(input) then
                        draggingSv = true
                        updateSvFromInput(input)
                    end
                end))
                table.insert(State.UnloadConnections, HueDrag.InputBegan:Connect(function(input)
                    if isBeginInput(input) then
                        draggingHue = true
                        updateHueFromInput(input)
                    end
                end))
                table.insert(State.UnloadConnections, Services.UserInputService.InputChanged:Connect(function(input)
                    if not isMoveInput(input) then return end
                    if draggingSv then
                        updateSvFromInput(input)
                    elseif draggingHue then
                        updateHueFromInput(input)
                    end
                end))
                table.insert(State.UnloadConnections, Services.UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        draggingSv = false
                        draggingHue = false
                    end
                end))

                applyColor(default, true)

                local isExpanded = false

                local function refreshLayoutAfterToggle()
                    task.delay(0.21, function()
                        if Module.SettingsOpen then
                            SyncSettingsFrame(false)
                            UpdateSize()
                        end
                    end)
                end

                local function Collapse()
                    isExpanded = false
                    if ActiveColorPicker and ActiveColorPicker.frame == PickerFrame then ActiveColorPicker = nil end
                    PickerPanel.Visible = false
                    Ui.Tween(PickerFrame, {Size = UDim2.new(1, 0, 0, 36)}, 0.2)
                    if pickerStroke then
                        pickerStroke.Color = UiBorderSoft
                        Ui.Tween(pickerStroke, {Transparency = 0.48}, Theme.Anim.Fast)
                    end
                    if pickerGradient then Ui.Tween(pickerGradient, {Offset = Vector2.new(0, 0.55), Rotation = 90}, Theme.Anim.Normal) end
                    if pickerStrokeGradient then Ui.Tween(pickerStrokeGradient, {Offset = Vector2.new(0, 0.55), Rotation = 110}, Theme.Anim.Normal) end
                    refreshLayoutAfterToggle()
                end

                local function Expand()
                    isExpanded = true
                    if ActiveColorPicker and ActiveColorPicker.frame ~= PickerFrame and ActiveColorPicker.collapse then
                        pcall(ActiveColorPicker.collapse)
                    end
                    ActiveColorPicker = { frame = PickerFrame, collapse = Collapse }
                    PickerPanel.Visible = true
                    Ui.Tween(PickerFrame, {Size = UDim2.new(1, 0, 0, 204)}, 0.2)
                    if pickerStroke then
                        Ui.Tween(pickerStroke, {Transparency = 0.26, Color = Settings.Colors.Accent}, Theme.Anim.Fast)
                    end
                    if pickerGradient then Ui.Tween(pickerGradient, {Offset = Vector2.new(0, 0.18), Rotation = 102}, Theme.Anim.Normal) end
                    if pickerStrokeGradient then Ui.Tween(pickerStrokeGradient, {Offset = Vector2.new(0, 0.22), Rotation = 126}, Theme.Anim.Normal) end
                    refreshVisuals()
                    refreshLayoutAfterToggle()
                end

                table.insert(State.UnloadConnections, TopButton.MouseEnter:Connect(function()
                    Ui.Tween(Label, {TextColor3 = UiTextBright}, Theme.Anim.Fast)
                    Ui.Tween(HexLabel, {TextColor3 = UiTextBright}, Theme.Anim.Fast)
                    if colorButtonStroke then Ui.Tween(colorButtonStroke, {Transparency = 0.25, Color = Settings.Colors.AccentSoft}, Theme.Anim.Fast) end
                    if colorButtonGradient then Ui.Tween(colorButtonGradient, {Offset = Vector2.new(0, 0.18), Rotation = 112}, Theme.Anim.Normal) end
                end))
                table.insert(State.UnloadConnections, TopButton.MouseLeave:Connect(function()
                    Ui.Tween(Label, {TextColor3 = UiTextBright}, Theme.Anim.Fast)
                    Ui.Tween(HexLabel, {TextColor3 = UiTextSoft}, Theme.Anim.Fast)
                    if colorButtonStroke then Ui.Tween(colorButtonStroke, {Transparency = 0.44, Color = UiBorderSoft}, Theme.Anim.Fast) end
                    if colorButtonGradient then Ui.Tween(colorButtonGradient, {Offset = Vector2.new(0, 0.45), Rotation = 92}, Theme.Anim.Normal) end
                end))
                table.insert(State.UnloadConnections, TopButton.MouseButton1Click:Connect(function()
                    Ui.PulseScale(colorButtonScale, 0.92, 0.05, 0.14)
                    if isExpanded then Collapse() else Expand() end
                end))

                Module:RegisterControl({
                    Key = text,
                    Type = "Color",
                    Getter = getter,
                    GetValue = function() return Color3.fromHSV(hue, saturation, value) end,
                    SetValue = function(_, valueToApply, silent) applyColor(valueToApply, silent) end,
                })
            end

            function Module:AddColorPalette(colorPairs, callback)
                Module.HasSettings = true
                Dots.Visible = true

                local cont = Instance.new("Frame", SettingsFrame)
                cont.BackgroundTransparency = 1
                cont.Size = UDim2.new(1, 0, 0, 60)

                local grid = Instance.new("UIGridLayout", cont)
                grid.CellSize = UDim2.new(0, 22, 0, 22)
                grid.CellPadding = UDim2.new(0, 5, 0, 5)
                grid.HorizontalAlignment = Enum.HorizontalAlignment.Center

                for _, pair in ipairs(colorPairs) do
                    local btn = Instance.new("TextButton", cont)
                    btn.BackgroundColor3 = pair[1]
                    btn.Text = ""
                    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
                    local pStroke = Ui.ApplyStroke(btn, UiBorderSoft, 0.62, 1)
                    local pGradient = Ui.ApplyGradient(btn, pair[1]:Lerp(Color3.new(0, 0, 0), 0.2), pair[2] or pair[1]:Lerp(Color3.new(1, 1, 1), 0.2), 88)
                    local pScale = Ui.EnsureScale(btn, 1)
                    if pGradient then
                        pGradient.Offset = Vector2.new(0, 0.5)
                    end
                    table.insert(State.UnloadConnections, btn.MouseEnter:Connect(function()
                        if pStroke then Ui.Tween(pStroke, {Transparency = 0.45}, Theme.Anim.Fast) end
                        if pGradient then Ui.Tween(pGradient, {Offset = Vector2.new(0, 0.2), Rotation = 110}, Theme.Anim.Normal) end
                    end))
                    table.insert(State.UnloadConnections, btn.MouseLeave:Connect(function()
                        if pStroke then Ui.Tween(pStroke, {Transparency = 0.72}, Theme.Anim.Fast) end
                        if pGradient then Ui.Tween(pGradient, {Offset = Vector2.new(0, 0.5), Rotation = 88}, Theme.Anim.Normal) end
                    end))
                    table.insert(State.UnloadConnections, btn.MouseButton1Click:Connect(function()
                        Ui.PulseScale(pScale, 0.88, 0.05, 0.13)
                        callback(pair[1], pair[2])
                    end))
                end
            end

            function Module:AddBind(text, default, call, getter, options)
                Module.HasSettings = true
                Dots.Visible = true
                local allowMouseButtons = type(options) == "table" and options.AllowMouseButtons == true

                local function isAllowedMouseInputType(inputType)
                    return inputType == Enum.UserInputType.MouseButton1
                        or inputType == Enum.UserInputType.MouseButton2
                        or inputType == Enum.UserInputType.MouseButton3
                end

                local Frame = Instance.new("Frame")
                Frame.Parent = SettingsFrame
                Frame.BackgroundTransparency = 1
                Frame.Size = UDim2.new(1, 0, 0, 38)
                Frame.ZIndex = 8

                local BindBg = Instance.new("Frame")
                BindBg.Parent = Frame
                BindBg.BackgroundColor3 = UiPanelBlack:Lerp(UiAccentDeep, 0.12)
                BindBg.BackgroundTransparency = 0.0
                BindBg.Size = UDim2.new(1, -16, 1, -8)
                BindBg.Position = UDim2.new(0, 8, 0, 4)
                BindBg.ZIndex = 8
                Ui.ApplyCorner(BindBg, Theme.Corner.Small)
                local bindStroke = Ui.ApplyStroke(BindBg, UiAccentMid, 0.48, 1)
                local bindGradient = Ui.ApplyGradient(BindBg, UiPanelBlack:Lerp(UiAccentDeep, 0.1), UiButtonBg:Lerp(UiAccentSoft, 0.06), 88)
                local bindStrokeGradient = bindStroke and Ui.ApplyGradient(bindStroke, UiAccentMid, UiAccentSoft, 108)
                local bindScale = Ui.EnsureScale(BindBg, 1)
                if bindGradient then
                    bindGradient.Offset = Vector2.new(0, 0.55)
                end

                local BindStrip = Instance.new("Frame")
                BindStrip.Parent = BindBg
                BindStrip.BackgroundColor3 = UiAccentSoft
                BindStrip.BackgroundTransparency = 0.62
                BindStrip.BorderSizePixel = 0
                BindStrip.Position = UDim2.new(0, 7, 0, 7)
                BindStrip.Size = UDim2.new(0, 2, 1, -14)
                BindStrip.ZIndex = 9
                Ui.ApplyCorner(BindStrip, Theme.Corner.Pill)

                local Label = Instance.new("TextLabel")
                Label.Parent = Frame
                Label.Text = text
                Label.TextColor3 = UiTextBright
                Label.Font = Enum.Font.GothamSemibold
                Label.TextSize = 14
                Label.BackgroundTransparency = 1
                Label.Position = UDim2.new(0, 22, 0, 0)
                Label.Size = UDim2.new(1, -100, 1, 0)
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.ZIndex = 9
                MarkReadableButton(Label, UiTextBright)

                local KeyBadge = Instance.new("Frame")
                KeyBadge.Parent = Frame
                KeyBadge.BackgroundColor3 = UiAccentDeep:Lerp(UiPanelBlack, 0.18)
                KeyBadge.BackgroundTransparency = 0.04
                KeyBadge.BorderSizePixel = 0
                KeyBadge.Position = UDim2.new(1, -86, 0.5, -10)
                KeyBadge.Size = UDim2.new(0, 74, 0, 20)
                KeyBadge.ZIndex = 9
                Ui.ApplyCorner(KeyBadge, Theme.Corner.Small)
                local keyBadgeStroke = Ui.ApplyStroke(KeyBadge, UiAccentSoft, 0.44, 1)

                local KeyLabel = Instance.new("TextLabel")
                KeyLabel.Parent = KeyBadge
                KeyLabel.Text = default and ("["..default.Name.."]") or "[None]"
                KeyLabel.TextColor3 = Settings.Colors.TextWhite
                KeyLabel.Font = Enum.Font.GothamSemibold
                KeyLabel.TextSize = 12
                KeyLabel.BackgroundTransparency = 1
                KeyLabel.Position = UDim2.new(0, 0, 0, 0)
                KeyLabel.Size = UDim2.new(1, 0, 1, 0)
                KeyLabel.TextXAlignment = Enum.TextXAlignment.Center
                KeyLabel.TextTruncate = Enum.TextTruncate.AtEnd
                KeyLabel.ZIndex = 10
                MarkReadableButton(KeyLabel, UiTextBright)

                local currentKey = default
                local function applyKey(keyValue, silent)
                    local resolved = keyValue
                    if typeof(resolved) ~= "EnumItem" then
                        local rawName = nil
                        if type(resolved) == "string" then
                            rawName = resolved
                        elseif type(resolved) == "table" and type(resolved.name) == "string" then
                            rawName = resolved.name
                        end
                        if rawName then
                            resolved = resolveEnumName(rawName, Enum.KeyCode)
                            if not resolved and allowMouseButtons then
                                resolved = resolveEnumName(rawName, Enum.UserInputType)
                            end
                        end
                    end
                    if typeof(resolved) == "EnumItem" then
                        if resolved.EnumType == Enum.UserInputType then
                            if not allowMouseButtons or not isAllowedMouseInputType(resolved) then
                                resolved = nil
                            end
                        elseif resolved.EnumType ~= Enum.KeyCode then
                            resolved = nil
                        end
                    end
                    currentKey = resolved
                    KeyLabel.Text = currentKey and ("["..currentKey.Name.."]") or "[None]"
                    if call and not silent then call(currentKey) end
                end
                if call then call(currentKey) end

                local button = Instance.new("TextButton", Frame)
                button.BackgroundTransparency = 1
                button.Size = UDim2.new(1,0,1,0)
                button.Text = ""
                button.ZIndex = 10

                local isBinding = false
                table.insert(State.UnloadConnections, button.MouseEnter:Connect(function()
                    if isBinding then return end
                    Ui.Tween(BindBg, {BackgroundTransparency = 0.0, BackgroundColor3 = UiPanelBlack:Lerp(UiAccentDeep, 0.2)}, Theme.Anim.Fast)
                    Ui.Tween(Label, {TextColor3 = UiTextBright}, Theme.Anim.Fast)
                    if bindStroke then Ui.Tween(bindStroke, {Transparency = 0.22, Color = UiAccentMid}, Theme.Anim.Fast) end
                    if keyBadgeStroke then Ui.Tween(keyBadgeStroke, {Transparency = 0.24, Color = UiAccentSoft}, Theme.Anim.Fast) end
                    Ui.Tween(BindStrip, {BackgroundTransparency = 0.28}, Theme.Anim.Fast)
                    if bindGradient then Ui.Tween(bindGradient, {Offset = Vector2.new(0, 0.2), Rotation = 98}, Theme.Anim.Normal) end
                    if bindStrokeGradient then Ui.Tween(bindStrokeGradient, {Offset = Vector2.new(0, 0.2), Rotation = 114}, Theme.Anim.Normal) end
                end))
                table.insert(State.UnloadConnections, button.MouseLeave:Connect(function()
                    if isBinding then return end
                    Ui.Tween(BindBg, {BackgroundTransparency = 0.0, BackgroundColor3 = UiPanelBlack:Lerp(UiAccentDeep, 0.12)}, Theme.Anim.Fast)
                    Ui.Tween(Label, {TextColor3 = UiTextBright}, Theme.Anim.Fast)
                    if bindStroke then Ui.Tween(bindStroke, {Transparency = 0.48, Color = UiAccentMid}, Theme.Anim.Fast) end
                    if keyBadgeStroke then Ui.Tween(keyBadgeStroke, {Transparency = 0.44, Color = UiAccentSoft}, Theme.Anim.Fast) end
                    Ui.Tween(BindStrip, {BackgroundTransparency = 0.62}, Theme.Anim.Fast)
                    if bindGradient then Ui.Tween(bindGradient, {Offset = Vector2.new(0, 0.55), Rotation = 74}, Theme.Anim.Normal) end
                    if bindStrokeGradient then Ui.Tween(bindStrokeGradient, {Offset = Vector2.new(0, 0.5), Rotation = 96}, Theme.Anim.Normal) end
                end))
                table.insert(State.UnloadConnections, button.MouseButton1Click:Connect(function()
                    if isBinding then return end
                    isBinding = true
                    Ui.PulseScale(bindScale, 0.94, 0.06, 0.16)
                    local oldText = KeyLabel.Text
                    KeyLabel.Text = "Press..."
                    KeyLabel.TextColor3 = Settings.Colors.Accent
                    Ui.Tween(BindBg, {BackgroundTransparency = 0.0, BackgroundColor3 = UiPanelBlack:Lerp(UiAccentDeep, 0.24)}, Theme.Anim.Fast)
                    Ui.Tween(KeyBadge, {BackgroundColor3 = UiAccentDeep}, Theme.Anim.Fast)
                    if bindStroke then
                        bindStroke.Color = Settings.Colors.Accent
                        Ui.Tween(bindStroke, {Transparency = 0.45}, Theme.Anim.Fast)
                    end
                    if keyBadgeStroke then
                        keyBadgeStroke.Color = UiAccentSoft
                        Ui.Tween(keyBadgeStroke, {Transparency = 0.18}, Theme.Anim.Fast)
                    end
                    if bindGradient then Ui.Tween(bindGradient, {Offset = Vector2.new(0, 0.1), Rotation = 116}, Theme.Anim.Normal) end

                    local conn
                    conn = Services.UserInputService.InputBegan:Connect(function(input)
                        local selectedInput = nil
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            local key = input.KeyCode
                            if key == KEY_ESCAPE then
                                KeyLabel.Text = oldText
                            elseif key == KEY_DELETE then
                                applyKey(nil, false)
                            else
                                selectedInput = key
                            end
                        elseif allowMouseButtons and isAllowedMouseInputType(input.UserInputType) then
                            selectedInput = input.UserInputType
                        else
                            return
                        end

                        if selectedInput then
                            applyKey(selectedInput, false)
                        end
                        KeyLabel.TextColor3 = Settings.Colors.TextWhite
                        isBinding = false
                        Ui.Tween(BindBg, {BackgroundTransparency = 0.0, BackgroundColor3 = UiPanelBlack:Lerp(UiAccentDeep, 0.12)}, Theme.Anim.Fast)
                        Ui.Tween(KeyBadge, {BackgroundColor3 = UiAccentDeep:Lerp(UiPanelBlack, 0.18)}, Theme.Anim.Fast)
                        if bindStroke then
                            bindStroke.Color = UiAccentMid
                            Ui.Tween(bindStroke, {Transparency = 0.48}, Theme.Anim.Fast)
                        end
                        if keyBadgeStroke then
                            keyBadgeStroke.Color = UiAccentSoft
                            Ui.Tween(keyBadgeStroke, {Transparency = 0.44}, Theme.Anim.Fast)
                        end
                        if bindGradient then Ui.Tween(bindGradient, {Offset = Vector2.new(0, 0.55), Rotation = 74}, Theme.Anim.Normal) end
                        conn:Disconnect()
                    end)
                end))
                Module:RegisterControl({
                    Key = text,
                    Type = "Bind",
                    Getter = getter,
                    GetValue = function() return currentKey end,
                    SetValue = function(_, value, silent) applyKey(value, silent) end,
                })
            end

            UpdateSize()
            if Window.ApplySearch then
                Window:ApplySearch(Library and Library.SearchQuery or "")
            end
            return Module
        end
        return Window
    end
    return {
        Library = Library,
        ResolveColors = ResolveColors,
        ghostBox = ghostBox,
        ScreenGui = ScreenGui,
        BlurEffect = BlurEffect,
        MenuDimOverlay = MenuDimOverlay,
        ghostPart = ghostPart,
        targetOutlineFolder = targetOutlineFolder,
        globalOutlineFolder = globalOutlineFolder,
        espImg = espImg,
        hudFrame = hudFrame,
        hudGradient = hudGradient,
        barGradient = barGradient,
        CategoryGradient = CategoryGradient,
        CategoryStrokeGradient = CategoryStrokeGradient,
        RightPanelGradient = RightPanelGradient,
        RightStrokeGradient = RightStrokeGradient,
        UpdateESPColor = UpdateESPColor,
        UpdateESPTexture = UpdateESPTexture,
        TargetESPTextureNames = TargetESPTextureNames,
        UpdateHUDColor = UpdateHUDColor,
        NormalizeUiVisualState = NormalizeUiVisualState,
        UpdateWatermarkVisibility = UpdateWatermarkVisibility,
        ApplyUILayout = ApplyUILayout,
        ResetUiColorTokens = Ui.ResetUiColorTokens,
        GetColorLuma = Ui.GetColorLuma,
        EnsureThemeContrast = Ui.EnsureThemeContrast,
        ComputeUILayout = Ui.ComputeUILayout,
        Tween = Ui.Tween,
        ApplyCorner = Ui.ApplyCorner,
        RightAddButton = RightAddButton,
        RightAddTextbox = RightAddTextbox,
        RightConfigsBody = RightConfigsBody,
        RightListsBody = RightListsBody,
        ApplyWatermarkSettings = ApplyWatermarkSettings,
        FOVCircle = FOVCircle,
    }
end
