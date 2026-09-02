--[[
    ZERT SHADOW AIMBOT + ESP v18.0 — HEAD SNAP ON SHOOT
    DELTA EXECUTOR MOBILE — PERFECT HEADSHOT AIMBOT
]]

-- [[ SERVICES ]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")

-- [[ VARIABLES ]]
local aimbotActive = true
local espActive = true
local triggerbotActive = true
local aimlockActive = false
local wallbangActive = true
local fovCircle = nil
local currentTarget = nil
local drawings = {}
local isDragging = false
local minimized = false
local lastTap = 0
local espUpdateCounter = 0
local lockedTarget = nil
local isAimlocking = false
local lastShotTime = 0
local snapActive = false

-- [[ CONFIG ]]
local Config = {
    AimFOV = 300,
    Smoothness = 0.08,
    AimPart = "Head",
    TeamCheck = false,
    VisibleCheck = false,
    Wallbang = true,
    Prediction = true,
    Triggerbot = true,
    MaxDistance = 500,
    ShowFOV = true,
    BoxESP = true,
    TracerESP = true,
    NameESP = true,
    HealthBar = true,
    ESPColor = Color3.fromRGB(0, 255, 255),
    HeadSnapSpeed = 0.01,      -- Instant snap to head
    AutoAim = true
}

-- [[ UI CREATION ]]
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ZertShadowGUI"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 210, 0, 420)
MainFrame.Position = UDim2.new(0.5, -105, 0.1, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(0, 255, 255)
MainFrame.Parent = ScreenGui
MainFrame.ClipsDescendants = true

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 30)
TitleBar.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
TitleBar.BackgroundTransparency = 0.15
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(0.5, 0, 1, 0)
TitleLabel.Position = UDim2.new(0, 10, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "⚡ ZERT v18"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 14
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

-- Status Indicator
local StatusLight = Instance.new("Frame")
StatusLight.Size = UDim2.new(0, 8, 0, 8)
StatusLight.Position = UDim2.new(0.5, -4, 0.5, -4)
StatusLight.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
StatusLight.BorderSizePixel = 0
StatusLight.Parent = TitleBar

local StatusCorner = Instance.new("UICorner")
StatusCorner.CornerRadius = UDim.new(1, 0)
StatusCorner.Parent = StatusLight

-- Hide Button
local HideButton = Instance.new("TextButton")
HideButton.Size = UDim2.new(0, 25, 0, 25)
HideButton.Position = UDim2.new(0.85, 0, 0.5, -12.5)
HideButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
HideButton.BackgroundTransparency = 0.3
HideButton.BorderSizePixel = 0
HideButton.Text = "✕"
HideButton.TextColor3 = Color3.fromRGB(255, 255, 255)
HideButton.TextSize = 14
HideButton.Font = Enum.Font.GothamBold
HideButton.Parent = TitleBar

local HideCorner = Instance.new("UICorner")
HideCorner.CornerRadius = UDim.new(0, 5)
HideCorner.Parent = HideButton

-- Minimize Button
local MinButton = Instance.new("TextButton")
MinButton.Size = UDim2.new(0, 25, 0, 25)
MinButton.Position = UDim2.new(0.7, 0, 0.5, -12.5)
MinButton.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
MinButton.BackgroundTransparency = 0.3
MinButton.BorderSizePixel = 0
MinButton.Text = "━"
MinButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinButton.TextSize = 14
MinButton.Font = Enum.Font.GothamBold
MinButton.Parent = TitleBar

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 5)
MinCorner.Parent = MinButton

-- Content Frame
local ContentFrame = Instance.new("ScrollingFrame")
ContentFrame.Size = UDim2.new(1, 0, 1, -30)
ContentFrame.Position = UDim2.new(0, 0, 0, 30)
ContentFrame.BackgroundTransparency = 1
ContentFrame.BorderSizePixel = 0
ContentFrame.Parent = MainFrame
ContentFrame.ScrollBarThickness = 2
ContentFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 255)

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 4)
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.Parent = ContentFrame

-- [[ UI FUNCTIONS ]]
local function CreateToggle(text, getter, setter)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.9, 0, 0, 28)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 45)
    frame.BackgroundTransparency = 0.2
    frame.BorderSizePixel = 1
    frame.BorderColor3 = Color3.fromRGB(0, 255, 255)
    frame.Parent = ContentFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 5)
    corner.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.Position = UDim2.new(0, 8, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 11
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local toggle = Instance.new("Frame")
    toggle.Size = UDim2.new(0, 28, 0, 15)
    toggle.Position = UDim2.new(0.7, 0, 0.5, -7.5)
    toggle.BackgroundColor3 = getter() and Color3.fromRGB(0, 255, 200) or Color3.fromRGB(60, 60, 60)
    toggle.BorderSizePixel = 0
    toggle.Parent = frame
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(1, 0)
    toggleCorner.Parent = toggle
    
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 10, 0, 10)
    dot.Position = getter() and UDim2.new(0.5, 0, 0.5, -5) or UDim2.new(0.05, 0, 0.5, -5)
    dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    dot.BorderSizePixel = 0
    dot.Parent = toggle
    
    local dotCorner = Instance.new("UICorner")
    dotCorner.CornerRadius = UDim.new(1, 0)
    dotCorner.Parent = dot
    
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            local newState = not getter()
            setter(newState)
            toggle.BackgroundColor3 = newState and Color3.fromRGB(0, 255, 200) or Color3.fromRGB(60, 60, 60)
            dot.Position = newState and UDim2.new(0.5, 0, 0.5, -5) or UDim2.new(0.05, 0, 0.5, -5)
            if text == "AIMBOT" then
                StatusLight.BackgroundColor3 = newState and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
            end
        end
    end)
    
    return frame
end

local function CreateSlider(text, min, max, getter, setter, format)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.9, 0, 0, 38)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 45)
    frame.BackgroundTransparency = 0.2
    frame.BorderSizePixel = 1
    frame.BorderColor3 = Color3.fromRGB(0, 255, 255)
    frame.Parent = ContentFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 5)
    corner.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0.4, 0)
    label.Position = UDim2.new(0, 8, 0, 2)
    label.BackgroundTransparency = 1
    label.Text = text .. ": " .. format(getter())
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 10
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local slider = Instance.new("Frame")
    slider.Size = UDim2.new(0.8, 0, 0.15, 0)
    slider.Position = UDim2.new(0.1, 0, 0.6, 0)
    slider.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    slider.BorderSizePixel = 0
    slider.Parent = frame
    
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(1, 0)
    sliderCorner.Parent = slider
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((getter() - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 255, 200)
    fill.BorderSizePixel = 0
    fill.Parent = slider
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill
    
    slider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            local pos = input.Position.X - slider.AbsolutePosition.X
            local value = math.clamp(min + ((pos / slider.AbsoluteSize.X) * (max - min)), min, max)
            setter(value)
            label.Text = text .. ": " .. format(value)
            fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            local pos = input.Position.X - slider.AbsolutePosition.X
            local value = math.clamp(min + ((pos / slider.AbsoluteSize.X) * (max - min)), min, max)
            setter(value)
            label.Text = text .. ": " .. format(value)
            fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
        end
    end)
    
    return frame
end

-- [[ BUILD UI ]]
CreateToggle("AIMBOT", function() return aimbotActive end, function(v) aimbotActive = v end)
CreateToggle("AIMLOCK", function() return aimlockActive end, function(v) aimlockActive = v end)
CreateToggle("TRIGGERBOT", function() return triggerbotActive end, function(v) triggerbotActive = v end)
CreateToggle("WALLBANG", function() return wallbangActive end, function(v) wallbangActive = v end)
CreateToggle("ESP", function() return espActive end, function(v) espActive = v end)
CreateToggle("PREDICTION", function() return Config.Prediction end, function(v) Config.Prediction = v end)
CreateToggle("FOV", function() return Config.ShowFOV end, function(v) Config.ShowFOV = v end)

CreateSlider("FOV", 50, 500,
    function() return Config.AimFOV end,
    function(v) Config.AimFOV = math.floor(v) end,
    function(v) return tostring(math.floor(v)) end
)

CreateSlider("SMOOTH", 0.01, 0.5,
    function() return Config.Smoothness end,
    function(v) Config.Smoothness = v end,
    function(v) return string.format("%.2f", v) end
)

CreateSlider("DISTANCE", 100, 1000,
    function() return Config.MaxDistance end,
    function(v) Config.MaxDistance = math.floor(v) end,
    function(v) return tostring(math.floor(v)) end
)

-- [[ DRAGGING SYSTEM ]]
local dragStart = nil
local dragOffset = nil

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        dragStart = input.Position
        dragOffset = Vector2.new(
            MainFrame.AbsolutePosition.X - input.Position.X,
            MainFrame.AbsolutePosition.Y - input.Position.Y
        )
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch and dragStart then
        MainFrame.Position = UDim2.new(0, input.Position.X + dragOffset.X, 0, input.Position.Y + dragOffset.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        dragStart = nil
    end
end)

-- [[ HIDE/SHOW ]]
HideButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

MinButton.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        MainFrame:TweenSize(UDim2.new(0, 210, 0, 30), "Out", "Quad", 0.3, true)
        ContentFrame.Visible = false
    else
        MainFrame:TweenSize(UDim2.new(0, 210, 0, 420), "Out", "Quad", 0.3, true)
        wait(0.3)
        ContentFrame.Visible = true
    end
end)

UserInputService.TouchTap:Connect(function()
    local currentTime = tick()
    if currentTime - lastTap < 0.3 then
        MainFrame.Visible = not MainFrame.Visible
    end
    lastTap = currentTime
end)

-- [[ AIMLOCK KEYBIND ]]
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Q then
        aimlockActive = not aimlockActive
        if aimlockActive then
            isAimlocking = true
            local target = GetBestTarget()
            if target then
                lockedTarget = target
            end
        else
            isAimlocking = false
            lockedTarget = nil
        end
        print("⚡ Aimlock:", aimlockActive and "ON ✓" or "OFF")
    end
end)

-- [[ DRAWING FUNCTIONS ]]
local function ClearDrawings()
    for _, d in pairs(drawings) do
        pcall(function() d:Remove() end)
    end
    drawings = {}
end

local function CreateDrawing(drawType, props)
    local success, d = pcall(function()
        return Drawing.new(drawType)
    end)
    if not success then return nil end
    for k, v in pairs(props) do
        pcall(function() d[k] = v end)
    end
    table.insert(drawings, d)
    return d
end

-- [[ SMOOTH ESP ]]
local function UpdateESP()
    if not espActive then 
        if #drawings > 0 then ClearDrawings() end
        return 
    end
    
    espUpdateCounter = espUpdateCounter + 1
    if espUpdateCounter % 2 ~= 0 then return end
    
    local persistent = {fovCircle}
    local newDrawings = {}
    for _, d in pairs(drawings) do
        local keep = false
        for _, p in pairs(persistent) do
            if d == p then keep = true end
        end
        if not keep then
            pcall(function() d:Remove() end)
        else
            table.insert(newDrawings, d)
        end
    end
    drawings = newDrawings
    
    local viewportSize = Camera.ViewportSize
    local center = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
    
    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if not player.Character then continue end
        
        local root = player.Character:FindFirstChild("HumanoidRootPart")
        local humanoid = player.Character:FindFirstChild("Humanoid")
        if not root or not humanoid then continue end
        
        local distance = (Camera.CFrame.Position - root.Position).Magnitude
        if distance > Config.MaxDistance then continue end
        
        local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
        if not onScreen then continue end
        
        -- BOX ESP
        if Config.BoxESP then
            local size = Vector2.new(2.5, 3.5) * (root.Size.X * 1.8)
            local boxPos = Vector2.new(pos.X - size.X/2, pos.Y - size.Y/2 + 10)
            
            CreateDrawing("Square", {
                Color = Color3.fromRGB(0, 0, 0),
                Thickness = 4,
                Transparency = 0.5,
                Position = boxPos,
                Size = size,
                Visible = true
            })
            
            CreateDrawing("Square", {
                Color = Config.ESPColor,
                Thickness = 2,
                Transparency = 0.7,
                Position = boxPos,
                Size = size,
                Visible = true
            })
        end
        
        -- TRACER
        if Config.TracerESP then
            CreateDrawing("Line", {
                Color = Config.ESPColor,
                Thickness = 1.5,
                Transparency = 0.5,
                From = Vector2.new(center.X, viewportSize.Y),
                To = Vector2.new(pos.X, pos.Y),
                Visible = true
            })
        end
        
        -- NAME
        if Config.NameESP then
            CreateDrawing("Text", {
                Text = player.Name .. " [" .. math.floor(distance) .. "m]",
                Position = Vector2.new(pos.X, pos.Y - 40),
                Size = 13,
                Center = true,
                Color = Color3.fromRGB(255, 255, 255),
                Visible = true,
                Outline = true,
                OutlineColor = Color3.fromRGB(0, 0, 0)
            })
        end
        
        -- HEALTH
        if Config.HealthBar then
            local health = humanoid.Health / humanoid.MaxHealth
            local healthColor = Color3.fromRGB(255 * (1 - health), 255 * health, 0)
            
            CreateDrawing("Line", {
                Color = Color3.fromRGB(40, 40, 40),
                Thickness = 4,
                From = Vector2.new(pos.X - 18, pos.Y - 28),
                To = Vector2.new(pos.X + 18, pos.Y - 28),
                Visible = true
            })
            
            CreateDrawing("Line", {
                Color = healthColor,
                Thickness = 4,
                From = Vector2.new(pos.X - 18, pos.Y - 28),
                To = Vector2.new(pos.X - 18 + (36 * health), pos.Y - 28),
                Visible = true
            })
        end
    end
end

-- [[ GET BEST TARGET ]]
local function GetBestTarget()
    if not aimbotActive then return nil end
    
    local closest = nil
    local closestDist = Config.AimFOV
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local localPos = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not localPos then return nil end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if not player.Character then continue end
        
        local root = player.Character:FindFirstChild("HumanoidRootPart")
        if not root then continue end
        
        if Config.TeamCheck and player.Team == LocalPlayer.Team then continue end
        
        local distance = (localPos.Position - root.Position).Magnitude
        if distance > Config.MaxDistance then continue end
        
        if wallbangActive then
            -- Wallbang enabled
        else
            local params = RaycastParams.new()
            params.FilterType = Enum.RaycastFilterType.Blacklist
            params.FilterDescendantsInstances = {LocalPlayer.Character}
            local ray = workspace:Raycast(Camera.CFrame.Position, (root.Position - Camera.CFrame.Position).Unit * distance, params)
            if ray and not ray.Instance:IsDescendantOf(player.Character) then continue end
        end
        
        -- AIM FOR HEAD
        local head = player.Character:FindFirstChild("Head")
        local aimPart = head or root
        local aimPos = aimPart.Position
        
        if Config.Prediction then
            local velocity = root.Velocity
            local timeToTarget = distance / 2500
            aimPos = aimPos + velocity * timeToTarget
        end
        
        local screenPos, onScreen = Camera:WorldToViewportPoint(aimPos)
        if not onScreen then continue end
        
        local screenDist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
        if screenDist < closestDist then
            closestDist = screenDist
            closest = {
                Player = player,
                Position = aimPos,
                ScreenPos = Vector2.new(screenPos.X, screenPos.Y),
                Distance = distance,
                Root = root,
                Head = head,
                AimPart = aimPart
            }
        end
    end
    
    return closest
end

-- [[ PERFECT HEAD AIM - SNAP ON SHOOT ]]
local function AimAtHead(targetPos, snap)
    if not targetPos then return end
    
    local currentCF = Camera.CFrame
    local direction = (targetPos - currentCF.Position).Unit
    local targetCF = CFrame.new(currentCF.Position, currentCF.Position + direction * 1000)
    
    if snap or aimlockActive then
        -- INSTANT HEAD SNAP
        Camera.CFrame = targetCF
        snapActive = true
    else
        -- Smooth aim
        local smoothFactor = Config.Smoothness
        Camera.CFrame = currentCF:Lerp(targetCF, smoothFactor)
    end
end

-- [[ HEAD SNAP ON SHOOT - MAIN FEATURE ]]
local function HeadSnapOnShoot(target)
    if not target then return end
    if not IsShooting() then return end
    
    -- INSTANTLY SNAP TO HEAD
    local currentCF = Camera.CFrame
    local headPos = target.Position
    local direction = (headPos - currentCF.Position).Unit
    Camera.CFrame = CFrame.new(currentCF.Position, currentCF.Position + direction * 1000)
    
    -- Visual snap indicator - HEADSHOT CROSS
    CreateDrawing("Line", {
        Color = Color3.fromRGB(255, 0, 0),
        Thickness = 3,
        Transparency = 0.6,
        From = Vector2.new(Camera.ViewportSize.X/2 - 25, Camera.ViewportSize.Y/2),
        To = Vector2.new(Camera.ViewportSize.X/2 + 25, Camera.ViewportSize.Y/2),
        Visible = true
    })
    CreateDrawing("Line", {
        Color = Color3.fromRGB(255, 0, 0),
        Thickness = 3,
        Transparency = 0.6,
        From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2 - 25),
        To = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2 + 25),
        Visible = true
    })
    
    -- Circle around crosshair
    CreateDrawing("Circle", {
        Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2),
        Radius = 15,
        Color = Color3.fromRGB(255, 0, 0),
        Thickness = 2,
        Filled = false,
        Visible = true,
        Transparency = 0.5
    })
    
    -- "HEADSHOT" text
    CreateDrawing("Text", {
        Text = "🎯 HEADSHOT",
        Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2 - 40),
        Size = 18,
        Center = true,
        Color = Color3.fromRGB(255, 0, 0),
        Visible = true,
        Outline = true,
        OutlineColor = Color3.fromRGB(0, 0, 0)
    })
end

-- [[ TRIGGERBOT ]]
local function DoTriggerbot()
    if not triggerbotActive then return end
    if not LocalPlayer.Character then return end
    
    local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
    if not tool then return end
    
    VirtualInputManager:SendMouseButtonEvent(Enum.UserInputType.MouseButton1, 0, 0, true)
    wait(0.05)
    VirtualInputManager:SendMouseButtonEvent(Enum.UserInputType.MouseButton1, 0, 0, false)
end

-- [[ SHOOT DETECTION ]]
local function IsShooting()
    if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
        return true
    end
    
    for _, touch in pairs(UserInputService:GetTouchPositions()) do
        if touch.X > Camera.ViewportSize.X / 2 then
            return true
        end
    end
    
    return false
end

-- [[ MAIN LOOP ]]
RunService.RenderStepped:Connect(function()
    -- Update ESP
    UpdateESP()
    
    -- FOV Circle
    if Config.ShowFOV and aimbotActive then
        if not fovCircle then
            fovCircle = Drawing.new("Circle")
            fovCircle.Thickness = 1
            fovCircle.Color = Color3.fromRGB(0, 255, 255)
            fovCircle.Filled = false
            fovCircle.NumSides = 64
            fovCircle.Radius = Config.AimFOV
            fovCircle.Visible = true
            fovCircle.Transparency = 0.3
        end
        fovCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
        fovCircle.Radius = Config.AimFOV
        fovCircle.Visible = true
    else
        if fovCircle then
            fovCircle.Visible = false
        end
    end
    
    -- AIMBOT LOGIC
    if aimbotActive then
        local target = GetBestTarget()
        
        -- AIMLOCK - Hard lock
        if aimlockActive then
            if target then
                lockedTarget = target
                AimAtHead(target.Position, true)
                
                -- Lock indicators
                CreateDrawing("Circle", {
                    Position = target.ScreenPos,
                    Radius = 30,
                    Color = Color3.fromRGB(255, 0, 0),
                    Thickness = 4,
                    Filled = false,
                    Visible = true,
                    Transparency = 0.5
                })
                
                CreateDrawing("Circle", {
                    Position = target.ScreenPos,
                    Radius = 40,
                    Color = Color3.fromRGB(255, 0, 0),
                    Thickness = 2,
                    Filled = false,
                    Visible = true,
                    Transparency = 0.3
                })
                
                CreateDrawing("Line", {
                    Color = Color3.fromRGB(255, 0, 0),
                    Thickness = 2,
                    Transparency = 0.5,
                    From = Vector2.new(target.ScreenPos.X - 20, target.ScreenPos.Y),
                    To = Vector2.new(target.ScreenPos.X + 20, target.ScreenPos.Y),
                    Visible = true
                })
                CreateDrawing("Line", {
                    Color = Color3.fromRGB(255, 0, 0),
                    Thickness = 2,
                    Transparency = 0.5,
                    From = Vector2.new(target.ScreenPos.X, target.ScreenPos.Y - 20),
                    To = Vector2.new(target.ScreenPos.X, target.ScreenPos.Y + 20),
                    Visible = true
                })
                
                CreateDrawing("Text", {
                    Text = "🔒 LOCKED ON HEAD",
                    Position = Vector2.new(target.ScreenPos.X, target.ScreenPos.Y - 50),
                    Size = 14,
                    Center = true,
                    Color = Color3.fromRGB(255, 0, 0),
                    Visible = true,
                    Outline = true,
                    OutlineColor = Color3.fromRGB(0, 0, 0)
                })
            end
        end
        
        -- NORMAL AIMBOT
        if target and not aimlockActive then
            currentTarget = target
            
            -- Smooth aim at head
            AimAtHead(target.Position, false)
            
            -- HEAD SNAP ON SHOOT - MAIN FEATURE
            if IsShooting() then
                HeadSnapOnShoot(target)
                DoTriggerbot()
            end
            
            -- Target indicator (green)
            CreateDrawing("Circle", {
                Position = target.ScreenPos,
                Radius = 12,
                Color = Color3.fromRGB(0, 255, 0),
                Thickness = 2,
                Filled = false,
                Visible = true,
                Transparency = 0.5
            })
            
            -- Head indicator
            if target.Head then
                local headPos, headOnScreen = Camera:WorldToViewportPoint(target.Head.Position)
                if headOnScreen then
                    CreateDrawing("Circle", {
                        Position = Vector2.new(headPos.X, headPos.Y),
                        Radius = 5,
                        Color = Color3.fromRGB(255, 255, 0),
                        Thickness = 2,
                        Filled = true,
                        Visible = true,
                        Transparency = 0.7
                    })
                end
            end
            
            -- Distance
            CreateDrawing("Text", {
                Text = math.floor(target.Distance) .. "m",
                Position = Vector2.new(target.ScreenPos.X, target.ScreenPos.Y + 25),
                Size = 12,
                Center = true,
                Color = Color3.fromRGB(255, 255, 0),
                Visible = true,
                Outline = true,
                OutlineColor = Color3.fromRGB(0, 0, 0)
            })
        end
    end
end)

-- [[ CLEANUP ]]
game:GetService("Players").PlayerRemoving:Connect(function()
    ClearDrawings()
end)

-- [[ FINAL STATUS ]]
print("========================================")
print("⚡ ZERT SHADOW v18.0 — HEAD SNAP ⚡")
print("========================================")
print("✅ HEAD SNAP ON SHOOT — Instant headshot")
print("✅ AIMLOCK — Hold Q for hard lock")
print("✅ FOV SYSTEM — Targets in FOV")
print("✅ WALLBANG — Shoot through walls")
print("✅ TRIGGERBOT — Auto-shoot on target")
print("✅ PREDICTION — Bullet drop + velocity")
print("========================================")
print("📱 CONTROLS:")
print("  • SHOOT = Instant HEAD SNAP")
print("  • Hold Q = AIMLOCK (hard lock)")
print("  • Drag title bar to move UI")
print("  • ✕ = Hide UI")
print("  • ━ = Minimize")
print("  • Double tap = Toggle UI")
print("========================================")
print("⚡ MADE BY ZERT SHADOW ⚡")
print("========================================")
