
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
