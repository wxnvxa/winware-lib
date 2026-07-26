
    function Library:CreateWindow(name)
        local Window = {}
        -- Main content panel aligned to the center layout
        local baseX = Theme.Layout.MainX or (Theme.Layout.Edge + Theme.Layout.CategoryWidth + Theme.Layout.Gap)
        local baseY = Theme.Layout.MainY or Theme.Layout.Top
        local MainFrame = NewUIContainer(); MainFrame.Name = name .. "Window"; MainFrame.Parent = ScreenGui; MainFrame.Position = UDim2.new(0, baseX, 0, baseY); MainFrame.Size = UDim2.new(0, Settings.Layout.WindowWidth, 0, 40); MainFrame.BackgroundColor3 = UiPanelBlack; MainFrame.Visible = false; MainFrame.ClipsDescendants = true; MainFrame.ZIndex = 5;
        if MainFrame:IsA("CanvasGroup") then
            MainFrame.GroupTransparency = 0
            MainFrame.GroupColor3 = CanvasGroupColor
        end
        local Corner = Instance.new("UICorner"); Corner.CornerRadius = UDim.new(0, Theme.Corner.Window); Corner.Parent = MainFrame
        if Ui.ApplyShadow then Ui.ApplyShadow(MainFrame) end
        local Stroke = Instance.new("UIStroke"); Stroke.Color = UiBorder; Stroke.Transparency = 0.5; Stroke.Thickness = 1; Stroke.Parent = MainFrame
        local winFrom, winTo = UiPanelBlack, UiPanelDark
        local MainGradient = Ui.ApplyGradient(MainFrame, winFrom, winTo, 78)
        local StrokeGradient = Ui.ApplyGradient(Stroke, UiBorderSoft, UiBorder, 98)
        if MainGradient then
            MainGradient.Offset = Vector2.new(0, 0.55)
        end
        local headerH = 54
        local Header = Instance.new("Frame"); Header.Parent = MainFrame; Header.BackgroundTransparency = 1; Header.Size = UDim2.new(1, 0, 0, headerH); Header.ZIndex = 6
        local HeaderDivider = Instance.new("Frame", Header)
        HeaderDivider.BackgroundColor3 = UiBorderSoft
        HeaderDivider.BackgroundTransparency = 0.62
        HeaderDivider.BorderSizePixel = 0
        HeaderDivider.Position = UDim2.new(0, 12, 1, -1)
        HeaderDivider.Size = UDim2.new(1, -24, 0, 1)
        HeaderDivider.ZIndex = 7
        local Title = Instance.new("TextLabel"); Title.Parent = Header; Title.Text = ""; Title.Font = Enum.Font.GothamBold; Title.TextSize = 13; Title.TextColor3 = Settings.Colors.TextWhite; Title.BackgroundTransparency = 1; Title.Position = UDim2.new(0, 14, 0, 0); Title.Size = UDim2.new(1, -24, 1, 0); Title.TextXAlignment = Enum.TextXAlignment.Left; Title.ZIndex = 7
        local MainScale = Instance.new("UIScale", MainFrame); MainScale.Scale = 1
        Window.Name = name
        Window.Frame = MainFrame
        Window._scale = MainScale
        Window._gradient = MainGradient
        Window._strokeGradient = StrokeGradient
        Library:RegisterCategory(name, MainFrame)
        local Container = Instance.new("ScrollingFrame"); Container.Parent = MainFrame; Container.BackgroundTransparency = 1; Container.Position = UDim2.new(0, 0, 0, headerH); Container.Size = UDim2.new(1, 0, 0, 0); Container.ClipsDescendants = true; Container.ZIndex = 6; Container.BorderSizePixel = 0; Container.CanvasSize = UDim2.new(0, 0, 0, 0); Container.ScrollBarThickness = 0; Container.ScrollBarImageColor3 = UiAccentSoft; Container.ScrollBarImageTransparency = 0.25; Container.ScrollingDirection = Enum.ScrollingDirection.Y
        Window.Container = Container
        table.insert(Library.Windows, Window)
        local ContentRoot = Instance.new("Frame", Container)
        ContentRoot.BackgroundTransparency = 1
        ContentRoot.Position = UDim2.new(0, 12, 0, 10)
        ContentRoot.Size = UDim2.new(1, -24, 0, 0)
        ContentRoot.ZIndex = 6

        local ContentLayout = Instance.new("UIListLayout"); ContentLayout.Parent = ContentRoot; ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder; ContentLayout.Padding = UDim.new(0, 10)

        local ModuleGrid = Instance.new("Frame", ContentRoot)
        ModuleGrid.BackgroundTransparency = 1
        ModuleGrid.Size = UDim2.new(1, 0, 0, 0)
        ModuleGrid.LayoutOrder = 1
        ModuleGrid.ZIndex = 6

        local ModuleColumns = Instance.new("UIListLayout", ModuleGrid)
        ModuleColumns.FillDirection = Enum.FillDirection.Horizontal
        ModuleColumns.HorizontalAlignment = Enum.HorizontalAlignment.Left
        ModuleColumns.SortOrder = Enum.SortOrder.LayoutOrder
        ModuleColumns.Padding = UDim.new(0, 10)

        local LeftColumn = Instance.new("Frame", ModuleGrid)
        LeftColumn.BackgroundTransparency = 1
        LeftColumn.Size = UDim2.new(0.5, -5, 0, 0)
        LeftColumn.AutomaticSize = Enum.AutomaticSize.Y
        LeftColumn.LayoutOrder = 1
        LeftColumn.ZIndex = 6
        local LeftLayout = Instance.new("UIListLayout", LeftColumn)
        LeftLayout.SortOrder = Enum.SortOrder.LayoutOrder
        LeftLayout.Padding = UDim.new(0, 8)
        LeftLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

        local RightColumn = Instance.new("Frame", ModuleGrid)
        RightColumn.BackgroundTransparency = 1
        RightColumn.Size = UDim2.new(0.5, -5, 0, 0)
        RightColumn.AutomaticSize = Enum.AutomaticSize.Y
        RightColumn.LayoutOrder = 2
        RightColumn.ZIndex = 6
        local RightLayout = Instance.new("UIListLayout", RightColumn)
        RightLayout.SortOrder = Enum.SortOrder.LayoutOrder
        RightLayout.Padding = UDim.new(0, 8)
        RightLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

        local UtilityStack = Instance.new("Frame", ContentRoot)
        UtilityStack.BackgroundTransparency = 1
        UtilityStack.Size = UDim2.new(1, 0, 0, 0)
        UtilityStack.AutomaticSize = Enum.AutomaticSize.Y
        UtilityStack.LayoutOrder = 2
        UtilityStack.ZIndex = 6
        local UtilityLayout = Instance.new("UIListLayout", UtilityStack)
        UtilityLayout.SortOrder = Enum.SortOrder.LayoutOrder
        UtilityLayout.Padding = UDim.new(0, 8)

        Window._leftColumn = LeftColumn
        Window._rightColumn = RightColumn
        Window._leftLayout = LeftLayout
        Window._rightLayout = RightLayout
        Window._utilityStack = UtilityStack
        Window._moduleCount = 0

        local function UpdateSize()
            local maxHeight = Theme.Layout.WindowMaxHeight or 420
            local viewHeight = math.max(140, maxHeight - headerH)
            local contentWidth = math.max(260, (Theme.Layout.WindowWidth or Settings.Layout.WindowWidth) - 24)
            ContentRoot.Size = UDim2.new(0, contentWidth, 0, ContentRoot.Size.Y.Offset)
            ModuleGrid.Size = UDim2.new(1, 0, 0, math.max(LeftLayout.AbsoluteContentSize.Y, RightLayout.AbsoluteContentSize.Y))
            UtilityStack.Visible = UtilityLayout.AbsoluteContentSize.Y > 0
            local height = ContentLayout.AbsoluteContentSize.Y + 20
            ContentRoot.Size = UDim2.new(0, contentWidth, 0, height)
            Container.CanvasSize = UDim2.new(0, 0, 0, height)
            Container.ScrollBarThickness = height > viewHeight and 3 or 0
            Container.Size = UDim2.new(1, 0, 0, viewHeight)
            MainFrame.Size = UDim2.new(0, Theme.Layout.WindowWidth, 0, maxHeight)
        end
        ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateSize)
        LeftLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateSize)
        RightLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateSize)
        UtilityLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateSize)
        Window.UpdateLayout = UpdateSize
        UpdateSize()

        Window._moduleEntries = {}
        function Window:ApplySearch(query)
            local q = (query or ""):lower()
            for _, mod in ipairs(Window._moduleEntries or {}) do
                local match = (q == "" or tostring(mod.Name):lower():find(q, 1, true) ~= nil)
                if mod._button then mod._button.Visible = match end
                if mod._settingsFrame then
                    if not match then
                        mod.SettingsOpen = false
                        mod._settingsFrame.Visible = false
                    end
                end
            end
            UpdateSize()
        end
        table.insert(State.UnloadConnections, Container:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
            Settings.UIState.WindowScroll[name] = {x = Container.CanvasPosition.X, y = Container.CanvasPosition.Y}
        end))
        if Settings.UIState.WindowScroll[name] then
            local stored = Settings.UIState.WindowScroll[name]
            if type(stored) == "table" and stored.x and stored.y then
                Container.CanvasPosition = Vector2.new(stored.x, stored.y)
            end
        end
