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
