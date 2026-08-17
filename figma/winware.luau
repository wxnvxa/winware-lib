-- WinWare UI Library
-- Derived from the MIT-licensed NeverLose Roblox UI project by 4lpacaLoL.

local WinWare = {}

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

WinWare.Flags = {}
WinWare.Theme = {
	Accent = Color3.fromRGB(60, 126, 255),
	AccentFill = Color3.fromRGB(0, 86, 255),
	Background = Color3.fromRGB(11, 11, 11),
	Card = Color3.fromRGB(17, 17, 17),
	Control = Color3.fromRGB(11, 11, 11),
	Stroke = Color3.fromRGB(255, 255, 255),
	Text = Color3.fromRGB(206, 206, 206),
	Muted = Color3.fromRGB(76, 76, 76),
}

local function font(weight)
	return Font.new("rbxasset://fonts/families/Montserrat.json", weight, Enum.FontStyle.Normal)
end

local FontMedium = font(Enum.FontWeight.Medium)
local FontSemiBold = font(Enum.FontWeight.SemiBold)
local FontBold = font(Enum.FontWeight.Bold)
local IconFont = Font.new(
	"rbxasset://LuaPackages/Packages/_Index/BuilderIcons/BuilderIcons/BuilderIcons.json",
	Enum.FontWeight.Regular,
	Enum.FontStyle.Normal
)

local function create(className, properties, parent)
	local instance = Instance.new(className)
	for property, value in pairs(properties) do
		instance[property] = value
	end
	instance.Parent = parent
	return instance
end

local function tween(instance, properties, duration)
	TweenService:Create(
		instance,
		TweenInfo.new(duration or 0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
		properties
	):Play()
end

local function corner(parent, radius)
	return create("UICorner", { CornerRadius = UDim.new(0, radius) }, parent)
end

local function stroke(parent, color, transparency, thickness)
	return create("UIStroke", {
		Color = color or WinWare.Theme.Stroke,
		Transparency = transparency or 0.95,
		Thickness = thickness or 1,
	}, parent)
end

local function hitbox(parent, callback)
	local button = create("TextButton", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		Text = "",
		ZIndex = parent.ZIndex + 5,
	}, parent)
	button.Activated:Connect(callback)
	return button
end

local function icon(parent, iconName, position, size, color)
	return create("TextLabel", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = position,
		Size = size,
		FontFace = IconFont,
		Text = iconName,
		TextColor3 = color or WinWare.Theme.Text,
		TextSize = size.Y.Offset * 0.72,
		TextTransparency = 0,
		ZIndex = parent.ZIndex + 1,
	}, parent)
end

local function text(parent, value, position, size, textSize, textColor, fontFace, alignment)
	return create("TextLabel", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = position,
		Size = size,
		FontFace = fontFace or FontMedium,
		Text = value,
		TextColor3 = textColor or WinWare.Theme.Text,
		TextSize = textSize,
		TextXAlignment = alignment or Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
		ZIndex = parent.ZIndex + 1,
	}, parent)
end

local function updateFlag(flag, value, callback)
	if flag then
		WinWare.Flags[flag] = value
	end
	if callback then
		task.spawn(callback, value)
	end
end

function WinWare:CreateWindow(config)
	config = config or {}
	local size = config.Size or UDim2.fromOffset(1250, 800)
	local keybind = config.Keybind or Enum.KeyCode.Insert
	local parent = config.Parent or LocalPlayer:WaitForChild("PlayerGui")

	local screenGui = create("ScreenGui", {
		Name = config.Name or "WinWare",
		IgnoreGuiInset = true,
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		DisplayOrder = config.DisplayOrder or 50,
	}, parent)

	local main = create("Frame", {
		Name = "Window",
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = WinWare.Theme.Background,
		BackgroundTransparency = 0.1,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = size,
		ZIndex = 10,
	}, screenGui)
	corner(main, 20)
	stroke(main, WinWare.Theme.Stroke, 0.95)

	local scaler = create("UIScale", { Scale = 1 }, main)
	local baseSize = Vector2.new(size.X.Offset, size.Y.Offset)
	local requestedScale = config.Scale or 1
	local cameraConnection
	local function refreshScale()
		local camera = Workspace.CurrentCamera
		if not camera then
			return
		end
		local viewport = camera.ViewportSize
		local available = Vector2.new(math.max(viewport.X - 40, 1), math.max(viewport.Y - 40, 1))
		scaler.Scale = math.min(available.X / baseSize.X, available.Y / baseSize.Y) * requestedScale
	end
	refreshScale()
	if Workspace.CurrentCamera then
		cameraConnection = Workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(refreshScale)
	end

	local header = create("Frame", {
		Active = true,
		Name = "Header",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(1250, 100),
		ZIndex = 11,
	}, main)
	local headerLine = create("Frame", {
		BackgroundColor3 = WinWare.Theme.Stroke,
		BackgroundTransparency = 0.95,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 1, -1),
		Size = UDim2.new(1, 0, 0, 1),
		ZIndex = 12,
	}, header)

	local sidebar = create("Frame", {
		Name = "Sidebar",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(0, 100),
		Size = UDim2.fromOffset(250, 700),
		ZIndex = 11,
	}, main)
	create("Frame", {
		BackgroundColor3 = WinWare.Theme.Stroke,
		BackgroundTransparency = 0.95,
		BorderSizePixel = 0,
		Position = UDim2.new(1, -1, 0, -100),
		Size = UDim2.new(0, 1, 1, 100),
		ZIndex = 12,
	}, sidebar)

	local title = text(header, config.Title or "WINWARE", UDim2.fromOffset(40, 0), UDim2.fromOffset(170, 100), 30, WinWare.Theme.Accent, FontBold)
	local titleGradient = create("UIGradient", {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(27, 39, 88)),
			ColorSequenceKeypoint.new(1, WinWare.Theme.Accent),
		}),
	}, title)
	titleGradient.Rotation = 0
	create("Frame", {
		BackgroundColor3 = WinWare.Theme.Stroke,
		BackgroundTransparency = 0.95,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(249, 0),
		Size = UDim2.fromOffset(1, 100),
		ZIndex = 12,
	}, header)

	local content = create("Frame", {
		Name = "Content",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(250, 100),
		Size = UDim2.fromOffset(1000, 700),
		ZIndex = 11,
	}, main)

	local navigation = create("ScrollingFrame", {
		Name = "Navigation",
		Active = true,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		CanvasSize = UDim2.new(),
		Position = UDim2.fromOffset(10, 10),
		ScrollBarThickness = 0,
		Size = UDim2.fromOffset(230, 480),
		ZIndex = 12,
	}, sidebar)
	local navLayout = create("UIListLayout", {
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		Padding = UDim.new(0, 0),
		SortOrder = Enum.SortOrder.LayoutOrder,
	}, navigation)
	navLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		navigation.CanvasSize = UDim2.fromOffset(0, navLayout.AbsoluteContentSize.Y + 10)
	end)

	local account = create("Frame", {
		Name = "Account",
		AnchorPoint = Vector2.new(0, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 1, 0),
		Size = UDim2.fromOffset(250, 100),
		ZIndex = 12,
	}, sidebar)
	create("Frame", {
		BackgroundColor3 = WinWare.Theme.Stroke,
		BackgroundTransparency = 0.95,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 1),
		ZIndex = 13,
	}, account)

	local avatar = create("ImageLabel", {
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0,
		Image = "",
		Position = UDim2.fromOffset(16, 25),
		Size = UDim2.fromOffset(48, 48),
		ZIndex = 13,
	}, account)
	corner(avatar, 22)
	stroke(avatar, Color3.fromRGB(77, 255, 158), 0, 2.5)
	local accountName = text(account, config.Username or LocalPlayer.Name, UDim2.fromOffset(75, 25), UDim2.fromOffset(155, 22), 15, Color3.fromRGB(18, 168, 96), FontSemiBold)
	local accountExpiry = text(account, config.Expires or "Until August 15, 2026", UDim2.fromOffset(75, 47), UDim2.fromOffset(155, 20), 12, Color3.fromRGB(145, 145, 145), FontSemiBold)

	local success, image = pcall(function()
		return Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
	end)
	if success then
		avatar.Image = image
	end

	local window = {
		Gui = screenGui,
		Frame = main,
		Tabs = {},
		Sections = {},
		CurrentTab = nil,
		Visible = true,
		Content = content,
		Navigation = navigation,
		SectionY = {},
		NavOrder = 0,
	}

	local dragging = false
	local dragStart
	local startPosition
	header.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPosition = main.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			main.Position = UDim2.new(startPosition.X.Scale, startPosition.X.Offset + delta.X, startPosition.Y.Scale, startPosition.Y.Offset + delta.Y)
		end
	end)

	function window:SetAccount(data)
		data = data or {}
		accountName.Text = data.Username or accountName.Text
		accountExpiry.Text = data.Expires or accountExpiry.Text
		avatar.Image = data.Profile or avatar.Image
	end

	function window:SetScale(value)
		requestedScale = value
		refreshScale()
	end

	function window:ToggleInterface(value)
		self.Visible = if value == nil then not self.Visible else value
		main.Visible = self.Visible
	end

	function window:Destroy()
		if cameraConnection then
			cameraConnection:Disconnect()
		end
		screenGui:Destroy()
	end

	UserInputService.InputBegan:Connect(function(input, processed)
		if not processed and input.KeyCode == keybind then
			window:ToggleInterface()
		end
	end)

	function window:AddTabLabel(name)
		local label = text(navigation, name, UDim2.new(), UDim2.fromOffset(230, 18), 15, Color3.fromRGB(51, 51, 51), FontSemiBold, Enum.TextXAlignment.Center)
		label.LayoutOrder = self.NavOrder
		self.NavOrder += 1
		return label
	end

	function window:AddTab(tabConfig)
		tabConfig = tabConfig or {}
		local tab = { Name = tabConfig.Name or "Tab", Sections = {}, Window = self }
		local button = create("Frame", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.fromOffset(230, 65),
			ZIndex = 13,
		}, navigation)
		button.LayoutOrder = self.NavOrder
		self.NavOrder += 1
		corner(button, 11)
		local tabStroke = stroke(button, Color3.fromRGB(21, 40, 78), 1, 2)
		local iconLabel = icon(button, tabConfig.Icon or "square", UDim2.fromOffset(10, 15), UDim2.fromOffset(35, 35))
		local nameLabel = text(button, tab.Name, UDim2.fromOffset(55, 0), UDim2.fromOffset(165, 65), 18, Color3.fromRGB(219, 219, 219), FontMedium)
		local tabContent = create("Frame", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.fromScale(1, 1),
			Visible = false,
			ZIndex = 12,
		}, content)
		tab.Button = button
		tab.Content = tabContent

		function tab:SetActive(active)
			tabContent.Visible = active
			if active then
				button.BackgroundColor3 = Color3.fromRGB(18, 41, 85)
				button.BackgroundTransparency = 0.9
				tabStroke.Transparency = 0.75
				iconLabel.TextColor3 = WinWare.Theme.Accent
				nameLabel.TextColor3 = WinWare.Theme.Accent
			else
				button.BackgroundTransparency = 1
				tabStroke.Transparency = 1
				iconLabel.TextColor3 = Color3.fromRGB(219, 219, 219)
				nameLabel.TextColor3 = Color3.fromRGB(219, 219, 219)
			end
		end

		function tab:AddSection(sectionConfig)
			sectionConfig = sectionConfig or {}
			local position = string.lower(sectionConfig.Position or "left")
			local section = {
				Name = sectionConfig.Name or "SECTION",
				Tab = tab,
				Position = position,
				Rows = 0,
			}
			local root = create("Frame", {
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = UDim2.fromOffset(470, 30),
				ZIndex = 13,
			}, tabContent)
			text(root, section.Name, UDim2.new(), UDim2.fromOffset(470, 24), 20, WinWare.Theme.Muted, FontSemiBold)
			local card = create("Frame", {
				BackgroundColor3 = WinWare.Theme.Card,
				BorderSizePixel = 0,
				Position = UDim2.fromOffset(0, 30),
				Size = UDim2.fromOffset(470, 0),
				ZIndex = 13,
			}, root)
			corner(card, 20)
			stroke(card, WinWare.Theme.Stroke, 0.95, 2)
			local layout = create("UIListLayout", {
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
			}, card)
			section.Root = root
			section.Card = card
			section.Layout = layout

			local function refresh()
				local contentHeight = layout.AbsoluteContentSize.Y
				card.Size = UDim2.fromOffset(470, contentHeight)
				root.Size = UDim2.fromOffset(470, contentHeight + 30)
				local y = 25
				for _, item in ipairs(tab.Sections) do
					if item.Position == position then
						item.Root.Position = UDim2.fromOffset(position == "right" and 515 or 15, y)
						y += item.Root.Size.Y.Offset + 10
					end
				end
			end
			layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(refresh)

			local function addDivider()
				if section.Rows > 0 then
					create("Frame", {
						BackgroundColor3 = WinWare.Theme.Stroke,
						BackgroundTransparency = 0.97,
						BorderSizePixel = 0,
						Size = UDim2.fromOffset(441, 2),
						ZIndex = 14,
					}, card)
				end
				section.Rows += 1
			end

			local function row(name)
				addDivider()
				local frame = create("Frame", {
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Size = UDim2.fromOffset(470, 65),
					ZIndex = 14,
				}, card)
				text(frame, name, UDim2.fromOffset(15, 0), UDim2.fromOffset(250, 65), 20, WinWare.Theme.Text, FontMedium)
				return frame
			end

			function section:AddToggle(elementConfig)
				elementConfig = elementConfig or {}
				local name = elementConfig.Name or "Toggle"
				local value = elementConfig.Default == true
				local item = row(name)
				local switch = create("Frame", {
					AnchorPoint = Vector2.new(1, 0.5),
					BackgroundColor3 = value and WinWare.Theme.AccentFill or WinWare.Theme.Control,
					BorderSizePixel = 0,
					Position = UDim2.new(1, -15, 0.5, 0),
					Size = UDim2.fromOffset(75, 45),
					ZIndex = 15,
				}, item)
				corner(switch, 20)
				local knob = create("Frame", {
					BackgroundColor3 = value and Color3.fromRGB(243, 242, 242) or Color3.fromRGB(77, 77, 77),
					BorderSizePixel = 0,
					Position = UDim2.fromOffset(value and 35 or 5, 5),
					Size = UDim2.fromOffset(35, 35),
					ZIndex = 16,
				}, switch)
				corner(knob, 15)
				local control = {}
				function control:SetValue(nextValue)
					value = nextValue == true
					tween(switch, { BackgroundColor3 = value and WinWare.Theme.AccentFill or WinWare.Theme.Control })
					tween(knob, {
						BackgroundColor3 = value and Color3.fromRGB(243, 242, 242) or Color3.fromRGB(77, 77, 77),
						Position = UDim2.fromOffset(value and 35 or 5, 5),
					})
					updateFlag(elementConfig.Flag, value, elementConfig.Callback)
				end
				function control:GetValue()
					return value
				end
				hitbox(switch, function()
					control:SetValue(not value)
				end)
				control:SetValue(value)
				return control
			end

			function section:AddSlider(elementConfig)
				elementConfig = elementConfig or {}
				local minimum = elementConfig.Min or 0
				local maximum = elementConfig.Max or 100
				local value = math.clamp(elementConfig.Default or minimum, minimum, maximum)
				local item = row(elementConfig.Name or "Slider")
				local track = create("Frame", {
					Active = true,
					AnchorPoint = Vector2.new(1, 0.5),
					BackgroundColor3 = WinWare.Theme.Control,
					BorderSizePixel = 0,
					Position = UDim2.new(1, -95, 0.5, 0),
					Size = UDim2.fromOffset(270, 45),
					ZIndex = 15,
				}, item)
				corner(track, 14)
				local fill = create("Frame", {
					BackgroundColor3 = WinWare.Theme.AccentFill,
					BorderSizePixel = 0,
					Position = UDim2.fromOffset(5, 5),
					Size = UDim2.fromOffset(0, 35),
					ZIndex = 16,
				}, track)
				corner(fill, 10)
				local thumb = create("Frame", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundColor3 = Color3.fromRGB(243, 242, 242),
					BorderSizePixel = 0,
					Position = UDim2.fromOffset(5, 22.5),
					Size = UDim2.fromOffset(36, 36),
					ZIndex = 17,
				}, track)
				corner(thumb, 11)
				local valueLabel = text(item, tostring(value), UDim2.new(1, -85, 0.5, -22), UDim2.fromOffset(70, 45), 18, WinWare.Theme.Text, FontMedium, Enum.TextXAlignment.Center)
				local control = {}
				function control:SetValue(nextValue)
					value = math.clamp(math.round(nextValue), minimum, maximum)
					local alpha = (value - minimum) / math.max(maximum - minimum, 1)
					fill.Size = UDim2.fromOffset(math.max(0, 260 * alpha), 35)
					thumb.Position = UDim2.fromOffset(5 + 260 * alpha, 22.5)
					valueLabel.Text = tostring(value)
					updateFlag(elementConfig.Flag, value, elementConfig.Callback)
				end
				function control:GetValue()
					return value
				end
				local draggingSlider = false
				local function setFromInput(input)
					local alpha = math.clamp((input.Position.X - track.AbsolutePosition.X - 5) / 260, 0, 1)
					control:SetValue(minimum + (maximum - minimum) * alpha)
				end
				track.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						draggingSlider = true
						setFromInput(input)
					end
				end)
				UserInputService.InputChanged:Connect(function(input)
					if draggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
						setFromInput(input)
					end
				end)
				UserInputService.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						draggingSlider = false
					end
				end)
				control:SetValue(value)
				return control
			end

			function section:AddDropdown(elementConfig)
				elementConfig = elementConfig or {}
				local values = elementConfig.Values or { "None" }
				local value = elementConfig.Default or values[1]
				local item = row(elementConfig.Name or "Dropdown")
				local select = create("TextButton", {
					AnchorPoint = Vector2.new(1, 0.5),
					BackgroundColor3 = WinWare.Theme.Control,
					BorderSizePixel = 0,
					Position = UDim2.new(1, -15, 0.5, 0),
					Size = UDim2.fromOffset(150, 45),
					Text = "",
					ZIndex = 15,
				}, item)
				corner(select, 14)
				local selectedText = text(select, tostring(value), UDim2.fromOffset(0, 0), UDim2.fromOffset(105, 45), 18, WinWare.Theme.Text, FontMedium, Enum.TextXAlignment.Center)
				icon(select, "chevron-small-down", UDim2.fromOffset(120, 12), UDim2.fromOffset(20, 20))
				local choices = create("Frame", {
					BackgroundColor3 = WinWare.Theme.Card,
					BorderSizePixel = 0,
					Position = UDim2.fromOffset(0, 48),
					Size = UDim2.fromOffset(150, 0),
					Visible = false,
					ZIndex = 30,
				}, select)
				corner(choices, 12)
				stroke(choices, WinWare.Theme.Stroke, 0.95)
				local choiceLayout = create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder }, choices)
				local control = {}
				function control:SetValue(nextValue)
					value = nextValue
					selectedText.Text = tostring(value)
					choices.Visible = false
					updateFlag(elementConfig.Flag, value, elementConfig.Callback)
				end
				function control:GetValue()
					return value
				end
				for _, option in ipairs(values) do
					local optionButton = create("TextButton", {
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						Size = UDim2.fromOffset(150, 35),
						FontFace = FontMedium,
						Text = tostring(option),
						TextColor3 = WinWare.Theme.Text,
						TextSize = 16,
						ZIndex = 31,
					}, choices)
					optionButton.Activated:Connect(function()
						control:SetValue(option)
					end)
				end
				choiceLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
					choices.Size = UDim2.fromOffset(150, choiceLayout.AbsoluteContentSize.Y)
				end)
				select.Activated:Connect(function()
					choices.Visible = not choices.Visible
				end)
				control:SetValue(value)
				return control
			end

			table.insert(tab.Sections, section)
			refresh()
			return section
		end

		table.insert(self.Tabs, tab)
		hitbox(button, function()
			for _, otherTab in ipairs(self.Tabs) do
				otherTab:SetActive(otherTab == tab)
			end
			self.CurrentTab = tab
		end)
		if #self.Tabs == 1 then
			tab:SetActive(true)
			self.CurrentTab = tab
		end
		return tab
	end

	return window
end

return WinWare
