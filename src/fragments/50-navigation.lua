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
