
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
