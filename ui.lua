local Library = {
    Version = "4.0 macOS Edition",
    Theme = {
        Background = Color3.fromRGB(24, 24, 26), -- macOS dark mode
        Container = Color3.fromRGB(32, 32, 35),
        Element = Color3.fromRGB(42, 42, 46),
        ElementHover = Color3.fromRGB(52, 52, 56),
        Accent = Color3.fromRGB(10, 132, 255), -- iOS Blue
        Text = Color3.fromRGB(245, 245, 245),
        TextMuted = Color3.fromRGB(140, 140, 145),
        Border = Color3.fromRGB(255, 255, 255),
        BorderOpacity = 0.15,
        
        -- Traffic Lights
        Close = Color3.fromRGB(255, 95, 86),
        Minimize = Color3.fromRGB(255, 189, 46),
        Maximize = Color3.fromRGB(39, 201, 63),
        
        -- Notifications
        Success = Color3.fromRGB(48, 209, 88),
        Error = Color3.fromRGB(255, 69, 58),
        Warning = Color3.fromRGB(255, 159, 10),
        Info = Color3.fromRGB(10, 132, 255)
    }
}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local function GetGuiParent()
    local success, parent = pcall(function() return CoreGui end)
    if success and parent then return parent end
    return Players.LocalPlayer:WaitForChild("PlayerGui")
end

-- ========================================================================
-- UTILITY FUNCTIONS
-- ========================================================================
local Utility = {}

function Utility:Tween(instance, prop, time, style, direction)
    time = time or 0.25
    style = style or Enum.EasingStyle.Quint
    direction = direction or Enum.EasingDirection.Out
    local tweenInfo = TweenInfo.new(time, style, direction)
    local tween = TweenService:Create(instance, tweenInfo, prop)
    tween:Play()
    return tween
end

function Utility:MakeDraggable(trigger, target)
    target = target or trigger
    local dragging = false
    local dragInput, dragStart, startPos

    trigger.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = target.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    trigger.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            Utility:Tween(target, {
                Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            }, 0.15, Enum.EasingStyle.Quad)
        end
    end)
end

function Utility:ApplyBorder(parent, transparency)
    local stroke = Instance.new("UIStroke")
    stroke.Color = Library.Theme.Border
    stroke.Thickness = 1
    stroke.Transparency = transparency or Library.Theme.BorderOpacity
    stroke.Parent = parent
    return stroke
end

-- ========================================================================
-- NOTIFICATION SYSTEM
-- ========================================================================
local NotifGui = Instance.new("ScreenGui")
NotifGui.Name = "macOSNotifGUI"
NotifGui.Parent = GetGuiParent()
NotifGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local NotifContainer = Instance.new("Frame")
NotifContainer.Name = "NotifContainer"
NotifContainer.Size = UDim2.new(0, 320, 1, -40)
NotifContainer.Position = UDim2.new(1, -340, 0, 20)
NotifContainer.BackgroundTransparency = 1
NotifContainer.Parent = NotifGui

local NotifListLayout = Instance.new("UIListLayout")
NotifListLayout.SortOrder = Enum.SortOrder.LayoutOrder
NotifListLayout.Padding = UDim.new(0, 12)
NotifListLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
NotifListLayout.Parent = NotifContainer

function Library:Notify(config)
    config = config or {}
    local title = config.Title or "Notification"
    local content = config.Content or ""
    local duration = config.Duration or 3
    local typeColor = Library.Theme.Accent
    
    if config.Type == "Success" then typeColor = Library.Theme.Success
    elseif config.Type == "Error" then typeColor = Library.Theme.Error
    elseif config.Type == "Warning" then typeColor = Library.Theme.Warning
    elseif config.Type == "Info" then typeColor = Library.Theme.Info end

    local notif = Instance.new("Frame")
    notif.Size = UDim2.new(1, 0, 0, 0)
    notif.BackgroundColor3 = Library.Theme.Element
    notif.BackgroundTransparency = 0.1 -- Glass effect
    notif.ClipsDescendants = true
    notif.Parent = NotifContainer
    Instance.new("UICorner", notif).CornerRadius = UDim.new(0, 12)
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = typeColor
    stroke.Transparency = 0.4
    stroke.Thickness = 1
    stroke.Parent = notif

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Text = title
    titleLbl.Font = Enum.Font.GothamMedium
    titleLbl.TextSize = 14
    titleLbl.TextColor3 = Library.Theme.Text
    titleLbl.Size = UDim2.new(1, -20, 0, 20)
    titleLbl.Position = UDim2.new(0, 15, 0, 10)
    titleLbl.BackgroundTransparency = 1
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Parent = notif

    local descLbl = Instance.new("TextLabel")
    descLbl.Text = content
    descLbl.Font = Enum.Font.Gotham
    descLbl.TextSize = 12
    descLbl.TextColor3 = Library.Theme.TextMuted
    descLbl.Size = UDim2.new(1, -30, 0, 20)
    descLbl.Position = UDim2.new(0, 15, 0, 30)
    descLbl.BackgroundTransparency = 1
    descLbl.TextXAlignment = Enum.TextXAlignment.Left
    descLbl.TextWrapped = true
    descLbl.Parent = notif
    
    local barBG = Instance.new("Frame")
    barBG.Size = UDim2.new(1, 0, 0, 2)
    barBG.Position = UDim2.new(0, 0, 1, -2)
    barBG.BackgroundColor3 = Library.Theme.Container
    barBG.BorderSizePixel = 0
    barBG.Parent = notif
    
    local barFill = Instance.new("Frame")
    barFill.Size = UDim2.new(1, 0, 1, 0)
    barFill.BackgroundColor3 = typeColor
    barFill.BorderSizePixel = 0
    barFill.Parent = barBG

    Utility:Tween(notif, {Size = UDim2.new(1, 0, 0, 70)}, 0.4, Enum.EasingStyle.Back)
    local barTween = Utility:Tween(barFill, {Size = UDim2.new(0, 0, 1, 0)}, duration, Enum.EasingStyle.Linear)
    
    task.spawn(function()
        task.wait(duration)
        local exitTween = Utility:Tween(notif, {Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1}, 0.3)
        exitTween.Completed:Connect(function()
            notif:Destroy()
        end)
    end)
end

-- ========================================================================
-- MAIN WINDOW CORE
-- ========================================================================
function Library:CreateWindow(config)
    config = config or {}
    local WindowTitle = config.Title or "macOS Hub"
    
    local WindowAPI = {
        Tabs = {},
        CurrentTab = nil
    }

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "macOSLibraryGUI"
    ScreenGui.Parent = GetGuiParent()
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- MAIN WINDOW (Glassmorphism / Blur)
    local Main = Instance.new("Frame")
    Main.Size = UDim2.new(0, 560, 0, 380)
    Main.Position = UDim2.new(0.5, -280, 0.5, -190)
    Main.BackgroundColor3 = Library.Theme.Background
    Main.BackgroundTransparency = 0.15 
    Main.Parent = ScreenGui
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 14) -- 14px as requested
    
    local UIScale = Instance.new("UIScale")
    UIScale.Scale = 0.95
    UIScale.Parent = Main

    Utility:ApplyBorder(Main, Library.Theme.BorderOpacity)
    
    -- Smooth Shadow via UIStroke Blur Trick is not native to Roblox, so we omit black boxes.
    -- We just keep the clean UIStroke.
    
    -- Open Anim
    Utility:Tween(UIScale, {Scale = 1}, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

    -- TITLE BAR
    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 40)
    TitleBar.BackgroundTransparency = 1
    TitleBar.Parent = Main
    Utility:MakeDraggable(TitleBar, Main)

    local TitleText = Instance.new("TextLabel")
    TitleText.Text = WindowTitle
    TitleText.Font = Enum.Font.GothamMedium
    TitleText.TextSize = 13
    TitleText.TextColor3 = Library.Theme.Text
    TitleText.Position = UDim2.new(0, 15, 0, 0)
    TitleText.Size = UDim2.new(1, -100, 1, 0)
    TitleText.BackgroundTransparency = 1
    TitleText.TextXAlignment = Enum.TextXAlignment.Left
    TitleText.Parent = TitleBar

    -- WINDOWS CONTROL BUTTONS
    local ControlContainer = Instance.new("Frame")
    ControlContainer.Size = UDim2.new(0, 80, 1, 0)
    ControlContainer.Position = UDim2.new(1, -85, 0, 0)
    ControlContainer.BackgroundTransparency = 1
    ControlContainer.Parent = TitleBar
    
    local ControlLayout = Instance.new("UIListLayout")
    ControlLayout.FillDirection = Enum.FillDirection.Horizontal
    ControlLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    ControlLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    ControlLayout.Padding = UDim.new(0, 8)
    ControlLayout.Parent = ControlContainer

    local function CreateControlButton(icon, hoverColor, action, order)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 24, 0, 24)
        btn.BackgroundColor3 = hoverColor
        btn.BackgroundTransparency = 1
        btn.LayoutOrder = order
        btn.Text = icon
        btn.TextColor3 = Library.Theme.TextMuted
        btn.Font = Enum.Font.GothamMedium
        btn.TextSize = 14
        btn.Parent = ControlContainer
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

        btn.MouseEnter:Connect(function()
            Utility:Tween(btn, {BackgroundTransparency = 0, TextColor3 = Library.Theme.Text}, 0.15)
        end)
        btn.MouseLeave:Connect(function()
            Utility:Tween(btn, {BackgroundTransparency = 1, TextColor3 = Library.Theme.TextMuted}, 0.15)
        end)
        btn.MouseButton1Click:Connect(action)
        return btn
    end
    
    local MinimizeBtn = CreateControlButton("-", Library.Theme.ElementHover, function()
        Utility:Tween(UIScale, {Scale = 0.9}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        local fade = Utility:Tween(Main, {BackgroundTransparency = 1}, 0.3)
        fade.Completed:Connect(function()
            Main.Visible = false
            if WindowAPI.FloatBtn then WindowAPI.FloatBtn.Visible = true end
        end)
    end, 1)

    local CloseBtn = CreateControlButton("X", Library.Theme.Close, function()
        Utility:Tween(UIScale, {Scale = 0.9}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        Utility:Tween(Main, {BackgroundTransparency = 1}, 0.3)
        task.wait(0.3)
        ScreenGui:Destroy()
    end, 2)

    -- ========================================================================
    -- FLOATING BUTTON (SQUIRCLE)
    -- ========================================================================
    local FloatBtn = Instance.new("ImageButton")
    FloatBtn.Size = UDim2.new(0, 55, 0, 55)
    FloatBtn.Position = UDim2.new(0, 25, 0.5, -27)
    FloatBtn.BackgroundTransparency = 1
    FloatBtn.Image = "rbxassetid://131068740559292"
    FloatBtn.Visible = false
    FloatBtn.Parent = ScreenGui
    Instance.new("UICorner", FloatBtn).CornerRadius = UDim.new(0, 14) -- Squircle shape
    
    Utility:ApplyBorder(FloatBtn, 0.5)
    
    local FloatScale = Instance.new("UIScale")
    FloatScale.Scale = 1
    FloatScale.Parent = FloatBtn

    Utility:MakeDraggable(FloatBtn, FloatBtn)

    FloatBtn.MouseEnter:Connect(function()
        Utility:Tween(FloatScale, {Scale = 1.05}, 0.3, Enum.EasingStyle.Back)
    end)
    FloatBtn.MouseLeave:Connect(function()
        Utility:Tween(FloatScale, {Scale = 1}, 0.3, Enum.EasingStyle.Back)
    end)
    
    FloatBtn.MouseButton1Click:Connect(function()
        FloatBtn.Visible = false
        Main.Visible = true
        Main.BackgroundTransparency = 0.15
        Utility:Tween(UIScale, {Scale = 1}, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    end)
    
    WindowAPI.FloatBtn = FloatBtn

    -- ========================================================================
    -- SIDEBAR (Finder Style)
    -- ========================================================================
    local Sidebar = Instance.new("Frame")
    Sidebar.Size = UDim2.new(0, 140, 1, -40)
    Sidebar.Position = UDim2.new(0, 0, 0, 40)
    Sidebar.BackgroundTransparency = 1
    Sidebar.Parent = Main

    local SidebarList = Instance.new("UIListLayout")
    SidebarList.Padding = UDim.new(0, 4)
    SidebarList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    SidebarList.Parent = Sidebar

    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, -140, 1, -40)
    Container.Position = UDim2.new(0, 140, 0, 40)
    Container.BackgroundTransparency = 1
    Container.Parent = Main

    local Pages = Instance.new("Folder")
    Pages.Name = "Pages"
    Pages.Parent = Container

    -- ========================================================================
    -- TAB API
    -- ========================================================================
    function WindowAPI:AddTab(tabConfig)
        tabConfig = tabConfig or {}
        local tabName = type(tabConfig) == "string" and tabConfig or tabConfig.Title or "Tab"
        local tabIcon = tabConfig.Icon or "⌘" 
        
        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(1, -16, 0, 32)
        TabBtn.BackgroundColor3 = Library.Theme.ElementHover
        TabBtn.BackgroundTransparency = 1
        TabBtn.Text = ""
        TabBtn.AutoButtonColor = false
        TabBtn.Parent = Sidebar
        Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)

        -- Garis vertikal indikator active tab (3px)
        local TabIndicator = Instance.new("Frame")
        TabIndicator.Size = UDim2.new(0, 3, 0, 0)
        TabIndicator.Position = UDim2.new(0, 0, 0.5, 0)
        TabIndicator.AnchorPoint = Vector2.new(0, 0.5)
        TabIndicator.BackgroundColor3 = Library.Theme.Accent
        TabIndicator.Parent = TabBtn
        Instance.new("UICorner", TabIndicator).CornerRadius = UDim.new(1, 0)

        local TabTitle = Instance.new("TextLabel")
        TabTitle.Text = tabIcon .. "  " .. tabName
        TabTitle.Font = Enum.Font.GothamMedium
        TabTitle.TextSize = 13
        TabTitle.TextColor3 = Library.Theme.TextMuted
        TabTitle.Size = UDim2.new(1, -12, 1, 0)
        TabTitle.Position = UDim2.new(0, 12, 0, 0)
        TabTitle.BackgroundTransparency = 1
        TabTitle.TextXAlignment = Enum.TextXAlignment.Left
        TabTitle.Parent = TabBtn

        -- CanvasGroup for Crossfade Animation
        local PageGroup = Instance.new("CanvasGroup")
        PageGroup.Size = UDim2.new(1, 0, 1, 0)
        PageGroup.BackgroundTransparency = 1
        PageGroup.GroupTransparency = 1
        PageGroup.Visible = false
        PageGroup.Parent = Pages

        -- ScrollingFrame with thin scrollbar
        local Page = Instance.new("ScrollingFrame")
        Page.Size = UDim2.new(1, -20, 1, -20)
        Page.Position = UDim2.new(0, 10, 0, 0)
        Page.BackgroundTransparency = 1
        Page.ScrollBarThickness = 3
        Page.ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255)
        Page.ScrollBarImageTransparency = 1
        Page.Parent = PageGroup
        
        local PageLayout = Instance.new("UIListLayout")
        PageLayout.Padding = UDim.new(0, 8)
        PageLayout.Parent = Page
        
        PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 20)
        end)
        
        -- Auto-hide scrollbar
        local scrollHideTask
        Page:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
            Utility:Tween(Page, {ScrollBarImageTransparency = 0.4}, 0.2)
            if scrollHideTask then task.cancel(scrollHideTask) end
            scrollHideTask = task.spawn(function()
                task.wait(1)
                Utility:Tween(Page, {ScrollBarImageTransparency = 1}, 0.5)
            end)
        end)

        TabBtn.MouseEnter:Connect(function()
            if WindowAPI.CurrentTab ~= PageGroup then
                Utility:Tween(TabBtn, {BackgroundTransparency = 0.9}, 0.2) -- Opacity 0.1
                Utility:Tween(TabTitle, {TextColor3 = Library.Theme.Text}, 0.2)
            end
        end)
        TabBtn.MouseLeave:Connect(function()
            if WindowAPI.CurrentTab ~= PageGroup then
                Utility:Tween(TabBtn, {BackgroundTransparency = 1}, 0.2)
                Utility:Tween(TabTitle, {TextColor3 = Library.Theme.TextMuted}, 0.2)
            end
        end)

        TabBtn.MouseButton1Click:Connect(function()
            if WindowAPI.CurrentTab == PageGroup then return end
            
            for _, btn in ipairs(Sidebar:GetChildren()) do
                if btn:IsA("TextButton") and btn ~= TabBtn then
                    Utility:Tween(btn, {BackgroundTransparency = 1}, 0.2)
                    Utility:Tween(btn.TextLabel, {TextColor3 = Library.Theme.TextMuted}, 0.2)
                    Utility:Tween(btn.Frame, {Size = UDim2.new(0, 3, 0, 0)}, 0.2)
                end
            end
            
            -- Crossfade
            if WindowAPI.CurrentTab then
                local prev = WindowAPI.CurrentTab
                Utility:Tween(prev, {GroupTransparency = 1}, 0.2).Completed:Connect(function()
                    prev.Visible = false
                end)
            end
            
            WindowAPI.CurrentTab = PageGroup
            PageGroup.Visible = true
            Utility:Tween(PageGroup, {GroupTransparency = 0}, 0.3)
            
            Utility:Tween(TabBtn, {BackgroundTransparency = 0.9}, 0.2)
            Utility:Tween(TabTitle, {TextColor3 = Library.Theme.Text}, 0.2)
            Utility:Tween(TabIndicator, {Size = UDim2.new(0, 3, 0, 16)}, 0.2)
        end)

        if #WindowAPI.Tabs == 0 then
            WindowAPI.CurrentTab = PageGroup
            PageGroup.Visible = true
            PageGroup.GroupTransparency = 0
            TabBtn.BackgroundTransparency = 0.9
            TabTitle.TextColor3 = Library.Theme.Text
            TabIndicator.Size = UDim2.new(0, 3, 0, 16)
        end
        table.insert(WindowAPI.Tabs, PageGroup)

        -- ========================================================================
        -- ELEMENTS API
        -- ========================================================================
        local TabAPI = {}

        -- >>> TOGGLE (iOS 16 Style) <<<
        function TabAPI:AddToggle(tConfig)
            tConfig = tConfig or {}
            local ToggleAPI = {
                Value = tConfig.Default or false,
                Callback = tConfig.Callback or function() end
            }

            local row = Instance.new("Frame")
            row.Size = UDim2.new(1, 0, 0, 38)
            row.BackgroundTransparency = 1
            row.Parent = Page
            
            local sep = Instance.new("Frame")
            sep.Size = UDim2.new(1, 0, 0, 1)
            sep.Position = UDim2.new(0, 0, 1, -1)
            sep.BackgroundColor3 = Library.Theme.Border
            sep.BackgroundTransparency = 0.85
            sep.BorderSizePixel = 0
            sep.Parent = row

            local lbl = Instance.new("TextLabel")
            lbl.Text = tConfig.Title or "Toggle"
            lbl.Font = Enum.Font.GothamMedium
            lbl.TextSize = 13
            lbl.TextColor3 = Library.Theme.Text
            lbl.Size = UDim2.new(1, -60, 1, 0)
            lbl.Position = UDim2.new(0, 15, 0, 0)
            lbl.BackgroundTransparency = 1
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Parent = row

            -- Capsule 44x24
            local toggleBG = Instance.new("TextButton")
            toggleBG.Size = UDim2.new(0, 44, 0, 24)
            toggleBG.Position = UDim2.new(1, -54, 0.5, -12)
            toggleBG.BackgroundColor3 = ToggleAPI.Value and Library.Theme.Success or Library.Theme.Container
            toggleBG.Text = ""
            toggleBG.AutoButtonColor = false
            toggleBG.Parent = row
            Instance.new("UICorner", toggleBG).CornerRadius = UDim.new(1, 0)
            Utility:ApplyBorder(toggleBG, 0.3)

            local circle = Instance.new("Frame")
            circle.Size = UDim2.new(0, 20, 0, 20)
            circle.Position = ToggleAPI.Value and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
            circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            circle.Parent = toggleBG
            Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)
            Utility:ApplyBorder(circle, 0.8)

            local function UpdateVisuals()
                local tPos = ToggleAPI.Value and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
                local tCol = ToggleAPI.Value and Library.Theme.Success or Library.Theme.Container
                -- Animasi Spring
                Utility:Tween(circle, {Position = tPos}, 0.35, Enum.EasingStyle.Back)
                Utility:Tween(toggleBG, {BackgroundColor3 = tCol}, 0.25)
            end

            toggleBG.MouseButton1Click:Connect(function()
                ToggleAPI:SetValue(not ToggleAPI.Value)
            end)

            function ToggleAPI:OnChanged(callback)
                self.Callback = callback
                return self
            end

            function ToggleAPI:SetValue(val)
                if self.Value ~= val then
                    self.Value = val
                    UpdateVisuals()
                    task.spawn(function() pcall(self.Callback, val) end)
                end
                return self
            end
            
            return ToggleAPI
        end

        -- >>> SLIDER (macOS Style) <<<
        function TabAPI:AddSlider(sConfig)
            sConfig = sConfig or {}
            local SliderAPI = {
                Value = sConfig.Default or sConfig.Min or 0,
                Min = sConfig.Min or 0,
                Max = sConfig.Max or 100,
                Callback = sConfig.Callback or function() end
            }

            local row = Instance.new("Frame")
            row.Size = UDim2.new(1, 0, 0, 48)
            row.BackgroundTransparency = 1
            row.Parent = Page

            local sep = Instance.new("Frame")
            sep.Size = UDim2.new(1, 0, 0, 1)
            sep.Position = UDim2.new(0, 0, 1, -1)
            sep.BackgroundColor3 = Library.Theme.Border
            sep.BackgroundTransparency = 0.85
            sep.BorderSizePixel = 0
            sep.Parent = row

            local lbl = Instance.new("TextLabel")
            lbl.Text = sConfig.Title or "Slider"
            lbl.Font = Enum.Font.GothamMedium
            lbl.TextSize = 13
            lbl.TextColor3 = Library.Theme.Text
            lbl.Size = UDim2.new(1, -20, 0, 25)
            lbl.Position = UDim2.new(0, 15, 0, 5)
            lbl.BackgroundTransparency = 1
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Parent = row

            local barBtn = Instance.new("TextButton")
            barBtn.Size = UDim2.new(1, -30, 0, 20)
            barBtn.Position = UDim2.new(0, 15, 0, 30)
            barBtn.BackgroundTransparency = 1
            barBtn.Text = ""
            barBtn.Parent = row

            -- Track garis tipis (height 3px)
            local bar = Instance.new("Frame")
            bar.Size = UDim2.new(1, 0, 0, 3)
            bar.Position = UDim2.new(0, 0, 0.5, -1)
            bar.BackgroundColor3 = Library.Theme.Container
            bar.Parent = barBtn
            Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)

            local fill = Instance.new("Frame")
            local initP = (SliderAPI.Max - SliderAPI.Min) == 0 and 0 or (SliderAPI.Value - SliderAPI.Min)/(SliderAPI.Max - SliderAPI.Min)
            fill.Size = UDim2.new(math.clamp(initP, 0, 1), 0, 1, 0)
            fill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            fill.Parent = bar
            Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
            
            local grad = Instance.new("UIGradient")
            grad.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Library.Theme.Accent),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 160, 255))
            })
            grad.Parent = fill

            -- Thumb lingkaran (diameter 14px)
            local thumb = Instance.new("Frame")
            thumb.Size = UDim2.new(0, 14, 0, 14)
            thumb.Position = UDim2.new(1, -7, 0.5, -7)
            thumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            thumb.Parent = fill
            Instance.new("UICorner", thumb).CornerRadius = UDim.new(1, 0)
            Utility:ApplyBorder(thumb, 0.8)

            -- Value Badge floating
            local ValueBadge = Instance.new("Frame")
            ValueBadge.Size = UDim2.new(0, 30, 0, 18)
            ValueBadge.Position = UDim2.new(0.5, -15, 0, -22)
            ValueBadge.BackgroundColor3 = Library.Theme.ElementHover
            ValueBadge.BackgroundTransparency = 1 -- Hide initial
            ValueBadge.Parent = thumb
            Instance.new("UICorner", ValueBadge).CornerRadius = UDim.new(0, 4)

            local ValueBadgeText = Instance.new("TextLabel")
            ValueBadgeText.Text = tostring(SliderAPI.Value)
            ValueBadgeText.Font = Enum.Font.GothamMedium
            ValueBadgeText.TextSize = 11
            ValueBadgeText.TextColor3 = Library.Theme.Text
            ValueBadgeText.Size = UDim2.new(1, 0, 1, 0)
            ValueBadgeText.BackgroundTransparency = 1
            ValueBadgeText.TextTransparency = 1
            ValueBadgeText.Parent = ValueBadge

            local function UpdateVisuals(val)
                local p = (SliderAPI.Max - SliderAPI.Min) == 0 and 0 or (val - SliderAPI.Min)/(SliderAPI.Max - SliderAPI.Min)
                p = math.clamp(p, 0, 1)
                Utility:Tween(fill, {Size = UDim2.new(p, 0, 1, 0)}, 0.1)
                ValueBadgeText.Text = tostring(val)
            end

            local dragging = false
            local dragConn
            
            local function updateByInput(input)
                local inputPos = input.Position.X
                local barPos = bar.AbsolutePosition.X
                local barSize = bar.AbsoluteSize.X
                
                local percent = math.clamp((inputPos - barPos) / barSize, 0, 1)
                local newVal = math.floor(SliderAPI.Min + (SliderAPI.Max - SliderAPI.Min) * percent)
                SliderAPI:SetValue(newVal)
            end

            barBtn.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    updateByInput(input)
                    Utility:Tween(ValueBadge, {BackgroundTransparency = 0.1, Position = UDim2.new(0.5, -15, 0, -26)}, 0.2, Enum.EasingStyle.Back)
                    Utility:Tween(ValueBadgeText, {TextTransparency = 0}, 0.2)
                    
                    if dragConn then dragConn:Disconnect() end
                    dragConn = UserInputService.InputChanged:Connect(function(cInput)
                        if dragging and (cInput.UserInputType == Enum.UserInputType.MouseMovement or cInput.UserInputType == Enum.UserInputType.Touch) then
                            updateByInput(cInput)
                        end
                    end)
                end
            end)

            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    if dragging then
                        dragging = false
                        Utility:Tween(ValueBadge, {BackgroundTransparency = 1, Position = UDim2.new(0.5, -15, 0, -22)}, 0.2)
                        Utility:Tween(ValueBadgeText, {TextTransparency = 1}, 0.2)
                        if dragConn then dragConn:Disconnect() dragConn = nil end
                    end
                end
            end)

            function SliderAPI:OnChanged(cb)
                self.Callback = cb
                return self
            end

            function SliderAPI:SetValue(val)
                val = math.clamp(val, self.Min, self.Max)
                if self.Value ~= val then
                    self.Value = val
                    UpdateVisuals(val)
                    task.spawn(function() pcall(self.Callback, val) end)
                end
                return self
            end
            
            return SliderAPI
        end

        -- >>> BUTTON <<<
        function TabAPI:AddButton(bConfig)
            bConfig = bConfig or {}
            local btnAPI = {
                Callback = bConfig.Callback or function() end
            }
            
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, 36)
            btn.BackgroundColor3 = Library.Theme.Element
            btn.BackgroundTransparency = 1
            btn.Text = bConfig.Title or "Button"
            btn.Font = Enum.Font.GothamMedium
            btn.TextSize = 13
            btn.TextColor3 = Library.Theme.Text
            btn.AutoButtonColor = false
            btn.Parent = Page
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

            local sep = Instance.new("Frame")
            sep.Size = UDim2.new(1, 0, 0, 1)
            sep.Position = UDim2.new(0, 0, 1, -1)
            sep.BackgroundColor3 = Library.Theme.Border
            sep.BackgroundTransparency = 0.85
            sep.BorderSizePixel = 0
            sep.Parent = btn
            
            local btnScale = Instance.new("UIScale")
            btnScale.Parent = btn

            btn.MouseEnter:Connect(function()
                Utility:Tween(btn, {BackgroundTransparency = 0.8}, 0.2)
                Utility:Tween(btnScale, {Scale = 1.02}, 0.2, Enum.EasingStyle.Back)
            end)
            btn.MouseLeave:Connect(function()
                Utility:Tween(btn, {BackgroundTransparency = 1}, 0.2)
                Utility:Tween(btnScale, {Scale = 1}, 0.2)
            end)
            btn.MouseButton1Down:Connect(function()
                Utility:Tween(btnScale, {Scale = 0.98}, 0.1)
            end)
            btn.MouseButton1Up:Connect(function()
                Utility:Tween(btnScale, {Scale = 1.02}, 0.1)
            end)

            btn.MouseButton1Click:Connect(function()
                task.spawn(function() pcall(btnAPI.Callback) end)
            end)

            function btnAPI:OnClick(cb)
                self.Callback = cb
                return self
            end
            
            return btnAPI
        end

        -- >>> DROPDOWN <<<
        function TabAPI:AddDropdown(dConfig)
            dConfig = dConfig or {}
            local DropdownAPI = {
                Value = dConfig.Default or "",
                Options = dConfig.Options or {},
                Callback = dConfig.Callback or function() end,
                IsOpen = false
            }

            local row = Instance.new("Frame")
            row.Size = UDim2.new(1, 0, 0, 38)
            row.BackgroundTransparency = 1
            row.ClipsDescendants = true
            row.Parent = Page

            local sep = Instance.new("Frame")
            sep.Size = UDim2.new(1, 0, 0, 1)
            sep.Position = UDim2.new(0, 0, 1, -1)
            sep.BackgroundColor3 = Library.Theme.Border
            sep.BackgroundTransparency = 0.85
            sep.BorderSizePixel = 0
            sep.Parent = row

            local topBtn = Instance.new("TextButton")
            topBtn.Size = UDim2.new(1, 0, 0, 42)
            topBtn.BackgroundTransparency = 1
            topBtn.Text = ""
            topBtn.Parent = row

            local lbl = Instance.new("TextLabel")
            lbl.Text = dConfig.Title or "Dropdown"
            lbl.Font = Enum.Font.GothamMedium
            lbl.TextSize = 13
            lbl.TextColor3 = Library.Theme.Text
            lbl.Size = UDim2.new(1, -50, 1, 0)
            lbl.Position = UDim2.new(0, 15, 0, 0)
            lbl.BackgroundTransparency = 1
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Parent = topBtn

            local icon = Instance.new("TextLabel")
            icon.Text = "˅"
            icon.Font = Enum.Font.GothamMedium
            icon.TextSize = 14
            icon.TextColor3 = Library.Theme.TextMuted
            icon.Size = UDim2.new(0, 20, 1, 0)
            icon.Position = UDim2.new(1, -30, 0, 0)
            icon.BackgroundTransparency = 1
            icon.Parent = topBtn

            local selectedLbl = Instance.new("TextLabel")
            selectedLbl.Text = DropdownAPI.Value ~= "" and DropdownAPI.Value or "Select..."
            selectedLbl.Font = Enum.Font.Gotham
            selectedLbl.TextSize = 12
            selectedLbl.TextColor3 = Library.Theme.Accent
            selectedLbl.Size = UDim2.new(0, 100, 1, 0)
            selectedLbl.Position = UDim2.new(1, -145, 0, 0)
            selectedLbl.BackgroundTransparency = 1
            selectedLbl.TextXAlignment = Enum.TextXAlignment.Right
            selectedLbl.Parent = topBtn

            local OptionContainer = Instance.new("ScrollingFrame")
            OptionContainer.Size = UDim2.new(1, -20, 0, 0)
            OptionContainer.Position = UDim2.new(0, 10, 0, 42)
            OptionContainer.BackgroundTransparency = 1
            OptionContainer.ScrollBarThickness = 2
            OptionContainer.ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255)
            OptionContainer.Parent = row
            
            local OList = Instance.new("UIListLayout")
            OList.Padding = UDim.new(0, 4)
            OList.Parent = OptionContainer

            local function UpdateOptions()
                for _, child in ipairs(OptionContainer:GetChildren()) do
                    if child:IsA("TextButton") then child:Destroy() end
                end
                
                local totalHeight = 0
                for _, opt in ipairs(DropdownAPI.Options) do
                    local optBtn = Instance.new("TextButton")
                    optBtn.Size = UDim2.new(1, 0, 0, 32)
                    optBtn.BackgroundColor3 = Library.Theme.Container
                    optBtn.BackgroundTransparency = 0.5
                    optBtn.Text = "  " .. opt
                    optBtn.Font = Enum.Font.Gotham
                    optBtn.TextSize = 12
                    optBtn.TextColor3 = (opt == DropdownAPI.Value) and Library.Theme.Accent or Library.Theme.TextMuted
                    optBtn.TextXAlignment = Enum.TextXAlignment.Left
                    optBtn.AutoButtonColor = false
                    optBtn.Parent = OptionContainer
                    Instance.new("UICorner", optBtn).CornerRadius = UDim.new(0, 6)
                    totalHeight = totalHeight + 36
                    
                    optBtn.MouseEnter:Connect(function()
                        if opt ~= DropdownAPI.Value then
                            Utility:Tween(optBtn, {BackgroundTransparency = 0, TextColor3 = Library.Theme.Text}, 0.2)
                        end
                    end)
                    optBtn.MouseLeave:Connect(function()
                        if opt ~= DropdownAPI.Value then
                            Utility:Tween(optBtn, {BackgroundTransparency = 0.5, TextColor3 = Library.Theme.TextMuted}, 0.2)
                        end
                    end)

                    optBtn.MouseButton1Click:Connect(function()
                        DropdownAPI:SetValue(opt)
                        DropdownAPI:Toggle()
                    end)
                end
                OptionContainer.CanvasSize = UDim2.new(0, 0, 0, totalHeight)
                return totalHeight
            end

            function DropdownAPI:Toggle()
                self.IsOpen = not self.IsOpen
                if self.IsOpen then
                    local th = UpdateOptions()
                    local targetH = math.clamp(th, 0, 160)
                    OptionContainer.Size = UDim2.new(1, -20, 0, targetH)
                    Utility:Tween(row, {Size = UDim2.new(1, 0, 0, 42 + targetH + 10)}, 0.4, Enum.EasingStyle.Quint)
                    Utility:Tween(icon, {Rotation = 180}, 0.4)
                else
                    Utility:Tween(row, {Size = UDim2.new(1, 0, 0, 42)}, 0.4, Enum.EasingStyle.Quint)
                    Utility:Tween(icon, {Rotation = 0}, 0.4)
                end
                return self
            end

            topBtn.MouseButton1Click:Connect(function()
                DropdownAPI:Toggle()
            end)

            function DropdownAPI:SetValue(val)
                if self.Value ~= val then
                    self.Value = val
                    selectedLbl.Text = val
                    UpdateOptions()
                    task.spawn(function() pcall(self.Callback, val) end)
                end
                return self
            end

            function DropdownAPI:OnChanged(cb)
                self.Callback = cb
                return self
            end
            
            function DropdownAPI:Refresh(newOptions)
                self.Options = newOptions
                if self.IsOpen then UpdateOptions() end
                return self
            end

            return DropdownAPI
        end

        return TabAPI
    end

    return WindowAPI
end

return Library

--[[
-- ========================================================================
-- EXAMPLE USAGE (macOS SONOMA / VENTURA API)
-- ========================================================================

local Library = require(path.to.this.module)

local Window = Library:CreateWindow({
    Title = "macOS Premium Hub"
})

-- Notifikasi Canggih
Library:Notify({
    Title = "System Connected",
    Content = "Clean UI injected successfully.",
    Type = "Info",
    Duration = 5
})

local MainTab = Window:AddTab({
    Title = "General",
    Icon = "⚙️"
})

-- Chainable Method untuk Toggle
local AimbotToggle = MainTab:AddToggle({
    Title = "Enable Premium Aimbot",
    Default = false
}):OnChanged(function(state)
    print("Aimbot is:", state)
end)

-- Chainable Method untuk Slider
local FOVSlider = MainTab:AddSlider({
    Title = "Field of View",
    Min = 30,
    Max = 120,
    Default = 70
}):OnChanged(function(val)
    print("FOV:", val)
end)

-- Chainable Method untuk Dropdown
local TargetPartDropdown = MainTab:AddDropdown({
    Title = "Target Body Part",
    Options = {"Head", "Torso", "HumanoidRootPart"},
    Default = "Head"
}):OnChanged(function(val)
    print("Target set to:", val)
end)

-- Chainable Method untuk Button
local KillAllBtn = MainTab:AddButton({
    Title = "Execute Script"
}):OnClick(function()
    print("Executing Action...")
    Library:Notify({
        Title = "Executed",
        Content = "Script is running in the background.",
        Type = "Success",
        Duration = 3
    })
end)

-- Mengubah nilai dari eksternal:
task.wait(2)
AimbotToggle:SetValue(true)
]]
