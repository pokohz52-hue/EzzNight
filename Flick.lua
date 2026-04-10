-- ==========================================
--  E Z Z  F L I C K  v1.8 (SILENT AIM)
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
    SilentAim = false,
    ESP = false,
    NoRecoil = false,
    FOV = 200, -- Радиус "магнита" пуль
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
Title.Text = "EZZ FLICK | SILENT"
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

-- Круг FOV для Сайлента
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.Color = Settings.Color
FOVCircle.Transparency = 0.7
FOVCircle.Filled = false

-- [ ЛОГИКА ПЕРЕТАСКИВАНИЯ ]
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

-- [ ФУНКЦИЯ ПОИСКА ЦЕЛИ ]
local function GetClosestTarget()
    local target = nil
    local shortestDist = Settings.FOV
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            if player.Character.Humanoid.Health > 0 then
                local pos, onScreen = Camera:WorldToViewportPoint(player.Character.Head.Position)
                if onScreen then
                    local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                    if dist < shortestDist then
                        target = player.Character.Head
                        shortestDist = dist
                    end
                end
            end
        end
    end
    return target
end

-- [ SILENT AIM (HOOK) ]
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    
    if Settings.SilentAim and method == "FindPartOnRayWithIgnoreList" or method == "Raycast" then
        local target = GetClosestTarget()
        if target then
            -- Магия: перенаправляем луч выстрела в голову цели
            args[1] = Ray.new(Camera.CFrame.Position, (target.Position - Camera.CFrame.Position).Unit * 1000)
            return oldNamecall(self, unpack(args))
        end
    end
    return oldNamecall(self, ...)
end)

-- [ ЦИКЛ ОБНОВЛЕНИЯ ]
local lastUpdate = tick()
RunService.RenderStepped:Connect(function()
    -- Обновление круга FOV
    FOVCircle.Visible = Settings.SilentAim
    FOVCircle.Radius = Settings.FOV
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

    -- Статы
    local fps = math.floor(1 / (tick() - lastUpdate))
    lastUpdate = tick()
    local ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
    StatsLabel.Text = "FPS: "..fps.." | Ping: "..ping.."ms"

    -- No Recoil
    if Settings.NoRecoil then
        local recoil = Camera:FindFirstChild("Recoil") or Camera:FindFirstChild("Shake")
        if recoil then recoil:Destroy() end
    end

    -- ВХ (Highlights)
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local highlight = player.Character:FindFirstChild("EzzHighlight") or Instance.new("Highlight", player.Character)
            highlight.Name = "EzzHighlight"
            highlight.Enabled = Settings.ESP
            highlight.FillColor = Settings.Color
        end
    end
end)

-- [ КНОПКИ ]
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

CreateToggle("Silent Aim", "SilentAim")
CreateToggle("Green ESP", "ESP")
CreateToggle("No Recoil", "NoRecoil")

-- Сворачивание
local min = false
Title.MouseButton1Click:Connect(function()
    if not dragging then
        min = not min
        Main:TweenSize(min and UDim2.new(0, 220, 0, 35) or UDim2.new(0, 220, 0, 310), "Out", "Quart", 0.3, true)
        List.Visible, StatsLabel.Visible = not min, not min
    end
end)
