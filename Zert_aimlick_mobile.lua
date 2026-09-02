--[[
    ZERT AIMLOCK — ALWAYS CLOSEST
    - Targets the nearest alive drone every frame
    - Snap or smooth camera movement
    - Auto‑fire jammer (toggle)
    - Tap a drone to manually lock (overridden by closest if toggle ON)
    - Mobile‑friendly UI
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- ============================================================
-- CONFIG
-- ============================================================
local Config = {
    Aim = {
        Enabled = false,
        Smooth = false,          -- false = snap, true = smooth lerp
        Speed = 0.15,            -- lerp speed (0.01–0.5)
        LockPart = "PrimaryPart",
        Predict = 0.1,
        ClosestOnly = true,      -- if true, always track the closest drone
    },
    AutoFire = {
        Enabled = false,
        Cooldown = 0.3,          -- seconds between shots
    },
    DroneFolder = "Drones",      -- folder name in workspace
}

-- ============================================================
-- REMOTE REFERENCES
-- ============================================================
local JammedDroneRemote = nil
pcall(function()
    JammedDroneRemote = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Weapon"):WaitForChild("Jammer"):WaitForChild("JammedDrone")
end)

-- ============================================================
-- DRONE DETECTION
-- ============================================================
local DroneFolder = Workspace:FindFirstChild(Config.DroneFolder) or Workspace

local function GetAliveDrones()
    local drones = {}
    for _, child in pairs(DroneFolder:GetChildren()) do
        if child:IsA("Model") then
            local life = child:FindFirstChild("LifeStatus")
            local alive = true
            if life then
                if life:IsA("BoolValue") then alive = life.Value
                elseif life:IsA("IntValue") then alive = life.Value > 0 end
            end
            if alive then
                local lockPart = child:FindFirstChild(Config.Aim.LockPart) or child:FindFirstChild("HumanoidRootPart") or child:FindFirstChild("Head")
                if not lockPart then
                    for _, p in pairs(child:GetChildren()) do
                        if p:IsA("BasePart") then lockPart = p break end
                    end
                end
                if lockPart then
                    table.insert(drones, {
                        Model = child,
                        Root = lockPart,
                        Name = child.Name,
                    })
                end
            end
        end
    end
    return drones
end

local function GetClosestDrone()
    local closest, closestDist = nil, math.huge
    local camPos = Camera.CFrame.Position
    for _, d in pairs(GetAliveDrones()) do
        local dist = (d.Root.Position - camPos).Magnitude
        if dist < closestDist then
            closest = d
            closestDist = dist
        end
    end
    return closest
end

-- ============================================================
-- JAMMER
-- ============================================================
local function GetJammer()
    local char = LocalPlayer.Character
    if char then
        local j = char:FindFirstChild("Jammer")
        if j then return j end
    end
    return LocalPlayer.Backpack:FindFirstChild("Jammer")
end

local function FireJammer(drone)
    if not drone then return end
    if not JammedDroneRemote then return end
    local jammer = GetJammer()
    if not jammer then return end
    pcall(function()
        JammedDroneRemote:FireServer(drone.Model, Camera.CFrame)
    end)
end

-- ============================================================
-- UI
-- ============================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ZertAimlock"
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
if not ScreenGui.Parent then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 200, 0, 220)
MainFrame.Position = UDim2.new(0, 10, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
MainFrame.BackgroundTransparency = 0.2
MainFrame.BorderSizePixel = 1
MainFrame.BorderColor3 = Color3.fromRGB(0, 200, 255)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.Text = "⚡ ZERT AIMLOCK ⚡"
Title.TextColor3 = Color3.fromRGB(0, 200, 255)
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

local function AddToggle(text, yPos, configPath, default)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 28)
    frame.Position = UDim2.new(0, 10, 0, yPos)
    frame.BackgroundTransparency = 1
    frame.Parent = MainFrame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.Parent = frame

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 50, 0, 22)
    btn.Position = UDim2.new(0.8, 0, 0.1, 0)
    btn.BackgroundColor3 = default and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(100, 100, 100)
    btn.Text = default and "ON" or "OFF"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamBold
    btn.BorderSizePixel = 0
    btn.Parent = frame

    local state = default
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.BackgroundColor3 = state and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(100, 100, 100)
        btn.Text = state and "ON" or "OFF"
        local keys = {}
        for part in configPath:gmatch("[^%.]+") do table.insert(keys, part) end
        local target = Config
        for i = 1, #keys - 1 do target = target[keys[i]] end
        target[keys[#keys]] = state
    end)
    return frame
end

AddToggle("Aimlock", 35, "Aim.Enabled", false)
AddToggle("Smooth", 65, "Aim.Smooth", false)
AddToggle("Closest Only", 95, "Aim.ClosestOnly", true)
AddToggle("Auto Fire", 125, "AutoFire.Enabled", false)

-- Status label
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -20, 0, 30)
StatusLabel.Position = UDim2.new(0, 10, 0, 160)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Target: None"
StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusLabel.TextSize = 14
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = MainFrame

-- ============================================================
-- CORE AIMLOCK
-- ============================================================
local AimTarget = nil
local lastFireTime = 0

local function UpdateAimlock()
    if not Config.Aim.Enabled then
        AimTarget = nil
        StatusLabel.Text = "🔴 Aimlock OFF"
        return
    end

    local newTarget = nil

    if Config.Aim.ClosestOnly then
        -- Always pick the closest drone
        newTarget = GetClosestDrone()
    else
        -- Sticky mode: keep current target if alive, else find new
        if AimTarget and AimTarget.Root and AimTarget.Root.Parent then
            local life = AimTarget.Model:FindFirstChild("LifeStatus")
            if not life or (life:IsA("BoolValue") and life.Value) then
                newTarget = AimTarget
            end
        end
        if not newTarget then
            newTarget = GetClosestDrone()
        end
    end

    if not newTarget then
        AimTarget = nil
        StatusLabel.Text = "🔍 No drones"
        return
    end

    -- Validate
    if not newTarget.Root or not newTarget.Root.Parent then
        AimTarget = nil
        return
    end

    local life = newTarget.Model:FindFirstChild("LifeStatus")
    if life and life:IsA("BoolValue") and not life.Value then
        AimTarget = nil
        return
    end

    -- Update target
    AimTarget = newTarget

    -- Predict
    local targetPos = AimTarget.Root.Position
    if Config.Aim.Predict > 0 then
        local vel = AimTarget.Root.Velocity
        if vel then
            targetPos = targetPos + (vel * Config.Aim.Predict)
        end
    end

    -- Apply aim
    local newCF = CFrame.new(Camera.CFrame.Position, targetPos)
    if Config.Aim.Smooth then
        Camera.CFrame = Camera.CFrame:Lerp(newCF, Config.Aim.Speed * 2)
    else
        Camera.CFrame = newCF
    end

    StatusLabel.Text = "🎯 Locked: " .. AimTarget.Name

    -- Auto fire
    if Config.AutoFire.Enabled then
        local now = tick()
        if now - lastFireTime >= Config.AutoFire.Cooldown then
            FireJammer(AimTarget)
            lastFireTime = now
        end
    end
end

-- ============================================================
-- LOOP
-- ============================================================
RunService.RenderStepped:Connect(function()
    UpdateAimlock()
end)

-- ============================================================
-- MANUAL TAP (only works if ClosestOnly is OFF)
-- ============================================================
Mouse.Button1Down:Connect(function()
    if Config.Aim.ClosestOnly then
        -- Overridden by closest targeting
        return
    end
    local part = Mouse.Target
    if part and part.Parent then
        local model = part.Parent
        if model:IsA("Model") then
            local life = model:FindFirstChild("LifeStatus")
            if life and (not life:IsA("BoolValue") or life.Value) then
                local root = model:FindFirstChild(Config.Aim.LockPart) or model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Head")
                if not root then
                    for _, p in pairs(model:GetChildren()) do
                        if p:IsA("BasePart") then root = p break end
                    end
                end
                if root then
                    AimTarget = {
                        Model = model,
                        Root = root,
                        Name = model.Name,
                    }
                    StatusLabel.Text = "👆 Manual: " .. model.Name
                end
            end
        end
    end
end)

-- ============================================================
-- CONSOLE DEBUG (print drone count every 2s)
-- ============================================================
spawn(function()
    while wait(2) do
        local count = #GetAliveDrones()
        print("[ZERT] Drones alive: " .. count)
        if Config.Aim.Enabled and AimTarget then
            print("[ZERT] Locked onto: " .. AimTarget.Name)
        end
    end
end)

print("⚡ ZERT AIMLOCK (ALWAYS CLOSEST) LOADED")
print("📱 Toggle Aimlock ON/OFF from UI")
print("🎯 'Closest Only' ON = always target nearest drone")
print("👆 Tap a drone to lock manually (if Closest Only is OFF)")
