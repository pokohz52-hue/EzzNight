-- ==========================================
--  E Z Z  F L I C K  v2.3 (STRICT WALL CHECK)
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
    FOV = 220,
    Smoothing = 0.2, 
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
Instance.new("UIStroke", Main).Color = Settings.Color

local Title = Instance.new("TextButton", Main)
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(0, 50, 0)
Title.Text = "EZZ FLICK | NO WALLS"
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

-- [ СТРОГАЯ ПРОВЕРКА ВИДИМОСТИ ]
local function IsVisible(targetPart)
    local char = LocalPlayer.Character
    if not char then return false end
    
    -- Метод 1: Raycast
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.FilterDescendantsInstances = {char, Camera, workspace.CurrentCamera}
    rayParams.IgnoreWater = true
    
    local rayResult = workspace:Raycast(Camera.CFrame.Position, (targetPart.Position - Camera.CFrame.Position).Unit * (targetPart.Position - Camera.CFrame.Position).Magnitude, rayParams)
    
    -- Метод 2: Проверка на перекрывающие объекты
    local obs = Camera:GetPartsObscuringTarget({targetPart.Position}, {char, targetPart.Parent})
    
    -- Если луч ни во что не врезался ИЛИ врезался в цель, И нет перекрывающих объектов
    if (not rayResult or rayResult.Instance:IsDescendantOf(targetPart.Parent)) and #obs == 0 then
        return true
    end
    
    return false
end

-- [ ПОИСК ЦЕЛИ ]
local function GetClosest()
    local target = nil
    local dist = Settings.FOV
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
            local hum = p.Character:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 then
                local head = p.Character.Head
                local pos, vis = Camera:WorldToViewportPoint(head.Position)
                
                if vis then
                    -- Самая важная часть: Сначала проверяем видимость, потом расстояние
                    if IsVisible(head) then
                        local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                        if mag < dist then
                            target = head
                            dist = mag
                        end
                    end
                end
            end
        end
    end
    return target
end

-- [ ОСНОВНОЙ ЦИКЛ ]
local lastUpdate = tick()
RunService.RenderStepped:Connect(function()
    local fps = math.floor(1 / (tick() - lastUpdate))
    lastUpdate = tick()
    local ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
    StatsLabel.Text = "FPS: "..fps.." | Ping: "..ping.."ms"

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

    if Settings.Aimbot then
        local target = GetClosest()
        if target then
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, target.Position), Settings.Smoothing)
        end
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

CreateToggle("Strict Aim", "Aimbot")
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
