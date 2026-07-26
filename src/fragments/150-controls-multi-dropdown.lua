
            function Module:AddMultiDropdown(text, options, default, call, getter)
                Module.HasSettings = true
                Dots.Visible = true
                options = type(options) == "table" and options or {}

                local DropFrame = Instance.new("Frame")
                DropFrame.Parent = SettingsFrame
                DropFrame.BackgroundTransparency = 1
                local collapsedHeight = 58
                DropFrame.Size = UDim2.new(1, 0, 0, collapsedHeight)
                DropFrame.ZIndex = 8

                local Label = Instance.new("TextLabel")
                Label.Parent = DropFrame
                Label.Text = text
                Label.TextColor3 = UiTextBright
                Label.Font = Enum.Font.Gotham
                Label.TextSize = 15
                Label.BackgroundTransparency = 1
                Label.Position = UDim2.new(0, 12, 0, 0)
                Label.Size = UDim2.new(1, -24, 0, 20)
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.ZIndex = 9

                local Button = Instance.new("TextButton")
                Button.Parent = DropFrame
                Button.BackgroundColor3 = UiPanelBlack:Lerp(UiInputDark, 0.6)
                Button.BackgroundTransparency = 0.0
                Button.Size = UDim2.new(1, -24, 0, 34)
                Button.Position = UDim2.new(0, 12, 0, 22)
                Button.Text = ""
                Button.ZIndex = 9
                Button.AutoButtonColor = false

                Ui.ApplyCorner(Button, Theme.Corner.Small)
                local buttonStroke = Ui.ApplyStroke(Button, UiAccentMid, 0.46, 1)
                local DropGradient = Ui.ApplyGradient(Button, UiPanelBlack:Lerp(UiInputDark, 0.56), UiDropdownOptionHover:Lerp(UiPanelBlack, 0.35), 90)
                if DropGradient then
                    DropGradient.Offset = Vector2.new(0, 0.55)
                end

                local ValueLabel = Instance.new("TextLabel")
                ValueLabel.Parent = Button
                ValueLabel.BackgroundTransparency = 1
                ValueLabel.Position = UDim2.new(0, 12, 0, 0)
                ValueLabel.Size = UDim2.new(1, -50, 1, 0)
                ValueLabel.Font = Enum.Font.GothamSemibold
                ValueLabel.TextSize = 15
                ValueLabel.TextColor3 = UiTextBright
                ValueLabel.TextXAlignment = Enum.TextXAlignment.Left
                ValueLabel.TextYAlignment = Enum.TextYAlignment.Center
                ValueLabel.TextTruncate = Enum.TextTruncate.AtEnd
                ValueLabel.ZIndex = 10
                MarkReadableButton(ValueLabel, UiTextBright)

                local ArrowSlot = Instance.new("Frame")
                ArrowSlot.Parent = Button
                ArrowSlot.BackgroundColor3 = UiDropdownArrowBg
                ArrowSlot.BackgroundTransparency = 0
                ArrowSlot.BorderSizePixel = 0
                ArrowSlot.Position = UDim2.new(1, -31, 0.5, -12)
                ArrowSlot.Size = UDim2.new(0, 24, 0, 24)
                ArrowSlot.ZIndex = 10
                Ui.ApplyCorner(ArrowSlot, Theme.Corner.Pill)
                local arrowSlotStroke = Ui.ApplyStroke(ArrowSlot, UiDropdownArrowBorder, 0.22, 1)

                local Arrow = Instance.new("TextLabel")
                Arrow.Parent = ArrowSlot
                Arrow.BackgroundTransparency = 1
                Arrow.Size = UDim2.new(1, 0, 1, 0)
                Arrow.Position = UDim2.new(0, 0, 0, 0)
                Arrow.Font = Enum.Font.GothamBold
                Arrow.Text = ">"
                Arrow.TextSize = 18
                Arrow.TextColor3 = UiTextBright
                Arrow.TextXAlignment = Enum.TextXAlignment.Center
                Arrow.TextYAlignment = Enum.TextYAlignment.Center
                Arrow.ZIndex = 11

                local ListFrame = Instance.new("Frame")
                ListFrame.Parent = DropFrame
                ListFrame.BackgroundColor3 = UiPanelBlack:Lerp(UiInputDark, 0.54)
                ListFrame.BackgroundTransparency = 0.0
                ListFrame.Position = UDim2.new(0, 12, 0, collapsedHeight)
                ListFrame.Size = UDim2.new(1, -24, 0, 0)
                ListFrame.Visible = false
                ListFrame.ZIndex = 15
                ListFrame.ClipsDescendants = true
                Ui.ApplyCorner(ListFrame, Theme.Corner.Small)
                local listStroke = Ui.ApplyStroke(ListFrame, UiAccentMid, 0.44, 1)
                local ListGradient = Ui.ApplyGradient(ListFrame, UiPanelBlack:Lerp(UiInputDark, 0.52), UiButtonHover:Lerp(UiPanelBlack, 0.25), 88)

                local LList = Instance.new("UIListLayout")
                LList.Parent = ListFrame
                LList.SortOrder = Enum.SortOrder.LayoutOrder
                LList.Padding = UDim.new(0, 2)
                local ListPad = Instance.new("UIPadding")
                ListPad.Parent = ListFrame
                ListPad.PaddingTop = UDim.new(0, 6)
                ListPad.PaddingBottom = UDim.new(0, 6)
                ListPad.PaddingLeft = UDim.new(0, 6)
                ListPad.PaddingRight = UDim.new(0, 6)

                local normalizedOptions = {}
                for _, opt in ipairs(options) do
                    if type(opt) == "table" then
                        table.insert(normalizedOptions, {
                            Label = tostring(opt.Label or opt.Name or opt.Value or ""),
                            Value = tostring(opt.Value or opt.Name or opt.Label or ""),
                        })
                    else
                        table.insert(normalizedOptions, {Label = tostring(opt), Value = tostring(opt)})
                    end
                end
                local validOptionValues = {}
                for _, opt in ipairs(normalizedOptions) do
                    validOptionValues[opt.Value] = true
                end

                local selected = {}
                local optionButtons = {}
                local isDropped = false

                local function normalizeSelection(value)
                    local result = {}
                    if type(value) ~= "table" then return result end
                    for key, enabled in pairs(value) do
                        local normalizedKey = tostring(key)
                        if type(key) == "number" then
                            local optionValue = tostring(enabled)
                            if validOptionValues[optionValue] then
                                result[optionValue] = true
                            end
                        elseif enabled and validOptionValues[normalizedKey] then
                            result[normalizedKey] = true
                        end
                    end
                    return result
                end

                local refreshOptions
                local function selectedSummary()
                    local labels = {}
                    for _, opt in ipairs(normalizedOptions) do
                        if selected[opt.Value] then
                            table.insert(labels, opt.Label)
                        end
                    end
                    return #labels > 0 and table.concat(labels, ", ") or "None"
                end

                local function emitValue()
                    local copy = {}
                    for _, opt in ipairs(normalizedOptions) do
                        copy[opt.Value] = selected[opt.Value] == true
                    end
                    return copy
                end

                local function applyValue(nextValue, silent)
                    selected = normalizeSelection(nextValue)
                    ValueLabel.Text = selectedSummary()
                    if refreshOptions then refreshOptions() end
                    if call and not silent then call(emitValue()) end
                end

                refreshOptions = function()
                    for _, entry in ipairs(optionButtons) do
                        local active = selected[entry.value] == true
                        entry.button.BackgroundColor3 = active and UiDropdownOptionActive or UiDropdownOptionBg
                        entry.button.BackgroundTransparency = 0.0
                        if entry.labelObject then
                            entry.labelObject.TextColor3 = active and UiDropdownText or UiDropdownMuted
                            entry.labelObject.TextTransparency = 0
                        end
                        if entry.indicator then
                            entry.indicator.BackgroundColor3 = active and UiAccentSoft or UiAccentMid
                            entry.indicator.BackgroundTransparency = active and 0.02 or 0.76
                        end
                        if entry.indicatorStroke then
                            entry.indicatorStroke.Color = active and UiTextBright or UiAccentSoft
                            entry.indicatorStroke.Transparency = active and 0.18 or 0.7
                        end
                        if entry.gradient then
                            entry.gradient.Color = ColorSequence.new(
                                active and UiDropdownOptionActive or UiDropdownOptionBg,
                                active and Settings.Colors.Accent:Lerp(UiDropdownOptionActive, 0.35) or UiDropdownBg
                            )
                            entry.gradient.Offset = Vector2.new(0, active and 0.14 or 0.55)
                            entry.gradient.Rotation = active and 120 or 92
                        end
                    end
                end

                local function listHeight()
                    return math.max(0, LList.AbsoluteContentSize.Y + 12)
                end

                local function setDropped(nextState, silent)
                    if isDropped == nextState then return end
                    isDropped = nextState
                    local height = listHeight()
                    if isDropped then
                        if ActiveDropdown and ActiveDropdown.frame ~= DropFrame and ActiveDropdown.close then
                            pcall(ActiveDropdown.close, true)
                        end
                        ActiveDropdown = {
                            frame = DropFrame,
                            button = Button,
                            list = ListFrame,
                            close = function(silentClose)
                                setDropped(false, silentClose)
                            end
                        }
                        ListFrame.Visible = true
                        Ui.Tween(DropFrame, {Size = UDim2.new(1, 0, 0, collapsedHeight + height + 2)}, 0.2)
                        Ui.Tween(ListFrame, {Size = UDim2.new(1, -24, 0, height)}, 0.2)
                        if buttonStroke then Ui.Tween(buttonStroke, {Transparency = 0.16, Color = Settings.Colors.Accent}, Theme.Anim.Fast) end
                        if listStroke then Ui.Tween(listStroke, {Transparency = 0.24, Color = UiAccentMid}, Theme.Anim.Fast) end
                        Ui.Tween(ArrowSlot, {BackgroundColor3 = UiAccentDeep:Lerp(UiDropdownArrowBg, 0.18)}, Theme.Anim.Fast)
                        if arrowSlotStroke then Ui.Tween(arrowSlotStroke, {Transparency = 0.08, Color = UiAccentSoft}, Theme.Anim.Fast) end
                        Ui.Tween(Arrow, {Rotation = 90, TextColor3 = Settings.Colors.AccentSoft}, Theme.Anim.Fast)
                        if DropGradient then Ui.Tween(DropGradient, {Offset = Vector2.new(0, 0.12), Rotation = 118}, Theme.Anim.Normal) end
                        if ListGradient then Ui.Tween(ListGradient, {Offset = Vector2.new(0, 0.2), Rotation = 106}, Theme.Anim.Normal) end
                    else
                        if ActiveDropdown and ActiveDropdown.frame == DropFrame then
                            ActiveDropdown = nil
                        end
                        Ui.Tween(DropFrame, {Size = UDim2.new(1, 0, 0, collapsedHeight)}, 0.2)
                        Ui.Tween(ListFrame, {Size = UDim2.new(1, -24, 0, 0)}, 0.2)
                        if buttonStroke then Ui.Tween(buttonStroke, {Transparency = 0.46, Color = UiAccentMid}, Theme.Anim.Fast) end
                        if listStroke then Ui.Tween(listStroke, {Transparency = 0.44, Color = UiAccentMid}, Theme.Anim.Fast) end
                        Ui.Tween(ArrowSlot, {BackgroundColor3 = UiDropdownArrowBg}, Theme.Anim.Fast)
                        if arrowSlotStroke then Ui.Tween(arrowSlotStroke, {Transparency = 0.22, Color = UiDropdownArrowBorder}, Theme.Anim.Fast) end
                        Ui.Tween(Arrow, {Rotation = 0, TextColor3 = UiTextBright}, Theme.Anim.Fast)
                        if DropGradient then Ui.Tween(DropGradient, {Offset = Vector2.new(0, 0.55), Rotation = 92}, Theme.Anim.Normal) end
                        if ListGradient then Ui.Tween(ListGradient, {Offset = Vector2.new(0, 0.6), Rotation = 88}, Theme.Anim.Normal) end
                        task.delay(0.2, function() if not isDropped then ListFrame.Visible = false end end)
                    end
                    if not silent then
                        task.delay(0.21, function()
                            SyncSettingsFrame(false)
                            UpdateSize()
                        end)
                    end
                end

                table.insert(State.UnloadConnections, Button.MouseButton1Click:Connect(function()
                    setDropped(not isDropped, false)
                end))
                table.insert(State.UnloadConnections, Button.MouseEnter:Connect(function()
                    if not isDropped then
                        if buttonStroke then Ui.Tween(buttonStroke, {Transparency = 0.2, Color = UiAccentMid}, Theme.Anim.Fast) end
                        Ui.Tween(ArrowSlot, {BackgroundColor3 = UiDropdownArrowHover}, Theme.Anim.Fast)
                        if arrowSlotStroke then Ui.Tween(arrowSlotStroke, {Transparency = 0.14, Color = UiAccentMid}, Theme.Anim.Fast) end
                        Ui.Tween(Arrow, {TextColor3 = UiTextBright}, Theme.Anim.Fast)
                        if DropGradient then Ui.Tween(DropGradient, {Offset = Vector2.new(0, 0.2), Rotation = 108}, Theme.Anim.Normal) end
                    end
                end))
                table.insert(State.UnloadConnections, Button.MouseLeave:Connect(function()
                    if not isDropped then
                        if buttonStroke then Ui.Tween(buttonStroke, {Transparency = 0.46, Color = UiAccentMid}, Theme.Anim.Fast) end
                        Ui.Tween(ArrowSlot, {BackgroundColor3 = UiDropdownArrowBg}, Theme.Anim.Fast)
                        if arrowSlotStroke then Ui.Tween(arrowSlotStroke, {Transparency = 0.22, Color = UiDropdownArrowBorder}, Theme.Anim.Fast) end
                        Ui.Tween(Arrow, {TextColor3 = UiTextBright}, Theme.Anim.Fast)
                        if DropGradient then Ui.Tween(DropGradient, {Offset = Vector2.new(0, 0.55), Rotation = 92}, Theme.Anim.Normal) end
                    end
                end))
                for _, opt in ipairs(normalizedOptions) do
                    local OptBtn = Instance.new("TextButton")
                    OptBtn.Parent = ListFrame
                    OptBtn.BackgroundColor3 = UiDropdownOptionBg
                    OptBtn.BackgroundTransparency = 0.0
                    OptBtn.Size = UDim2.new(1, 0, 0, 30)
                    OptBtn.Text = ""
                    OptBtn.TextColor3 = UiDropdownMuted
                    OptBtn.Font = Enum.Font.GothamSemibold
                    OptBtn.TextSize = 15
                    OptBtn.AutoButtonColor = false
                    OptBtn.ZIndex = 16
                    OptBtn.TextXAlignment = Enum.TextXAlignment.Left
                    Ui.ApplyCorner(OptBtn, Theme.Corner.Small)
                    local optGradient = Ui.ApplyGradient(OptBtn, UiDropdownOptionBg, UiDropdownBg, 90)

                    local Indicator = Instance.new("Frame")
                    Indicator.Parent = OptBtn
                    Indicator.BackgroundColor3 = UiAccentMid
                    Indicator.BackgroundTransparency = 0.76
                    Indicator.BorderSizePixel = 0
                    Indicator.Position = UDim2.new(0, 8, 0.5, -5)
                    Indicator.Size = UDim2.new(0, 10, 0, 10)
                    Indicator.ZIndex = 17
                    Ui.ApplyCorner(Indicator, 3)
                    local indicatorStroke = Ui.ApplyStroke(Indicator, UiAccentSoft, 0.7, 1)

                    local OptionLabel = Instance.new("TextLabel")
                    OptionLabel.Parent = OptBtn
                    OptionLabel.BackgroundTransparency = 1
                    OptionLabel.Position = UDim2.new(0, 26, 0, 0)
                    OptionLabel.Size = UDim2.new(1, -34, 1, 0)
                    OptionLabel.Font = Enum.Font.GothamSemibold
                    OptionLabel.Text = opt.Label
                    OptionLabel.TextColor3 = UiDropdownMuted
                    OptionLabel.TextTransparency = 0
                    OptionLabel.TextSize = 15
                    OptionLabel.TextXAlignment = Enum.TextXAlignment.Left
                    OptionLabel.TextYAlignment = Enum.TextYAlignment.Center
                    OptionLabel.TextTruncate = Enum.TextTruncate.AtEnd
                    OptionLabel.ZIndex = 17

                    table.insert(optionButtons, {
                        button = OptBtn,
                        value = opt.Value,
                        label = opt.Label,
                        gradient = optGradient,
                        labelObject = OptionLabel,
                        indicator = Indicator,
                        indicatorStroke = indicatorStroke,
                    })

                    table.insert(State.UnloadConnections, OptBtn.MouseButton1Click:Connect(function()
                        selected[opt.Value] = not selected[opt.Value]
                        ValueLabel.Text = selectedSummary()
                        refreshOptions()
                        if call then call(emitValue()) end
                    end))
                    table.insert(State.UnloadConnections, OptBtn.MouseEnter:Connect(function()
                        if selected[opt.Value] ~= true then
                            Ui.Tween(OptBtn, {BackgroundColor3 = UiDropdownOptionHover, BackgroundTransparency = 0.0}, Theme.Anim.Fast)
                            Ui.Tween(OptionLabel, {TextColor3 = UiDropdownText, TextTransparency = 0}, Theme.Anim.Fast)
                            Ui.Tween(Indicator, {BackgroundTransparency = 0.34, BackgroundColor3 = UiAccentMid}, Theme.Anim.Fast)
                            if indicatorStroke then Ui.Tween(indicatorStroke, {Transparency = 0.42, Color = UiAccentSoft}, Theme.Anim.Fast) end
                            if optGradient then
                                optGradient.Color = ColorSequence.new(UiDropdownOptionHover, UiDropdownBg:Lerp(UiAccentSoft, 0.08))
                                Ui.Tween(optGradient, {Offset = Vector2.new(0, 0.3), Rotation = 110}, Theme.Anim.Normal)
                            end
                        end
                    end))
                    table.insert(State.UnloadConnections, OptBtn.MouseLeave:Connect(function()
                        refreshOptions()
                    end))
                end

                applyValue(default, true)
                refreshOptions()
                if call then call(emitValue()) end
                Module:RegisterControl({
                    Key = text,
                    Type = "MultiDropdown",
                    Getter = getter,
                    GetValue = function() return emitValue() end,
                    SetValue = function(_, value, silent) applyValue(value, silent) end,
                })
                return DropFrame
            end
