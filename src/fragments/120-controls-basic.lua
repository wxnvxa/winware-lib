
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
