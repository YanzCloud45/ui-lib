local Library = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

-- ========================================================================
-- THEME SETTINGS
-- ========================================================================
local Themes = {
    Dark = {
        Background = Color3.fromRGB(15, 15, 15),
        Container = Color3.fromRGB(22, 22, 22),
        Row = Color3.fromRGB(28, 28, 28),
        Text = Color3.fromRGB(200, 200, 200),
        TextMuted = Color3.fromRGB(150, 150, 150),
        Accent = Color3.fromRGB(0, 170, 255),
        ToggleOff = Color3.fromRGB(50, 50, 50),
        SliderBar = Color3.fromRGB(50, 50, 55),
        Hover = Color3.fromRGB(35, 35, 35)
    },
    Light = {
        Background = Color3.fromRGB(240, 240, 240),
        Container = Color3.fromRGB(255, 255, 255),
        Row = Color3.fromRGB(245, 245, 245),
        Text = Color3.fromRGB(30, 30, 30),
        TextMuted = Color3.fromRGB(100, 100, 100),
        Accent = Color3.fromRGB(0, 120, 255),
        ToggleOff = Color3.fromRGB(200, 200, 200),
        SliderBar = Color3.fromRGB(200, 200, 205),
        Hover = Color3.fromRGB(220, 220, 220)
    }
}

-- ========================================================================
-- UTILITY FUNCTIONS
-- ========================================================================

-- Menambahkan efek hover pada komponen UI
local function addHoverEffect(obj, normalColor, hoverColor)
    obj.MouseEnter:Connect(function()
        TweenService:Create(obj, TweenInfo.new(0.2), {BackgroundColor3 = hoverColor}):Play()
    end)
    obj.MouseLeave:Connect(function()
        TweenService:Create(obj, TweenInfo.new(0.2), {BackgroundColor3 = normalColor}):Play()
    end)
end

-- ========================================================================
-- CORE LIBRARY
-- ========================================================================

function Library.init(titleOrConfig, version, sub)
    -- Mendukung format lama (title, version, sub) dan format baru (config table)
    local config = {}
    if type(titleOrConfig) == "table" then
        config = titleOrConfig
    else
        config = {
            title = titleOrConfig,
            version = version,
            sub = sub,
            theme = "Dark"
        }
    end

    local titleText = config.title or "UI Library"
    local versionText = config.version or ""
    local subText = config.sub or ""
    local theme = Themes[config.theme] or Themes.Dark

    local UI = {}
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "UniversalMacOSLib"
    ScreenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- 1. Main Frame (Window Utama)
    local Main = Instance.new("Frame")
    Main.Size = UDim2.new(0, 520, 0, 380)
    Main.Position = UDim2.new(0.5, -260, 0.5, -190)
    Main.BackgroundColor3 = theme.Background
    Main.Parent = ScreenGui
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)

    -- 2. Title Bar & Tombol Navigasi (MacOS style)
    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 40)
    TitleBar.BackgroundTransparency = 1
    TitleBar.Parent = Main
    
    local function makeDot(color, x, isCloseBtn)
        local btn = Instance.new(isCloseBtn and "TextButton" or "Frame")
        btn.Size = UDim2.new(0, 12, 0, 12)
        btn.Position = UDim2.new(0, x, 0, 14)
        btn.BackgroundColor3 = color
        btn.Parent = TitleBar
        Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
        
        if isCloseBtn then
            btn.Text = ""
            btn.AutoButtonColor = false
            local hR = math.clamp(color.R*255 * 0.8, 0, 255)
            local hG = math.clamp(color.G*255 * 0.8, 0, 255)
            local hB = math.clamp(color.B*255 * 0.8, 0, 255)
            addHoverEffect(btn, color, Color3.fromRGB(hR, hG, hB))
            
            btn.MouseButton1Click:Connect(function()
                Main.Visible = false
            end)
        end
    end

    makeDot(Color3.fromRGB(255, 95, 87), 15, true) -- Tombol Close (merah)
    makeDot(Color3.fromRGB(255, 189, 46), 35, false) -- Kuning
    makeDot(Color3.fromRGB(40, 201, 64), 55, false) -- Hijau

    local TitleLbl = Instance.new("TextLabel")
    local fullTitle = titleText
    if subText ~= "" then fullTitle = fullTitle .. " | " .. subText end
    if versionText ~= "" then fullTitle = fullTitle .. " " .. versionText end
    
    TitleLbl.Text = fullTitle
    TitleLbl.Position = UDim2.new(0, 85, 0, 0)
    TitleLbl.Size = UDim2.new(0, 200, 1, 0)
    TitleLbl.BackgroundTransparency = 1
    TitleLbl.TextColor3 = theme.Text
    TitleLbl.Font = Enum.Font.GothamBold
    TitleLbl.TextSize = 13
    TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
    TitleLbl.Parent = TitleBar

    -- 3. Sidebar
    local Sidebar = Instance.new("Frame")
    Sidebar.Size = UDim2.new(0, 140, 1, -50)
    Sidebar.Position = UDim2.new(0, 10, 0, 45)
    Sidebar.BackgroundTransparency = 1
    Sidebar.Parent = Main
    local sList = Instance.new("UIListLayout", Sidebar)
    sList.Padding = UDim.new(0, 5)

    -- 4. Container (Tempat halaman konten)
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, -170, 1, -55)
    Container.Position = UDim2.new(0, 160, 0, 45)
    Container.BackgroundColor3 = theme.Container
    Container.Parent = Main
    Instance.new("UICorner", Container).CornerRadius = UDim.new(0, 10)

    -- 5. Floating Button (Untuk memunculkan GUI ketika di-close, cocok untuk mobile)
    local Float = Instance.new("TextButton")
    Float.Size = UDim2.new(0, 45, 0, 45)
    Float.Position = UDim2.new(0, 20, 0.5, 0)
    Float.Text = "M"
    Float.BackgroundColor3 = theme.Row
    Float.TextColor3 = theme.Text
    Float.Font = Enum.Font.GothamBold
    Float.TextSize = 18
    Float.Parent = ScreenGui
    Instance.new("UICorner", Float).CornerRadius = UDim.new(1, 0)
    addHoverEffect(Float, theme.Row, theme.Hover)
    Float.MouseButton1Click:Connect(function() 
        Main.Visible = not Main.Visible 
    end)

    -- 6. Logika Dragging (Support Mouse & Touch)
    local function makeDraggable(trigger, target)
        local dragging, dragStart, startPos
        
        trigger.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = target.Position
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - dragStart
                target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
    end
    
    makeDraggable(TitleBar, Main)
    makeDraggable(Float, Float)

    -- ========================================================================
    -- TAB SYSTEM
    -- ========================================================================
    local firstTab = true
    
    function UI:AddTab(tabName)
        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(1, 0, 0, 35)
        TabBtn.BackgroundColor3 = theme.Hover
        TabBtn.BackgroundTransparency = 1
        TabBtn.Text = tabName or "Tab"
        TabBtn.TextColor3 = theme.TextMuted
        TabBtn.Font = Enum.Font.GothamMedium
        TabBtn.TextSize = 13
        TabBtn.AutoButtonColor = false
        TabBtn.Parent = Sidebar
        Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)

        local Page = Instance.new("ScrollingFrame")
        Page.Size = UDim2.new(1, -20, 1, -20)
        Page.Position = UDim2.new(0, 10, 0, 10)
        Page.BackgroundTransparency = 1
        Page.Visible = false
        Page.ScrollBarThickness = 0
        Page.Parent = Container
        Instance.new("UIListLayout", Page).Padding = UDim.new(0, 10)

        -- Inisialisasi tab pertama
        if firstTab then
            Page.Visible = true
            TabBtn.BackgroundTransparency = 0
            TabBtn.TextColor3 = theme.Text
            firstTab = false
        end

        -- Efek Hover Tab
        TabBtn.MouseEnter:Connect(function()
            if not Page.Visible then
                TweenService:Create(TabBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0.5}):Play()
                TweenService:Create(TabBtn, TweenInfo.new(0.2), {TextColor3 = theme.Text}):Play()
            end
        end)
        TabBtn.MouseLeave:Connect(function()
            if not Page.Visible then
                TweenService:Create(TabBtn, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
                TweenService:Create(TabBtn, TweenInfo.new(0.2), {TextColor3 = theme.TextMuted}):Play()
            end
        end)

        -- Logika Pindah Tab
        TabBtn.MouseButton1Click:Connect(function()
            for _, v in ipairs(Container:GetChildren()) do 
                if v:IsA("ScrollingFrame") then v.Visible = false end 
            end
            for _, v in ipairs(Sidebar:GetChildren()) do 
                if v:IsA("TextButton") then 
                    TweenService:Create(v, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
                    TweenService:Create(v, TweenInfo.new(0.2), {TextColor3 = theme.TextMuted}):Play()
                end 
            end
            Page.Visible = true
            TweenService:Create(TabBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
            TweenService:Create(TabBtn, TweenInfo.new(0.2), {TextColor3 = theme.Text}):Play()
        end)

        local TabFunctions = {}
        
        -- ========================================================================
        -- SECTION & COMPONENTS
        -- ========================================================================
        function TabFunctions:AddSeperator(sepTitle)
            local SepFrame = Instance.new("Frame")
            SepFrame.Size = UDim2.new(1, 0, 0, 30)
            SepFrame.BackgroundTransparency = 1
            SepFrame.Parent = Page
            
            local SepLbl = Instance.new("TextLabel")
            SepLbl.Text = (sepTitle or "Separator"):upper()
            SepLbl.Size = UDim2.new(1, 0, 1, 0)
            SepLbl.TextColor3 = theme.Accent
            SepLbl.Font = Enum.Font.GothamBold
            SepLbl.TextSize = 11
            SepLbl.BackgroundTransparency = 1
            SepLbl.TextXAlignment = Enum.TextXAlignment.Left
            SepLbl.Parent = SepFrame

            local SectionFunctions = {}
            
            -- TOGGLE
            function SectionFunctions:AddToggle(tConfig)
                tConfig = tConfig or {}
                local state = tConfig.checked or false
                local callback = tConfig.callback or function() end

                local row = Instance.new("Frame")
                row.Size = UDim2.new(1, 0, 0, 38)
                row.BackgroundColor3 = theme.Row
                row.Parent = Page
                Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)

                local lbl = Instance.new("TextLabel")
                lbl.Text = tConfig.title or "Toggle"
                lbl.Size = UDim2.new(1, -60, 1, 0)
                lbl.Position = UDim2.new(0, 10, 0, 0)
                lbl.BackgroundTransparency = 1
                lbl.TextColor3 = theme.Text
                lbl.Font = Enum.Font.GothamMedium
                lbl.TextSize = 13
                lbl.TextXAlignment = Enum.TextXAlignment.Left
                lbl.Parent = row

                local sw = Instance.new("TextButton")
                sw.Size = UDim2.new(0, 40, 0, 22)
                sw.Position = UDim2.new(1, -50, 0.5, -11)
                sw.BackgroundColor3 = state and theme.Accent or theme.ToggleOff
                sw.Text = ""
                sw.AutoButtonColor = false
                sw.Parent = row
                Instance.new("UICorner", sw).CornerRadius = UDim.new(1, 0)

                local circle = Instance.new("Frame")
                circle.Size = UDim2.new(0, 18, 0, 18)
                circle.Position = state and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
                circle.BackgroundColor3 = Color3.new(1,1,1)
                circle.Parent = sw
                Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)

                -- Fungsi internal untuk update animasi UI Toggle
                local function updateUI(newState)
                    local tPos = newState and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
                    local tCol = newState and theme.Accent or theme.ToggleOff
                    TweenService:Create(circle, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = tPos}):Play()
                    TweenService:Create(sw, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = tCol}):Play()
                end

                sw.MouseButton1Click:Connect(function()
                    state = not state
                    updateUI(state)
                    task.spawn(function() pcall(callback, state) end)
                end)
                
                return {
                    getToggled = function() return state end,
                    setToggled = function(v) 
                        if type(v) == "boolean" and state ~= v then
                            state = v
                            updateUI(state)
                            task.spawn(function() pcall(callback, state) end)
                        end
                    end
                }
            end

            -- SLIDER
            function SectionFunctions:AddSlider(sConfig)
                sConfig = sConfig or {}
                local sValues = sConfig.values or {}
                local minVal = sValues.min or 0
                local maxVal = sValues.max or 100
                local val = sValues.default or minVal
                local callback = sConfig.callback or function() end

                local row = Instance.new("Frame")
                row.Size = UDim2.new(1, 0, 0, 50)
                row.BackgroundColor3 = theme.Row
                row.Parent = Page
                Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)

                local lbl = Instance.new("TextLabel")
                lbl.Text = sConfig.title or "Slider"
                lbl.Position = UDim2.new(0, 10, 0, 5)
                lbl.Size = UDim2.new(1, -20, 0, 20)
                lbl.BackgroundTransparency = 1
                lbl.TextColor3 = theme.TextMuted
                lbl.Font = Enum.Font.Gotham
                lbl.TextSize = 12
                lbl.TextXAlignment = Enum.TextXAlignment.Left
                lbl.Parent = row

                local valLbl = Instance.new("TextLabel")
                valLbl.Text = tostring(val)
                valLbl.Position = UDim2.new(1, -60, 0, 5)
                valLbl.Size = UDim2.new(0, 50, 0, 20)
                valLbl.BackgroundTransparency = 1
                valLbl.TextColor3 = theme.Text
                valLbl.Font = Enum.Font.GothamBold
                valLbl.TextSize = 12
                valLbl.TextXAlignment = Enum.TextXAlignment.Right
                valLbl.Parent = row

                local barBtn = Instance.new("TextButton")
                barBtn.Size = UDim2.new(1, -20, 0, 12) -- Hitbox lebih besar agar mudah disentuh
                barBtn.Position = UDim2.new(0, 10, 0, 30)
                barBtn.BackgroundTransparency = 1
                barBtn.Text = ""
                barBtn.Parent = row

                local bar = Instance.new("Frame")
                bar.Size = UDim2.new(1, 0, 0, 4)
                bar.Position = UDim2.new(0, 0, 0.5, -2)
                bar.BackgroundColor3 = theme.SliderBar
                bar.Parent = barBtn
                Instance.new("UICorner", bar)

                local fill = Instance.new("Frame")
                local p = (maxVal - minVal) == 0 and 0 or (val - minVal)/(maxVal - minVal)
                fill.Size = UDim2.new(math.clamp(p, 0, 1), 0, 1, 0)
                fill.BackgroundColor3 = theme.Accent
                fill.Parent = bar
                Instance.new("UICorner", fill)

                -- Fungsi internal untuk update posisi bar & angka
                local function setSliderVal(newVal)
                    val = math.clamp(newVal, minVal, maxVal)
                    local percent = (maxVal - minVal) == 0 and 0 or (val - minVal) / (maxVal - minVal)
                    
                    TweenService:Create(fill, TweenInfo.new(0.1), {Size = UDim2.new(percent, 0, 1, 0)}):Play()
                    valLbl.Text = tostring(val)
                    
                    task.spawn(function() pcall(callback, val) end)
                end

                -- Fungsi ketika disentuh / di-drag
                local function updateByInput(input)
                    local inputPos = input.Position.X
                    local barPos = bar.AbsolutePosition.X
                    local barSize = bar.AbsoluteSize.X
                    
                    local percent = math.clamp((inputPos - barPos) / barSize, 0, 1)
                    local newVal = math.floor(minVal + (maxVal - minVal) * percent)
                    
                    if val ~= newVal then
                        setSliderVal(newVal)
                    end
                end

                local dragging = false
                local dragConn

                barBtn.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = true
                        updateByInput(input)
                        
                        -- Hindari memory leak: putus koneksi lama jika ada
                        if dragConn then dragConn:Disconnect() end
                        
                        dragConn = UserInputService.InputChanged:Connect(function(changedInput)
                            if dragging and (changedInput.UserInputType == Enum.UserInputType.MouseMovement or changedInput.UserInputType == Enum.UserInputType.Touch) then
                                updateByInput(changedInput)
                            end
                        end)
                    end
                end)

                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = false
                        if dragConn then
                            dragConn:Disconnect()
                            dragConn = nil
                        end
                    end
                end)

                return {
                    getValue = function() return val end,
                    setValue = function(v) 
                        if type(v) == "number" then
                            setSliderVal(v)
                        end
                    end
                }
            end

            return SectionFunctions
        end
        return TabFunctions
    end
    return UI
end

return Library

--[[
-- ========================================================================
-- CONTOH PENGGUNAAN (EXAMPLE)
-- ========================================================================

local Library = require(path.to.this.module)

-- Init GUI, mendukung konfigurasi table untuk opsi ekstra
local UI = Library.init({
    title = "My Script Hub",
    sub = "v1.0",
    theme = "Dark" -- Pilihan: "Dark" atau "Light"
})

local TabMain = UI:AddTab("Main Features")
local SectionPlayer = TabMain:AddSeperator("Player Setup")

local ToggleGodMode = SectionPlayer:AddToggle({
    title = "God Mode",
    checked = false,
    callback = function(state)
        print("God Mode is now:", state)
    end
})

local SliderSpeed = SectionPlayer:AddSlider({
    title = "Walk Speed",
    values = {min = 16, max = 100, default = 16},
    callback = function(value)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
        print("Set walk speed to:", value)
    end
})

-- Mengubah nilai dari luar script (Berguna untuk load config):
task.spawn(function()
    task.wait(2)
    ToggleGodMode.setToggled(true)
    SliderSpeed.setValue(50)
end)
]]
