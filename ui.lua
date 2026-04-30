local Library = {
    Version = "3.0 Ultra Modern",
    Theme = {
        Background = Color3.fromRGB(15, 15, 20),
        Container = Color3.fromRGB(22, 22, 28),
        Element = Color3.fromRGB(28, 28, 35),
        ElementHover = Color3.fromRGB(38, 38, 45),
        Accent = Color3.fromRGB(180, 80, 255), -- Purple
        AccentSecondary = Color3.fromRGB(0, 230, 255), -- Cyan
        Text = Color3.fromRGB(245, 245, 255),
        TextMuted = Color3.fromRGB(140, 140, 155),
        BorderOpacity = 0.3,
        
        -- Notification Colors
        Success = Color3.fromRGB(50, 220, 120),
        Error = Color3.fromRGB(240, 80, 80),
        Warning = Color3.fromRGB(250, 200, 50),
        Info = Color3.fromRGB(60, 160, 240)
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
-- UTILITY FUNCTIONS (ANIMATIONS & EFFECTS)
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

function Utility:CreateRipple(parent)
    local ripple = Instance.new("Frame")
    ripple.Name = "Ripple"
    ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ripple.BackgroundTransparency = 0.8
    ripple.ZIndex = parent.ZIndex + 1
    ripple.Size = UDim2.new(0, 0, 0, 0)
    ripple.Position = UDim2.new(0.5, 0, 0.5, 0)
    ripple.AnchorPoint = Vector2.new(0.5, 0.5)
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = ripple
    ripple.Parent = parent
    
    local maxSize = math.max(parent.AbsoluteSize.X, parent.AbsoluteSize.Y) * 1.5
    
    local tweenInfo = TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(ripple, tweenInfo, {
        Size = UDim2.new(0, maxSize, 0, maxSize),
        BackgroundTransparency = 1
    })
    
    tween:Play()
    tween.Completed:Connect(function()
        ripple:Destroy()
    end)
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

-- Gradient Border Utility
function Utility:ApplyGradientBorder(parent, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = thickness or 1
    stroke.Transparency = 1 - Library.Theme.BorderOpacity
    stroke.Parent = parent

    local grad = Instance.new("UIGradient")
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Library.Theme.AccentSecondary),
        ColorSequenceKeypoint.new(0.5, Library.Theme.Accent),
        ColorSequenceKeypoint.new(1, Library.Theme.AccentSecondary)
    })
    grad.Rotation = 45
    grad.Parent = stroke
    
    -- Animasi perputaran gradient secara terus-menerus
    task.spawn(function()
        local t = 0
        while parent.Parent do
            t = t + RunService.RenderStepped:Wait() * 45
            grad.Rotation = t % 360
        end
    end)
    
    return stroke, grad
end

-- Multi Layer Shadow Utility
function Utility:CreateShadows(parent, radius, offsetOuter, offsetInner)
    radius = radius or 15
    offsetOuter = offsetOuter or 5
    offsetInner = offsetInner or 2
    
    -- Layer 1: Outer shadow yang lebar
    local Outer = Instance.new("ImageLabel")
    Outer.Name = "OuterShadow"
    Outer.Image = "rbxassetid://6014261900"
    Outer.ImageColor3 = Color3.fromRGB(0, 0, 0)
    Outer.ImageTransparency = 0.7
    Outer.ScaleType = Enum.ScaleType.Slice
    Outer.SliceCenter = Rect.new(49, 49, 450, 450)
    Outer.Size = UDim2.new(1, radius*4, 1, radius*4)
    Outer.Position = UDim2.new(0, -radius*2, 0, -radius*2 + offsetOuter)
    Outer.BackgroundTransparency = 1
    Outer.ZIndex = parent.ZIndex - 2
    Outer.Parent = parent

    -- Layer 2: Inner shadow yang solid
    local Inner = Instance.new("ImageLabel")
    Inner.Name = "InnerShadow"
    Inner.Image = "rbxassetid://6015897843"
    Inner.ImageColor3 = Color3.fromRGB(0, 0, 0)
    Inner.ImageTransparency = 0.8
    Inner.ScaleType = Enum.ScaleType.Slice
    Inner.SliceCenter = Rect.new(49, 49, 450, 450)
    Inner.Size = UDim2.new(1, radius*2, 1, radius*2)
    Inner.Position = UDim2.new(0, -radius, 0, -radius + offsetInner)
    Inner.BackgroundTransparency = 1
    Inner.ZIndex = parent.ZIndex - 1
    Inner.Parent = parent
    
    return Outer, Inner
end

-- ========================================================================
-- NOTIFICATION SYSTEM
-- ========================================================================
local NotifGui = Instance.new("ScreenGui")
NotifGui.Name = "UltraModernNotifGUI"
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
    titleLbl.Font = Enum.Font.GothamBold
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
    barBG.Size = UDim2.new(1, 0, 0, 4)
    barBG.Position = UDim2.new(0, 0, 1, -4)
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
    local WindowTitle = config.Title or "Ultra Modern Hub"
    
    local WindowAPI = {
        Tabs = {},
        CurrentTab = nil
    }

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "UltraModernLibraryGUI"
    ScreenGui.Parent = GetGuiParent()
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- MAIN WINDOW (Acrylic/Glassmorphism)
    local Main = Instance.new("Frame")
    Main.Size = UDim2.new(0, 650, 0, 450)
    Main.Position = UDim2.new(0.5, -325, 0.5, -225)
    Main.BackgroundColor3 = Library.Theme.Background
    Main.BackgroundTransparency = 0.15 -- Acrylic blur effect
    Main.Parent = ScreenGui
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 16) -- Rounded 16px
    
    -- Border Gradient & Multi Layer Shadow
    Utility:ApplyGradientBorder(Main, 1)
    Utility:CreateShadows(Main, 20, 8, 3)

    -- TITLE BAR
    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 50)
    TitleBar.BackgroundTransparency = 1
    TitleBar.Parent = Main
    Utility:MakeDraggable(TitleBar, Main)

    -- Drag Indicator
    local DragIndicator = Instance.new("Frame")
    DragIndicator.Size = UDim2.new(0, 50, 0, 4)
    DragIndicator.Position = UDim2.new(0.5, -25, 0, 8)
    DragIndicator.BackgroundColor3 = Library.Theme.TextMuted
    DragIndicator.BackgroundTransparency = 0.5
    DragIndicator.Parent = TitleBar
    Instance.new("UICorner", DragIndicator).CornerRadius = UDim.new(1, 0)

    local TitleText = Instance.new("TextLabel")
    TitleText.Text = WindowTitle
    TitleText.Font = Enum.Font.GothamBold
    TitleText.TextSize = 16
    TitleText.TextColor3 = Library.Theme.Text
    TitleText.Position = UDim2.new(0, 20, 0, 0)
    TitleText.Size = UDim2.new(0, 200, 1, 0)
    TitleText.BackgroundTransparency = 1
    TitleText.TextXAlignment = Enum.TextXAlignment.Left
    TitleText.Parent = TitleBar

    -- CLOSE BUTTON
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Position = UDim2.new(1, -40, 0.5, -15)
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Text = "✕"
    CloseBtn.TextColor3 = Library.Theme.TextMuted
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 16
    CloseBtn.Parent = TitleBar
    
    CloseBtn.MouseEnter:Connect(function()
        Utility:Tween(CloseBtn, {TextColor3 = Library.Theme.Error}, 0.2)
    end)
    CloseBtn.MouseLeave:Connect(function()
        Utility:Tween(CloseBtn, {TextColor3 = Library.Theme.TextMuted}, 0.2)
    end)
    CloseBtn.MouseButton1Click:Connect(function()
        -- Animasi Hide Window
        Utility:Tween(Main, {Size = UDim2.new(0, 650, 0, 0), BackgroundTransparency = 1}, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        task.wait(0.3)
        Main.Visible = false
        if WindowAPI.FloatBtn then WindowAPI.FloatBtn.Visible = true end
    end)

    -- ========================================================================
    -- FLOATING BUTTON (SQUIRCLE)
    -- ========================================================================
    local FloatBtn = Instance.new("ImageButton")
    FloatBtn.Size = UDim2.new(0, 65, 0, 65)
    FloatBtn.Position = UDim2.new(0, 25, 0.5, -32)
    FloatBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    FloatBtn.BackgroundTransparency = 0.15
    FloatBtn.Image = "rbxassetid://131068740559292"
    FloatBtn.Visible = false
    FloatBtn.Parent = ScreenGui
    Instance.new("UICorner", FloatBtn).CornerRadius = UDim.new(0, 16) -- Squircle shape
    
    Utility:ApplyGradientBorder(FloatBtn, 2)
    Utility:CreateShadows(FloatBtn, 15, 5, 2)
    
    -- Layer 3: Glow effect saat hover
    local FloatGlow = Instance.new("ImageLabel")
    FloatGlow.Image = "rbxassetid://6014261900"
    FloatGlow.ImageColor3 = Library.Theme.Accent
    FloatGlow.ImageTransparency = 1
    FloatGlow.ScaleType = Enum.ScaleType.Slice
    FloatGlow.SliceCenter = Rect.new(49, 49, 450, 450)
    FloatGlow.Size = UDim2.new(1, 40, 1, 40)
    FloatGlow.Position = UDim2.new(0, -20, 0, -20)
    FloatGlow.BackgroundTransparency = 1
    FloatGlow.ZIndex = FloatBtn.ZIndex - 1
    FloatGlow.Parent = FloatBtn

    Utility:MakeDraggable(FloatBtn, FloatBtn)

    FloatBtn.MouseEnter:Connect(function()
        Utility:Tween(FloatBtn, {Size = UDim2.new(0, 72, 0, 72)}, 0.4, Enum.EasingStyle.Quint)
        Utility:Tween(FloatGlow, {ImageTransparency = 0.3}, 0.4, Enum.EasingStyle.Quint)
    end)
    FloatBtn.MouseLeave:Connect(function()
        Utility:Tween(FloatBtn, {Size = UDim2.new(0, 65, 0, 65)}, 0.4, Enum.EasingStyle.Quint)
        Utility:Tween(FloatGlow, {ImageTransparency = 1}, 0.4, Enum.EasingStyle.Quint)
    end)
    
    FloatBtn.MouseButton1Click:Connect(function()
        FloatBtn.Visible = false
        Main.Visible = true
        Utility:Tween(Main, {Size = UDim2.new(0, 650, 0, 450), BackgroundTransparency = 0.15}, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    end)
    
    WindowAPI.FloatBtn = FloatBtn

    -- ========================================================================
    -- SIDEBAR & CONTAINER
    -- ========================================================================
    local Sidebar = Instance.new("Frame")
    Sidebar.Size = UDim2.new(0, 170, 1, -50)
    Sidebar.Position = UDim2.new(0, 0, 0, 50)
    Sidebar.BackgroundTransparency = 1
    Sidebar.Parent = Main

    local SidebarList = Instance.new("UIListLayout")
    SidebarList.Padding = UDim.new(0, 8)
    SidebarList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    SidebarList.Parent = Sidebar

    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, -180, 1, -65)
    Container.Position = UDim2.new(0, 170, 0, 50)
    Container.BackgroundColor3 = Library.Theme.Container
    Container.BackgroundTransparency = 0.2
    Container.Parent = Main
    Instance.new("UICorner", Container).CornerRadius = UDim.new(0, 12)
    
    local UIStrokeContainer = Instance.new("UIStroke")
    UIStrokeContainer.Color = Library.Theme.Element
    UIStrokeContainer.Thickness = 1
    UIStrokeContainer.Parent = Container

    local Pages = Instance.new("Folder")
    Pages.Name = "Pages"
    Pages.Parent = Container

    -- ========================================================================
    -- TAB API
    -- ========================================================================
    function WindowAPI:AddTab(tabConfig)
        tabConfig = tabConfig or {}
        local tabName = type(tabConfig) == "string" and tabConfig or tabConfig.Title or "Tab"
        local tabIcon = tabConfig.Icon or "✦"
        
        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(1, -24, 0, 42)
        TabBtn.BackgroundColor3 = Library.Theme.Element
        TabBtn.BackgroundTransparency = 1
        TabBtn.Text = ""
        TabBtn.AutoButtonColor = false
        TabBtn.Parent = Sidebar
        Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 10)

        local TabIndicator = Instance.new("Frame")
        TabIndicator.Size = UDim2.new(0, 3, 0, 0)
        TabIndicator.Position = UDim2.new(0, 0, 0.5, 0)
        TabIndicator.AnchorPoint = Vector2.new(0, 0.5)
        TabIndicator.BackgroundColor3 = Library.Theme.Accent
        TabIndicator.Parent = TabBtn
        Instance.new("UICorner", TabIndicator).CornerRadius = UDim.new(1, 0)

        local TabTitle = Instance.new("TextLabel")
        TabTitle.Text = tabIcon .. "   " .. tabName
        TabTitle.Font = Enum.Font.GothamMedium
        TabTitle.TextSize = 13
        TabTitle.TextColor3 = Library.Theme.TextMuted
        TabTitle.Size = UDim2.new(1, -15, 1, 0)
        TabTitle.Position = UDim2.new(0, 15, 0, 0)
        TabTitle.BackgroundTransparency = 1
        TabTitle.TextXAlignment = Enum.TextXAlignment.Left
        TabTitle.Parent = TabBtn

        local Page = Instance.new("ScrollingFrame")
        Page.Size = UDim2.new(1, -20, 1, -20)
        Page.Position = UDim2.new(0, 10, 0, 10)
        Page.BackgroundTransparency = 1
        Page.ScrollBarThickness = 2
        Page.ScrollBarImageColor3 = Library.Theme.Accent
        Page.Visible = false
        Page.Parent = Pages
        
        local PageLayout = Instance.new("UIListLayout")
        PageLayout.Padding = UDim.new(0, 12)
        PageLayout.Parent = Page
        
        PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 20)
        end)

        TabBtn.MouseEnter:Connect(function()
            if WindowAPI.CurrentTab ~= Page then
                Utility:Tween(TabBtn, {BackgroundTransparency = 0.5}, 0.2)
                Utility:Tween(TabTitle, {TextColor3 = Library.Theme.Text}, 0.2)
            end
        end)
        TabBtn.MouseLeave:Connect(function()
            if WindowAPI.CurrentTab ~= Page then
                Utility:Tween(TabBtn, {BackgroundTransparency = 1}, 0.2)
                Utility:Tween(TabTitle, {TextColor3 = Library.Theme.TextMuted}, 0.2)
            end
        end)

        TabBtn.MouseButton1Click:Connect(function()
            Utility:CreateRipple(TabBtn)
            if WindowAPI.CurrentTab == Page then return end
            
            for _, btn in ipairs(Sidebar:GetChildren()) do
                if btn:IsA("TextButton") and btn ~= TabBtn then
                    Utility:Tween(btn, {BackgroundTransparency = 1}, 0.2)
                    Utility:Tween(btn.TextLabel, {TextColor3 = Library.Theme.TextMuted}, 0.2)
                    Utility:Tween(btn.Frame, {Size = UDim2.new(0, 3, 0, 0)}, 0.2)
                end
            end
            for _, p in ipairs(Pages:GetChildren()) do
                p.Visible = false
            end
            
            WindowAPI.CurrentTab = Page
            Page.Visible = true
            Utility:Tween(TabBtn, {BackgroundTransparency = 0}, 0.2)
            Utility:Tween(TabTitle, {TextColor3 = Library.Theme.Text}, 0.2)
            Utility:Tween(TabIndicator, {Size = UDim2.new(0, 4, 0, 24)}, 0.2)
        end)

        if #WindowAPI.Tabs == 0 then
            WindowAPI.CurrentTab = Page
            Page.Visible = true
            TabBtn.BackgroundTransparency = 0
            TabTitle.TextColor3 = Library.Theme.Text
            TabIndicator.Size = UDim2.new(0, 4, 0, 24)
        end
        table.insert(WindowAPI.Tabs, Page)

        -- ========================================================================
        -- ELEMENTS API
        -- ========================================================================
        local TabAPI = {}

        -- >>> TOGGLE <<<
        function TabAPI:AddToggle(tConfig)
            tConfig = tConfig or {}
            local ToggleAPI = {
                Value = tConfig.Default or false,
                Callback = tConfig.Callback or function() end
            }

            local row = Instance.new("Frame")
            row.Size = UDim2.new(1, 0, 0, 48)
            row.BackgroundColor3 = Library.Theme.Element
            row.Parent = Page
            Instance.new("UICorner", row).CornerRadius = UDim.new(0, 12)

            local lbl = Instance.new("TextLabel")
            lbl.Text = tConfig.Title or "Toggle"
            lbl.Font = Enum.Font.GothamMedium
            lbl.TextSize = 13
            lbl.TextColor3 = Library.Theme.Text
            lbl.Size = UDim2.new(1, -80, 1, 0)
            lbl.Position = UDim2.new(0, 15, 0, 0)
            lbl.BackgroundTransparency = 1
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Parent = row

            local toggleBG = Instance.new("TextButton")
            toggleBG.Size = UDim2.new(0, 48, 0, 26)
            toggleBG.Position = UDim2.new(1, -65, 0.5, -13)
            toggleBG.BackgroundColor3 = ToggleAPI.Value and Library.Theme.Accent or Library.Theme.Container
            toggleBG.Text = ""
            toggleBG.AutoButtonColor = false
            toggleBG.Parent = row
            Instance.new("UICorner", toggleBG).CornerRadius = UDim.new(1, 0)

            local UIStroke = Instance.new("UIStroke")
            UIStroke.Color = Library.Theme.TextMuted
            UIStroke.Transparency = 0.8
            UIStroke.Parent = toggleBG

            local circle = Instance.new("Frame")
            circle.Size = UDim2.new(0, 20, 0, 20)
            circle.Position = ToggleAPI.Value and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 3, 0.5, -10)
            circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            circle.Parent = toggleBG
            Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)
            
            local circleShadow = Instance.new("ImageLabel")
            circleShadow.Image = "rbxassetid://6015897843"
            circleShadow.ImageColor3 = Color3.fromRGB(0,0,0)
            circleShadow.ImageTransparency = 0.6
            circleShadow.Size = UDim2.new(1, 12, 1, 12)
            circleShadow.Position = UDim2.new(0, -6, 0, -6)
            circleShadow.BackgroundTransparency = 1
            circleShadow.ZIndex = circle.ZIndex - 1
            circleShadow.Parent = circle

            local function UpdateVisuals()
                local tPos = ToggleAPI.Value and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 3, 0.5, -10)
                local tCol = ToggleAPI.Value and Library.Theme.Accent or Library.Theme.Container
                Utility:Tween(circle, {Position = tPos}, 0.35, Enum.EasingStyle.Back)
                Utility:Tween(toggleBG, {BackgroundColor3 = tCol}, 0.25)
                Utility:Tween(UIStroke, {Transparency = ToggleAPI.Value and 1 or 0.8}, 0.25)
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

        -- >>> SLIDER <<<
        function TabAPI:AddSlider(sConfig)
            sConfig = sConfig or {}
            local SliderAPI = {
                Value = sConfig.Default or sConfig.Min or 0,
                Min = sConfig.Min or 0,
                Max = sConfig.Max or 100,
                Callback = sConfig.Callback or function() end
            }

            local row = Instance.new("Frame")
            row.Size = UDim2.new(1, 0, 0, 65)
            row.BackgroundColor3 = Library.Theme.Element
            row.Parent = Page
            Instance.new("UICorner", row).CornerRadius = UDim.new(0, 12)

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

            local valLbl = Instance.new("TextLabel")
            valLbl.Text = tostring(SliderAPI.Value)
            valLbl.Font = Enum.Font.GothamBold
            valLbl.TextSize = 13
            valLbl.TextColor3 = Library.Theme.Accent
            valLbl.Size = UDim2.new(0, 50, 0, 25)
            valLbl.Position = UDim2.new(1, -65, 0, 5)
            valLbl.BackgroundTransparency = 1
            valLbl.TextXAlignment = Enum.TextXAlignment.Right
            valLbl.Parent = row

            local barBtn = Instance.new("TextButton")
            barBtn.Size = UDim2.new(1, -30, 0, 20)
            barBtn.Position = UDim2.new(0, 15, 0, 36)
            barBtn.BackgroundTransparency = 1
            barBtn.Text = ""
            barBtn.Parent = row

            local bar = Instance.new("Frame")
            bar.Size = UDim2.new(1, 0, 0, 6)
            bar.Position = UDim2.new(0, 0, 0.5, -3)
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
                ColorSequenceKeypoint.new(0, Library.Theme.AccentSecondary),
                ColorSequenceKeypoint.new(1, Library.Theme.Accent)
            })
            grad.Parent = fill

            local thumb = Instance.new("Frame")
            thumb.Size = UDim2.new(0, 16, 0, 16)
            thumb.Position = UDim2.new(1, -8, 0.5, -8)
            thumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            thumb.Parent = fill
            Instance.new("UICorner", thumb).CornerRadius = UDim.new(1, 0)
            
            local thumbShadow = Instance.new("ImageLabel")
            thumbShadow.Image = "rbxassetid://6015897843"
            thumbShadow.ImageColor3 = Library.Theme.Accent
            thumbShadow.ImageTransparency = 0.3
            thumbShadow.Size = UDim2.new(1, 16, 1, 16)
            thumbShadow.Position = UDim2.new(0, -8, 0, -8)
            thumbShadow.BackgroundTransparency = 1
            thumbShadow.Parent = thumb

            local function UpdateVisuals(val)
                local p = (SliderAPI.Max - SliderAPI.Min) == 0 and 0 or (val - SliderAPI.Min)/(SliderAPI.Max - SliderAPI.Min)
                p = math.clamp(p, 0, 1)
                Utility:Tween(fill, {Size = UDim2.new(p, 0, 1, 0)}, 0.1)
                valLbl.Text = tostring(val)
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
                    Utility:Tween(thumb, {Size = UDim2.new(0, 20, 0, 20), Position = UDim2.new(1, -10, 0.5, -10)}, 0.2)
                    
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
                        Utility:Tween(thumb, {Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(1, -8, 0.5, -8)}, 0.2)
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
            btn.Size = UDim2.new(1, 0, 0, 48)
            btn.BackgroundColor3 = Library.Theme.Element
            btn.Text = bConfig.Title or "Button"
            btn.Font = Enum.Font.GothamMedium
            btn.TextSize = 13
            btn.TextColor3 = Library.Theme.Text
            btn.AutoButtonColor = false
            btn.Parent = Page
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 12)
            
            local UIStroke = Instance.new("UIStroke")
            UIStroke.Color = Library.Theme.Accent
            UIStroke.Transparency = 0.8
            UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            UIStroke.Parent = btn

            btn.MouseEnter:Connect(function()
                Utility:Tween(btn, {BackgroundColor3 = Library.Theme.ElementHover}, 0.2)
                Utility:Tween(UIStroke, {Transparency = 0.2}, 0.2)
            end)
            btn.MouseLeave:Connect(function()
                Utility:Tween(btn, {BackgroundColor3 = Library.Theme.Element}, 0.2)
                Utility:Tween(UIStroke, {Transparency = 0.8}, 0.2)
            end)
            btn.MouseButton1Down:Connect(function()
                Utility:Tween(btn, {Size = UDim2.new(1, -4, 0, 44)}, 0.1)
            end)
            btn.MouseButton1Up:Connect(function()
                Utility:Tween(btn, {Size = UDim2.new(1, 0, 0, 48)}, 0.1)
            end)

            btn.MouseButton1Click:Connect(function()
                Utility:CreateRipple(btn)
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
            row.Size = UDim2.new(1, 0, 0, 48)
            row.BackgroundColor3 = Library.Theme.Element
            row.ClipsDescendants = true
            row.Parent = Page
            Instance.new("UICorner", row).CornerRadius = UDim.new(0, 12)

            local topBtn = Instance.new("TextButton")
            topBtn.Size = UDim2.new(1, 0, 0, 48)
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
            icon.Text = "▼"
            icon.Font = Enum.Font.GothamBold
            icon.TextSize = 12
            icon.TextColor3 = Library.Theme.TextMuted
            icon.Size = UDim2.new(0, 20, 1, 0)
            icon.Position = UDim2.new(1, -35, 0, 0)
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
            OptionContainer.Position = UDim2.new(0, 10, 0, 48)
            OptionContainer.BackgroundTransparency = 1
            OptionContainer.ScrollBarThickness = 2
            OptionContainer.Parent = row
            
            local OList = Instance.new("UIListLayout")
            OList.Padding = UDim.new(0, 6)
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
                    optBtn.Text = "  " .. opt
                    optBtn.Font = Enum.Font.Gotham
                    optBtn.TextSize = 12
                    optBtn.TextColor3 = (opt == DropdownAPI.Value) and Library.Theme.Accent or Library.Theme.TextMuted
                    optBtn.TextXAlignment = Enum.TextXAlignment.Left
                    optBtn.AutoButtonColor = false
                    optBtn.Parent = OptionContainer
                    Instance.new("UICorner", optBtn).CornerRadius = UDim.new(0, 8)
                    totalHeight = totalHeight + 38
                    
                    optBtn.MouseEnter:Connect(function()
                        if opt ~= DropdownAPI.Value then
                            Utility:Tween(optBtn, {BackgroundColor3 = Library.Theme.ElementHover, TextColor3 = Library.Theme.Text}, 0.2)
                        end
                    end)
                    optBtn.MouseLeave:Connect(function()
                        if opt ~= DropdownAPI.Value then
                            Utility:Tween(optBtn, {BackgroundColor3 = Library.Theme.Container, TextColor3 = Library.Theme.TextMuted}, 0.2)
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
                    Utility:Tween(row, {Size = UDim2.new(1, 0, 0, 48 + targetH + 10)}, 0.4, Enum.EasingStyle.Quint)
                    Utility:Tween(icon, {Rotation = 180}, 0.4)
                else
                    Utility:Tween(row, {Size = UDim2.new(1, 0, 0, 48)}, 0.4, Enum.EasingStyle.Quint)
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
-- EXAMPLE USAGE (ULTRA MODERN 2025 API)
-- ========================================================================

local Library = require(path.to.this.module)

local Window = Library:CreateWindow({
    Title = "Ultra Modern Premium Hub 2025"
})

-- Notifikasi Canggih
Library:Notify({
    Title = "Authentication Success",
    Content = "Welcome back to the premium experience.",
    Type = "Success",
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
    Title = "Field of View (FOV)",
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
    Title = "Execute Kill All"
}):OnClick(function()
    print("Executing Action...")
    Library:Notify({
        Title = "Warning",
        Content = "Executing high-risk action...",
        Type = "Warning",
        Duration = 3
    })
end)

-- Mengubah nilai dari eksternal:
task.wait(2)
AimbotToggle:SetValue(true)
]]
