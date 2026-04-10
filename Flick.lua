-- ==========================================
--  E Z Z  F L I C K  v2.6 (HEAD/BODY MIX)
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
    Smoothing = 0.35,
    Color = Color3.fromRGB(0, 255, 0)
}

local CurrentTarget = nil
local CurrentPartName = "Head" -- По умолчанию

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
Instance.new("UIStroke", Main).Color = Settings.Color

local Title = Instance.new("TextButton", Main)
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(0, 50, 0)
Title.Text = "EZZ FLICK | MIXED AIM"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.RobotoMono
Title.TextSize = 13

local List = Instance.new("Frame", Main)
List.Position = UDim2.new(0, 10, 0, 45)
List.Size = UDim2.new(1, -20, 1, -90)
List.BackgroundTransparency = 1
Instance.new("UIListLayout", List).Padding = UDim.new(0, 5)

local StatsLabel = Instance.new("TextLabel", Main)
StatsLabel.Size = UDim2.new(1, 0, 0, 25)
StatsLabel.Position = UDim2.new(0, 0, 1, -25)
StatsLabel.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
StatsLabel.TextColor3 = Color3.new(0.7, 0.7, 0.7)
StatsLabel.TextSize = 12

-- [ ПРОВЕРКА ВИДИМОСТИ ]
local function IsVisible(targetPart)
    if not targetPart then return false end
    local char = LocalPlayer.Character
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.FilterDescendantsInstances = {char, Camera}
    
    local rayResult = workspace:Raycast(Camera.CFrame.Position, (targetPart.Position - Camera.CFrame.Position).Unit * (targetPart.Position - Camera.CFrame.Position).Magnitude, rayParams)
    local obs = Camera:GetPartsObscuringTarget({targetPart.Position}, {char, targetPart.Parent})
    
    return (not rayResult or rayResult.Instance:IsDescendantOf(targetPart.Parent)) and #obs == 0
end

-- [ ПОИСК ЦЕЛИ С РАНДОМОМ ЧАСТИ ТЕЛА ]
local function GetTarget()
    -- Проверка текущей цели
    if CurrentTarget and CurrentTarget.Parent and CurrentTarget.Parent:FindFirstChild("Humanoid") and CurrentTarget.Parent.Humanoid.Health > 0 then
        local targetPart = CurrentTarget.Parent:FindFirstChild(CurrentPartName) or CurrentTarget.Parent:FindFirstChild("HumanoidRootPart")
        if targetPart and IsVisible(targetPart) then
            local pos, vis = Camera:WorldToViewportPoint(targetPart.Position)
            if vis and (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude < Settings.FOV then
                return targetPart
            end
        end
    end

    -- Поиск новой цели
    local potentialTarget = nil
    local dist = Settings.FOV
    
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
            -- Выбираем часть тела ПЕРЕД проверкой (50/50)
            local chosenName = (math.random(1, 100) <= 50) and "Head" or "UpperTorso"
            local part = p.Character:FindFirstChild(chosenName) or p.Character:FindFirstChild("Torso") or p.Character:FindFirstChild("HumanoidRootPart")
            
            if part and IsVisible(part) then
                local pos, vis = Camera:WorldToViewportPoint(part.Position)
                if vis then
                    local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                    if mag < dist then
                        potentialTarget = part
                        CurrentPartName = part.Name -- Запоминаем имя части
                        dist = mag
                    end
                end
            end
        end
    end
    
    CurrentTarget = potentialTarget
    return potentialTarget
end

-- [ ОСНОВНОЙ ЦИКЛ ]
RunService.RenderStepped:Connect(function(dt)
    local fps = math.floor(1 / dt)
    local ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
    StatsLabel.Text = "FPS: "..fps.." | Ping: "..ping.."ms"

    -- ВХ
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local hi = player.Character:FindFirstChild("EzzHighlight") or Instance.new("Highlight", player.Character)
            hi.Name = "EzzHighlight"
            hi.Enabled = Settings.ESP
            hi.FillColor = Settings.Color
        end
    end

    -- Анти-отдача
    if Settings.NoRecoil then
        local r = Camera:FindFirstChild("Recoil") or Camera:FindFirstChild("Shake")
        if r then r:Destroy() end
    end

    -- MIXED AIMBOT
    if Settings.Aimbot then
        local target = GetTarget()
        if target then
            local lookAt = CFrame.new(Camera.CFrame.Position, target.Position)
            Camera.CFrame = Camera.CFrame:Lerp(lookAt, Settings.Smoothing * (dt * 60))
        end
    else
        CurrentTarget = nil
    end
end)

-- [ КНОПКИ ]
local function CreateToggle(text, field)
    local btn = Instance.new("TextButton", List)
    btn.Size = UDim2.new(1, 0, 0, 35)
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

CreateToggle("Mix Aim (50/50)", "Aimbot")
CreateToggle("Green ESP", "ESP")
CreateToggle("No Recoil", "NoRecoil")

-- Перетаскивание
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

local min = false
Title.MouseButton1Click:Connect(function()
    if not dragging then
        min = not min
        Main:TweenSize(min and UDim2.new(0, 220, 0, 35) or UDim2.new(0, 220, 0, 310), "Out", "Quart", 0.3, true)
        List.Visible, StatsLabel.Visible = not min, not min
    end
end)
