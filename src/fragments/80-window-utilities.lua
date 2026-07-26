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
