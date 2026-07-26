
            function Module:AddColorPicker(text, default, call, getter)
                Module.HasSettings = true
                Dots.Visible = true

                local function resolveColor(value)
                    if typeof(value) == "Color3" then
                        return value
                    end
                    if type(value) == "table" then
                        local rr = value.r or value.R or 0
                        local gg = value.g or value.G or 0
                        local bb = value.b or value.B or 0
                        if rr <= 1 and gg <= 1 and bb <= 1 then
                            return Color3.new(rr, gg, bb)
                        end
                        return Color3.fromRGB(rr, gg, bb)
                    end
                    return Settings.Colors.Accent or Color3.fromRGB(255, 255, 255)
                end

                local function toByte(component)
                    return math.clamp(math.floor((component * 255) + 0.5), 0, 255)
                end

                local function toHex(color)
                    return string.format("#%02X%02X%02X", toByte(color.R), toByte(color.G), toByte(color.B))
                end

                local function toRgbText(color)
                    return string.format("RGB %d, %d, %d", toByte(color.R), toByte(color.G), toByte(color.B))
                end

                local function colorToHsv(color)
                    local ok, h, s, v = pcall(function()
                        return color:ToHSV()
                    end)
                    if ok and h ~= nil then
                        return h, s, v
                    end
                    return Color3.toHSV(color)
                end

                local initialColor = resolveColor(default)
                local hue, saturation, value = colorToHsv(initialColor)
                local currentColor = Color3.fromHSV(hue, saturation, value)

                local PickerFrame = Instance.new("Frame")
                PickerFrame.Parent = SettingsFrame
                PickerFrame.BackgroundTransparency = 1
                PickerFrame.Size = UDim2.new(1, 0, 0, 36)
                PickerFrame.ZIndex = 8
                PickerFrame.ClipsDescendants = true

                local TopPart = Instance.new("Frame")
                TopPart.Parent = PickerFrame
                TopPart.BackgroundTransparency = 1
                TopPart.Size = UDim2.new(1, 0, 0, 36)
                TopPart.ZIndex = 9

                local Label = Instance.new("TextLabel")
                Label.Parent = TopPart
                Label.Text = text
                Label.TextColor3 = UiTextBright
                Label.Font = Enum.Font.Gotham
                Label.TextSize = 15
                Label.BackgroundTransparency = 1
                Label.Position = UDim2.new(0, 12, 0, 0)
                Label.Size = UDim2.new(1, -138, 1, 0)
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.TextTruncate = Enum.TextTruncate.AtEnd
                Label.ZIndex = 10

                local HexLabel = Instance.new("TextLabel")
                HexLabel.Parent = TopPart
                HexLabel.Text = toHex(currentColor)
                HexLabel.TextColor3 = UiTextSoft
                HexLabel.Font = Enum.Font.GothamSemibold
                HexLabel.TextSize = 11
                HexLabel.BackgroundTransparency = 1
                HexLabel.Position = UDim2.new(1, -116, 0, 0)
                HexLabel.Size = UDim2.new(0, 68, 1, 0)
                HexLabel.TextXAlignment = Enum.TextXAlignment.Right
                HexLabel.ZIndex = 10

                local ColorButton = Instance.new("Frame")
                ColorButton.Parent = TopPart
                ColorButton.Size = UDim2.new(0, 34, 0, 22)
                ColorButton.Position = UDim2.new(1, -46, 0, 7)
                ColorButton.BackgroundColor3 = currentColor
                ColorButton.BorderSizePixel = 0
                ColorButton.ZIndex = 10
                Instance.new("UICorner", ColorButton).CornerRadius = UDim.new(0, 5)
                local colorButtonStroke = Ui.ApplyStroke(ColorButton, UiBorderSoft, 0.44, 1)
                local colorButtonGradient = Ui.ApplyGradient(ColorButton, currentColor:Lerp(Color3.new(0, 0, 0), 0.18), currentColor:Lerp(Color3.new(1, 1, 1), 0.16), 92)
                local colorButtonScale = Ui.EnsureScale(ColorButton, 1)
                if colorButtonGradient then
                    colorButtonGradient.Offset = Vector2.new(0, 0.45)
                end

                local TopButton = Instance.new("TextButton")
                TopButton.Parent = TopPart
                TopButton.BackgroundTransparency = 1
                TopButton.Size = UDim2.new(1, 0, 1, 0)
                TopButton.Text = ""
                TopButton.AutoButtonColor = false
                TopButton.ZIndex = 12

                local PickerPanel = Instance.new("Frame")
                PickerPanel.Parent = PickerFrame
                PickerPanel.BackgroundColor3 = UiPanelBlack:Lerp(UiAccentDeep, 0.1)
                PickerPanel.Position = UDim2.new(0, 10, 0, 40)
                PickerPanel.Size = UDim2.new(1, -20, 0, 158)
                PickerPanel.Visible = false
                PickerPanel.ZIndex = 15
                PickerPanel.ClipsDescendants = true
                Ui.ApplyCorner(PickerPanel, Theme.Corner.Small)
                local pickerStroke = Ui.ApplyStroke(PickerPanel, UiBorderSoft, 0.48, 1)
                local pickerGradient = Ui.ApplyGradient(PickerPanel, UiPanelBlack:Lerp(UiAccentDeep, 0.08), UiFieldBg:Lerp(UiAccentSoft, 0.04), 90)
                local pickerStrokeGradient = pickerStroke and Ui.ApplyGradient(pickerStroke, UiAccentMid, UiBorderSoft, 110)
                if pickerGradient then
                    pickerGradient.Offset = Vector2.new(0, 0.55)
                end

                local SVBox = Instance.new("Frame")
                SVBox.Parent = PickerPanel
                SVBox.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
                SVBox.BorderSizePixel = 0
                SVBox.Position = UDim2.new(0, 10, 0, 12)
                SVBox.Size = UDim2.new(1, -66, 0, 108)
                SVBox.ClipsDescendants = true
                SVBox.ZIndex = 16
                Ui.ApplyCorner(SVBox, Theme.Corner.Small)
                Ui.ApplyStroke(SVBox, UiBorderSoft, 0.34, 1)

                local WhiteLayer = Instance.new("Frame")
                WhiteLayer.Parent = SVBox
                WhiteLayer.BackgroundColor3 = Color3.new(1, 1, 1)
                WhiteLayer.BorderSizePixel = 0
                WhiteLayer.Size = UDim2.fromScale(1, 1)
                WhiteLayer.ZIndex = 17
                local WhiteGradient = Instance.new("UIGradient")
                WhiteGradient.Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 0),
                    NumberSequenceKeypoint.new(1, 1)
                })
                WhiteGradient.Parent = WhiteLayer

                local BlackLayer = Instance.new("Frame")
                BlackLayer.Parent = SVBox
                BlackLayer.BackgroundColor3 = Color3.new(0, 0, 0)
                BlackLayer.BorderSizePixel = 0
                BlackLayer.Size = UDim2.fromScale(1, 1)
                BlackLayer.ZIndex = 18
                local BlackGradient = Instance.new("UIGradient")
                BlackGradient.Rotation = 90
                BlackGradient.Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 1),
                    NumberSequenceKeypoint.new(1, 0)
                })
                BlackGradient.Parent = BlackLayer

                local SVSelector = Instance.new("Frame")
                SVSelector.Parent = SVBox
                SVSelector.AnchorPoint = Vector2.new(0.5, 0.5)
                SVSelector.BackgroundColor3 = Color3.new(1, 1, 1)
                SVSelector.BackgroundTransparency = 0.82
                SVSelector.BorderSizePixel = 0
                SVSelector.Size = UDim2.fromOffset(10, 10)
                SVSelector.ZIndex = 20
                Ui.ApplyCorner(SVSelector, Theme.Corner.Pill)
                Ui.ApplyStroke(SVSelector, Color3.new(1, 1, 1), 0.06, 1)
                local SelectorInner = Instance.new("Frame")
                SelectorInner.Parent = SVSelector
                SelectorInner.BackgroundTransparency = 1
                SelectorInner.Position = UDim2.fromOffset(2, 2)
                SelectorInner.Size = UDim2.new(1, -4, 1, -4)
                SelectorInner.ZIndex = 21
                Ui.ApplyCorner(SelectorInner, Theme.Corner.Pill)
                Ui.ApplyStroke(SelectorInner, Color3.new(0, 0, 0), 0.18, 1)

                local SVDrag = Instance.new("TextButton")
                SVDrag.Parent = SVBox
                SVDrag.BackgroundTransparency = 1
                SVDrag.Size = UDim2.fromScale(1, 1)
                SVDrag.Text = ""
                SVDrag.AutoButtonColor = false
                SVDrag.ZIndex = 22

                local HueBar = Instance.new("Frame")
                HueBar.Parent = PickerPanel
                HueBar.BackgroundColor3 = Color3.new(1, 1, 1)
                HueBar.BorderSizePixel = 0
                HueBar.Position = UDim2.new(1, -30, 0, 12)
                HueBar.Size = UDim2.new(0, 18, 0, 108)
                HueBar.ClipsDescendants = true
                HueBar.ZIndex = 16
                Ui.ApplyCorner(HueBar, Theme.Corner.Small)
                Ui.ApplyStroke(HueBar, UiBorderSoft, 0.34, 1)
                local HueGradient = Instance.new("UIGradient")
                HueGradient.Rotation = 90
                HueGradient.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 0)),
                    ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
                    ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
                    ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0, 255, 255)),
                    ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
                    ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
                    ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 0))
                })
                HueGradient.Parent = HueBar

                local HueSelector = Instance.new("Frame")
                HueSelector.Parent = PickerPanel
                HueSelector.BackgroundColor3 = Color3.new(1, 1, 1)
                HueSelector.BorderSizePixel = 0
                HueSelector.Size = UDim2.fromOffset(24, 3)
                HueSelector.ZIndex = 19
                Ui.ApplyCorner(HueSelector, Theme.Corner.Pill)
                Ui.ApplyStroke(HueSelector, Color3.new(0, 0, 0), 0.26, 1)

                local HueDrag = Instance.new("TextButton")
                HueDrag.Parent = HueBar
                HueDrag.BackgroundTransparency = 1
                HueDrag.Size = UDim2.fromScale(1, 1)
                HueDrag.Text = ""
                HueDrag.AutoButtonColor = false
                HueDrag.ZIndex = 22

                local Preview = Instance.new("Frame")
                Preview.Parent = PickerPanel
                Preview.BackgroundColor3 = currentColor
                Preview.BorderSizePixel = 0
                Preview.Position = UDim2.new(0, 10, 0, 130)
                Preview.Size = UDim2.new(0, 44, 0, 20)
                Preview.ZIndex = 16
                Ui.ApplyCorner(Preview, Theme.Corner.Small)
                Ui.ApplyStroke(Preview, UiBorderSoft, 0.38, 1)

                local PanelHex = Instance.new("TextLabel")
                PanelHex.Parent = PickerPanel
                PanelHex.BackgroundTransparency = 1
                PanelHex.Position = UDim2.new(0, 64, 0, 124)
                PanelHex.Size = UDim2.new(1, -78, 0, 15)
                PanelHex.Font = Enum.Font.GothamSemibold
                PanelHex.TextSize = 12
                PanelHex.TextColor3 = UiTextBright
                PanelHex.TextXAlignment = Enum.TextXAlignment.Left
                PanelHex.Text = toHex(currentColor)
                PanelHex.ZIndex = 16

                local RgbLabel = Instance.new("TextLabel")
                RgbLabel.Parent = PickerPanel
                RgbLabel.BackgroundTransparency = 1
                RgbLabel.Position = UDim2.new(0, 64, 0, 140)
                RgbLabel.Size = UDim2.new(1, -78, 0, 13)
                RgbLabel.Font = Enum.Font.Gotham
                RgbLabel.TextSize = 11
                RgbLabel.TextColor3 = UiTextSoft
                RgbLabel.TextXAlignment = Enum.TextXAlignment.Left
                RgbLabel.Text = toRgbText(currentColor)
                RgbLabel.ZIndex = 16

                local function refreshVisuals()
                    currentColor = Color3.fromHSV(hue, saturation, value)
                    local hueColor = Color3.fromHSV(hue, 1, 1)
                    local hex = toHex(currentColor)

                    SVBox.BackgroundColor3 = hueColor
                    SVSelector.Position = UDim2.new(saturation, 0, 1 - value, 0)
                    HueSelector.Position = UDim2.new(1, -33, 0, 12 + (hue * 108) - 1)

                    ColorButton.BackgroundColor3 = currentColor
                    Preview.BackgroundColor3 = currentColor
                    HexLabel.Text = hex
                    PanelHex.Text = hex
                    RgbLabel.Text = toRgbText(currentColor)

                    if colorButtonGradient then
                        colorButtonGradient.Color = ColorSequence.new({
                            ColorSequenceKeypoint.new(0, currentColor:Lerp(Color3.new(0, 0, 0), 0.18)),
                            ColorSequenceKeypoint.new(1, currentColor:Lerp(Color3.new(1, 1, 1), 0.16))
                        })
                    end
                end

                local function updateColorAndCallback(silent)
                    refreshVisuals()
                    if call and not silent then
                        pcall(call, currentColor)
                    end
                end

                local function applyColor(valueToApply, silent)
                    local color = resolveColor(valueToApply)
                    hue, saturation, value = colorToHsv(color)
                    updateColorAndCallback(silent)
                end

                local function isBeginInput(input)
                    return input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch
                end

                local function isMoveInput(input)
                    return input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch
                end

                local draggingSv = false
                local draggingHue = false

                local function updateSvFromInput(input)
                    if SVBox.AbsoluteSize.X <= 0 or SVBox.AbsoluteSize.Y <= 0 then return end
                    local relX = input.Position.X - SVBox.AbsolutePosition.X
                    local relY = input.Position.Y - SVBox.AbsolutePosition.Y
                    saturation = math.clamp(relX / SVBox.AbsoluteSize.X, 0, 1)
                    value = 1 - math.clamp(relY / SVBox.AbsoluteSize.Y, 0, 1)
                    updateColorAndCallback(false)
                end

                local function updateHueFromInput(input)
                    if HueBar.AbsoluteSize.Y <= 0 then return end
                    local relY = input.Position.Y - HueBar.AbsolutePosition.Y
                    hue = math.clamp(relY / HueBar.AbsoluteSize.Y, 0, 1)
                    updateColorAndCallback(false)
                end

                table.insert(State.UnloadConnections, SVDrag.InputBegan:Connect(function(input)
                    if isBeginInput(input) then
                        draggingSv = true
                        updateSvFromInput(input)
                    end
                end))
                table.insert(State.UnloadConnections, HueDrag.InputBegan:Connect(function(input)
                    if isBeginInput(input) then
                        draggingHue = true
                        updateHueFromInput(input)
                    end
                end))
                table.insert(State.UnloadConnections, Services.UserInputService.InputChanged:Connect(function(input)
                    if not isMoveInput(input) then return end
                    if draggingSv then
                        updateSvFromInput(input)
                    elseif draggingHue then
                        updateHueFromInput(input)
                    end
                end))
                table.insert(State.UnloadConnections, Services.UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        draggingSv = false
                        draggingHue = false
                    end
                end))

                applyColor(default, true)

                local isExpanded = false

                local function refreshLayoutAfterToggle()
                    task.delay(0.21, function()
                        if Module.SettingsOpen then
                            SyncSettingsFrame(false)
                            UpdateSize()
                        end
                    end)
                end

                local function Collapse()
                    isExpanded = false
                    if ActiveColorPicker and ActiveColorPicker.frame == PickerFrame then ActiveColorPicker = nil end
                    PickerPanel.Visible = false
                    Ui.Tween(PickerFrame, {Size = UDim2.new(1, 0, 0, 36)}, 0.2)
                    if pickerStroke then
                        pickerStroke.Color = UiBorderSoft
                        Ui.Tween(pickerStroke, {Transparency = 0.48}, Theme.Anim.Fast)
                    end
                    if pickerGradient then Ui.Tween(pickerGradient, {Offset = Vector2.new(0, 0.55), Rotation = 90}, Theme.Anim.Normal) end
                    if pickerStrokeGradient then Ui.Tween(pickerStrokeGradient, {Offset = Vector2.new(0, 0.55), Rotation = 110}, Theme.Anim.Normal) end
                    refreshLayoutAfterToggle()
                end

                local function Expand()
                    isExpanded = true
                    if ActiveColorPicker and ActiveColorPicker.frame ~= PickerFrame and ActiveColorPicker.collapse then
                        pcall(ActiveColorPicker.collapse)
                    end
                    ActiveColorPicker = { frame = PickerFrame, collapse = Collapse }
                    PickerPanel.Visible = true
                    Ui.Tween(PickerFrame, {Size = UDim2.new(1, 0, 0, 204)}, 0.2)
                    if pickerStroke then
                        Ui.Tween(pickerStroke, {Transparency = 0.26, Color = Settings.Colors.Accent}, Theme.Anim.Fast)
                    end
                    if pickerGradient then Ui.Tween(pickerGradient, {Offset = Vector2.new(0, 0.18), Rotation = 102}, Theme.Anim.Normal) end
                    if pickerStrokeGradient then Ui.Tween(pickerStrokeGradient, {Offset = Vector2.new(0, 0.22), Rotation = 126}, Theme.Anim.Normal) end
                    refreshVisuals()
                    refreshLayoutAfterToggle()
                end

                table.insert(State.UnloadConnections, TopButton.MouseEnter:Connect(function()
                    Ui.Tween(Label, {TextColor3 = UiTextBright}, Theme.Anim.Fast)
                    Ui.Tween(HexLabel, {TextColor3 = UiTextBright}, Theme.Anim.Fast)
                    if colorButtonStroke then Ui.Tween(colorButtonStroke, {Transparency = 0.25, Color = Settings.Colors.AccentSoft}, Theme.Anim.Fast) end
                    if colorButtonGradient then Ui.Tween(colorButtonGradient, {Offset = Vector2.new(0, 0.18), Rotation = 112}, Theme.Anim.Normal) end
                end))
                table.insert(State.UnloadConnections, TopButton.MouseLeave:Connect(function()
                    Ui.Tween(Label, {TextColor3 = UiTextBright}, Theme.Anim.Fast)
                    Ui.Tween(HexLabel, {TextColor3 = UiTextSoft}, Theme.Anim.Fast)
                    if colorButtonStroke then Ui.Tween(colorButtonStroke, {Transparency = 0.44, Color = UiBorderSoft}, Theme.Anim.Fast) end
                    if colorButtonGradient then Ui.Tween(colorButtonGradient, {Offset = Vector2.new(0, 0.45), Rotation = 92}, Theme.Anim.Normal) end
                end))
                table.insert(State.UnloadConnections, TopButton.MouseButton1Click:Connect(function()
                    Ui.PulseScale(colorButtonScale, 0.92, 0.05, 0.14)
                    if isExpanded then Collapse() else Expand() end
                end))

                Module:RegisterControl({
                    Key = text,
                    Type = "Color",
                    Getter = getter,
                    GetValue = function() return Color3.fromHSV(hue, saturation, value) end,
                    SetValue = function(_, valueToApply, silent) applyColor(valueToApply, silent) end,
                })
            end

            function Module:AddColorPalette(colorPairs, callback)
                Module.HasSettings = true
                Dots.Visible = true

                local cont = Instance.new("Frame", SettingsFrame)
                cont.BackgroundTransparency = 1
                cont.Size = UDim2.new(1, 0, 0, 60)

                local grid = Instance.new("UIGridLayout", cont)
                grid.CellSize = UDim2.new(0, 22, 0, 22)
                grid.CellPadding = UDim2.new(0, 5, 0, 5)
                grid.HorizontalAlignment = Enum.HorizontalAlignment.Center

                for _, pair in ipairs(colorPairs) do
                    local btn = Instance.new("TextButton", cont)
                    btn.BackgroundColor3 = pair[1]
                    btn.Text = ""
                    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
                    local pStroke = Ui.ApplyStroke(btn, UiBorderSoft, 0.62, 1)
                    local pGradient = Ui.ApplyGradient(btn, pair[1]:Lerp(Color3.new(0, 0, 0), 0.2), pair[2] or pair[1]:Lerp(Color3.new(1, 1, 1), 0.2), 88)
                    local pScale = Ui.EnsureScale(btn, 1)
                    if pGradient then
                        pGradient.Offset = Vector2.new(0, 0.5)
                    end
                    table.insert(State.UnloadConnections, btn.MouseEnter:Connect(function()
                        if pStroke then Ui.Tween(pStroke, {Transparency = 0.45}, Theme.Anim.Fast) end
                        if pGradient then Ui.Tween(pGradient, {Offset = Vector2.new(0, 0.2), Rotation = 110}, Theme.Anim.Normal) end
                    end))
                    table.insert(State.UnloadConnections, btn.MouseLeave:Connect(function()
                        if pStroke then Ui.Tween(pStroke, {Transparency = 0.72}, Theme.Anim.Fast) end
                        if pGradient then Ui.Tween(pGradient, {Offset = Vector2.new(0, 0.5), Rotation = 88}, Theme.Anim.Normal) end
                    end))
                    table.insert(State.UnloadConnections, btn.MouseButton1Click:Connect(function()
                        Ui.PulseScale(pScale, 0.88, 0.05, 0.13)
                        callback(pair[1], pair[2])
                    end))
                end
            end
