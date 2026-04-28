local Library = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

function Library.init(title, version, sub)
    local UI = {}
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "UniversalMacOSLib"
    ScreenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- Main Frame
    local Main = Instance.new("Frame")
    Main.Size = UDim2.new(0, 520, 0, 380)
    Main.Position = UDim2.new(0.5, -260, 0.5, -190)
    Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    Main.Parent = ScreenGui
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)

    -- MacOS Dots
    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 40)
    TitleBar.BackgroundTransparency = 1
    TitleBar.Parent = Main
    
    local function makeDot(color, x)
        local d = Instance.new("Frame")
        d.Size = UDim2.new(0, 12, 0, 12)
        d.Position = UDim2.new(0, x, 0, 14)
        d.BackgroundColor3 = color
        d.Parent = TitleBar
        Instance.new("UICorner", d).CornerRadius = UDim.new(1, 0)
    end
    makeDot(Color3.fromRGB(255, 95, 87), 15)
    makeDot(Color3.fromRGB(255, 189, 46), 35)
    makeDot(Color3.fromRGB(40, 201, 64), 55)

    local TitleLbl = Instance.new("TextLabel")
    TitleLbl.Text = title .. " | " .. sub
    TitleLbl.Position = UDim2.new(0, 85, 0, 0)
    TitleLbl.Size = UDim2.new(0, 200, 1, 0)
    TitleLbl.BackgroundTransparency = 1
    TitleLbl.TextColor3 = Color3.fromRGB(200, 200, 200)
    TitleLbl.Font = Enum.Font.GothamBold
    TitleLbl.TextSize = 13
    TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
    TitleLbl.Parent = TitleBar

    -- Sidebar
    local Sidebar = Instance.new("Frame")
    Sidebar.Size = UDim2.new(0, 140, 1, -50)
    Sidebar.Position = UDim2.new(0, 10, 0, 45)
    Sidebar.BackgroundTransparency = 1
    Sidebar.Parent = Main
    local sList = Instance.new("UIListLayout", Sidebar)
    sList.Padding = UDim.new(0, 5)

    -- Container
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, -170, 1, -55)
    Container.Position = UDim2.new(0, 160, 0, 45)
    Container.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    Container.Parent = Main
    Instance.new("UICorner", Container).CornerRadius = UDim.new(0, 10)

    -- Floating Button for Android
    local Float = Instance.new("TextButton")
    Float.Size = UDim2.new(0, 45, 0, 45)
    Float.Position = UDim2.new(0, 20, 0.5, 0)
    Float.Text = "M"
    Float.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Float.TextColor3 = Color3.new(1,1,1)
    Float.Parent = ScreenGui
    Instance.new("UICorner", Float).CornerRadius = UDim.new(1, 0)
    Float.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)

    -- Dragging Logic
    local function drag(p, obj)
        local d, start, pStart
        p.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then d = true start = i.Position pStart = obj.Position end end)
        UserInputService.InputChanged:Connect(function(i) if d and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then 
            local delta = i.Position - start
            obj.Position = UDim2.new(pStart.X.Scale, pStart.X.Offset + delta.X, pStart.Y.Scale, pStart.Y.Offset + delta.Y)
        end end)
        p.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then d = false end end)
    end
    drag(TitleBar, Main)
    drag(Float, Float)

    local firstTab = true
    function UI:AddTab(tabName)
        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(1, 0, 0, 35)
        TabBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        TabBtn.BackgroundTransparency = 1
        TabBtn.Text = tabName
        TabBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
        TabBtn.Font = Enum.Font.GothamMedium
        TabBtn.TextSize = 13
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

        if firstTab then
            Page.Visible = true
            TabBtn.BackgroundTransparency = 0
            TabBtn.TextColor3 = Color3.new(1, 1, 1)
            firstTab = false
        end

        TabBtn.MouseButton1Click:Connect(function()
            for _, v in pairs(Container:GetChildren()) do if v:IsA("ScrollingFrame") then v.Visible = false end end
            for _, v in pairs(Sidebar:GetChildren()) do if v:IsA("TextButton") then v.BackgroundTransparency = 1 v.TextColor3 = Color3.fromRGB(150, 150, 150) end end
            Page.Visible = true
            TabBtn.BackgroundTransparency = 0
            TabBtn.TextColor3 = Color3.new(1,1,1)
        end)

        local TabFunctions = {}
        function TabFunctions:AddSeperator(sepTitle)
            local SepFrame = Instance.new("Frame")
            SepFrame.Size = UDim2.new(1, 0, 0, 30)
            SepFrame.BackgroundTransparency = 1
            SepFrame.Parent = Page
            
            local SepLbl = Instance.new("TextLabel")
            SepLbl.Text = sepTitle:upper()
            SepLbl.Size = UDim2.new(1, 0, 1, 0)
            SepLbl.TextColor3 = Color3.fromRGB(0, 170, 255)
            SepLbl.Font = Enum.Font.GothamBold
            SepLbl.TextSize = 11
            SepLbl.BackgroundTransparency = 1
            SepLbl.TextXAlignment = Enum.TextXAlignment.Left
            SepLbl.Parent = SepFrame

            local SectionFunctions = {}
            
            function SectionFunctions:AddToggle(config)
                local row = Instance.new("Frame")
                row.Size = UDim2.new(1, 0, 0, 38)
                row.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
                row.Parent = Page
                Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)

                local lbl = Instance.new("TextLabel")
                lbl.Text = config.title
                lbl.Size = UDim2.new(1, -60, 1, 0)
                lbl.Position = UDim2.new(0, 10, 0, 0)
                lbl.BackgroundTransparency = 1
                lbl.TextColor3 = Color3.fromRGB(200, 200, 200)
                lbl.Font = Enum.Font.GothamMedium
                lbl.TextSize = 13
                lbl.TextXAlignment = Enum.TextXAlignment.Left
                lbl.Parent = row

                local sw = Instance.new("TextButton")
                sw.Size = UDim2.new(0, 40, 0, 22)
                sw.Position = UDim2.new(1, -50, 0.5, -11)
                sw.BackgroundColor3 = config.checked and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(50, 50, 50)
                sw.Text = ""
                sw.Parent = row
                Instance.new("UICorner", sw).CornerRadius = UDim.new(1, 0)

                local circle = Instance.new("Frame")
                circle.Size = UDim2.new(0, 18, 0, 18)
                circle.Position = config.checked and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
                circle.BackgroundColor3 = Color3.new(1,1,1)
                circle.Parent = sw
                Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)

                local state = config.checked or false
                sw.MouseButton1Click:Connect(function()
                    state = not state
                    local tPos = state and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
                    local tCol = state and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(50, 50, 50)
                    TweenService:Create(circle, TweenInfo.new(0.2), {Position = tPos}):Play()
                    TweenService:Create(sw, TweenInfo.new(0.2), {BackgroundColor3 = tCol}):Play()
                    if config.callback then config.callback(state) end
                end)
                
                return {
                    getToggled = function() return state end,
                    setToggled = function(v) state = v -- (Add animation logic here) 
                    end
                }
            end

            function SectionFunctions:AddSlider(config)
                local row = Instance.new("Frame")
                row.Size = UDim2.new(1, 0, 0, 50)
                row.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
                row.Parent = Page
                Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)

                local lbl = Instance.new("TextLabel")
                lbl.Text = config.title
                lbl.Position = UDim2.new(0, 10, 0, 5)
                lbl.Size = UDim2.new(1, -20, 0, 20)
                lbl.BackgroundTransparency = 1
                lbl.TextColor3 = Color3.fromRGB(150, 150, 150)
                lbl.Font = Enum.Font.Gotham
                lbl.TextSize = 12
                lbl.TextXAlignment = Enum.TextXAlignment.Left
                lbl.Parent = row

                local valLbl = Instance.new("TextLabel")
                valLbl.Text = tostring(config.values.default)
                valLbl.Position = UDim2.new(1, -60, 0, 5)
                valLbl.Size = UDim2.new(0, 50, 0, 20)
                valLbl.BackgroundTransparency = 1
                valLbl.TextColor3 = Color3.new(1,1,1)
                valLbl.Font = Enum.Font.GothamBold
                valLbl.TextSize = 12
                valLbl.TextXAlignment = Enum.TextXAlignment.Right
                valLbl.Parent = row

                local bar = Instance.new("Frame")
                bar.Size = UDim2.new(1, -20, 0, 4)
                bar.Position = UDim2.new(0, 10, 0, 35)
                bar.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
                bar.Parent = row
                Instance.new("UICorner", bar)

                local fill = Instance.new("Frame")
                fill.Size = UDim2.new((config.values.default - config.values.min)/(config.values.max - config.values.min), 0, 1, 0)
                fill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
                fill.Parent = bar
                Instance.new("UICorner", fill)

                local val = config.values.default
                local function update()
                    local m = UserInputService:GetMouseLocation().X
                    local p = math.clamp((m - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
                    val = math.floor(config.values.min + (config.values.max - config.values.min) * p)
                    fill.Size = UDim2.new(p, 0, 1, 0)
                    valLbl.Text = tostring(val)
                    if config.callback then config.callback(val) end
                end

                local active = false
                row.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then active = true update() end end)
                UserInputService.InputChanged:Connect(function(i) if active and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then update() end end)
                UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then active = false end end)

                return {
                    getValue = function() return val end,
                    setValue = function(v) -- (Add logic here) 
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
