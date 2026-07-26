
            function Module:AddLabel(text)
                Module.HasSettings = true
                Dots.Visible = true

                local Frame = Instance.new("Frame")
                Frame.Parent = SettingsFrame
                Frame.BackgroundColor3 = UiFieldBg
                Frame.BackgroundTransparency = 0.06
                Frame.BorderSizePixel = 0
                Frame.Size = UDim2.new(1, 0, 0, 32)
                Frame.ZIndex = 8
                Ui.ApplyCorner(Frame, Theme.Corner.Small)
                Ui.ApplyStroke(Frame, UiButtonBorder, 0.42, 1)

                local Label = Instance.new("TextLabel")
                Label.Parent = Frame
                Label.Text = tostring(text or "")
                Label.TextColor3 = UiTextSoft
                Label.Font = Enum.Font.GothamSemibold
                Label.TextSize = 12
                Label.BackgroundTransparency = 1
                Label.Position = UDim2.new(0, 10, 0, 0)
                Label.Size = UDim2.new(1, -20, 1, 0)
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.TextTruncate = Enum.TextTruncate.AtEnd
                Label.ZIndex = 9

                local LabelControl = {Frame = Frame, Label = Label}
                function LabelControl:SetText(value)
                    Label.Text = tostring(value or "")
                end

                return LabelControl
            end
