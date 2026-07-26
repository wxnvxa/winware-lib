
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
