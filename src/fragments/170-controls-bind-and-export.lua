
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
