
        function Window:AddTextbox(name, placeholder)
            UtilityStack.Visible = true
            local Frame = Instance.new("Frame")
            Frame.Name = name
            Frame.Parent = UtilityStack
            Frame.BackgroundTransparency = 1
            Frame.Size = UDim2.new(1, 0, 0, 46)
            Frame.ZIndex = 7

            local Shell, TextBox = CreateTextBoxShell(Frame, {
                PlaceholderText = placeholder or "",
                Size = UDim2.new(1, 0, 1, -10),
                Position = UDim2.new(0, 0, 0, 5),
                ZIndex = 8,
                TextSize = 15,
                PaddingLeft = 18,
                PaddingRight = 12,
                StrokeTransparency = 0.32,
                BackgroundColor3 = UiPanelBlack:Lerp(UiInputDark, 0.55),
                HoverColor3 = UiPanelBlack:Lerp(UiInputDark, 0.68),
                FocusColor3 = UiPanelBlack:Lerp(UiAccentDeep, 0.16),
                StrokeColor = UiFieldBorder:Lerp(UiAccentSoft, 0.24),
                HoverStrokeColor = UiAccentMid,
                FocusStrokeColor = UiAccentSoft,
                HoverStrokeTransparency = 0.22,
                GradientFrom = UiPanelBlack:Lerp(UiInputDark, 0.48),
                GradientTo = UiInputDark:Lerp(UiAccentDeep, 0.08),
            })
            local InputStrip = Instance.new("Frame")
            InputStrip.Parent = Shell
            InputStrip.BackgroundColor3 = UiAccentSoft
            InputStrip.BackgroundTransparency = 0.66
            InputStrip.BorderSizePixel = 0
            InputStrip.Position = UDim2.new(0, 8, 0, 8)
            InputStrip.Size = UDim2.new(0, 2, 1, -16)
            InputStrip.ZIndex = 9
            Ui.ApplyCorner(InputStrip, Theme.Corner.Pill)

            UpdateSize()
            return TextBox
        end
        function Window:AddModule(modName, tooltip, callback, defaultState)
            local Module = {
                Name = modName,
                Category = Window.Name,
                Enabled = defaultState or false,
                Keybind = nil,
                HasSettings = false,
                SettingsOpen = false,
                StateGetter = nil,
                _label = nil,
                _bindLabel = nil,
                Controls = {},
                ControlsList = {}
            }
            table.insert(Library.Modules, Module)
            Window._moduleCount = (Window._moduleCount or 0) + 1
            local ModuleParent = (Window._moduleCount % 2 == 1) and LeftColumn or RightColumn
            local function GetModuleCardBg(active, hovered)
                if active then
                    return UiPanelBlack:Lerp(UiAccentDeep, hovered and 0.28 or 0.22)
                end
                return UiPanelBlack:Lerp(UiInputDark, hovered and 0.48 or 0.34)
            end
            local function GetModuleCardTo(active, hovered)
                if active then
                    return UiPanelBlack:Lerp(UiAccentSoft, hovered and 0.18 or 0.12)
                end
                return UiInputDark:Lerp(UiAccentDeep, hovered and 0.12 or 0.04)
            end
            local function GetModuleStrokeColor(active, hovered)
                if active then
                    return hovered and UiAccentSoft or UiAccentMid
                end
                return hovered and UiAccentMid or UiModuleInactiveBorder
            end
            local function GetModuleStrokeTrans(active, hovered)
                if active then
                    return hovered and 0.1 or 0.16
                end
                return hovered and 0.2 or 0.28
            end
            local function GetModuleDescColor(active)
                return active and UiTextBright:Lerp(UiAccentSoft, 0.1) or UiTextSoft:Lerp(UiTextBright, 0.2)
            end

            local Button = Instance.new("TextButton")
            Button.Parent = ModuleParent
            Button.BackgroundTransparency = 1
            Button.Size = UDim2.new(1, 0, 0, 74)
            Button.Text = ""
            Button.AutoButtonColor = false
            Button.LayoutOrder = Window._moduleCount * 2
            Button.ZIndex = 7

            -- Module card background
            local rowBaseTrans = 0
            local rowHoverTrans = 0.0
            local RowBg = Instance.new("Frame")
            RowBg.Parent = Button
            RowBg.BackgroundColor3 = GetModuleCardBg(Module.Enabled, false)
            RowBg.BackgroundTransparency = rowBaseTrans
            RowBg.Size = UDim2.new(1, 0, 1, 0)
            RowBg.Position = UDim2.new(0, 0, 0, 0)
            RowBg.ZIndex = 7
            Ui.ApplyCorner(RowBg, Theme.Corner.Big)
            local rowStroke = Ui.ApplyStroke(RowBg, GetModuleStrokeColor(Module.Enabled, false), GetModuleStrokeTrans(Module.Enabled, false), 1)
            local rowGradient = Ui.ApplyGradient(
                RowBg,
                GetModuleCardBg(Module.Enabled, false),
                GetModuleCardTo(Module.Enabled, false),
                Module.Enabled and 104 or 86
            )
            local rowStrokeGradient = rowStroke and Ui.ApplyGradient(
                rowStroke,
                GetModuleStrokeColor(Module.Enabled, false),
                Module.Enabled and UiAccentSoft or UiBorderSoft,
                112
            )
            local rowScale = Ui.EnsureScale(RowBg, 1)
            if rowGradient then
                rowGradient.Offset = Vector2.new(0, 0.56)
            end
            Module._rowBg = RowBg
            Module._rowStroke = rowStroke
            Module._rowGradient = rowGradient
            Module._rowStrokeGradient = rowStrokeGradient
            Module._rowScale = rowScale
            local RowDivider = Instance.new("Frame", RowBg)
            RowDivider.BackgroundColor3 = UiAccentSoft
            RowDivider.BackgroundTransparency = Module.Enabled and 0.08 or 1
            RowDivider.BorderSizePixel = 0
            RowDivider.Size = UDim2.new(0, 3, 1, -18)
            RowDivider.Position = UDim2.new(0, 8, 0, 9)
            RowDivider.ZIndex = 8
            Ui.ApplyCorner(RowDivider, Theme.Corner.Pill)

            local rightReserve = 58
            local labelLeft = 16

            local ClipFrame = Instance.new("Frame", Button)
            ClipFrame.BackgroundTransparency = 1
            ClipFrame.Position = UDim2.new(0, labelLeft, 0, 8)
            ClipFrame.Size = UDim2.new(1, -(labelLeft + rightReserve), 0, 24)
            ClipFrame.ClipsDescendants = true
            ClipFrame.ZIndex = 8

            local Label = Instance.new("TextLabel")
            Label.Parent = ClipFrame
            Label.Text = modName
            Label.TextColor3 = UiTextBright
            Label.TextTransparency = 0
            Label.TextStrokeTransparency = 1
            Label.Font = Enum.Font.GothamSemibold
            Label.TextSize = 15
            Label.BackgroundTransparency = 1
            Label.Position = UDim2.new(0, 0, 0, 0)
            Label.Size = UDim2.new(1, 0, 1, 0)
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.ZIndex = 8
            Module._label = Label

            local DescLabel = Instance.new("TextLabel")
            DescLabel.Parent = RowBg
            DescLabel.BackgroundTransparency = 1
            DescLabel.Position = UDim2.new(0, labelLeft, 0, 32)
            DescLabel.Size = UDim2.new(1, -(labelLeft + rightReserve), 0, 30)
            DescLabel.Text = tostring(tooltip or "")
            DescLabel.TextColor3 = GetModuleDescColor(Module.Enabled)
            DescLabel.TextTransparency = Module.Enabled and 0.02 or 0.0
            DescLabel.Font = Enum.Font.Gotham
            DescLabel.TextSize = 11
            DescLabel.TextWrapped = true
            DescLabel.TextXAlignment = Enum.TextXAlignment.Left
            DescLabel.TextYAlignment = Enum.TextYAlignment.Top
            DescLabel.ZIndex = 8
            Module._descLabel = DescLabel

            local textSize = Services.TextService:GetTextSize(modName, Label.TextSize, Label.Font, Vector2.new(math.huge, math.huge))
            local availableWidth = ClipFrame.AbsoluteSize.X
            if availableWidth == 0 then availableWidth = Settings.Layout.WindowWidth - 140 end

            if textSize.X > availableWidth then
                Label.Size = UDim2.new(0, textSize.X, 1, 0)
                local currentTween

                table.insert(State.UnloadConnections, Button.MouseEnter:Connect(function()
                    if currentTween then currentTween:Cancel() end
                    local duration = (textSize.X - availableWidth) / 40
                    currentTween = Services.TweenService:Create(Label, TweenInfo.new(duration, Enum.EasingStyle.Linear), {Position = UDim2.new(0, availableWidth - textSize.X, 0, 0)})
                    currentTween:Play()
                end))

                table.insert(State.UnloadConnections, Button.MouseLeave:Connect(function()
                    if currentTween then currentTween:Cancel() end
                    currentTween = Services.TweenService:Create(Label, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Position = UDim2.new(0, 0, 0, 0)})
                    currentTween:Play()
                end))
            end

            local Dots = Instance.new("TextLabel")
            Dots.Parent = Button
            Dots.Text = "*"
            Dots.TextColor3 = Module.Enabled and UiTextBright or UiAccentSoft
            Dots.BackgroundTransparency = 1
            Dots.Position = UDim2.new(1, -24, 0, 8)
            Dots.Size = UDim2.new(0, 18, 0, 18)
            Dots.Visible = false
            Dots.Font = Enum.Font.GothamBold
            Dots.ZIndex = 8

            local BindLabel = Instance.new("TextLabel")
            BindLabel.Parent = Button
            BindLabel.Text = ""
            BindLabel.TextColor3 = UiTextMuted
            BindLabel.BackgroundTransparency = 1
            BindLabel.Position = UDim2.new(1, -54, 0, 38)
            BindLabel.Size = UDim2.new(0, 44, 0, 18)
            BindLabel.Font = Enum.Font.Gotham
            BindLabel.TextSize = 11
            BindLabel.TextXAlignment = Enum.TextXAlignment.Right
            BindLabel.ZIndex = 8
            Module._bindLabel = BindLabel
            Module._button = Button

            local toggleOffColor = UiToggleOffBg
            local toggleStrokeColor = UiToggleOffBorder
            local toggleStrokeTrans = 0.18
            local ToggleIndicator = Instance.new("Frame")
            ToggleIndicator.Parent = Button
            ToggleIndicator.Size = UDim2.new(0, 44, 0, 22)
            ToggleIndicator.Position = UDim2.new(1, -54, 0, 11)
            ToggleIndicator.BackgroundColor3 = Module.Enabled and Settings.Colors.Accent or toggleOffColor
            ToggleIndicator.BackgroundTransparency = 0
            ToggleIndicator.BorderSizePixel = 0
            ToggleIndicator.ZIndex = 8
            Ui.ApplyCorner(ToggleIndicator, Theme.Corner.Pill)
            local toggleStroke = Ui.ApplyStroke(ToggleIndicator, toggleStrokeColor, toggleStrokeTrans, 1)
            local toggleOffGradFrom = toggleOffColor
            local toggleOffGradTo = toggleOffColor:Lerp(UiTextBright, 0.07)
            local toggleGradient = Ui.ApplyGradient(
                ToggleIndicator,
                Module.Enabled and Settings.Colors.Accent or toggleOffGradFrom,
                Module.Enabled and Settings.Colors.AccentSoft or toggleOffGradTo,
                90
            )
            local toggleStrokeGradient = toggleStroke and Ui.ApplyGradient(
                toggleStroke,
                Module.Enabled and Settings.Colors.AccentSoft or toggleOffGradTo,
                Module.Enabled and Settings.Colors.Accent or toggleOffGradFrom,
                104
            )
            if toggleGradient then
                toggleGradient.Offset = Vector2.new(0, 0.5)
            end

            local ToggleDot = Instance.new("Frame", ToggleIndicator)
            ToggleDot.Size = UDim2.new(0, 18, 0, 18)
            ToggleDot.Position = Module.Enabled and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
            ToggleDot.BackgroundColor3 = Module.Enabled and UiTextBright or UiToggleOffThumb
            ToggleDot.BorderSizePixel = 0
            ToggleDot.Visible = true
            Ui.ApplyCorner(ToggleDot, Theme.Corner.Pill)
            Module._toggle = ToggleIndicator
            Module._toggleDot = ToggleDot
            Module._toggleStroke = toggleStroke
            Module._toggleGradient = toggleGradient
            Module._toggleStrokeGradient = toggleStrokeGradient
