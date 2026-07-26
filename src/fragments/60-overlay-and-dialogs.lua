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
