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
