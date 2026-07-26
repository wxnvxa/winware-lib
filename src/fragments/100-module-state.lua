
            function Module:RegisterControl(control)
                if not control then return end
                table.insert(Module.ControlsList, control)
                if control.Key then
                    Module.Controls[control.Key] = control
                end
            end

            function Module:SetKeybind(key, silent)
                local resolved = key
                if typeof(resolved) ~= "EnumItem" then
                    if type(resolved) == "string" then
                        resolved = resolveEnumName(resolved, Enum.KeyCode)
                    elseif type(resolved) == "table" and type(resolved.name) == "string" then
                        resolved = resolveEnumName(resolved.name, Enum.KeyCode)
                    end
                end
                Module.Keybind = resolved
                RegisterModuleKeybind(Module, resolved)
                if Module.RefreshBind then
                    Module:RefreshBind()
                end
                if not silent then
                    Library:UpdateHotkeys()
                end
            end

            function Module:SerializeControls()
                local data = {}
                for _, control in ipairs(Module.ControlsList) do
                    if control and control.Key and control.GetValue then
                        data[control.Key] = encodeValue(control:GetValue())
                    end
                end
                return data
            end

            function Module:ApplyControlStates(states)
                if type(states) ~= "table" then return end
                for key, rawValue in pairs(states) do
                    local control = Module.Controls[key]
                    if control and control.SetValue then
                        local decoded = decodeValue(rawValue)
                        if decoded ~= nil then
                            control:SetValue(decoded, false)
                        end
                    end
                end
            end

            function Module:SyncControls()
                for _, control in ipairs(Module.ControlsList) do
                    if control and control.SetValue then
                        local getter = control.Getter or control.GetValue
                        if getter then
                            local ok, value = pcall(getter)
                            if ok and value ~= nil then
                                control:SetValue(value, false)
                            end
                        end
                    end
                end
            end

            function Module:RefreshBind()
                if Module._bindLabel then
                    if Module.Keybind then
                        Module._bindLabel.Text = "[" .. Module.Keybind.Name:sub(1, 3) .. "]"
                    else
                        Module._bindLabel.Text = ""
                    end
                end
            end

            function Module:SetEnabled(state, silent, skipHotkeys, force)
                local nextState = not not state
                if Module.Enabled == nextState and not force then
                    return
                end
                Module.Enabled = nextState
                if Module._label then
                    Module._label.TextColor3 = UiTextBright
                    Module._label.TextTransparency = 0
                end
                if Module._descLabel then
                    Ui.Tween(Module._descLabel, {
                        TextColor3 = GetModuleDescColor(nextState),
                        TextTransparency = nextState and 0.02 or 0.0
                    }, Theme.Anim.Fast)
                end
                if Dots then
                    Ui.Tween(Dots, {TextColor3 = nextState and UiTextBright or UiAccentSoft}, Theme.Anim.Fast)
                end
                if Module._toggle then
                    Ui.Tween(Module._toggle, {BackgroundColor3 = nextState and Settings.Colors.Accent or toggleOffColor}, Theme.Anim.Fast)
                end
                if Module._toggleStroke then
                    Ui.Tween(Module._toggleStroke, {
                        Transparency = nextState and 0.24 or toggleStrokeTrans,
                        Color = nextState and Settings.Colors.AccentSoft or toggleStrokeColor
                    }, Theme.Anim.Fast)
                end
                if Module._toggleGradient then
                    Module._toggleGradient.Color = ColorSequence.new(
                        nextState and Settings.Colors.Accent or toggleOffGradFrom,
                        nextState and Settings.Colors.AccentSoft or toggleOffGradTo
                    )
                    Ui.Tween(Module._toggleGradient, {
                        Offset = Vector2.new(0, nextState and 0.1 or 0.5),
                        Rotation = nextState and 122 or 84
                    }, Theme.Anim.Normal)
                end
                if Module._toggleStrokeGradient then
                    Module._toggleStrokeGradient.Color = ColorSequence.new(
                        nextState and Settings.Colors.AccentSoft or toggleOffGradTo,
                        nextState and Settings.Colors.Accent or toggleOffGradFrom
                    )
                    Ui.Tween(Module._toggleStrokeGradient, {
                        Offset = Vector2.new(0, nextState and 0.12 or 0.45),
                        Rotation = nextState and 136 or 104
                    }, Theme.Anim.Normal)
                end
                if Module._toggleDot then
                    Ui.Tween(Module._toggleDot, {
                        Size = UDim2.new(0, 18, 0, 18),
                        Position = nextState and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9),
                        BackgroundColor3 = nextState and UiTextBright or UiToggleOffThumb
                    }, Theme.Anim.Fast)
                end
                if Module._rowBg then
                    Ui.Tween(Module._rowBg, {BackgroundColor3 = GetModuleCardBg(nextState, false), BackgroundTransparency = rowBaseTrans}, Theme.Anim.Fast)
                end
                if Module._rowStroke then
                    Ui.Tween(Module._rowStroke, {Transparency = GetModuleStrokeTrans(nextState, false), Color = GetModuleStrokeColor(nextState, false)}, Theme.Anim.Fast)
                end
                if Module._rowGradient then
                    Module._rowGradient.Color = nextState
                        and ColorSequence.new({
                            ColorSequenceKeypoint.new(0, GetModuleCardBg(true, false)),
                            ColorSequenceKeypoint.new(0.52, GetModuleCardBg(true, false):Lerp(UiAccentMid, 0.08)),
                            ColorSequenceKeypoint.new(1, GetModuleCardTo(true, false)),
                        })
                        or ColorSequence.new(GetModuleCardBg(false, false), GetModuleCardTo(false, false))
                    Ui.Tween(Module._rowGradient, {
                        Offset = Vector2.new(0, nextState and 0.08 or 0.56),
                        Rotation = nextState and 116 or 74
                    }, Theme.Anim.Normal)
                end
                if Module._rowStrokeGradient then
                    Module._rowStrokeGradient.Color = nextState and ColorSequence.new(UiAccentSoft, UiAccent) or ColorSequence.new(UiModuleInactiveBorder, UiBorderSoft)
                    Ui.Tween(Module._rowStrokeGradient, {
                        Offset = Vector2.new(0, nextState and 0.1 or 0.5),
                        Rotation = nextState and 128 or 96
                    }, Theme.Anim.Normal)
                end
                if RowDivider then
                    Ui.Tween(RowDivider, {BackgroundTransparency = nextState and 0.08 or 1}, Theme.Anim.Fast)
                end
                if Module._rowScale and not silent then
                    Ui.PulseScale(Module._rowScale, 0.95, 0.05, 0.16)
                end
                local callbackFailed = false
                if callback then
                    local okCallback, callbackErr = pcall(callback, nextState)
                    if not okCallback then
                        callbackFailed = true
                        warn(("WinWare module callback failed for %s: %s"):format(tostring(modName), tostring(callbackErr)))
                        if not silent then
                            Library:Notify(modName, "Module callback failed", "Warn")
                        end
                    end
                end
                if not callbackFailed and not silent and Settings.Notifications.Enabled and Settings.Notifications.NotifyOnToggle then
                    Library:Notify(modName, (nextState and "Enabled" or "Disabled") .. "!", "Normal")
                end
                if not skipHotkeys then
                    Library:UpdateHotkeys()
                end
            end

            -- Collapsible settings panel for module controls
            local SettingsFrame = Instance.new("ScrollingFrame")
            SettingsFrame.Parent = ModuleParent
            SettingsFrame.BackgroundColor3 = UiPanelBlack:Lerp(UiAccentDeep, 0.08)
            SettingsFrame.BackgroundTransparency = 0
            SettingsFrame.Size = UDim2.new(1, -12, 0, 0)
            SettingsFrame.LayoutOrder = (Window._moduleCount * 2) + 1
            SettingsFrame.Visible = false
            SettingsFrame.ClipsDescendants = true
            SettingsFrame.ZIndex = 7
            SettingsFrame.BorderSizePixel = 0
            SettingsFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
            SettingsFrame.ScrollBarThickness = 3
            SettingsFrame.ScrollBarImageColor3 = Settings.Colors.Accent
            SettingsFrame.ScrollBarImageTransparency = 0.2
            SettingsFrame.ScrollingDirection = Enum.ScrollingDirection.Y
            Ui.ApplyCorner(SettingsFrame, Theme.Corner.Big)
            local settingsStroke = Ui.ApplyStroke(SettingsFrame, UiAccentMid, 0.42, 1)
            local settingsGradient = Ui.ApplyGradient(SettingsFrame, UiPanelBlack:Lerp(UiAccentDeep, 0.06), UiInputDark:Lerp(UiAccentDeep, 0.08), 86)
            local settingsStrokeGradient = settingsStroke and Ui.ApplyGradient(settingsStroke, UiAccentMid, UiBorderSoft, 108)
            Module._settingsFrame = SettingsFrame
            table.insert(Window._moduleEntries, Module)

            local SettingsList = Instance.new("UIListLayout")
            SettingsList.Parent = SettingsFrame
            SettingsList.Padding = UDim.new(0, 4)

            local SettingsAccent = Instance.new("Frame")
            SettingsAccent.Parent = SettingsFrame
            SettingsAccent.BackgroundColor3 = UiAccentSoft
            SettingsAccent.BackgroundTransparency = 0.34
            SettingsAccent.BorderSizePixel = 0
            SettingsAccent.Size = UDim2.new(1, -12, 0, 2)
            SettingsAccent.LayoutOrder = -10
            SettingsAccent.ZIndex = 8
            Ui.ApplyCorner(SettingsAccent, Theme.Corner.Pill)

            local SettingsPad = Instance.new("UIPadding")
            SettingsPad.Parent = SettingsFrame
            SettingsPad.PaddingTop = UDim.new(0, 8)
            SettingsPad.PaddingBottom = UDim.new(0, 8)
            SettingsPad.PaddingLeft = UDim.new(0, 6)
            SettingsPad.PaddingRight = UDim.new(0, 6)

            if Module.Enabled and callback then
                task.spawn(function() callback(true) end)
            end

            table.insert(State.UnloadConnections, Button.MouseEnter:Connect(function()
                Ui.Tween(RowBg, {BackgroundColor3 = GetModuleCardBg(Module.Enabled, true), BackgroundTransparency = rowHoverTrans}, Theme.Anim.Fast)
                if rowStroke then Ui.Tween(rowStroke, {Transparency = GetModuleStrokeTrans(Module.Enabled, true), Color = GetModuleStrokeColor(Module.Enabled, true)}, Theme.Anim.Fast) end
                if rowGradient then
                    rowGradient.Color = ColorSequence.new(GetModuleCardBg(Module.Enabled, true), GetModuleCardTo(Module.Enabled, true))
                    Ui.Tween(rowGradient, {Offset = Vector2.new(0, 0.2), Rotation = 102}, Theme.Anim.Normal)
                end
                if rowStrokeGradient then
                    rowStrokeGradient.Color = Module.Enabled and ColorSequence.new(UiAccentSoft, UiAccent) or ColorSequence.new(UiModuleInactiveHoverBorder, UiAccentMid)
                    Ui.Tween(rowStrokeGradient, {Offset = Vector2.new(0, 0.2), Rotation = 116}, Theme.Anim.Normal)
                end
                if Module._toggle and not Module.Enabled then
                    Ui.Tween(Module._toggle, {BackgroundColor3 = toggleOffColor:Lerp(UiAccentSoft, 0.08)}, Theme.Anim.Fast)
                end
                if Module._toggleStroke and not Module.Enabled then
                    Ui.Tween(Module._toggleStroke, {Transparency = 0.12, Color = toggleStrokeColor:Lerp(UiAccentMid, 0.35)}, Theme.Anim.Fast)
                end
            end))
            table.insert(State.UnloadConnections, Button.MouseLeave:Connect(function()
                local active = Module.Enabled
                Ui.Tween(RowBg, {BackgroundColor3 = GetModuleCardBg(active, false), BackgroundTransparency = active and 0.0 or rowBaseTrans}, Theme.Anim.Fast)
                if rowStroke then Ui.Tween(rowStroke, {Transparency = GetModuleStrokeTrans(active, false), Color = GetModuleStrokeColor(active, false)}, Theme.Anim.Fast) end
                if rowGradient then
                    rowGradient.Color = ColorSequence.new(GetModuleCardBg(active, false), GetModuleCardTo(active, false))
                    Ui.Tween(rowGradient, {Offset = Vector2.new(0, active and 0.08 or 0.56), Rotation = active and 116 or 74}, Theme.Anim.Normal)
                end
                if rowStrokeGradient then
                    rowStrokeGradient.Color = active and ColorSequence.new(UiAccentSoft, UiAccent) or ColorSequence.new(UiModuleInactiveBorder, UiBorderSoft)
                    Ui.Tween(rowStrokeGradient, {Offset = Vector2.new(0, active and 0.1 or 0.5), Rotation = active and 128 or 96}, Theme.Anim.Normal)
                end
                if Module._toggle then
                    Ui.Tween(Module._toggle, {BackgroundColor3 = active and Settings.Colors.Accent or toggleOffColor}, Theme.Anim.Fast)
                end
                if Module._toggleStroke then
                    Ui.Tween(Module._toggleStroke, {
                        Transparency = active and 0.24 or toggleStrokeTrans,
                        Color = active and Settings.Colors.AccentSoft or toggleStrokeColor
                    }, Theme.Anim.Fast)
                end
            end))

            local function GetSettingsHeights()
                local content = SettingsList.AbsoluteContentSize.Y + 12
                local maxH = math.floor(State.Camera.ViewportSize.Y * 0.6)
                return content, math.min(content, maxH)
            end

            local function SyncSettingsFrame(animated)
                local fullH, viewH = GetSettingsHeights()
                SettingsFrame.CanvasSize = UDim2.new(0, 0, 0, fullH)
                SettingsFrame.ScrollBarThickness = fullH > viewH and 3 or 0
                if Module.SettingsOpen then
                    if animated then
                        Ui.Tween(SettingsFrame, {Size = UDim2.new(1, -12, 0, viewH)}, 0.2)
                    else
                        SettingsFrame.Size = UDim2.new(1, -12, 0, viewH)
                    end
                end
                local maxY = math.max(0, fullH - viewH)
                if SettingsFrame.CanvasPosition.Y > maxY then
                    SettingsFrame.CanvasPosition = Vector2.new(0, maxY)
                end
            end

            local function Toggle()
                Module:SetEnabled(not Module.Enabled, false)
            end
            Module._toggleFromKeybind = Toggle

            local isBinding = false

            table.insert(State.UnloadConnections, Button.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 and not isBinding then
                    if rowScale then
                        Ui.PulseScale(rowScale, 0.94, 0.05, 0.16)
                    end
                    Toggle()
                elseif input.UserInputType == Enum.UserInputType.MouseButton2 and Module.HasSettings then
                    Module.SettingsOpen = not Module.SettingsOpen
                    SettingsFrame.Visible = true
                    SettingsFrame.CanvasPosition = Vector2.new(0, 0)
                    if Module.SettingsOpen then
                        SyncSettingsFrame(true)
                        if settingsStroke then
                            Ui.Tween(settingsStroke, {Transparency = 0.2, Color = Settings.Colors.Accent}, Theme.Anim.Fast)
                        end
                        if settingsGradient then
                            Ui.Tween(settingsGradient, {Offset = Vector2.new(0, 0.2), Rotation = 106}, Theme.Anim.Normal)
                        end
                        if settingsStrokeGradient then
                            Ui.Tween(settingsStrokeGradient, {Offset = Vector2.new(0, 0.2), Rotation = 122}, Theme.Anim.Normal)
                        end
                    else
                        Ui.Tween(SettingsFrame, {Size = UDim2.new(1, -12, 0, 0)}, 0.3)
                        if settingsStroke then
                            settingsStroke.Color = UiAccentMid
                            Ui.Tween(settingsStroke, {Transparency = 0.42}, Theme.Anim.Fast)
                        end
                        if settingsGradient then
                            Ui.Tween(settingsGradient, {Offset = Vector2.new(0, 0.6), Rotation = 82}, Theme.Anim.Normal)
                        end
                        if settingsStrokeGradient then
                            Ui.Tween(settingsStrokeGradient, {Offset = Vector2.new(0, 0.52), Rotation = 104}, Theme.Anim.Normal)
                        end
                    end
                    task.delay(0.3, function() if not Module.SettingsOpen then SettingsFrame.Visible = false end end)
                    task.wait(0.1); UpdateSize(); task.wait(0.25); UpdateSize()
                elseif input.UserInputType == Enum.UserInputType.MouseButton3 then
                    isBinding = true
                    SetModuleKeybindCapture(true)
                    BindLabel.Text = "..."
                    BindLabel.TextColor3 = Settings.Colors.Accent
                    local previousKey = Module.Keybind
                    local conn
                    conn = Services.UserInputService.InputBegan:Connect(function(k)
                        if k.UserInputType == Enum.UserInputType.Keyboard then
                            if k.KeyCode == KEY_ESCAPE then
                                Module:SetKeybind(previousKey, true)
                            elseif k.KeyCode == KEY_DELETE then
                                Module:SetKeybind(nil, true)
                            else
                                Module:SetKeybind(k.KeyCode, true)
                            end
                            Module:RefreshBind()
                            BindLabel.TextColor3 = UiTextMuted
                            isBinding = false
                            SetModuleKeybindCapture(false)
                            conn:Disconnect()
                            Library:UpdateHotkeys()
                        end
                    end)
                end
            end))


            SettingsList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                SyncSettingsFrame(false)
                if Module.SettingsOpen then
                    UpdateSize()
                end
            end)
