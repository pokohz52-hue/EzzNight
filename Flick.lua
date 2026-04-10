-- ==========================================
--  E Z Z  F L I C K  v1.9 (SAFE EDITION)
--  Сделал @MrFixTop
-- ==========================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Stats = game:GetService("Stats")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Settings = {
    Aimbot = false,
    ESP = false,
    NoRecoil = false,
    FOV = 250,
    Smoothing = 0.1, -- Баланс между скоростью и отсутствием тряски
    Color = Color3.fromRGB(0, 255, 0)
}

if CoreGui:FindFirstChild("EzzFlick") then CoreGui.EzzFlick:Destroy() end

-- [ ИНТЕРФЕЙС ]
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "EzzFlick"

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 220, 0, 310)
Main.Position = UDim2.new(0.5, -110, 0.5, -155)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Main.BorderSizePixel = 0
Main.Active = true

local Stroke = Instance.new("UIStroke", Main)
Stroke.Color = Settings.Color
Stroke.Thickness = 1.5

local Title = Instance.new("TextButton", Main)
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(0, 50, 0)
Title.Text = "EZZ FLICK | SAFE"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.RobotoMono
Title.TextSize = 14

local List = Instance.new("Frame", Main)
List.Position = UDim2.new(0, 10, 0, 45)
List.Size = UDim2.new(1, -20, 1, -90)
List.BackgroundTransparency = 1
Instance.new("UIListLayout", List).Padding = UDim.new(0, 5)

local StatsLabel = Instance.new("TextLabel", Main)
StatsLabel.Size = UDim2.new(1, 0, 0, 25)
StatsLabel.Position = UDim2.new(0, 0, 1, -25)
StatsLabel.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
StatsLabel.Font = Enum.Font.SourceSans
StatsLabel.TextColor3 = Color3.new(0.7, 0.7, 0.7)
StatsLabel.TextSize = 13

-- [ DRAG LOGIC ]
local dragging, dragStart, startPos
Title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = input.Position; startPos = Main.Position
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- [ AIM LOGIC ]
local function GetTarget()
    local target = nil
    local dist = Settings.FOV
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") and p.Character.Humanoid.Health > 0 then
            local pos, vis = Camera:WorldToViewportPoint(p.Character.Head.Position)
            if vis then
                local m = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                if m < dist then
                    target = p.Character.Head
                    dist = m
                end
            end
        end
    end
    return target
end

-- [ MAIN LOOP ]
local lastTick = tick()
RunService.RenderStepped:Connect(function()
    -- Stats update
    local fps = math.floor(1/(tick()-lastTick))
    lastTick = tick()
    local p = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
    StatsLabel.Text = "FPS: "..fps.." | Ping: "..p.."ms"

    -- ESP & NoRecoil
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local hi = player.Character:FindFirstChild("EzzHighlight") or Instance.new("Highlight", player.Character)
            hi.Name = "EzzHighlight"
            hi.Enabled = Settings.ESP
            hi.FillColor = Settings.Color
        end
    end
    
    if Settings.NoRecoil then
        local r = Camera:FindFirstChild("Recoil") or Camera:FindFirstChild("Shake")
        if r then r:Destroy() end
    end

    -- Aimbot (Safe method)
    if Settings.Aimbot then
        local t = GetTarget()
        if t then
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, t.Position), Settings.Smoothing)
        end
    end
end)

-- [ BUTTONS ]
local function CreateToggle(text, field)
    local btn = Instance.new("TextButton", List)
    btn.Size = UDim2.new(1, 0, 0, 32)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.Text = text .. ": OFF"
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.SourceSansBold
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 2)
    btn.MouseButton1Click:Connect(function()
        Settings[field] = not Settings[field]
        btn.Text = text .. (Settings[field] and ": ON" or ": OFF")
        btn.BackgroundColor3 = Settings[field] and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(30, 30, 30)
    end)
end

CreateToggle("Fast Aim", "Aimbot")
CreateToggle("Green ESP", "ESP")
CreateToggle("No Recoil", "NoRecoil")

-- Minimize
local min = false
Title.MouseButton1Click:Connect(function()
    if not dragging then
        min = not min
        Main:TweenSize(min and UDim2.new(0, 220, 0, 35) or UDim2.new(0, 220, 0, 310), "Out", "Quart", 0.3, true)
        List.Visible, StatsLabel.Visible = not min, not min
    end
end)
